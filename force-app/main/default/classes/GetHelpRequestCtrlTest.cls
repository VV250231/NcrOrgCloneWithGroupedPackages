@isTest(seeAllData = true)
public class GetHelpRequestCtrlTest {

 
  
   private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        insert accounts;

    }

  /*  private static void createMetadata(){
        Get_help_Configuration__mdt  m = new   Get_help_Configuration__mdt();
     
       
        m.Case_Assigned_User_Name__c='rg250274@ncr.com';
       m.Email_Send_List__c ='r@ncr.com,s@ncr.com';
        insert m;
        
    } */
    private static User createUserandpartnerContact(){
        //createAcc();
        Account ac = [SELECT Id FROM Account LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        Profile p = [select Name from Profile WHERE name ='Partner Community User'];     
               
       List<USER> userList = [Select id , name from USER Where ProfileId =:p.id And isActive =true];
       return userList[0];
     
    }

    static testmethod  void testsubmit() {
    //    createMetadata();
      PageReference pageRef = Page.GetHelpRequest;
        ApexPages.currentPage().getParameters().put('prevId','');
      Case cas = new Case();
            ApexPages.StandardController dealstd= new ApexPages.StandardController(cas);
            GetHelpRequestCtrl controller = new GetHelpRequestCtrl(dealstd);
        	system.assert(controller!=null);
        	controller.getcases();
        	controller.subject='General';
            controller.submit();
    }
    static testmethod  void testSave() {
    //    createMetadata();
      PageReference pageRef = Page.GetHelpRequest;
        ApexPages.currentPage().getParameters().put('prevId','');
      Case cas = new Case();
            ApexPages.StandardController dealstd= new ApexPages.StandardController(cas);
            GetHelpRequestCtrl controller = new GetHelpRequestCtrl(dealstd);
        	system.assert(controller!=null);
        	controller.getcases();
        	controller.subject='General';
            controller.saveAndNew();
    }
    
    static testMethod  void getHelpController(){
        GetHelpController g = new GetHelpController();
        system.assert(g!=null);
        g.redirectToCase();
    }
    
    static testmethod void testTriggerCloseCase(){
        Account a = TestRecordsFactory.createAccount();
        //Account accounts = new Account(Name = 'Unit Test Corp');
        //insert accounts;
        Contact cont = new Contact(LastName ='testCon',AccountId = a.Id,email ='r@ncr.com');
        insert cont;  
        Case c = new case();
        c.contactId = cont.id;
        c.subject='MDF';
        c.category__c ='MDF';
        c.status ='new';
        c.Origin='IPT SSOT';
        c.RecordTypeId = getRecordType('IPT Partner');
        insert c;
        c.status = 'close';
        update c;
     }
    
    static testmethod void testCaseComment(){
        Account a = TestRecordsFactory.createAccount();
        //Account accounts = new Account(Name = 'Unit Test Corp');
       // insert accounts;
        Contact cont = new Contact(LastName ='testCon',AccountId = a.Id,email ='r@ncr.com');
        system.assert(cont.AccountId!=NUll);
        insert cont;  
        Case c = new case();
        c.contactId = cont.id;
        c.subject='MDF';
        c.category__c ='MDF';
        c.status ='new';
        c.Origin='IPT SSOS';
        c.RecordTypeId = getRecordType('IPT Partner');
        system.debug('c.RecordTypeId' +  c.RecordTypeId);
        insert c;
        casecomment cm = new caseComment();
        cm.CommentBody = 'test';
        cm.ParentId = c.id;
        insert cm;
     }
    
    static testmethod void testSendEmail(){
        List<Case> caseList = new List<Case>();
        Account a = TestRecordsFactory.createAccount();
        //Account accounts = new Account(Name = 'Unit Test Corp');
        //insert accounts;
        Contact cont = new Contact(LastName ='testCon',AccountId = a.Id,email ='r@ncr.com');
        system.assert(cont.AccountId!=NUll);
        insert cont;  
        Case c = new case();
        c.contactId = cont.id;
        c.subject='MDF';
        c.category__c ='MDF';
        c.status ='new';
        c.Origin='IPT SSOS';
        c.RecordTypeId = getRecordType('IPT Partner');
        system.debug('c.RecordTypeId' +  c.RecordTypeId);
        caseList.add(c);
        insert caseList;
       // sendCaseEmail send = new sendCaseEmail();
        sendCaseEmail.getAccountNames(caseList);
     }
    private static Id getRecordType(String name){
		 Map<String,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
		 return  rt_Map.get(name).getRecordTypeId();
	}
}