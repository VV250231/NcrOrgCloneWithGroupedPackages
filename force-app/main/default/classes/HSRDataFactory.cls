/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Data Factory to help test Hospitality Service Cloud custom integration logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-05-20
* @modified       2022-05-25
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-05-20      mock sObject records
*
* v1.1            ba250204@ncr.com
* 2022-07-15      Add make SObject records logic
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
public class HSRDataFactory {
    // ------------------------ Make SObject Records ------------------------

    public static Account makeCustomerAccount(Integer index) {
        return new Account(
                Name = 'Test Customer Account' + index,
                Account_Country_Code__c = 'US',
                Active_Account__c = true,
                RecordTypeId = HSRDataFactory.getRecordTypeId(Schema.Account.getSObjectType(), HSRConstants.ACCOUNT_RT_CUSTOMER),
                Master_Customer_Number__c = String.valueOf(index)
        );
    }
    public static Account makePartnerAccount(Integer index) {
        return new Account(
                Name = 'Test Partner Account' + index,
                Account_Country_Code__c = 'US',
                Active_Account__c = true,
                RecordTypeId = HSRDataFactory.getRecordTypeId(Schema.Account.getSObjectType(), HSRConstants.ACCOUNT_RT_PARTNER),
                Master_Customer_Number__c = String.valueOf(index)
        );
    }
    public static Account makeSiteAccount(Integer index, Account customerAccount) {
        return new Account(
                Name = 'Test Site Account' + index,
                Account_Country_Code__c = 'US',
                ParentId = customerAccount.Id,
                Active_Account__c = true,
                Site_Number__c = '42785373' + index,
                MDM_Data_Source_Code__c = 'CDM',
                CDM_Account_Status__c = 'Active',
                RecordTypeId = HSRDataFactory.getRecordTypeId(Schema.Account.getSObjectType(), HSRConstants.ACCOUNT_RT_SITE)
        );
    }

    public static Contact makeContact(Integer index, Account mcnAccount, String ACRProcessStatus) {
        return new Contact(
                AccountId = mcnAccount?.Id,
                FirstName = 'test',
                LastName = 'test' + index,
                Email = 'test' + index + '@test.com',
                Hospitality_ACR_Processing_Status__c = ACRProcessStatus
        );
    }

    public static AccountContactRelation makeAccountContactRelations(Id accountId, Id contactId, Boolean isAutomation) {
        AccountContactRelation acr = new AccountContactRelation(
                AccountId = accountId,
                ContactId = contactId
        );

        if (isAutomation) {
            acr.Roles = HSRConstants.ACR_DEFAULT_ROLES;
            acr.Hospitality_Experience_Cloud_Automation__c = true;
        }
        return acr;
    }

    public static User makeUser(Integer index, Profile profile, String email, String federationId) {
        return new User(
                Alias = 'user' + index,
                Email = email,
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'test' + index + '@ncr.com.hospitality',
                FederationIdentifier = federationId,
                ProfileId = profile.Id
        );
    }


    // ------------------------ Mock SObject Records ------------------------

    public enum AccountType {
        Site, Customer, Enterprise
    }
    public static Account mockAccount(Integer index, AccountType type) {
        User owner = mockUser(99);
        Account account = new Account(
                Id = mockId(Account.getSObjectType(), index),
                Name = 'Test Account' + index,
                Account_Country_Code__c = 'US',
                OwnerId = owner.Id,
                Owner = owner
        );

        if (type == AccountType.Enterprise) {
            account.RecordTypeId = getRecordTypeId(Schema.Account.getSObjectType(), HSRConstants.ACCOUNT_RT_ENTERPRISE);
        } else if (type == AccountType.Customer) {
            account.RecordTypeId = getRecordTypeId(Schema.Account.getSObjectType(), HSRConstants.ACCOUNT_RT_CUSTOMER);
            account.Master_Customer_Number__c = String.valueOf(index);
        } else {
            account.Site_Number__c = '42785373' + index;
            account.RecordTypeId = getRecordTypeId(Schema.Account.getSObjectType(), HSRConstants.ACCOUNT_RT_SITE);
            account.cdm_Solution_Set_ID__c = '2345';
        }

        return account;
    }

    public static Contact mockContact(Integer index, Account account) {
        String email = String.format('test{0}@ncr.com', new List<String>{
                String.valueOf(index)
        });

        return new Contact(
                Id = mockId(Contact.getSObjectType(), index),
                AccountId = account.Id,
                Account = account,
                FirstName = 'test',
                LastName = 'test',
                Email = email,
                Phone = '+1 (117) 828-7332'

        );
    }

