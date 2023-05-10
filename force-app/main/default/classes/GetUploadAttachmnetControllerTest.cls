@isTest(SeeAllData = true)
public class GetUploadAttachmnetControllerTest {
    
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
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id,email='r@ncr.com');
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
        Contact cont = [SELECT Id FROM Contact Where Email != null LIMIT 1];
        case c = new case();
        //c.ContactId = cont.id;
        c.Status ='new';
        c.Subject='General';
        c.contactId = cont.id;
        
            insert c;
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.GetHelpUploadAttachment;
          
            VFpage.getParameters().put('id', c.id);
       // pageRef1.setRedirect(true);
            Test.setCurrentPageReference(VFpage);
         GetUploadAttachmentController fruc = new GetUploadAttachmentController();
          //  fruc.selectedtype = 'others';
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
            
            fruc.processUpload();
            fruc.back();
        system.assert(c.id!=null);
    }

    }