/****************************************************************************************************
* Author        :   Pankaj Kashyap  
* Date          :   18-01-2022
* Description   :   This is the Test Class for SendDisputeStatusToMyncr.
*************************************************************************************************/
@isTest
public class SendDisputeStatusToMyncrtest {
    
    static testmethod void sendDisputeCount(){
        Test.startTest();
        All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile'; 
        // setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = NSCCommonInfoUtil.getIdOf('CCAD_Service_Ignored_Profile_Id');
        insert setting;
        Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        
        SetDisputeStatusCode__c disputeStaus = new SetDisputeStatusCode__c(Name='New',caseStatus__c='New' , caseStatusCode__c = 10);
        insert disputeStaus;
        
        Case caseObj = new Case();
        caseObj.RecordTypeId = DisputeRecordTypeId;
        caseObj.Master_Customer_Nbr__c='12345';
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
        
        CaseComment ccObj= new CaseComment();
        ccObj.CommentBody='[Comment from MyNCR - Created By: Test(test1234)]\n\n test comment';
        ccObj.IsPublished=true;
        ccObj.ParentId=caseObj.id;        
        insert ccObj;
        
        CaseComment ccObj1= new CaseComment();
        ccObj1.CommentBody='Test Comment';
        ccObj1.IsPublished=true;
        ccObj1.ParentId=caseObj.id;        
        insert ccObj1; 
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/invoiceDispute/status?x-transaction-id=12125412'; 
        
        //req.params.put('x-transaction-id','12125412');
        req.headers.put('x-transaction-id','12125412');
        req.headers.put('x-source-system','12125412');
        //req.params.put('x-source-system','test');
        req.params.put('DisputeID', '123412');
        req.params.put('IsExternalOnly', 'Y');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        SendDisputeStatusToMyncr.getDisputeHeader();
        Test.stopTest();  
        
    }
    
}