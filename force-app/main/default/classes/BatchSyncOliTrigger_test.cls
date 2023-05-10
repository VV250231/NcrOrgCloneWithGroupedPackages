@isTest
public class BatchSyncOliTrigger_test {
    @isTest
    public static void testBatch(){
        Opportunity o=TestRecordsFactory.createOpportunityWithLineItemSchedule();
        SyncOLI_Config__c config = new SyncOLI_Config__c(name='Org_Config', LastRun_Datetime__c = Datetime.now().addDays(-1));
        insert config;
        test.startTest();
        String jobID = System.schedule('Schedule Oli Sync', '0 25 * * * ?', new SyncOliScheduler());
        BatchSyncOliTrigger reassign = new BatchSyncOliTrigger(); 
        ID batchprocessid = Database.executeBatch(reassign);
        test.stopTest();
        EmailMessage mssObj = [select id from EmailMessage where subject='batch finished for triggering SyncOli'];
        System.assert(mssObj.id!=null);
    }
}