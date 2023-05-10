/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class that covers Hospitality Experience Cloud Just-in-Time provisioning logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-05-20
* @modified
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-05-20
*
* v1.1            ba250204@ncr.com
* 2022-07-15      Switch from "make" to "mock" sObject
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
private class HSRUserProvisioningHandlerTest {
    @TestSetup
    static void setup() {
        Automation_Setting__c setting = new Automation_Setting__c(
                Skip_Trigger__c = true,
                Skip_Validation_Rule__c = true,
                Skip_Flow__c = true,
                Skip_Outbound_Integration__c = true
        );
        insert setting;
    }

    @IsTest
    static void testCreateUser_New() {

        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer),
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Customer)
        };
        HSRSelector.mockAccounts = accounts;

        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        Test.startTest();
        Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
        User user = handler.createUser(null, communityId, null, 'TestUser', null, null);
        Test.stopTest();

        System.assertNotEquals(null, handler.userRecord);
        System.assertEquals(1, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(1, HSRUserProvisioningHandler.casesEvents.size());


        String profileId = HSRSelector.getProfileByName(System.Label.HSR_UsrPrv_Profile_Name).Id;
        System.assertEquals('test0@ncr.com.hospitality', user.Username, generateValidationErrorMessage('Username'));
        System.assertEquals('TestUser', user.FederationIdentifier, generateValidationErrorMessage('FederationIdentifier'));
        System.assertEquals(profileId, user.ProfileId, generateValidationErrorMessage('ProfileId'));
        System.assertEquals('test', user.FirstName, generateValidationErrorMessage('FirstName'));
        System.assertEquals('user', user.LastName, generateValidationErrorMessage('LastName'));
        System.assertEquals('(987)654-3232', user.Phone, generateValidationErrorMessage('Phone'));
        System.assertEquals('test0@ncr.com', user.Email, generateValidationErrorMessage('Email'));
        System.assertEquals('Information Technology', user.Title, generateValidationErrorMessage('Title'));
        System.assertEquals('123 main street', user.Street, generateValidationErrorMessage('Street'));
        System.assertEquals('columbus', user.City, generateValidationErrorMessage('City'));
        System.assertEquals('OH', user.State, generateValidationErrorMessage('State'));
        System.assertEquals('43215', user.PostalCode, generateValidationErrorMessage('PostalCode'));

    }

    @IsTest
    static void testCreateUser_Existing_Single() {
        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer),
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Customer)
        };
        HSRSelector.mockAccounts = accounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.mockContact(0, accounts[0])
        };
        HSRSelector.mockContacts = contacts;


        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        Test.startTest();
        Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
        User user = handler.createUser(null, communityId, null, 'TestUser', null, null);
        Test.stopTest();

        // Validate updated contact new values
        System.assertNotEquals(null, handler.userRecord);
        Contact updatedContact = handler.portalContact;
        System.assertEquals('test', updatedContact.FirstName, generateValidationErrorMessage('FirstName'));
        System.assertEquals('user', updatedContact.LastName, generateValidationErrorMessage('LastName'));
        System.assertEquals('(987)654-3232', updatedContact.Phone, generateValidationErrorMessage('Phone'));
        System.assertEquals('test0@ncr.com', updatedContact.Email, generateValidationErrorMessage('Email'));
        System.assertEquals('Information Technology', updatedContact.Title, generateValidationErrorMessage('Title'));
        System.assertEquals('123 main street', updatedContact.MailingStreet, generateValidationErrorMessage('Street'));
        System.assertEquals('columbus', updatedContact.MailingCity, generateValidationErrorMessage('City'));
        System.assertEquals('OH', updatedContact.MailingState, generateValidationErrorMessage('State'));
        System.assertEquals('43215', updatedContact.MailingPostalCode, generateValidationErrorMessage('PostalCode'));

        System.assertEquals(1, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(1, HSRUserProvisioningHandler.casesEvents.size());

        // Validate the newly created user values
        String profileId = HSRSelector.getProfileByName(System.Label.HSR_UsrPrv_Profile_Name).Id;
        System.assertEquals('test0@ncr.com.hospitality', user.Username, generateValidationErrorMessage('Username'));
        System.assertEquals('TestUser', user.FederationIdentifier, generateValidationErrorMessage('FederationIdentifier'));
        System.assertEquals(profileId, user.ProfileId, generateValidationErrorMessage('ProfileId'));
        System.assertEquals('test', user.FirstName, generateValidationErrorMessage('FirstName'));
        System.assertEquals('user', user.LastName, generateValidationErrorMessage('LastName'));
        System.assertEquals('(987)654-3232', user.Phone, generateValidationErrorMessage('Phone'));
        System.assertEquals('test0@ncr.com', user.Email, generateValidationErrorMessage('Email'));
        System.assertEquals('Information Technology', user.Title, generateValidationErrorMessage('Title'));
        System.assertEquals('123 main street', user.Street, generateValidationErrorMessage('Street'));
        System.assertEquals('columbus', user.City, generateValidationErrorMessage('City'));
        System.assertEquals('OH', user.State, generateValidationErrorMessage('State'));
        System.assertEquals('43215', user.PostalCode, generateValidationErrorMessage('PostalCode'));
    }

    @IsTest
    static void testCreateUser_Existing_Single_NoMCNMatch() {
        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(90, HSRDataFactory.AccountType.Customer),
                HSRDataFactory.mockAccount(91, HSRDataFactory.AccountType.Customer)
        };
        HSRSelector.mockAccounts = accounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.mockContact(0, accounts[0])
        };
        HSRSelector.mockContacts = contacts;


        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        User user;
        Test.startTest();
        try {
            HSRSelector.mockAccounts = null;
            Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
            user = handler.createUser(null, communityId, null, 'TestUser', null, null);
        } catch (HSRUserProvisioningHandler.JitException err) {
            System.assertEquals(err.getTypeName(), HSRUserProvisioningHandler.JitException.class.getName());
        } catch (Exception err) {
            System.debug('Unexpected error Details:');
            System.debug(HSRUtil.generateExceptionMessage(err));
            System.assertNotEquals(false, true, 'Unhandled error has occurred, check the debug logs for more details');
        }
        Test.stopTest();
        System.assertEquals(null, user);

        System.assertEquals(null, handler.portalContact);
        System.assertEquals(0, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(1, HSRUserProvisioningHandler.casesEvents.size());
    }

    @IsTest
    static void testCreateUser_Existing_Multiple() {
        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer),
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Customer)
        };
        HSRSelector.mockAccounts = accounts;


        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.mockContact(0, accounts[0]),
                HSRDataFactory.mockContact(1, accounts[0])
        };
        contacts[0].Email = 'test0@ncr.com';
        contacts[1].Email = 'test0@ncr.com';
        HSRSelector.mockContacts = contacts;


        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        User user;
        Test.startTest();
        try {
            Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
            user = handler.createUser(null, communityId, null, 'TestUser', null, null);
        } catch (HSRUserProvisioningHandler.JitException err) {
            System.assertEquals(err.getTypeName(), HSRUserProvisioningHandler.JitException.class.getName());
        } catch (Exception err) {
            System.debug('Unexpected error Details:');
            System.debug(HSRUtil.generateExceptionMessage(err));
            System.assertNotEquals(false, true, 'Unhandled error has occurred, check the debug logs for more details');
        }

        Test.stopTest();
        System.assertEquals(null, user);

        System.assertEquals(null, handler.portalContact);
        System.assertEquals(0, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(1, HSRUserProvisioningHandler.casesEvents.size());
    }

    @IsTest
    static void testCreateUser_UserNotFound() {
        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock_NotFound());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer),
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Customer)
        };
        HSRSelector.mockAccounts = accounts;

        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        User user;
        Test.startTest();
        try {
            Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
            user = handler.createUser(null, communityId, null, 'TestUser', null, null);
        } catch (HSRUserProvisioningHandler.JitException err) {
            System.assertEquals(err.getTypeName(), HSRUserProvisioningHandler.JitException.class.getName());
        } catch (Exception err) {
            System.debug('Unexpected error Details:');
            System.debug(HSRUtil.generateExceptionMessage(err));
            System.assertNotEquals(false, true, 'Unhandled error has occurred, check the debug logs for more details');
        }
        Test.stopTest();
        System.assertEquals(null, user);

        System.assertEquals(null, handler.portalContact);
        System.assertEquals(0, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(0, HSRUserProvisioningHandler.casesEvents.size());
    }

    @IsTest
    static void testCreateUser_ExistingUser() {
        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock());
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        Account account = HSRDataFactory.makeCustomerAccount(0);
        insert account;
        Contact contact = HSRDataFactory.makeContact(0, account, HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS);
        insert contact;
        Profile customerProfile = HSRSelector.getProfileByName(System.Label.HSR_UsrPrv_Profile_Name);
        User portalUser = HSRDataFactory.makeUser(0, customerProfile, 'test0@ncr.com', 'TestUser');
        portalUser.ContactId = contact.Id;
        insert portalUser;

        HSRSelector.mockContacts = new List<Contact>{
                contact
        };

        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        Test.startTest();
        Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
        User user = handler.createUser(null, communityId, null, 'NewFedId', null, null);
        Test.stopTest();

        // Validate created contact new values
        System.assertNotEquals(null, handler.userRecord);
        Contact createdContact = handler.portalContact;
        System.assertEquals('test', createdContact.FirstName, generateValidationErrorMessage('FirstName'));
        System.assertEquals('user', createdContact.LastName, generateValidationErrorMessage('LastName'));
        System.assertEquals('(987)654-3232', createdContact.Phone, generateValidationErrorMessage('Phone'));
        System.assertEquals('test0@ncr.com', createdContact.Email, generateValidationErrorMessage('Email'));
        System.assertEquals('Information Technology', createdContact.Title, generateValidationErrorMessage('Title'));
        System.assertEquals('123 main street', createdContact.MailingStreet, generateValidationErrorMessage('Street'));
        System.assertEquals('columbus', createdContact.MailingCity, generateValidationErrorMessage('City'));
        System.assertEquals('OH', createdContact.MailingState, generateValidationErrorMessage('State'));
        System.assertEquals('43215', createdContact.MailingPostalCode, generateValidationErrorMessage('PostalCode'));

        System.assertEquals(0, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(1, HSRUserProvisioningHandler.casesEvents.size());

        // Validate the newly created user values
        String profileId = customerProfile.Id;
        System.assertEquals('test0@ncr.com.hospitality', user.Username, generateValidationErrorMessage('Username'));
        System.assertEquals('TestUser', user.FederationIdentifier, generateValidationErrorMessage('FederationIdentifier'));
        System.assertEquals(profileId, user.ProfileId, generateValidationErrorMessage('ProfileId'));
        System.assertEquals('test', user.FirstName, generateValidationErrorMessage('FirstName'));
        System.assertEquals('user', user.LastName, generateValidationErrorMessage('LastName'));
        System.assertEquals('(987)654-3232', user.Phone, generateValidationErrorMessage('Phone'));
        System.assertEquals('test0@ncr.com', user.Email, generateValidationErrorMessage('Email'));
        System.assertEquals('Information Technology', user.Title, generateValidationErrorMessage('Title'));
        System.assertEquals('123 main street', user.Street, generateValidationErrorMessage('Street'));
        System.assertEquals('columbus', user.City, generateValidationErrorMessage('City'));
        System.assertEquals('OH', user.State, generateValidationErrorMessage('State'));
        System.assertEquals('43215', user.PostalCode, generateValidationErrorMessage('PostalCode'));
    }

    @IsTest
    static void testCreateUser_ServerError() {
        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.JITAttributesCalloutMock_ServerError());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer),
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Customer)
        };
        HSRSelector.mockAccounts = accounts;

        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        User user;
        Test.startTest();
        try {
            Id communityId = HSRDataFactory.mockId(Network.SObjectType, 0);
            user = handler.createUser(null, communityId, null, 'TestUser', null, null);
        } catch (HSRUserProvisioningHandler.JitException err) {
            System.assert(err.getMessage().containsIgnoreCase('Server Error'));
        } catch (Exception err) {
            System.debug('Unexpected error Details:');
            System.debug(HSRUtil.generateExceptionMessage(err));
            System.assertNotEquals(false, true, 'Unhandled error has occurred, check the debug logs for more details');
        }
        Test.stopTest();
        System.assertEquals(null, user);

        System.assertEquals(null, handler.portalContact);
        System.assertEquals(0, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
        System.assertEquals(0, HSRUserProvisioningHandler.casesEvents.size());
    }

    @IsTest
    static void testUpdateUser() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Site),
                HSRDataFactory.mockAccount(2, HSRDataFactory.AccountType.Site)
        };
        HSRSelector.mockAccounts = siteAccounts;

        Account customerAccount = HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer);
        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.mockContact(0, customerAccount)
        };
        HSRSelector.mockContacts = contacts;

        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();

        User user = HSRDataFactory.mockUser(0);
        user.ContactId = contacts[0].Id;
        user.Contact = contacts[0];

        Test.startTest();
        handler.updateUser(user.Id, null, null, null, 'TestUser', null, null);
        Test.stopTest();

        System.assertNotEquals(null, handler.portalContact);
        System.assertEquals(2, handler.accountContactRelationsToInsert.size());
        System.assertEquals(0, handler.accountContactRelationsToDelete.size());
    }

    @IsTest
    private static void testCreateAccountContactRelations_async() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        List<Account> accounts = new List<Account>{
                HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Site),
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Site)
        };
        HSRSelector.mockAccounts = accounts;

        Account mcnAccount = HSRDataFactory.mockAccount(2, HSRDataFactory.AccountType.Customer);
        HSRUserProvisioningHandler handler = new HSRUserProvisioningHandler();
        handler.portalContact = HSRDataFactory.mockContact(0, mcnAccount);

        HSRUtil.mockMaxNumberOfDMLRows = 0;
        HSRUtil.isRunningBatch = false;
        handler.insertAccountContactRelations();

        System.assertEquals(null, handler.accountContactRelationsToInsert, 'NO ACRs are expected to be inserted in sync mode');
        List<AsyncApexJob> scheduledJobs = HSRSelector.getRunningBatchByClassName(HSRACRCreationBatch.class.getName(), HSRConstants.ASYNC_JOB_JOB_TYPE_BATCH);
        System.assertEquals(1, scheduledJobs.size());
    }

    @IsTest
    private static void testCreateCase() {
        Account mcnAccount = HSRDataFactory.makeCustomerAccount(0);
        insert mcnAccount;

        Contact relatedContact = HSRDataFactory.makeContact(0, mcnAccount, HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS);
        insert relatedContact;

        Test.startTest();
        HSRUserProvisioningHandler.createCase(mcnAccount.Id, relatedContact.Id, relatedContact.Email, 'test@testncruser.com', '');
        Test.stopTest();

        List<EventBusSubscriber> createdEventBus = HSRTestSelector.getEventBus('HSR_Case__e');
        System.assertEquals(1, createdEventBus.size());
    }

    @IsTest
    private static void testUtil_isUserProvProfile() {
        System.assertEquals(true, HSRUtil.isUserProvisioningCustomerProfile(System.Label.HSR_UsrPrv_Profile_Name));
        System.assertEquals(false, HSRUtil.isUserProvisioningCustomerProfile('Random Profile Name'));
    }

    // -------------- Util Methods --------------
    private static String generateValidationErrorMessage(String fieldName) {
        return String.format('Missing or incorrect "{0}" field mapping.', new List<String>{
                fieldName
        });
    }

}