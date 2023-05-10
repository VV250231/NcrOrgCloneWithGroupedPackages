/*
##################################################################################################
# Class Name............................:ApprovalClassTest                                                                                                                                
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class ApprovalClassTest {
  
    static{
  		createAcc();  
    }
    private static void createAcc(){
         User u = TestRecordsFactory.getUser();
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp',Partner_Type__c='Distributor'));
        accounts.add(new Account(Name = 'Unit Test LLC',Partner_Type__c='Distributor'));
        accounts.add(new Account(Name = 'Parent Company Inc',Partner_Type__c='Distributor'));
        System.runAs(u){
            insert accounts;
        }
        
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
     
        string result = ApprovalClass.submitforApproval(eng.id, userinfo.getUserId());
        System.assert(result == 'Successfully Submitted for Approval');
        eng.Status__c = 'Submitted';
        update eng;
        ApprovalClass.submitforApproval(eng.id, userinfo.getUserId());
        
        eng.Status__c = 'Approved';
        update eng;
        string result2 = ApprovalClass.submitforApproval(eng.id, userinfo.getUserId());
        System.assert(result2 == 'Portal access has already been approved. You will not be able to re-submit this request for approval.');
        
        eng.Status__c = 'Approved';
        eng.Type_of_Portal_Access__c = 'Diagnostic';
        update eng;
      
        string result3 = ApprovalClass.submitforApproval(eng.id, userinfo.getUserId());
        System.assert(result3 == 'Portal access has already been approved. You will not be able to re-submit this request for approval.');
  
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
        Account acc = [SELECT Id,Partner_Type__c,Recordtype.name FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        system.debug('acc=='+acc.Partner_Type__c);
        system.debug('acc=='+acc.Recordtype.name);
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
        
        string result = ApprovalClass.processDiagnosticsRequest(eng.id, userinfo.getUserId());
        System.assert(result=='Successfully Submitted for Approval');
        eng.Diagnostics_Request_Status__c = 'Submitted';
        update eng;
        string result1 = ApprovalClass.processDiagnosticsRequest(eng.id, userinfo.getUserId());
        System.assert(result1=='Diagnostics Request has already been submitted. You will not be able to re-submit this request for approval.');
        eng.Diagnostics_Request_Status__c = 'Approved';
        update eng;
        string result2 = ApprovalClass.processDiagnosticsRequest(eng.id, userinfo.getUserId());
        System.assert(result2=='Diagnostics Request has already been approved. You will not be able to re-submit this request for approval.');
    }

    static testmethod  void EngineeringTest() {
        Deal_Registration__c deal = new Deal_Registration__c();
        deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
        deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
        deal.Is_this_part_of_an_RFP__c =true;
        insert deal;
        string result = ApprovalClass.submitForApprovalDeal(deal.id,userinfo.getUserId());
        System.assert(result==' cannot be submitted because of glitch in System. Contact IT support');
    }
    
    private static Id getRecordType(String name){
         Map<String,Schema.RecordTypeInfo> rt_Map = Deal_Registration__c.sObjectType.getDescribe().getRecordTypeInfosByName();
         return  rt_Map.get(name).getRecordTypeId();
    }

}