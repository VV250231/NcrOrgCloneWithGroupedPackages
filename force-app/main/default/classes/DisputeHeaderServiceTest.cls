@isTest
private class DisputeHeaderServiceTest {
    
    static testmethod void runtest1(){
        All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile'; 
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c =NSCCommonInfoUtil.getIdOf('CCAD_Service_Ignored_Profile_Id');
        insert setting;
        Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        
        SetDisputeStatusCode__c disputeStaus = new SetDisputeStatusCode__c(Name='New',caseStatus__c='New' , caseStatusCode__c = 10);
        insert disputeStaus;
        Account acc = TestRecordsFactory.createAccount();
        
        Case caseObj = new Case();
        caseObj.RecordTypeId = DisputeRecordTypeId;
        caseObj.AccountId= acc.Id;
        caseObj.Master_Customer_Nbr__c = acc.Master_Customer_Number__c;
        caseObj.Country_Code__c='IT';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';  
        caseObj.Dispute_Updated_By_Name__c='77379';
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        caseObj.CCAD_Dispute_Nbr__c='123412' ;
        system.debug('@@Case: '+caseObj );
        insert caseObj;
        
        Dispute_Invoices__c invOvj= new Dispute_Invoices__c();
        invOvj.Invoice_Number__c= '201820662';
        invOvj.Total_Invoice_Amount__c=1234567;
        invOvj.Customer_Trx_ID__c=1378389;
        invOvj.Dispute__c=caseObj.id;
        insert invOvj; 
        
        DisputeResponseHeader rspHdr = new DisputeResponseHeader();
        DisputeResponseHeader rspHdr1 = new DisputeResponseHeader('test', Datetime.now().format(), 'test');
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/invoiceDispute/header?x-transaction-id=12125412'; 
        req.httpMethod = 'GET'; 
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;  
        
        DisputeHeaderService.getDisputeHeader();
        
        req.headers.put('x-transaction-id','trans1234');
        req.headers.put('x-source-system','Test');
        
        RestContext.request = req;
        DisputeHeaderService.getDisputeHeader();
        
        req.params.put('DisputeID', '123412');
        req.params.put('MCNs', acc.Master_Customer_Number__c);
        req.params.put('OpenType', 'Y');
        
        RestContext.request = req;        
        DisputeHeaderService.getDisputeHeader();
        
        req.params.put('DisputeID', '');
        req.params.put('InvoiceID', '201820662');
        req.params.put('CountryCode', 'IT');
        RestContext.request = req;        
        DisputeHeaderService.getDisputeHeader();
        Test.stopTest();
        
        
    }
}