    public static AccountContactRelation mockAccountContactRelations(Integer index, Id accountId, Id contactId, Boolean isAutomation) {
        AccountContactRelation acr = new AccountContactRelation(
                Id = mockId(AccountContactRelation.getSObjectType(), index),
                AccountId = accountId,
                ContactId = contactId
        );

        if (isAutomation) {
            acr.Roles = HSRConstants.ACR_DEFAULT_ROLES;
            acr.Hospitality_Experience_Cloud_Automation__c = true;
        }
        return acr;
    }

    public static Case mockCase(Integer index, Account cdmAccount, Account siteAccount, Asset pidAsset, Contact contact) {
        return new Case(
                Id = mockId(Case.getSObjectType(), index),
                AccountId = cdmAccount.Id,
                Account = cdmAccount,
                Site_Id__c = siteAccount.Id,
                Site_Id__r = siteAccount,
                AssetId = pidAsset.Id,
                Asset = pidAsset,
                ContactId = contact.Id,
                Contact = contact,
                Subject = 'test subject',
                Description = 'test description'
        );
    }

    public enum AssetType {
        PID, SN
    }
    public static Asset mockAsset(Integer index, Account account, Account site, Contact contact, AssetType type) {
        Asset asset = new Asset(
                Id = mockId(Asset.getSObjectType(), index),
                AccountId = account.Id,
                Account = account,
                Site_Id__c = site.Id,
                Site_Id__r = site,
                ContactId = contact.Id,
                Contact = contact,
                PID__c = '7128-0212-8801',
                External_Id__c = '42393372-1666-6003-8801-725095' + index
        );
        if (type == AssetType.SN) {
            asset.Name = 'SN test';
            asset.RecordTypeId = getRecordTypeId(Schema.Asset.getSObjectType(), HSRConstants.ASSET_RT_SERIALIZED_ASSET);
            asset.Serial_Number__c = 'SN-123877';
            asset.Is_Serialized_Flag__c = true;
        } else {
            asset.Name = 'PID test';
            asset.RecordTypeId = getRecordTypeId(Schema.Asset.getSObjectType(), HSRConstants.ASSET_RT_ASSET);
            asset.HW_Class_Id__c = '12345';
            asset.RAD_Support_Class__c = 'test';
        }
        return asset;
    }

    public static Entitlement mockEntitlement(Integer index, Account account) {
        return new Entitlement(
                Id = mockId(Entitlement.getSObjectType(), index),
                AccountId = account.Id,
                Account = account,
                Name = 'Test entitlement',
                ES_Entitlement_Id__c = '123456',
                Service_Level_Id__c = '123456'
        );
    }

    public static Solution_Set_HW_Role_Relation__c mockSolutionSetHWRoleRelation(Integer index) {
        return new Solution_Set_HW_Role_Relation__c(
                Id = mockId(Solution_Set_HW_Role_Relation__c.getSObjectType(), index),
                HW_Role_Id__c = '12345',
                Solution_Id__c = '2345',
                Name = 'test SS'
        );
    }

    public static Support_Class_Failure_Reason_Relation__c mockSupportClassFailureReasonRelation(Integer index) {
        return new Support_Class_Failure_Reason_Relation__c(
                Id = mockId(Support_Class_Failure_Reason_Relation__c.getSObjectType(), index),
                Failure_Reason_Id__c = '12345',
                Product_Class__c = 'test'
        );
    }

    public static User mockUser(Integer index) {
        UserRole userRole = mockUserRole();
        return new User(
                Id = mockId(User.getSObjectType(), index),
                FirstName = 'Integration',
                LastName = 'User' + index,
                Username = 'intuser' + index + '@ncr.com',
                Alias = 'intu' + index,
                Email = 'na' + index + '@ncr.com',
                UserRoleId = userRole.Id,
                UserRole = userRole
        );
    }

    private static UserRole mockUserRole() {
        return new UserRole(
                Id = mockId(UserRole.getSObjectType(), 0),
                Name = 'TEST User Role'
        );
    }

