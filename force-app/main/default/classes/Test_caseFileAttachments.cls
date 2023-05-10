@isTest
public class Test_caseFileAttachments {
    
    @isTest
    private static void DisputeCasesFileAttachments(){
        Profile p = [Select id from Profile limit 1];
		insert new All_profie_config__c(Name='CCAD Service Ignored Profile',Profile_Id__c=p.Id);
        // Create Contact
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        //cont.Accountid= testAccount.id;
        insert cont;
        
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        Case caseObj = new Case();
        List<Id> caseIdList = new List<Id>();
        caseObj.RecordTypeId = CaseRecordTypeId;
        caseObj.Master_Customer_Nbr__c='12345';
        caseObj.Country_Code__c='US';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';
        caseObj.Customer_Contact__c=cont.id;
        caseObj.Alternate_Contact__c=cont.id;
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        
        ContentVersion content=new ContentVersion(); 
          
      
        //case insert
        insert caseObj;
       
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=caseObj.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';

        insert contentlink;
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        delete contentlink;
    }
}