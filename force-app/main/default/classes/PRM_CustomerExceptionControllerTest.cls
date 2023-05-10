@isTest
public class PRM_CustomerExceptionControllerTest 
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
        System.runAs(u)
        {insert accounts;}
        
    }
    
     private static void createContact(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id);
        insert con;
    }  
    static testMethod void testPRM_CustomerExceptionControllerTest() 
    {
        Exception_Account__c ea = new Exception_Account__c(Name = 'Test');
        insert ea;
        
        System.assertNotEquals(ea,NULL,'Exception_Account__c not be NULL');
        
        Account_Exception__c ae = new Account_Exception__c();
        ae.Customer_Name__c = ea.Id;
        ae.Primary_Contact_Name__c ='XYZ';
        ae.Primary_Solution__c ='test';
		ae.Primary_Competitor__c ='test123';
		ae.Opportunity_Value__c = 123;
       
        ae.Expected_Close_Date__c = system.today();
        ae.Status__c = 'Created';
        insert ae;
        
        PRM_CustomerExceptionController.getCustomerException('All');
        PRM_CustomerExceptionController.getCustomerException('Created');
       	update ae;
        
        
          
        
        PRM_CustomerExceptionController.getCustomerExceptionDetail(ae.Id);
        PRM_CustomerExceptionController.getEditCustomerExceptionDetail(ae.Id);
        PRM_CustomerExceptionController.saveEditedCustomerException(ae,ea.Id);
        PRM_CustomerExceptionController.getCEAttachments(ae.Id);
        
        Account_Exception__c objCE = new Account_Exception__c();
        objCE.Customer_Name__c = ea.Id;
        objCE.Primary_Contact_Name__c ='XYZ';
        objCE.Primary_Solution__c ='test';
		objCE.Primary_Competitor__c ='test123';
		objCE.Opportunity_Value__c = 123;
       
        objCE.Expected_Close_Date__c = system.today();
        objCE.Status__c = 'Created';
       
        PRM_CustomerExceptionController.saveCustomerException(objCE, ea.Id);
        
        
        
        PRM_CustomerExceptionController.saveChunk(ae.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = ae.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_CustomerExceptionController.saveChunk(ae.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }
    static testmethod void submitApprovalRequest()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        
        Exception_Account__c ea = new Exception_Account__c(Name = 'Test');
        insert ea;
         System.assertNotEquals(ea,NULL,'Exception_Account__c not be NULL');
        Account_Exception__c ae = new Account_Exception__c();
        ae.Customer_Name__c = ea.Id;
        ae.Primary_Contact_Name__c ='XYZ';
        ae.Primary_Solution__c ='test';
		ae.Primary_Competitor__c ='test123';
		ae.Opportunity_Value__c = 123;
        
        ae.Expected_Close_Date__c = system.today();
        ae.Status__c = 'Created';
        insert ae;
     
        PRM_CustomerExceptionController.submitApprovalRequest(ae.id, 'Test');
        
    //    ae.Status__c = 'Submitted';
    //    update ae;
        
  //      ae.Status__c = 'Approved';
  //      update ae;
        
        
           
       	List<Attachment__c> aeAttList = new List<Attachment__c>();
       	
       	Attachment__c obj = new Attachment__c();
        
        
        aeAttList.add(obj);
        
       
        
        
        
        insert aeAttList;
    }
    
  	
}