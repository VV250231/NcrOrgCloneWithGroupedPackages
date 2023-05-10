@isTest
public class Delete_PMDM_RequestLogTest {
    static testMethod void myUnitTest(){
        PMDM_Request_log__c requestLog = new PMDM_Request_log__c();
        insert requestLog;
        
        Test.startTest();
            ScheduleDelete_PMDM_RequestLog sh1 = new ScheduleDelete_PMDM_RequestLog();
            String sch = '0 0 23 * * ?';
            String jobId =system.schedule('Test request Log', sch, sh1);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];    
        	System.assertEquals(sch, ct.CronExpression);
        test.stopTest();
    } 
}