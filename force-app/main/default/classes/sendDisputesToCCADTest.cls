@isTest
private class sendDisputesToCCADTest {
    
    @testSetup static void setup() {
        
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
        system.debug('@@Case: '+caseObj );
        insert caseObj;
        
        Dispute_Invoices__c invOvj= new Dispute_Invoices__c();
        invOvj.Invoice_Number__c= '201820662';
        invOvj.Total_Invoice_Amount__c=1234567;
        invOvj.Customer_Trx_ID__c=1378389;
        invOvj.Dispute__c=caseObj.id;
        insert invOvj;  
        
        CaseComment ccObj= new CaseComment();
        ccObj.CommentBody='Test Comment';
        ccObj.IsPublished=true;
        ccObj.ParentId=caseObj.id;        
        insert ccObj;
        
        Other_Attachments__c otherAttach = new Other_Attachments__c();
        otherAttach.Attachment_Description__c = 'test';
        otherAttach.Attachment_FULL_URL__c = 'test@ncr.com';
        otherAttach.Attachment_Source__c = 'CCAD';
        otherAttach.Case__c = caseObj.Id;
        insert otherAttach;    
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = caseObj.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;  
        
        Delete cdl; 
    }
    
    static testMethod void sendDisputeTest() {
        Case c = [SELECT Id, CaseNumber FROM Case Limit 1];
        List<Id> caseIds = new List<Id>();
        caseIds.add(c.Id);
        system.assert(caseIds.size() > 0);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new sendDisputesToCCAD_MockCallOut()); 
        sendDisputesToCCAD.syncCaseToCCAD(caseIds, false);
        Test.stopTest();       
        
    }
    
}