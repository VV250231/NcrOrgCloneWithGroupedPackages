@isTest
public class ApprovalClassLtngConTest {
  
    static
    {
        System.runAs(TestRecordsFactory.getUser()) {
            createAcc(); 
        } 
    }
    
    private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp',partner_type__c='Distributor'));
        accounts.add(new Account(Name = 'Unit Test LLC',partner_type__c='Distributor'));
        accounts.add(new Account(Name = 'Parent Company Inc',partner_type__c='Distributor'));
        insert accounts;
   }
    
    private static void createContact(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id);
        insert con;
    }    
        
    private static User createUserandpartnerContact(){
        Profile p = [select Name from Profile WHERE Name like 'IPT Partner Community Login User'];     
        List<USER> userList = [Select id , name from USER Where ProfileId =:p.id And isActive =true];
        return userList[0];
    }
    
    static testmethod void submitProtalAccessRequest()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        
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
        
        ApprovalClassLtngCon.submitPortalRequest(eng.id, 'Test');       
        
        eng.Status__c = 'Submitted';
        update eng;
        ApprovalClassLtngCon.submitPortalRequest(eng.id, 'Test');      
        ApprovalClassLtngCon.approvalSubmission(eng.id, UserInfo.getUserId(), 'Test');
        
        eng.Status__c = 'Approved';
        update eng;
        ApprovalClassLtngCon.submitPortalRequest(eng.id, 'Test');
        
        
        eng.Status__c = 'Approved';
        eng.Type_of_Portal_Access__c = 'Diagnostic';
        update eng;
        ApprovalClassLtngCon.submitPortalRequest(eng.id, 'Test');
       
           
        List<Attachment__c> engAttList = new List<Attachment__c>();
        
        Attachment__c obj = new Attachment__c();
        obj.Engineer_Attachment_Type__c='Diagnostic Worksheet';
        obj.Engineers__c =eng.id;
        engAttList.add(obj);
       
        system.assertEquals(obj.Engineers__c,eng.id);
        
        Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        engAttList.add(obj1);
       
        system.assertEquals(obj1.Engineers__c,eng.id);
        
        Attachment__c obj2 = new Attachment__c();
        obj2.Engineer_Attachment_Type__c='NCRU Certificate';
        obj2.Engineers__c =eng.id;
        engAttList.add(obj2);
        
        system.assertEquals(obj2.Engineers__c,eng.id);
        
        insert engAttList;
        system.assert(obj2.id!=null);
        
        
        
        
    }
    
    static testmethod void submitDiagnosticsReqeust()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        
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
        
        List<Attachment__c> engAttList = new List<Attachment__c>();
        
        Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        engAttList.add(obj1);
        
        insert engAttList;
        system.assert(obj1.id!=null);
        
        ApprovalClassLtngCon.submitDiagnosticsApprovalRequest(eng.id, 'Test');
        eng.Type_of_Portal_Access__c = 'Submitted';
        update eng;
        ApprovalClassLtngCon.submitDiagnosticsApprovalRequest(eng.id, 'Test');
        eng.Type_of_Portal_Access__c = 'Approved';
        eng.Diagnostics_Request_Status__c='Approved';
        update eng;
        ApprovalClassLtngCon.submitDiagnosticsApprovalRequest(eng.id, 'Test');
    }

    
}