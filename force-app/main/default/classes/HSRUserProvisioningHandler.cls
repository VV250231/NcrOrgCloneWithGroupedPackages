/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Just-in-Time Provisioning for Experience Cloud using SamlJitHandler
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-06-28
* @modified
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-06-28
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global without sharing class HSRUserProvisioningHandler implements Auth.SamlJitHandler {

    private final String REQUEST_NAMED_CREDENTIAL = 'callout:SOUP_MYNCR';
    private final String REQUEST_METHOD_GET = 'GET';
    private final Integer REQUEST_TIMEOUT = 5000;
    private final String REQUEST_SOURCE_SYSTEM = 'NSCServiceCloud';
    private final String REQUEST_USER_ID = 'SCHSR';

    private final Integer MAX_NUMBER_RECORDS_PROCESSING_SYNC = 200;
    private final Integer BATCH_SIZE = 200;

    private final Integer MAX_NUMBER_OF_ATTEMPTS = 3;

    @TestVisible private User userRecord;
    @TestVisible private Contact portalContact;
    @TestVisible private List<AccountContactRelation> accountContactRelationsToInsert;
    @TestVisible private List<AccountContactRelation> accountContactRelationsToDelete;

    @TestVisible private static List<HSR_Case__e> casesEvents;
    static {
        casesEvents = new List<HSR_Case__e>();
    }


    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        userRecord = new User();
        handleJit(true, userRecord, samlSsoProviderId, communityId, portalId,
                federationIdentifier, attributes, assertion);
        return userRecord;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {

        List <Contact> existingContacts = HSRSelector.getContactsByUserIds(
                new List<Id>{
                        userId
                }
        );
        if (existingContacts != null && !existingContacts.isEmpty()) {
            portalContact = existingContacts[0];
        }
        handleAccountContactRelations();

    }

    // ------------- Handling Methods -------------

    private void handleJit(Boolean isCreate, User user, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {

        // initialize sObjects lists
        accountContactRelationsToInsert = new List<AccountContactRelation>();
        accountContactRelationsToDelete = new List<AccountContactRelation>();

        // Try to get User details from MyNCR. If request failed number of times, log error and stop the log in process
        SoupMyNcrResult apiAttributes;
        Boolean retry = false;
        Integer attemptNumber = 1;
        String errorMessage;
        do {
            try {
                apiAttributes = getNCRUserAttributes(federationIdentifier);
                retry = false;
            } catch (JitException err) {
                retry = true;
                errorMessage = err.getMessage();
                System.debug('HSRUserProvisioningHandler/handleJit Failed to get user details - attempt #' + attemptNumber + '. Error: "' + errorMessage + '"');
            }
            attemptNumber++;
        } while (retry && attemptNumber <= MAX_NUMBER_OF_ATTEMPTS);

        if (retry) {
            String requestParam = String.format('username={0}', new List<String>{
                    federationIdentifier
            });
            // todo: move to Platform event. Reason: @Future method will failed and rolled back when an exceptions occurs
            createMyNCRExceptionLog(null, requestParam, errorMessage);
            throw new JitException(errorMessage);
        }

        // Retrieve/create Portal Contact Record
        try {
            handleContact(isCreate, apiAttributes);

            handleAccountContactRelations();

            // create/update Customer User record
            if (communityId != null || portalId != null) {
                if (isCreate && portalContact.Id != null) {
                    handleInsertUser(apiAttributes, federationIdentifier);
                }
            }
        } catch (Exception err) {
            throw new JitException(err.getMessage());
        }
    }

    private void handleContact(Boolean isCreate, SoupMyNcrResult apiAttributes) {
        if (isCreate) {
            String emailAddress = apiAttributes.myNCRUserProfileResp.email;

            List<Contact> existingContacts = HSRSelector.getContactsByEmail(emailAddress);
            // Ignore Contact records that are associated to existing users
            for (Integer inx = 0; inx < existingContacts.size(); inx++) {
                if (existingContacts[inx].Users.size() > 0) {
                    existingContacts.remove(inx);
                }
            }
            Id defaultContactId = (existingContacts != null && !existingContacts.isEmpty()) ? existingContacts[0].Id : null;

            Account MCNAccount = getMCNAccount(apiAttributes);
            String myNCRUsername = getMyNCRUserName(apiAttributes);
            if (MCNAccount == null) {
                String errorMessage = String.format(System.Label.HSR_UsrPrv_Err_NoMCNAccountFound, new List<String>{
                        myNCRUsername
                });

                // If no MCN account is found, log a case and stop the process
                createCase(null, defaultContactId, emailAddress, getUserName(emailAddress), errorMessage);
                throw new JitException(errorMessage);
            }

            if (existingContacts.size() > 1) {
                String errorMessage = String.format(System.Label.HSR_UsrPrv_Err_MultipleCaseMatch, new List<String>{
                        myNCRUsername
                });

                createCase(MCNAccount.Id, defaultContactId, emailAddress, getUserName(emailAddress), errorMessage);
                throw new JitException(errorMessage);
            } else {
                portalContact = handlePortalContact(existingContacts, MCNAccount, apiAttributes);
            }
        } else {
            portalContact = userRecord.Contact;
        }
    }

    private Contact handlePortalContact(List<Contact> existingContacts, Account MCNAccount, SoupMyNcrResult apiAttributes) {
        Contact contactRecord = new Contact();

        contactRecord.FirstName = apiAttributes.myNCRUserProfileResp.firstName;
        contactRecord.LastName = apiAttributes.myNCRUserProfileResp.lastname;
        contactRecord.Phone = apiAttributes.myNCRUserProfileResp.officePhone;
        contactRecord.Email = apiAttributes.myNCRUserProfileResp.email.trim().toLowerCase();
        contactRecord.Title = apiAttributes.myNCRUserProfileResp.jobTitle;

        contactRecord.MailingStreet = apiAttributes.myNCRUserProfileResp.address.address1;
        contactRecord.MailingCity = apiAttributes.myNCRUserProfileResp.address.city;
        contactRecord.MailingState = apiAttributes.myNCRUserProfileResp.address.state;
        contactRecord.MailingPostalCode = apiAttributes.myNCRUserProfileResp.address.postalCode;

        contactRecord.AccountId = MCNAccount.Id;

        if (existingContacts.size() == 0) {
            contactRecord.RecordTypeId = Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.HSR_UsrPrv_Contact_RecordType_Dev_Name)?.getRecordTypeId();

            HSRUtil.insertList(new List<Contact>{
                    contactRecord
            }, true);
        } else {
            contactRecord.Id = existingContacts[0].Id;
        }

        return contactRecord;
    }

    private void handleInsertUser(SoupMyNcrResult apiAttributes, String federationIdentifier) {

        Profile p = HSRSelector.getProfileByName(System.Label.HSR_UsrPrv_Profile_Name);
        userRecord.ProfileId = p.Id;

        userRecord.Username = getUserName(apiAttributes.myNCRUserProfileResp.email);

        userRecord.FirstName = apiAttributes.myNCRUserProfileResp.firstName;
        userRecord.LastName = apiAttributes.myNCRUserProfileResp.lastname;
        userRecord.Phone = apiAttributes.myNCRUserProfileResp.officePhone;
        userRecord.Email = apiAttributes.myNCRUserProfileResp.email.trim().toLowerCase();
        userRecord.Title = apiAttributes.myNCRUserProfileResp.jobTitle;

        userRecord.Street = apiAttributes.myNCRUserProfileResp.address.address1;
        userRecord.City = apiAttributes.myNCRUserProfileResp.address.city;
        userRecord.State = apiAttributes.myNCRUserProfileResp.address.state;
        userRecord.PostalCode = apiAttributes.myNCRUserProfileResp.address.postalCode;

        userRecord.FederationIdentifier = !String.isBlank(apiAttributes.myNCRUserProfileResp.login) ? apiAttributes.myNCRUserProfileResp.login : federationIdentifier;
        userRecord.Alias = userRecord.FederationIdentifier.left(8);
        userRecord.Quicklook_ID__c = userRecord.FederationIdentifier;
        userRecord.CommunityNickname = String.format('{0}, {1}', new List<String>{
                userRecord.LastName,
                userRecord.FirstName
        });
        userRecord.ContactId = portalContact.Id;
        userRecord.LocaleSidKey = 'en_US';
        userRecord.TimeZoneSidKey = 'America/New_York';
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.EmailEncodingKey = 'UTF-8';
        userRecord.Do_Not_Deactivate__c = true;

        createCase(portalContact.AccountId, userRecord.ContactId, userRecord.Email, userRecord.Username, System.Label.HSR_UsrPrv_Info_FirstLogIn);

        System.debug('HSRUserProvisioningHandler/handleInsertUser User to be inserted/updated: ' + JSON.serializePretty(userRecord));
    }

    private void handleAccountContactRelations() {
        // Process or schedule creating/deleting AccountContactRelation records
        insertAccountContactRelations();
        deleteAccountContactRelations();
    }

    @TestVisible private void insertAccountContactRelations() {
        List<Account> siteAccountsToProcess = HSRSelector.getSiteAccountsByParentId_ACRToCreate(new List<Id>{
                portalContact.Id
        }, MAX_NUMBER_RECORDS_PROCESSING_SYNC);

        if (!siteAccountsToProcess.isEmpty()) {
            if (canProcessInSyncMode(siteAccountsToProcess)) {
                accountContactRelationsToInsert = HSRUtil.makeAccountContactRelations(siteAccountsToProcess, portalContact);
                HSRUtil.insertList(accountContactRelationsToInsert, false);
            } else {
                portalContact.Hospitality_ACR_Processing_Status__c = HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS;
                HSRUtil.updateList(new List<Contact>{
                        portalContact
                }, false);

                HSRACRCreationBatch.runBatch(BATCH_SIZE);
            }
        }
    }
    @TestVisible private void deleteAccountContactRelations() {

        List<AccountContactRelation> mcnACRs = HSRSelector.getMCNAccountContactRelations(new List<Id>{
                portalContact.Id
        });

        List<Id> parentAccountIds = new List<Id>();
        for (AccountContactRelation mcnACR : mcnACRs) {
            parentAccountIds.add(mcnACR.AccountId);
        }

        accountContactRelationsToDelete = HSRSelector.getPendingACRToDelete(
                portalContact.Id,
                parentAccountIds,
                MAX_NUMBER_RECORDS_PROCESSING_SYNC);

        if (!accountContactRelationsToDelete.isEmpty()) {
            if (canProcessInSyncMode(accountContactRelationsToDelete)) {
                HSRUtil.deleteList(accountContactRelationsToDelete, false);
            } else {
                HSRACRDeletionQueueable.enqueue(portalContact.Id, parentAccountIds);
            }
        }
    }

    private Boolean canProcessInSyncMode(List<SObject> recordsToProcess) {
        Integer recordsLimit = HSRUtil.getMaxNumberOfDMLRows();
        return recordsToProcess.size() < recordsLimit && recordsToProcess.size() < MAX_NUMBER_RECORDS_PROCESSING_SYNC;
    }

    // --------------- Util Methods -----------------

    private Account getMCNAccount(SoupMyNcrResult apiAttributes) {
        List<SoupMyNcrResult.memberOf> memberOfList = apiAttributes.myNCRUserProfileResp?.memberOf;
        List<String> accountsNumbers = new List<String>();
        for (SoupMyNcrResult.memberOf mo : memberOfList) {
            accountsNumbers.add(mo.accountNumber);
        }

        List<Account> accounts = HSRSelector.getAccountsByCustomersNumbers(accountsNumbers);
        for (Account account : accounts) {
            // return first match that has a UserRole
            if (account.Owner.UserRoleId != null) {
                return account;
            }
        }

        return null;
    }

    private String getMyNCRUserName(SoupMyNcrResult soupMyNcrResult) {
        return soupMyNcrResult.myNCRUserProfileResp.username;
    }

    private String getUserName(String emailAddress) {
        return String.format('{0}.{1}', new List<String>{
                emailAddress,
                System.Label.HSR_UsrPrv_Username_Postfix
        });
    }

    /**
     * publish an "HSR Case" Event to create a Case record.
     * @param MCNAccountId existing MCN Account Id
     * @param contactId portal contact record Id
     * @param email user email address
     * @param salesforceUserName Logged in SF User username
     * @param additionalDetails Case additional information
     */
    @TestVisible
    private static void createCase(Id MCNAccountId, Id contactId, String email, String salesforceUserName, String additionalDetails) {
        HSR_Case__e casePE = new HSR_Case__e();
        casePE.AccountId__c = MCNAccountId;
        casePE.ContactId__c = contactId;
        casePE.Email_Address__c = email;

        casePE.Subject__c = String.format(System.Label.HSR_UsrPrv_Case_Subject, new List<String>{
                salesforceUserName
        });
        casePE.Description__c = String.format(System.Label.HSR_UsrPrv_Case_Description, new List<String>{
                salesforceUserName,
                additionalDetails
        });

        casesEvents.add(casePE);
        System.debug('HSRUserProvisioningHandler/createCase HSR Case Events (' + casesEvents.size() + '): ' + JSON.serializePretty(casesEvents));

        HSRUtil.publishEvent(casesEvents);
    }

    @Future
    public static void createMyNCRExceptionLog(String caseNumber, String requestBody, String errorMessage) {
        String friendlyMessage = String.format(System.Label.HSR_UsrPrv_MyNCR_Callout_Error, new List<String>{
                errorMessage.left(200)
        });
        HttpRequest sentRequest = new HttpRequest();
        sentRequest.setBody(requestBody);
        Dispute_Integration_Logs__c disputeIntegrationLog = HSRUtil.createExceptionLog(caseNumber, sentRequest, friendlyMessage, errorMessage);
        System.debug('HSRUserProvisioningHandler/createMyNCRExceptionLog Integration Error Log: ' + JSON.serializePretty(disputeIntegrationLog));
        insert disputeIntegrationLog;
    }

    public SoupMyNcrResult getNCRUserAttributes(String userName) {

        String endPoint = String.format('{0}?username={1}', new List<String>{
                REQUEST_NAMED_CREDENTIAL,
                EncodingUtil.urlEncode(userName, 'utf-8')
        });

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(REQUEST_METHOD_GET);
        request.setTimeout(REQUEST_TIMEOUT);

        String transactionId = new Uuid().getValue();
        request.setHeader('SourceSystem', REQUEST_SOURCE_SYSTEM);
        request.setHeader('UserID', REQUEST_USER_ID);
        request.setHeader('transactionId', transactionId);

        HttpResponse response = new Http().send(request);
        SoupMyNcrResult responseWrapper;
        if (isSuccessful(response)) {
            System.debug('HSRUserProvisioningHandler/getNCRUserAttributes MYNCR Response:');
            System.debug('HSRUserProvisioningHandler/getNCRUserAttributes ' + response.getStatusCode());
            System.debug('HSRUserProvisioningHandler/getNCRUserAttributes ' + response.getStatus());
            System.debug('HSRUserProvisioningHandler/getNCRUserAttributes ' + response.getBody());
            try {
                responseWrapper = SoupMyNcrResult.parseResponse(response.getBody());
            } catch (JSONException err) {
                System.debug(HSRUtil.generateExceptionMessage(err));
                String ssoError = String.format(System.Label.HSR_UsrPrv_Err_UserNotFound, new List<String>{
                        userName
                });
                throw new JitException(ssoError);
            }
            if (!userIsFound(responseWrapper)) {
                String ssoError = String.format(System.Label.HSR_UsrPrv_Err_UserNotFound, new List<String>{
                        userName
                });
                throw new JitException(ssoError);
            }
        } else {
            String errorMessage = String.format(System.Label.HSR_UsrPrv_Err_General, new List<String>{
                    response.getStatus()
            });
            throw new JitException(errorMessage);
        }

        return responseWrapper;
    }

    private Boolean isSuccessful(HttpResponse response) {
        return response.getStatusCode() == 200 || response.getStatusCode() == 201;
    }

    private Boolean userIsFound(SoupMyNcrResult apiAttributes) {
        return apiAttributes.responseHeader.status == 'SUCCESS' && apiAttributes.responseHeader.statusCode == 0;
    }
    // ------------- Util Classes -------------
    public class JitException extends Exception {
    }
}