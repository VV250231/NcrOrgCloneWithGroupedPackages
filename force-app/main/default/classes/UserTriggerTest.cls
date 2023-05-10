@isTest 
public class UserTriggerTest {
    @testSetUp
    public static void testUserData(){
        Profile pf= [Select Id from profile where Name='04 NSC UI Administrator'];
        List<User> uList = new List<user>();
        User userList = new User();
        userList.LastName = 'Test';
        userList.IsActive = true;
        userList.Email = 'Test@test.com';
        userList.Username = 'Test@test.com' + System.currentTimeMillis();
        //  userList.CompanyName = 'TEST';
        userList.Title = 'title';
        userList.Quicklook_ID__c='tt250288';
        userList.FederationIdentifier ='tt250288';
        // userList.ContactId = '0037000000U47qkAAB';
        userList.Alias = 'alias';
        userList.TimeZoneSidKey = 'America/Los_Angeles';
        userList.EmailEncodingKey = 'UTF-8';
        userList.LanguageLocaleKey = 'en_US';
        userList.LocaleSidKey = 'en_US';
        userList.ProfileId = pf.id;
        //userList.Incentive_Plan__c='SCP';
        userList.IsActive = true;
        userList.Manager_Global_ID__c='1234';
        userList.Job_Code__c='test';
        userList.Global_ID__c='1234';
        userList.Sales_Org_Code__c='123Test';
        userList.ICM_User__c = true;
        userList.Job_Role_Start_Date__c =System.today()-1;
        userList.Country_Code__c ='US';
        uList.add(userList);
        // userList.Incentive_Plan__c='SCP';
        Profile pf0= [Select Id from profile where Name='System Administrator'];
        User userList0 = new User();
        userList0.LastName = 'Test0';
        userList0.IsActive = true;
        userList0.Email = 'Test0@test.com';
        userList0.Username = 'Test0@test.com' + System.currentTimeMillis();
        //  userList.CompanyName = 'TEST';
        userList0.Title = 'title';
        userList0.Quicklook_ID__c='tt250280';
        userList0.FederationIdentifier ='tt250280';
        // userList.ContactId = '0037000000U47qkAAB';
        userList0.Alias = 'alias09';
        userList0.TimeZoneSidKey = 'America/Los_Angeles';
        userList0.EmailEncodingKey = 'UTF-8';
        userList0.LanguageLocaleKey = 'en_US';
        userList0.LocaleSidKey = 'en_US';
        userList0.ProfileId = pf0.id;
        //userList.Incentive_Plan__c='SCP';
        userList0.IsActive = true;
        userList0.Manager_Global_ID__c='1234';
        userList0.Job_Code__c='test';
        userList0.Global_ID__c='1234';
        userList0.Sales_Org_Code__c='123Test';
        userList0.ICM_User__c = true;
        uList.add(userList0);
        insert uList;
        system.assert(uList.size()>0);
        userList.ICM_User__c = false;
        update userList;
        
        List<lead> leadList = new List<lead>();
        leadList.add(new Lead(LastName='Test', OwnerId=uList[0].id,Company='Test',Industry__c='Test',Country__c='Test',LeadType__c='Test',LeadSource__c='Test',LeadSource='test',Status='Test',Lead_Stage__c='Test'));
        insert leadList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(LastName='Test', OwnerId=uList[0].id));        
        insert contactList;
        User__c cs = new User__c();
        cs.Email_Address__c='test@test.com';
        cs.Name ='Test';
        //cs.Other fiels values
        insert cs;
        NCR_Employee_Detail__c n =  new NCR_Employee_Detail__c();
        n.Name ='Test';
        n.Manager_Global_ID__c ='1234';
        n.InActive__c =false;
        insert n;
        sales_org__c s = new sales_org__c();
        s.sales_org_code__c ='123Test';
        s.Name='Test';
        insert s;
        
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C='vp250252@ncr.com'));       
        insert bpmConfList;
    }
    
    @isTest
    public static void updateTestData(){
        User u =[Select id,IsActive,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250288'];
        System.assertNotEquals(u.Id, null);
        u.Quicklook_ID__c =null;
        u.FederationIdentifier ='tt250288';
        Test.startTest();
        update u;
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateTestData2(){
        User u =[Select id,IsActive,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250288'];
        u.IsActive = true;
        u.Quicklook_ID__c =null;
        u.FederationIdentifier =null;
        u.ProfileId = [select id from profile where name ='90 Chatter Free'].id;
        Account acc=TestRecordsFactory.createAccount('abc');
        Contact con = TestRecordsFactory.createContact(acc);
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
        insert bpmConfList;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Test.startTest();
            try{
                update u;  
            }
            catch(exception e){
                System.assertNotEquals(e.getMessage(), null);
            }
            Test.stopTest();
        }
    }
    @isTest
    public static void updateTestData3(){
        User u =[Select id,IsActive,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250288'];
        System.assertNotEquals(u.Id, null);
        u.ProfileId = [select id from profile where name ='90 Chatter Free'].id;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Test.startTest();
            update u;  
            Test.stopTest();
        }
    }
    @isTest
    public static void testUserCreationAutomation(){
        Profile pf= [Select Id from profile where Name='04 NSC UI Administrator'];
        System.assertNotEquals(pf.Id, null);
        User userList1 = new User();
        userList1.LastName = 'Test1';
        userList1.IsActive = true;
        userList1.Email = 'Test1@test.com';
        userList1.Username = 'Test1@test.com' + System.currentTimeMillis();
        //  userList.CompanyName = 'TEST';
        userList1.Title = 'title';
        userList1.Quicklook_ID__c='tt250188';
        userList1.FederationIdentifier ='tt250188';
        // userList.ContactId = '0037000000U47qkAAB';
        userList1.Alias = 'alias1';
        userList1.TimeZoneSidKey = 'America/Los_Angeles';
        userList1.EmailEncodingKey = 'UTF-8';
        userList1.LanguageLocaleKey = 'en_US';
        userList1.LocaleSidKey = 'en_US';
        userList1.ProfileId = pf.id;
        //userList.Incentive_Plan__c='SCP';
        userList1.IsActive = true;
        userList1.Manager_Global_ID__c='1234';
        userList1.Job_Code__c='test';
        userList1.Global_ID__c='1234';
        userList1.Sales_Org_Code__c='123Test';
        userList1.ICM_User__c = true;
        insert userList1;
        
        Profile pf0= [Select Id from profile where Name='90 Chatter Free'];
        User userList2 = new User();
        userList2.LastName = 'Test2';
        userList2.IsActive = true;
        userList2.Email = 'Test2@test.com';
        userList2.Username = 'Test2@test.com' + System.currentTimeMillis();
        //  userList.CompanyName = 'TEST';
        userList2.Title = 'title';
        userList2.Quicklook_ID__c='tt252188';
        userList2.FederationIdentifier ='tt252188';
        // userList.ContactId = '0037000000U47qkAAB';
        userList2.Alias = 'alias2';
        userList2.TimeZoneSidKey = 'America/Los_Angeles';
        userList2.EmailEncodingKey = 'UTF-8';
        userList2.LanguageLocaleKey = 'en_US';
        userList2.LocaleSidKey = 'en_US';
        userList2.ProfileId = pf0.id;
        //userList.Incentive_Plan__c='SCP';
        userList2.IsActive = true;
        userList2.Manager_Global_ID__c='1234';
        userList2.Job_Code__c='test';
        userList2.Global_ID__c='1234';
        userList2.Sales_Org_Code__c='123Test';
        userList2.ICM_User__c = true;
        insert userList2;
    }
    
    @isTest
    public static void deleteMembersUnitTest(){
        Profile pf= [Select Id from profile where Name='02 NSC Administrator'];
        User u =[Select id,IsActive,Job_Role_Start_Date__c,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250288'];
        User u1 =[Select id,IsActive,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250280'];
        Test.startTest();
        // System.runAs(TestRecordsFactory.getUser()){
        u.IsActive = false;
        u.ProfileId =pf.id;
        u.Incentive_Plan__c ='SCP';
        u.Job_Role_Start_Date__c = System.today();
        Account acc=TestRecordsFactory.createAccount('abc');
        Contact con = TestRecordsFactory.createContact(acc);
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
        insert bpmConfList;
        Job_Role_Mapping__c jR = new Job_Role_Mapping__c(Name='test');
        insert jR;
        system.assertEquals(jR.Name, 'test');
        System.runAs(new User(Id=u1.Id)) {
            update u;
            u.Incentive_Plan__c ='';
            update u;
            u.Incentive_Plan__c ='SCP';
            u.IsActive =true;
            update u;
            u.IsActive =false;
            u.Country_Code__c='';
            update u;
        }
 
        Test.stopTest();
    }
    
    @isTest
    public static void testPartnerUserDatawithCpq()
        
    {
        
        //contact cn = [select id from contact where id = '0030g000028C1tyAAC'];
        Account a =  TestRecordsFactory.createAccount('1234321','HOSPITALITY:TSR','NAMER SMB');
        Account ra =  TestRecordsFactory.createAccount('123432111','HOSPITALITY:TSR','NAMER SMB');
        Account site =  TestRecordsFactory.createAccount('site1',ra.Id);
        
        List<Contact> cl=new List<Contact>();
        Contact cn0 =  TestRecordsFactory.createContact(a);
        Contact cn1 =  TestRecordsFactory.createContact(a);
        Contact cn2 =  TestRecordsFactory.createContact(a);
        cl.add(cn0);
        cl.add(cn1);
        cl.add(cn2);
        cdm_Account_Relationship__c c = new cdm_Account_Relationship__c(Account__c = a.Id ,Name='End Customer',Relationship_Type__c ='End Customer - Partner',Related_Account__c=ra.Id);
        insert c;
        Profile pf= [Select Id from profile where Name='Hospitality SMB Partner Manager'];
        List<User> uList = new List<user>();
        system.assertNotEquals(pf.id, null);
        
        List<User> uListupdate = new List<user>();
        for(Integer i=0;i<3;i++){
            User userList = new User();
            userList.LastName = 'Test1'+i;
            userList.IsActive = true;
            userList.Email = 'Test@test1'+i+'.com';
            userList.Username = 'Test@test1.com' +i+ System.currentTimeMillis();
            //  userList.CompanyName = 'TEST';
            userList.Title = 'title';
            userList.Quicklook_ID__c='tt25028'+i;
            userList.FederationIdentifier ='tt25028'+i;
            // userList.ContactId = '0037000000U47qkAAB';
            userList.Alias = 'alias';
            userList.TimeZoneSidKey = 'America/Los_Angeles';
            userList.EmailEncodingKey = 'UTF-8';
            userList.LanguageLocaleKey = 'en_US';
            userList.LocaleSidKey = 'en_US';
            userList.ProfileId = pf.id;
            //userList.Incentive_Plan__c='SCP';
            userList.IsActive = true;
            userList.Manager_Global_ID__c='1234';
            userList.Job_Code__c='test';
            userList.Global_ID__c='1234';
            userList.Sales_Org_Code__c='123Test';
            userList.ContactId = cl[i].id;
            userList.Partner_Owned_Accounts__c=ra.Master_Customer_Number__c;
            userList.CPQ_Pilot__c =  True;  
            uList.add(userList);
        }
        uList[1].Partner_Owned_Accounts__c='1234321';
        uList[2].Partner_Owned_Accounts__c='x';    
        try{
            insert uList;  
        }catch(Exception e){
            System.debug('Error '+e.getMessage());
        }
        
    }
    
    @isTest
    public static void testListOfInactiveUserinFtr(){
        User u =[Select id,IsActive,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250288'];
        system.assertNotEquals(u.Id,null);
        u.IsActive = false;
        Account acc=TestRecordsFactory.createAccount('abc');
        Account acc1=TestRecordsFactory.createAccount('acctest');
        Contact con = TestRecordsFactory.createContact(acc);
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
        insert bpmConfList;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Test.startTest();
            update u;
            Test.stopTest();
        }
    }
    @isTest
    public static void testInsertUsersInAccountTeam(){
        User u =[Select id,IsActive,UserType,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where Quicklook_ID__c='tt250288'];
        system.assertNotEquals(u.Id,null);
        User u2 = TestRecordsFactory.getUser();
        Account ra =  TestRecordsFactory.createAccount('123432111','HOSPITALITY:TSR','NAMER SMB');
        System.runAs(u2){
        ra.CDM_Account_Type__c ='END CUSTOMER';
        update ra;
        }
       
        Account acc =  TestRecordsFactory.createAccount('1234320','HOSPITALITY:TSR','NAMER SMB');
        Contact con = TestRecordsFactory.createContact(acc);
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
        insert bpmConfList;
        cdm_Account_Relationship__c c = new cdm_Account_Relationship__c(Account__c = acc.Id ,Name='End Customer',Relationship_Type__c ='End Customer - Partner',Related_Account__c=ra.Id);
        insert c;
        Profile pf0= [Select Id from profile where Name='Hospitality SMB Partner Manager'];
        User userList = new User();
        userList.LastName = 'Test18';
        userList.IsActive = true;
        userList.Email = 'Test@test1.com';
        userList.Username = 'Test@test1.com' + System.currentTimeMillis();
        userList.Title = 'title';
        userList.Quicklook_ID__c='tt250281';
        userList.FederationIdentifier ='tt250281';
        userList.Alias = 'alias';
        userList.TimeZoneSidKey = 'America/Los_Angeles';
        userList.EmailEncodingKey = 'UTF-8';
        userList.LanguageLocaleKey = 'en_US';
        userList.LocaleSidKey = 'en_US';
        userList.ProfileId = pf0.id;
        userList.IsActive = true;
        userList.Manager_Global_ID__c='1234';
        userList.Job_Code__c='test';
        userList.Global_ID__c='1234';
        userList.Sales_Org_Code__c='123Test';
        userList.ContactId = con.id;
        userList.Partner_Owned_Accounts__c=ra.Master_Customer_Number__c;
        userList.CPQ_Pilot__c =  true;  
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Test.startTest();
            insert userList;
            Test.stopTest();
        }
    } 
    
}