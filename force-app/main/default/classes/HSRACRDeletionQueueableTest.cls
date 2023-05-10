/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class that covers Account-Contact_relations batch job deletion for Hospitality Experience
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
private class HSRACRDeletionQueueableTest {
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
    static void testEnqueue_InactiveCustomerAccount_AllAutomation() {
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

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[1].Id, contacts[0].Id, true)
        };
        insert acrs;

        siteAccounts[0].Active_Account__c = false;
        siteAccounts[0].CDM_Account_Status__c = 'Inactive';
        update siteAccounts[0];

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(customerAccounts));
        Test.stopTest();

        List<AccountContactRelation> remainingAccountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(2, remainingAccountContactRelations.size());

    }

    @IsTest
    static void testEnqueue_InactivePartnerAccount_AllAutomation() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> partnerAccounts = new List<Account>{
                HSRDataFactory.makePartnerAccount(0)
        };
        insert partnerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, partnerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, partnerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, partnerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[1].Id, contacts[0].Id, true)
        };
        insert acrs;

        siteAccounts[0].Active_Account__c = false;
        siteAccounts[0].CDM_Account_Status__c = 'Inactive';
        update siteAccounts[0];

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(partnerAccounts));
        Test.stopTest();

        List<AccountContactRelation> remainingAccountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(2, remainingAccountContactRelations.size());

    }
    @IsTest
    static void testEnqueue_InactiveAccount_MultiCustomerAccounts_AllAutomation() {
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

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[1].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[2].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[3].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(customerAccounts[1].Id, contacts[0].Id, false)
        };
        insert acrs;

        for (Account siteAccount : siteAccounts) {
            siteAccount.Active_Account__c = false;
            siteAccount.CDM_Account_Status__c = 'Inactive';
        }

        update siteAccounts;

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(customerAccounts));
        Test.stopTest();

        List<AccountContactRelation> remainingAccountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(2, remainingAccountContactRelations.size());

    }

    @IsTest
    static void testEnqueue_InactiveAccount_MultiCustomerAccounts_Mixed() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0),
                HSRDataFactory.makeCustomerAccount(1),
                HSRDataFactory.makeCustomerAccount(2)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(1, customerAccounts[0]),
                HSRDataFactory.makeSiteAccount(2, customerAccounts[1]),
                HSRDataFactory.makeSiteAccount(3, customerAccounts[1]),
                HSRDataFactory.makeSiteAccount(4, customerAccounts[2]),
                HSRDataFactory.makeSiteAccount(5, customerAccounts[2]),
                HSRDataFactory.makeSiteAccount(6, customerAccounts[2])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true), // [Delete] inactive
                HSRDataFactory.makeAccountContactRelations(siteAccounts[1].Id, contacts[0].Id, true), // [Keep] active
                HSRDataFactory.makeAccountContactRelations(siteAccounts[2].Id, contacts[0].Id, true), // [Delete] inactive
                HSRDataFactory.makeAccountContactRelations(siteAccounts[3].Id, contacts[0].Id, false), // [Delete] inactive
                HSRDataFactory.makeAccountContactRelations(siteAccounts[4].Id, contacts[0].Id, true), // [Delete] no existing ACR -> customer account
                HSRDataFactory.makeAccountContactRelations(siteAccounts[5].Id, contacts[0].Id, true), // [Delete] no existing ACR -> customer account
                HSRDataFactory.makeAccountContactRelations(siteAccounts[6].Id, contacts[0].Id, false), // [Delete] inactive
                HSRDataFactory.makeAccountContactRelations(customerAccounts[1].Id, contacts[0].Id, false)
        };
        insert acrs;

        siteAccounts[0].Active_Account__c = false;
        siteAccounts[0].CDM_Account_Status__c = 'Inactive';
        siteAccounts[2].Active_Account__c = false;
        siteAccounts[2].CDM_Account_Status__c = 'Inactive';
        siteAccounts[3].Active_Account__c = false;
        siteAccounts[3].CDM_Account_Status__c = 'Inactive';
        siteAccounts[4].Active_Account__c = false;
        siteAccounts[4].CDM_Account_Status__c = 'Inactive';
        siteAccounts[6].Active_Account__c = false;
        siteAccounts[6].CDM_Account_Status__c = 'Inactive';
        update siteAccounts;

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        List<Account> relatedCustomerAccounts = new List<Account>{
                customerAccounts[0],
                customerAccounts[1]
        };
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(relatedCustomerAccounts));
        Test.stopTest();

        Map<Id, AccountContactRelation> remainingAccountContactRelations = new Map<Id, AccountContactRelation>(HSRTestSelector.getAccountContactRelations());
        System.assertEquals(3, remainingAccountContactRelations.size());

        System.assertEquals(false, remainingAccountContactRelations.containsKey(acrs[0].Id), 'Expect: Delete (inactive), Actual: Not deleted');
        System.assertEquals(true, remainingAccountContactRelations.containsKey(acrs[1].Id), 'Expect: Keep (active), Actual: Deleted');
        System.assertEquals(false, remainingAccountContactRelations.containsKey(acrs[2].Id), 'Expect: Delete (inactive), Actual Not Deleted');
        System.assertEquals(false, remainingAccountContactRelations.containsKey(acrs[3].Id), 'Expect: Delete (inactive), Actual Not Deleted');
        System.assertEquals(false, remainingAccountContactRelations.containsKey(acrs[4].Id), 'Expect: Delete (no existing ACR to the customer account), Actual Not Deleted');
        System.assertEquals(false, remainingAccountContactRelations.containsKey(acrs[5].Id), 'Expect: Delete (no existing ACR to the customer account), Actual Not Deleted');
        System.assertEquals(false, remainingAccountContactRelations.containsKey(acrs[6].Id), 'Expect: Delete (inactive), Actual: Not deleted');

    }

    @IsTest
    static void testEnqueue_InactiveAccount_Mixed() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(1, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[1].Id, false)
        };
        insert acrs;

        List<AccountContactRelation> accountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(4, accountContactRelations.size());

        siteAccounts[0].Active_Account__c = false;
        siteAccounts[0].CDM_Account_Status__c = 'Inactive';
        update siteAccounts[0];

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(customerAccounts));
        Test.stopTest();

        accountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(3, accountContactRelations.size());

    }

    @IsTest
    static void testEnqueue_ChangedParent_AllAutomation() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0),
                HSRDataFactory.makeCustomerAccount(1)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(1, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[1].Id, true)
        };
        insert acrs;

        List<AccountContactRelation> accountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(4, accountContactRelations.size());

        siteAccounts[0].ParentId = customerAccounts[1].Id;
        update siteAccounts[0];

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(customerAccounts));
        Test.stopTest();

        accountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(4, accountContactRelations.size());

        List<AccountContactRelation> siteACRs = getSitesAccountContactRelations(accountContactRelations, customerAccounts[0].Id);
        System.assertEquals(0, siteACRs.size());
        siteACRs = getSitesAccountContactRelations(accountContactRelations, customerAccounts[1].Id);
        System.assertEquals(2, siteACRs.size());
    }

    @IsTest
    static void testEnqueue_ChangedParent_AllManual() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        List<Account> customerAccounts = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0),
                HSRDataFactory.makeCustomerAccount(1)
        };
        insert customerAccounts;

        List<Account> siteAccounts = new List<Account>{
                HSRDataFactory.makeSiteAccount(0, customerAccounts[0])
        };
        insert siteAccounts;

        List<Contact> contacts = new List<Contact>{
                HSRDataFactory.makeContact(0, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS),
                HSRDataFactory.makeContact(1, customerAccounts[0], HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS)
        };
        insert contacts;

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, false),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[1].Id, false)
        };
        insert acrs;

        siteAccounts[0].ParentId = customerAccounts[1].Id;
        update siteAccounts[0];

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = 0;
        HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(customerAccounts));
        Test.stopTest();

        List<AccountContactRelation> accountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(4, accountContactRelations.size());

        List<AccountContactRelation> siteACRs = getSitesAccountContactRelations(accountContactRelations, customerAccounts[0].Id);
        System.assertEquals(0, siteACRs.size());
        siteACRs = getSitesAccountContactRelations(accountContactRelations, customerAccounts[1].Id);
        System.assertEquals(2, siteACRs.size());
    }

    @IsTest
    static void testEnqueue_QueueLimit() {
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

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
                HSRDataFactory.makeAccountContactRelations(siteAccounts[0].Id, contacts[0].Id, true),
                HSRDataFactory.makeAccountContactRelations(siteAccounts[1].Id, contacts[0].Id, true)
        };
        insert acrs;

        siteAccounts[0].Active_Account__c = false;
        siteAccounts[0].CDM_Account_Status__c = 'Inactive';
        update siteAccounts[0];

        Test.startTest();
        HSRUtil.mockCurrentQueueableUsage = System.Limits.getLimitQueueableJobs() + 1;

        try {
            HSRACRDeletionQueueable.enqueue(contacts[0].Id, getsObjectRecordIds(customerAccounts));
        } catch (HSRACRDeletionQueueable.HSRACRDeletionException err) {
            System.assertNotEquals('', err.getMessage());
        } catch (Exception err) {
            System.assertEquals(true, false, 'Unexpected error: ' + err.getMessage());
        }
        Test.stopTest();

        List<AccountContactRelation> accountContactRelations = HSRTestSelector.getAccountContactRelations();
        System.assertEquals(3, accountContactRelations.size());

    }

    // ------------- Util Method -------------

    private static List<AccountContactRelation> getSitesAccountContactRelations(List<AccountContactRelation> allACRs, Id customerAccountId) {
        List<AccountContactRelation> acrs = new List<AccountContactRelation>();
        for (AccountContactRelation acr : allACRs) {
            if (acr.Account.ParentId == customerAccountId) {
                acrs.add(acr);
            }
        }
        return acrs;
    }

    private static List<Id> getsObjectRecordIds(List<SObject> records) {
        return new List<Id>(new Map<Id, SObject>(records).keySet());
    }
}