    public static WorkOrder mockWorkOrder(
            Integer index,
            Account cdmAccount,
            Account siteAccount,
            Contact contact,
            Case caseRecord,
            Asset pidAsset,
            Asset snAsset,
            Entitlement entitlement,
            Solution_Set_HW_Role_Relation__c sshwrr,
            Support_Class_Failure_Reason_Relation__c scfrr,
            User createdBy
    ) {
        return new WorkOrder(
                Id = mockId(WorkOrder.getSObjectType(), index),
                AccountId = cdmAccount.Id,
                Account = cdmAccount,
                Site_Id__c = siteAccount.Id,
                Site_Id__r = siteAccount,
                ContactId = contact.Id,
                Contact = contact,
                CaseId = caseRecord.Id,
                Case = caseRecord,
                AssetId = pidAsset.Id,
                Asset = pidAsset,
                Serialized_Asset_Id__c = snAsset.Id,
                Serialized_Asset_Id__r = snAsset,
                EntitlementId = entitlement.Id,
                Entitlement = entitlement,
                Solution_Set_HW_Role_Relation__c = sshwrr.Id,
                Solution_Set_HW_Role_Relation__r = sshwrr,
                Support_Class_Failure_Reason_Relation__c = scfrr.Id,
                Support_Class_Failure_Reason_Relation__r = scfrr,
                Priority = 'Medium',
                SN_Override_Flag__c = true,
                SN_Override__c = '123456789',
                Out_of_Scope__c = true,
                Shipment_Method__c = 'Default',
                Alt_Work_Site_Flag__c = true,
                Street = '1348 Coleman Avenue',
                Street_Line_2__c = 'A-01',
                PostalCode = '93523',
                State = 'CA',
                City = 'North Edwards',
                CreatedById = createdBy.Id,
                CreatedBy = createdBy,
                CreatedDate = System.now()
        );
    }

    public static WorkOrder mockWorkOrder(Integer index) {
        Account cdmAccount = HSRDataFactory.mockAccount(index, AccountType.Enterprise);
        Account siteAccount = HSRDataFactory.mockAccount(index + 1, AccountType.Site);
        Contact contact = HSRDataFactory.mockContact(index, siteAccount);
        Asset pidAsset = HSRDataFactory.mockAsset(index, cdmAccount, siteAccount, contact, AssetType.PID);
        Asset snAsset = HSRDataFactory.mockAsset(index + 1, cdmAccount, siteAccount, contact, AssetType.SN);
        Entitlement entitlement = HSRDataFactory.mockEntitlement(index, siteAccount);
        Case caseRecord = HSRDataFactory.mockCase(index, cdmAccount, siteAccount, pidAsset, contact);
        Solution_Set_HW_Role_Relation__c sshwrr = HSRDataFactory.mockSolutionSetHWRoleRelation(1);
        Support_Class_Failure_Reason_Relation__c scfrr = HSRDataFactory.mockSupportClassFailureReasonRelation(1);
        User createdBy = HSRDataFactory.mockUser(1);

        return HSRDataFactory.mockWorkOrder(index, cdmAccount, siteAccount, contact, caseRecord, pidAsset, snAsset, entitlement, sshwrr, scfrr, createdBy);
    }

    // --------------------- Http Mock ---------------------
    public class WorkOrderCalloutMock_Success implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertNotEquals(null, request.getHeader('x-transaction-id'), 'Request transaction Id should not be null');
            System.assertNotEquals(null, request.getEndpoint(), 'Missing request endpoint');
            System.assertEquals(HSRDispatchToES.REQUEST_METHOD_POST, request.getMethod(), 'Unexpected request method');

            HttpResponse response = new HttpResponse();
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(
                    '{\n' +
                            '    "TransactionID": {\n' +
                            '        "$": "1234567c"\n' +
                            '    },\n' +
                            '    "TimeStamp": "2022-05-24T15:24:47.681-04:00",\n' +
                            '    "SourceSystem": {\n' +
                            '        "$": "SOUP"\n' +
                            '    },\n' +
                            '    "Status": "Accepted"\n' +
                            '}');

