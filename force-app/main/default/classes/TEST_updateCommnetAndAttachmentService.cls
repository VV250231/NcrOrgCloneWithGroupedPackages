/****************************************************************************************************
* Author        :   Santosh  
* Date          :   18-01-2022
* Description   :   This is the Test Class for updateCommnetAndAttachmentService.
*************************************************************************************************/

@isTest
public class TEST_updateCommnetAndAttachmentService {
    
    
    static testmethod void UpdateDispute()
    {
        Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile';
        setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        insert setting;
        
        
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
        caseObj.CCAD_Dispute_Nbr__c = '100';
        system.debug('@@Case: '+caseObj );
        insert caseObj; 
        
        
        
        
        
        
        //Construct HTTP request and response
        RestRequest  req = new RestRequest ();
        RestResponse  res = new RestResponse ();
        DisputeUtil dspUtil = new DisputeUtil();
        
        
        updateCommentAndAttachmentService.RequestHeader requestheader = new updateCommentAndAttachmentService.RequestHeader(); 
        requestheader.TransactionID = '123e4567-e89b-12d3-a456-426655440003';
        requestheader.Timestamp ='2021-08-02T12:36:08.370-04:00';
        requestheader.SourceSystem = 'MyNCR';
        requestheader.TargetSystem = 'NSC';
        
        
        updateCommentAndAttachmentService.Attachment attachment = new updateCommentAndAttachmentService.Attachment();
        attachment.Source = 'bwali tred';
        attachment.Description = 'bawali tred';
        attachment.URL = 'www.google.com';
        
        
        updateCommentAndAttachmentService.Dispute dispute = new updateCommentAndAttachmentService.Dispute();  
        dispute.DisputeID =  caseObj.CCAD_Dispute_Nbr__c;
        dispute.CreatedBy = 'sj185091';
        dispute.SubmitterName = 'santosh jha';
        dispute.Comment = 'santosh jha';
        list<updateCommentAndAttachmentService.Attachment> ss = new list<updateCommentAndAttachmentService.Attachment>();
        ss.add(attachment);
        dispute.Attachment = ss;
        
        
        
        
        updateCommentAndAttachmentService.InvoiceDisputeRequest invoicedisputerequest = new updateCommentAndAttachmentService.InvoiceDisputeRequest() ;
        invoicedisputerequest.Dispute = dispute;
        
        
        updateCommentAndAttachmentService.MainHeader mainheader = new updateCommentAndAttachmentService.MainHeader();
        mainheader.RequestHeader = requestheader;
        mainheader.InvoiceDisputeRequest = invoicedisputerequest;
        
        
        
        
        
        
        
        req.requestURI = '/services/apexrest/invoiceDispute/updateCommentAndAttachment';
        req.httpMethod = 'PUT';
        //req.requestBody = Blob.valueOf('"{\n\t\"RequestHeader\": {\n\t\t\"TransactionID\": \"123e4567-e89b-12d3-a456-426655440003\",\n\t\t\"Timestamp\": \"2021-08-02T12:36:08.370-04:00\",\n\t\t\"SourceSystem\": \"MyNCR\",\n\t\t\"TargetSystem\": \"NSC\"\n\t},\n\t\"InvoiceDisputeRequest\": {\n\t\t\"Dispute\": {\n\t\t\t\"DisputeID\": \"00254471\",\n\t\t\t\"CreatedBy\": \"\",\n\t\t\t\"SubmitterName\": \"santosh jha\",\n\t\t\t\"Comment\": \"testing on friday\",\n\t\t\t\"Attachment\": [{\n\t\t\t\t\t\"Source\": \"\",\n\t\t\t\t\t\"Description\": \"\",\n\t\t\t\t\t\"URL\": \"\"\n\t\t\t\t},\n\t\t\t\t{\n\t\t\t\t\t\"Source\": \"\",\n\t\t\t\t\t\"Description\": \"\",\n\t\t\t\t\t\"URL\": \"\"\n\t\t\t\t}\n\t\t\t]\n\t\t}\n\t}\n}"');
        
        // res.responseBody = Blob.valueOf('"{\n\"ResponseHeader\":{\n\"TransactionID\":\"123e4567-e89b-12d3-a456-426655440003\",\n\"Timestamp\":\"2021-08-02T12:36:08.370-04:00\",\n\"Status\":\"FAILURE\"\n},\n\"InvoiceDisputeResponse\":{\n\"Dispute\":{\n\"Result\":\"Existing Case not found\",\n\"InvoiceCount\":1,\n\"DisputeID\":\"00254471\"\n}\n}\n}"');
        req.requestBody= blob.valueOf(json.serializePretty(mainheader));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        updateCommentAndAttachmentService.UpdateDispute();
        Test.stopTest();
        
        
        
        
    }
}