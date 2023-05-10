@istest
class AWSS3ScheduleTest {
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testMethod void testschedule() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        Last_SIEM_Logs_Sent__c setting = new Last_SIEM_Logs_Sent__c();       
        setting.Name = 'SIEM Logs';
        setting.Timestamp__c= Datetime.now();
        insert setting;
        System.assertNotEquals(setting.Name, null,'Custom Setting Not Found');
        
        salesforceLogsGeneratorforAWSS3Schedule runjob = new salesforceLogsGeneratorforAWSS3Schedule();
        String sch = '0 0 0,4,8,12,16,20 * * ?';
        String job1=system.schedule('AWS S3 Logs Job', sch, runjob );
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }
}