            return response;
        }
    }
    public class WorkOrderCalloutMock_Failed implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertNotEquals(null, request.getHeader('x-transaction-id'), 'Request transaction Id should not be null');
            System.assertNotEquals(null, request.getEndpoint(), 'Missing request endpoint');
            System.assertEquals(HSRDispatchToES.REQUEST_METHOD_POST, request.getMethod(), 'Unexpected request method');

            HttpResponse response = new HttpResponse();
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(
                    '{\n' +
                            '  "TransactionID" : {\n' +
                            '    "$" : "0WO790000000NfRGAU"\n' +
                            '  },\n' +
                            '  "TimeStamp" : "2022-05-20T19:40:39.717-04:00",\n' +
                            '  "SourceSystem" : {\n' +
                            '    "$" : "SOUP"\n' +
                            '  },\n' +
                            '  "Status" : "Error",\n' +
                            '  "Fault" : {\n' +
                            '    "FaultCode" : "CSDI_VLD_001",\n' +
                            '    "FaultDescription" : "Expected Element -CountryCode,CustomerTicketID,Summary,SiteShortName,AssetID,ProductID,Brand,DevicePhysicalLocation"\n' +
                            '  }\n' +
                            '}');

            return response;
        }
    }
    public class WorkOrderCalloutMock_ServerError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertNotEquals(null, request.getHeader('x-transaction-id'), 'Request transaction Id should not be null');
            System.assertNotEquals(null, request.getEndpoint(), 'Missing request endpoint');
            System.assertEquals(HSRDispatchToES.REQUEST_METHOD_POST, request.getMethod(), 'Unexpected request method');

            HttpResponse response = new HttpResponse();
            response.setStatus('Internal Server Error');
            response.setStatusCode(500);

            return response;
        }
    }

    public class JITAttributesCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertNotEquals(null, request.getEndpoint(), 'Missing request endpoint');
            System.assertEquals('GET', request.getMethod(), 'Unexpected request method');

            HttpResponse response = new HttpResponse();
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(
                    '{' +
                            '"responseHeader":{' +
                            '    "status":"SUCCESS",' +
                            '    "statusCode":"00",' +
                            '    "statusMessage":"User attributes returned.",' +
                            '    "timestamp":"2022-06-30T17:48:33.625+00:00",' +
                            '    "transactionId":null' +
                            '},' +
                            '"myNCRUserProfileResp":{' +
                            '    "address":{' +
                            '        "address1":"123 main street",' +
                            '        "address2":"",' +
                            '        "address3":"",' +
                            '        "city":"columbus",' +
                            '        "postalCode":"43215",' +
                            '        "county":"",' +
                            '        "state":"OH",' +
                            '        "country":"US"' +
                            '    },' +
                            '    "federatedUser":"NO",' +
                            '    "lastname":"user",' +
                            '    "myNCRUser":"YES",' +
                            '    "userStatus":"ENABLED",' +
                            '    "lastLoginTime":"",' +
                            '    "officePhone":"(987)654-3232",' +
                            '    "admin":"YES",' +
                            '    "firstName":"test",' +
                            '    "email":"test0@ncr.com",' +
                            '    "login":"TestUser",' +
                            '    "username":"test0@ncr.com",' +
                            '    "jobTitle":"Information Technology",' +
                            '    "memberOf":[' +
                            '        {' +
                            '            "accountNumber":"0",' +
                            '            "accountName":"Test Account0"' +
                            '        },' +
                            '        {' +
                            '            "accountNumber":"1",' +
                            '            "accountName":"Test Account1"' +
                            '        }' +
                            '    ],' +
                            '    "userCreationDateTime":"17 May 2022 12:27:22 GMT"' +
                            '    }' +
                            '}'
            );

            return response;
        }
    }
    public class JITAttributesCalloutMock_NotFound implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertNotEquals(null, request.getEndpoint(), 'Missing request endpoint');
            System.assertEquals('GET', request.getMethod(), 'Unexpected request method');

            HttpResponse response = new HttpResponse();
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(
                    '{\n' +
                            '    "responseHeader": {\n' +
                            '        "status": "SUCCESS",\n' +
                            '        "statusCode": "01",\n' +
                            '        "statusMessage": "User not found.",\n' +
                            '        "timestamp": "2022-07-05T02:50:24.317+00:00",\n' +
                            '        "transactionId": null\n' +
                            '    },\n' +
                            '    "myNCRUserProfileResp": ""\n' +
                            '}'
            );

            return response;
        }
    }
    public class JITAttributesCalloutMock_ServerError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertNotEquals(null, request.getEndpoint(), 'Missing request endpoint');
            System.assertEquals('GET', request.getMethod(), 'Unexpected request method');

            HttpResponse response = new HttpResponse();
            response.setStatus('Internal Server Error');
            response.setStatusCode(500);
            response.setBody(
                    '{\n' +
                            '    "timestamp": "2022-07-05T03:01:38.839+00:00",\n' +
                            '    "path": "/user-service/user/",\n' +
                            '    "status": 500,\n' +
                            '    "error": "Internal Server Error",\n' +
                            '    "message": "",\n' +
                            '    "requestId": "c809ee1d-1"\n' +
                            '}'
            );

            return response;
        }
    }


    // --------------------- Private util methods ---------------------
    public static String mockId(SObjectType sot, Integer index) {
        return String.isBlank(sot.getDescribe().getKeyPrefix()) ? null : sot.getDescribe().getKeyPrefix().rightPad(15 - (String.valueOf(index).length()), '0') + String.valueOf(index);
    }

    public static String getRecordTypeId(SObjectType sot, String developerName) {
        return sot.getDescribe().getRecordTypeInfosByDeveloperName().get(developerName)?.getRecordTypeId();
    }
}