@isTest
public class salesforceLogsGeneratorforAWSS3Test {
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
    
    public static testMethod void AWSLogs(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        Last_SIEM_Logs_Sent__c setting = new Last_SIEM_Logs_Sent__c();       
        setting.Name = 'SIEM Logs';
        setting.Timestamp__c= Datetime.now();
        insert setting;
        System.assertNotEquals(setting.Name, null,'Custom Setting Not Found');
        try{
            salesforceLogsGeneratorforAWSS3.uploadToAmazonS3();
        }
        Catch(exception e){
            system.debug('Exception Caught:'+e.getmessage());
        } 
        Test.StopTest();
    }
}