/****************************************************************************************************
* Author        :   Saurav  
* Date          :   18-01-2022
* Description   :   This is the Test Class for sendDisputeCountToMyNCR.
*************************************************************************************************/
@isTest
public class sendDisputeCountToMyNCRTest {
    
    static testmethod void sendDisputeCount(){
        All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile'; 
        setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        insert setting;

	 	SetDisputeStatusCode__c disputeStaus = new SetDisputeStatusCode__c(Name='New',caseStatus__c='New' , caseStatusCode__c = 10);
        insert disputeStaus;
        Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        
        Account acc = TestRecordsFactory.createAccount();
        
        Test.startTest();        
       
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
         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/invoiceDispute/count?x-transaction-id=1234'; 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.response= res;
        RestContext.request = req;
        
        sendDisputeCountToMyNCR.disputeCount();
        
        req.headers.put('x-transaction-id','1234');
        req.headers.put('x-source-system','12345');
        
        RestContext.request = req;        
        sendDisputeCountToMyNCR.disputeCount();
       
        req.params.put('MCNs', acc.Master_Customer_Number__c);
        RestContext.response= res;
        RestContext.request = req;
        
        sendDisputeCountToMyNCR.reqVald('1234',acc.Master_Customer_Number__c);
        sendDisputeCountToMyNCR.disputeCount();
        
        Test.stopTest();  
        
    }

}