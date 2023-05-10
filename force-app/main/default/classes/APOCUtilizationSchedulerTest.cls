@isTest
public class APOCUtilizationSchedulerTest {
    @isTest
    public static void unitTest(){
		Test.startTest();
        APOCUtilizationScheduler apc = new APOCUtilizationScheduler();
        String sch = '0 0 2 * * ?';	
        system.schedule('Test Territory Check', sch, apc);
        System.assertEquals([select id from APOC_Utilization__c].size(),0);
        Test.stopTest();
    }
}