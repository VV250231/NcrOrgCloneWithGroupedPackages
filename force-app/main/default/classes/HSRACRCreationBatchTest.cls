/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class that covers Account-Contact_relations batch job creation for Hospitality Experience
* Cloud
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-07-15
* @modified       2022-07-15
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-07-15
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
private class HSRACRCreationBatchTest {
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
    static void testRunBatch_singleCustomerAccount() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0),
                HSRDataFactory.makeCustomerAccount(1)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(2, customerAccounts[1]),
                HSRDataFactory.makeSiteAccount(3, customerAccounts[1])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(1, customerAccounts[1], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(2, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_ERROR),
                HSRDataFactory.makeContact(3, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_COMPLETE)
        };
        insert contacts;

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        HSRACRCreationBatch.runBatch();
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertEquals(3, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(8, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(3, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[1].Id);
        System.assertEquals(3, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[2].Id);
        System.assertEquals(1, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[3].Id);
        System.assertEquals(1, relatedACRs.size());
    }

    @IsTest
    static void testRunBatch_singlePartnerAccount() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> partnerAccounts = new List<Account>{
                HSRDataFactory.makePartnerAccount(0),
                HSRDataFactory.makePartnerAccount(1)
        };
        insert partnerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, partnerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, partnerAccounts[0]),
                HSRDataFactory.makeSiteAccount(2, partnerAccounts[1]),
                HSRDataFactory.makeSiteAccount(3, partnerAccounts[1])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, partnerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(1, partnerAccounts[1], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(2, partnerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_ERROR),
                HSRDataFactory.makeContact(3, partnerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_COMPLETE)
        };
        insert contacts;

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        HSRACRCreationBatch.runBatch();
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertEquals(3, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(8, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(3, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[1].Id);
        System.assertEquals(3, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[2].Id);
        System.assertEquals(1, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[3].Id);
        System.assertEquals(1, relatedACRs.size());
    }

    @IsTest
    static void testRunBatch_multipleCustomerAccount() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0),
                HSRDataFactory.makeCustomerAccount(1)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(2, customerAccounts[1]),
                HSRDataFactory.makeSiteAccount(3, customerAccounts[1])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        List<AccountContactRelation> contactRelations = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(customerAccounts[1].Id, contacts[0].Id, false)
        };
        insert contactRelations;

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        HSRACRCreationBatch.runBatch();
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertEquals(1, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(6, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(6, relatedACRs.size());
    }

    @IsTest
    static void testRunBatch_MissingMCNAccount() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0),
                HSRDataFactory.makeCustomerAccount(1)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(2, customerAccounts[1]),
                HSRDataFactory.makeSiteAccount(3, customerAccounts[1])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(1, null, HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        HSRACRCreationBatch.runBatch();
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertEquals(2, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(3, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(3, relatedACRs.size());
        relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[1].Id);
        System.assertEquals(0, relatedACRs.size());
    }

    @IsTest
    static void testRunBatch_ExistingACR() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        insert new AccountContactRelation(AccountId = siteAccounts[0].Id, ContactId = contacts[0].Id);

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        HSRACRCreationBatch.runBatch();
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertEquals(1, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(3, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(3, relatedACRs.size());
    }

    @IsTest
    static void testRunBatch_BatchLimit() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        Test.startTest();
        HSRUtil.isRunningBatch = true;
        try {
            HSRACRCreationBatch.runBatch();
        } catch (HSRACRCreationBatch.HSRACRCreationBatchException err) {
            System.assertNotEquals('', err.getMessage());
        } catch (Exception err) {
            System.assertEquals(true, false, 'Unexpected error: ' + err.getMessage());
        }
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS);
        System.assertEquals(1, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(1, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(1, relatedACRs.size());
    }

    @IsTest
    static void testScheduleJob() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        String CRON_EXP = '0 0 2 * * ? *';

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        HSRACRCreationBatch batchJob = new HSRACRCreationBatch();

        String jobId = System.schedule(
                HSRACRCreationBatch.class.getName(),
                CRON_EXP,
                batchJob
        );
        batchJob.execute(null);
        Test.stopTest();

        List<Contact> updatedContacts = HSRTestSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertEquals(1, updatedContacts.size());

        List<AccountContactRelation> createdACRs = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(3, createdACRs.size());

        List<AccountContactRelation> relatedACRs = getRelatedACRsByContactId(createdACRs, contacts[0].Id);
        System.assertEquals(3, relatedACRs.size());
    }

    @IsTest
    private static void testExceptionHandling() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Account mcnAccount = HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer);
        Contact relatedContact = HSRDataFactory.mockContact(0, mcnAccount);
        relatedContact.Hospitality_ACR_Processing_Status__c = HSRConstants.CONTACT_ACR_STATUS_ERROR;
        HSRSelector.mockContacts = new List<Contact>{
                relatedContact
        };

        List<Account> accounts = new List<Account>{
                mcnAccount,
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Site),
                HSRDataFactory.mockAccount(2, HSRDataFactory.AccountType.Site)
        };
        HSRSelector.mockAccounts = accounts;

        List<AccountContactRelation> createdACRs = new List<AccountContactRelation>{
                HSRDataFactory.mockAccountContactRelations(0, mcnAccount.Id, relatedContact.Id, false),
                HSRDataFactory.mockAccountContactRelations(1, accounts[0].Id, relatedContact.Id, true),
                HSRDataFactory.mockAccountContactRelations(2, accounts[1].Id, relatedContact.Id, true)
        };

        HSRTestSelector.mockAccountContactRelations = createdACRs;

        Test.startTest();
        HSRUtil.isRunningBatch = false;
        // An error will occur when the code tries to update the original contact records (mocked records with no real Ids)
        // If the unit test run was successful, this confirms that the class error handling is working as expected
        HSRACRCreationBatch.runBatch();
        Test.stopTest();
    }


    // ------------- Util Method -------------
    private static List<AccountContactRelation> getRelatedACRsByContactId(List<AccountContactRelation> allACRs, Id contactId) {
        List<AccountContactRelation> relatedACRs = new List<AccountContactRelation>();
        for (AccountContactRelation acr : allACRs) {
            if (acr.ContactId == contactId) {
                relatedACRs.add(acr);
            }
        }
        return relatedACRs;
    }


}