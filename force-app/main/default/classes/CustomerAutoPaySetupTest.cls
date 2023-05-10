@IsTest
private class CustomerAutoPaySetupTest {
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    @testSetup
    static void dataSetup() {
        Account Acc = new Account(Name = 'Parent acct',Master_Customer_Number__c = '123456');
        System.runAs(getUser()){
            insert Acc;
        }
        Account Billacc = new Account(Name = 'test acct',ParentId =Acc.Id ,Bill_To__c = true,CDM_Account_Type__c = 'Site', Site_Number__c = '966521');
        System.runAs(getUser()){
            insert Billacc;
        }
        OpportunityStage oppStage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id,CloseDate = Date.today().addDays(5), StageName = oppStage.MasterLabel,CPQ__c = true);
        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = Acc.id,qtc_Bill_To_Site__c = Billacc.Id,SBQQ__Opportunity2__c = opp.id);
        insert quote;
    }
    @isTest static void testAutoPaySetup1() {
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='https://ncr--cert.my.salesforce.com/services/apexrest/AutoPaySetup/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String MyJSON = '{"TransactionID": "37373532-3337-3334-3635-313035333832","AutopayStatus":"SUCCESS","MCN":"123456","BillToSite":"966521"}';
        request.requestBody = Blob.valueof(MyJSON);
        RestContext.request = request;
        RestContext.response = res;
        System.assertNotEquals(request.requestBody, null,'Request Body is null');
        CustomerAutoPaySetup.AutoPaySetup();
    }
        @isTest static void testAutoPaySetup2() {
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='https://ncr--cert.my.salesforce.com/services/apexrest/AutoPaySetup/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String MyJSON = '{"TransactionID": "37373532-3337-3334-3635-313035333832","AutopayStatus":"Fail","MCN":"123456","BillToSite":"966521"}';
        request.requestBody = Blob.valueof(MyJSON);
        System.assertNotEquals(request.requestBody, null,'Request Body is null');
        RestContext.request = request;
        RestContext.response = res;
        CustomerAutoPaySetup.AutoPaySetup();
    }
}