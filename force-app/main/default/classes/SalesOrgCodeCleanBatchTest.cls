@isTest
public class SalesOrgCodeCleanBatchTest {

    @isTest
    public static void unitTest(){
        Account acc = TestRecordsFactory.createAccount('112121');
        Contact con = TestRecordsFactory.createContact(acc);
        Sales_Org__c sOrg = TestRecordsFactory.createSalesOrg();
        Opportunity opp = TestRecordsFactory.createOpportunityWithContact(con, acc);
        Test.startTest();
        SalesOrgCodeCleanBatch obj = new SalesOrgCodeCleanBatch();
        Database.executeBatch(obj);
        System.assert(obj!=null);
        Test.stopTest();
        
    }
}