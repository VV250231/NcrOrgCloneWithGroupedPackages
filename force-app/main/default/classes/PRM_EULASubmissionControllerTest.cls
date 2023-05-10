@isTest
public class PRM_EULASubmissionControllerTest 
{
    static
    {
        createAcc();  
    }
    private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        user u = [select id from user where name = 'Soup user'];
        System.runAs(u){
            insert accounts;}
    }
    
     private static void createContact(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id);
        insert con;
    }  
    static testMethod void testPRM_EULASubmissionControllerTest() 
    {
        
        EULA_submission__c es = new EULA_submission__c();
        es.Customer_Name__c = 'ABC';
        es.Solution_Name_or_Identifying_PID__c ='XYZ';
        es.Country__c ='India';
        es.End_Date_of_Agreement__c = system.today();
        es.Address__c = 'Test';
        es.Date_of_Agreement__c = system.today();
        
       
        
        es.Status__c = 'Created';
        insert es;
        System.assertNotEquals(es,NULL,'EULA_submission__c should not be NULL');
        PRM_EULASubmissionController.getEULASubmission('All');
        PRM_EULASubmissionController.getEULASubmission('Created');
        update es;
        
        PRM_EULASubmissionController.getEULASubmissionDetail(es.Id);
        PRM_EULASubmissionController.getEditEULASubmissionDetail(es.Id);
        PRM_EULASubmissionController.saveEditedEULA(es);
        PRM_EULASubmissionController.getCBCAttachments(es.Id);
        
        EULA_submission__c objES = new EULA_submission__c();
        objES.Customer_Name__c = 'ABC';
        objES.Solution_Name_or_Identifying_PID__c ='XYZ';
        objES.Country__c ='India';
        objES.End_Date_of_Agreement__c = system.today();
        objES.Address__c = 'Test';
        objES.Date_of_Agreement__c = system.today();
        objES.Status__c = 'Created';
       
        PRM_EULASubmissionController.saveEULA(objES);
        
        
        
        PRM_EULASubmissionController.saveChunk(es.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = es.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_EULASubmissionController.saveChunk(es.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }
    static testmethod void submitApprovalRequest()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        
        EULA_submission__c es = new EULA_submission__c();
        es.Customer_Name__c = 'ABC';
        es.Solution_Name_or_Identifying_PID__c ='XYZ';
        es.Country__c ='India';
        es.End_Date_of_Agreement__c = system.today();
        es.Address__c = 'Test';
        es.Date_of_Agreement__c = system.today();
        es.Status__c = 'Created';
        insert es;
     System.assertNotEquals(es,NULL,'EULA_submission__c should not be NULL');
        PRM_EULASubmissionController.submitApprovalRequest(es.id, 'Test');
        
   
        
        
           
        List<Attachment__c> esAttList = new List<Attachment__c>();
        
        Attachment__c obj = new Attachment__c();
        
        
        esAttList.add(obj);
        
       
        
        
        
        insert esAttList;
    }
    
    
}