@isTest
public class PRM_EngineerControllerTest 
{
    static
    {
        createAcc();  
    }
    private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC',Partner_Type__c='Dealer',RecordTypeId='0127000000011t5AAA'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        System.runAs(TestRecordsFactory.getUser()){ 
            insert accounts;
        }
    }
    
    private static void createContact(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id);
        insert con;
    }  
    static testMethod void testPRM_EngineerControllerTest() 
    {
        Engineers__C eng = new Engineers__C();
        eng.First_name__c ='ABC';
        eng.Last_Name__c ='XYZ';
        eng.Active_Engineer__c =true;
        eng.Email_Address__c ='xyz@ncr.com';
        eng.City__c='noWhere';
        eng.Type_of_Portal_Access__c ='Portal Access';
        eng.Status__c = 'Created';
        insert eng;
        
        System.assertNotEquals(eng.id, null,'Engineer Should not be null');
        Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        insert obj1;
        
        PRM_EngineerController.getEngineer('All');
        PRM_EngineerController.getEngineer('Inactive Engineers');
        
        eng.In_Breach__c = true;
        eng.Active_Engineer__c = true;
        
        update eng;
        PRM_EngineerController.getEngineer('In Breach Engineers');
            
        PRM_EngineerController.getEngineer('Active Engineers');   
        
        PRM_EngineerController.getEngineerDetail(eng.Id);
        PRM_EngineerController.getEngineerAttachment(eng.Id);
        
        Engineers__C objEng = new Engineers__C();
        objEng.First_name__c ='ABC';
        objEng.Last_Name__c ='XYZ';
        objEng.Active_Engineer__c =true;
        objEng.Email_Address__c ='xyz@ncr.com';
        objEng.City__c='noWhere';
        objEng.Type_of_Portal_Access__c ='Portal Access';
        objEng.Status__c = 'Created';
        PRM_EngineerController.saveEngineer(objEng);
        System.assertEquals(objEng.Type_of_Portal_Access__c, 'Portal Access','Type of Portal access should  be Portal Access');
        
        PRM_EngineerController.getPicklistValues();
        
        PRM_EngineerController.saveChunk('Test',eng.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = eng.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_EngineerController.saveChunk('Test',eng.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }
    static testmethod void submitProtalAccessRequest()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        System.assertNotEquals(acc.id, null,'Account Should not be null');
        Engineers__C eng = new Engineers__C();
        eng.First_name__c ='ABC';
        eng.Last_Name__c ='XYZ';
        eng.Active_Engineer__c =true;
        eng.Partner_Account__c = acc.id;
        eng.Email_Address__c ='xyz@ncr.com';
        eng.City__c='noWhere';
        eng.Type_of_Portal_Access__c ='Portal Access';
        eng.Status__c = 'Created';
        insert eng;
     
        PRM_EngineerController.submitPortalRequest(eng.id, 'Test', eng);
        
        eng.Status__c = 'Submitted';
        update eng;
        System.assertEquals(eng.Status__c, 'Submitted','Status should be Submitted');
        PRM_EngineerController.submitPortalRequest(eng.id, 'Test', eng);
        
        eng.Status__c = 'Approved';
        update eng;
        PRM_EngineerController.submitPortalRequest(eng.id, 'Test', eng);
        
        eng.Status__c = 'Approved';
        eng.Type_of_Portal_Access__c = 'Diagnostic';
        update eng;
        PRM_EngineerController.submitPortalRequest(eng.id, 'Test', eng);
           
       	List<Attachment__c> engAttList = new List<Attachment__c>();
       	
       	Attachment__c obj = new Attachment__c();
        obj.Engineer_Attachment_Type__c='Diagnostic Worksheet';
        obj.Engineers__c =eng.id;
        engAttList.add(obj);
        
        Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        engAttList.add(obj1);
        
        Attachment__c obj2 = new Attachment__c();
        obj2.Engineer_Attachment_Type__c='NCRU Certificate';
        obj2.Engineers__c =eng.id;
        engAttList.add(obj2);
        
        insert engAttList;
    }
    
  	static testmethod void submitDiagnosticsReqeust()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        System.assertNotEquals(acc.id, null,'Account Should not be null');
        Engineers__C eng = new Engineers__C();
        eng.First_name__c ='ABC';
        eng.Last_Name__c ='XYZ';
        eng.Active_Engineer__c =true;
        eng.Partner_Account__c = acc.id;
        eng.Email_Address__c ='xyz@ncr.com';
        eng.City__c='noWhere';
        eng.Type_of_Portal_Access__c ='Portal Access';
        eng.Status__c = 'Approved';
        insert eng;
     	PRM_EngineerController.submitDiagnosticsApprovalRequest(eng.id, 'Test', eng);
     	List<Attachment__c> engAttList = new List<Attachment__c>();
       	
        Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        engAttList.add(obj1);
        
        insert engAttList;
        
        PRM_EngineerController.submitDiagnosticsApprovalRequest(eng.id, 'Test', eng);
        
        eng.Type_of_Portal_Access__c = 'Submitted';
        update eng;
        PRM_EngineerController.submitDiagnosticsApprovalRequest(eng.id, 'Test', eng);
        
        eng.Type_of_Portal_Access__c = 'Approved';
        update eng;
        System.assertEquals(eng.Type_of_Portal_Access__c, 'Approved','Type of Portal Access should be Approved');
        PRM_EngineerController.submitDiagnosticsApprovalRequest(eng.id, 'Test', eng);
    }
}