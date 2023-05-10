@isTest
public class InstitutionSyncBatch_Test {
    @isTest 
    static void testPostCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new InstitutionSyncMock()); 
        test.startTest();
        InstitutionSyncScheduler m = new InstitutionSyncScheduler();
        String sch = '20 30 8 10 2 ?';
        //String jobID = system.schedule('Merge Job', sch, m);
               InstitutionSyncScheduler.makeCallOut('50','100');
            //InstitutionSyncBatch bt = new InstitutionSyncBatch('50','20');
            //Database.executeBatch(bt, 50);
        test.stopTest();
    }
    
}