/*
##################################################################################################
# Class Name............................:UploadAttachmentControllerTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class UploadAttachmentControllerTest {
    
    static{
        createAcc();  
        
    }
    private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
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
    
    private static User createUserandpartnerContact(){
        Profile p = [select Name from Profile WHERE name ='Partner Community User'];     
        List<USER> userList = [Select id , name from USER Where ProfileId =:p.id And isActive =true];
        return userList[0];
        
    }
    
    
    
    static testmethod void submitOpptyForApprovalPage()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
         // System.assertNotEquals(acc, null,'Account should not be null');
        Engineers__C eng = new Engineers__C();
        eng.First_name__c ='ABC';
        eng.Last_Name__c ='XYZ';
        eng.Active_Engineer__c =true;
        //eng.Partner_Account__c = acc.id;
        eng.Email_Address__c ='xyz@ncr.com';
        eng.City__c='noWhere';
        insert eng;
        System.assertNotEquals(eng, null,'Engineers__C should not be null');
        Attachment__c obj = new Attachment__c();
        PageReference VFpage = Page.UploadAttachment;
        
        VFpage.getParameters().put('id', eng.id);
        // pageRef1.setRedirect(true);
        Test.setCurrentPageReference(VFpage);
        UploadAttachmentController fruc = new UploadAttachmentController();
        fruc.selectedtype = 'others';
        fruc.fileBody =  Blob.valueOf(' ');
        fruc.fileName ='test.txt';
        
        fruc.processUpload();
        fruc.back();
        
        
    }      
    
    static testmethod void submitOpptyForApprovalPageAcc()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        System.assertNotEquals(acc, null,'Account should not be null');
        Attachment__c obj = new Attachment__c();
        PageReference VFpage = Page.UploadAttachment;
        
        VFpage.getParameters().put('id', acc.id);
        // pageRef1.setRedirect(true);
        Test.setCurrentPageReference(VFpage);
        UploadAttachmentController fruc = new UploadAttachmentController();
        //fruc.Account_Attachment_Type__c ='Business';
        fruc.selectedtype = 'Business Plan';
        fruc.fileBody =  Blob.valueOf(' ');
        fruc.fileName ='test.txt';
        
        fruc.processUpload();
        fruc.back();
        
        
    }   
    
    static testmethod void submitOpptyForApprovalPageAccQuota()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
         System.assertNotEquals(acc, null,'Account should not be null');
        Attachment__c obj = new Attachment__c();
        PageReference VFpage = Page.UploadAttachment;
        
        VFpage.getParameters().put('id', acc.id);
        // pageRef1.setRedirect(true);
        Test.setCurrentPageReference(VFpage);
        UploadAttachmentController fruc = new UploadAttachmentController();
        //fruc.Account_Attachment_Type__c ='Business';
        fruc.selectedtype = 'Quota';
        fruc.fileBody =  Blob.valueOf(' ');
        fruc.fileName ='test.txt';
        
        fruc.processUpload();
        fruc.back();
        
        
    } 
}