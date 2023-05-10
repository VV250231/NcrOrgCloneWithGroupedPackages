@isTest
public class APOC_MassUpdateAllRolesHandlerTest {
    @TestSetUp
    public static void unitTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Profile p1 = [SELECT Id FROM Profile WHERE Name='90 Chatter Free'];  
        
        User userObj = new User(Alias = 'commuser', Email='standarduser1@testorg.com', quicklook_Id__c = 'ab123456',
                                EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='stand11122@testorg.com');
        insert userObj;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', quicklook_Id__c = 'aa123456',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/Los_Angeles', Manager = userObj, UserName='stand11111@testorg.com',Manager_Level_01_ID__c='1001');
        insert u;
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', quicklook_Id__c = 'ad123456',
                           EmailEncodingKey='UTF-8', LastName='Testing30', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id, 
                           TimeZoneSidKey='America/Los_Angeles', Manager = userObj, UserName='Testing30@testorg.com',Manager_Level_01_ID__c='1001',isactive=false);
        insert u1;
        System.debug('u !!'+u.id);
        System.debug('userObj !!'+userObj.id);
        
        Map<Id, ASM_Role_Hierarchy__c> oldMap = new Map<Id, ASM_Role_Hierarchy__c>();
        // Account accObj = new Account(Name = 'Test', Master_Customer_Number__c = '13308');
        //insert accObj;''
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
            Account acc=TestRecordsFactory.createAccount('abc');
            Account acc1=TestRecordsFactory.createAccount('acctest');
            Contact con = TestRecordsFactory.createContact(acc);
            List<Contact> cl = new List<Contact>{new Contact(Lastname='testing',Email='apoc@test.com')};
                System.enqueueJob(new  APOC_MassUpdateAllRolesHandler.ConCrtnQueue(cl));
            List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
            bpmConfList.add(new BPM_Configuration__c(Name='APOCMail',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCBCC',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
            bpmConfList.add(new BPM_Configuration__c(Name='BPM Email - added into QLID',values__C='@ncr.com.invalid'));
            bpmConfList.add(new BPM_Configuration__c(Name='BPMProfile',values__C='BPM Partner Community User'));
            //  bpmConfList.add(new BPM_Configuration__c(Name='excProfileId',values__C='00e70000001NyoaAAC'));
            bpmConfList.add(new BPM_Configuration__c(Name='excProfileId',values__C=NSCCommonInfoUtil.getIdOf('iPaas_Administration_Profile_Id')));
            bpmConfList.add(new BPM_Configuration__c(Name='BPMDefaultPOQLID',values__C='ob230024'));
            
            insert bpmConfList;
       
            List<NCR_Employee_Detail__c> ncrlist = new List<NCR_Employee_Detail__c>();
            
            NCR_Employee_Detail__c n = new NCR_Employee_Detail__c(Name='User1',Quicklook_ID__c='ab123456',Global_ID__c='1000',Contingent_Manager__c='1001',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n);
            NCR_Employee_Detail__c n1 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='aa123456',Global_ID__c='1001',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n1);
            NCR_Employee_Detail__c n2 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='nb250250',Global_ID__c=u.Manager_Level_01_ID__c,Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n2);
            NCR_Employee_Detail__c n3 = new NCR_Employee_Detail__c(Name='User3',Quicklook_ID__c='ac123456',Global_ID__c=u.Manager_Level_01_ID__c,Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n3);
            NCR_Employee_Detail__c n4 = new NCR_Employee_Detail__c(Name='User3',Quicklook_ID__c='ad123456',Global_ID__c=u.Manager_Level_01_ID__c,Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n4);
            insert ncrlist;
            system.assert(n.id!=null);
            System.debug('acc 1 '+acc);
            //acc.Active_Account__c = true;
            //update acc;
            ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ab123456',Role_Name__c = 'PO/Billing Person');
            Insert obj;
            ASM_Role_Hierarchy__c obj2 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'Account Support Manager');
            Insert obj2;    
            ASM_Role_Hierarchy__c obj3 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='nb250250',Role_Name__c = 'Account Support Manager');
            Insert obj3; 
            ASM_Role_Hierarchy__c obj4 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'Customer Advocate');
            Insert obj4; 
            system.assert(obj.id!=null);
            
        }
    }
    
    @isTest
    static void Test1(){
        account acc = [select id,name,Active_Account__c,Master_Customer_Number__c from Account limit 1];
       
        System.debug('acc '+acc);
        Test.startTest();
        
        ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ab123456',Role_Name__c = 'Account Support Manager');
        APOC_MassUpdateAllRolesHandler.isInsertFromUI = true; 
        Insert obj;
        system.assertEquals(obj.QuickLook_ID__c,'ab123456');
        Test.stopTest();
    }
    @isTest
    static void Test2(){
        Test.startTest();
        user u = [select id,quicklook_Id__c from User where quicklook_Id__c = 'ab123456' limit 1 ];
        ASM_Role_Hierarchy__c obj2 = [select id,action__c,QuickLook_ID__c,Role_User_Name__c,Role_Name__c from ASM_Role_Hierarchy__c  where Role_Name__c = 'Account Support Manager' limit 1];
       
        System.debug('this is obj2 before '+obj2);
        //obj2.Action__c = 'Overwrite';
        obj2.QuickLook_ID__c='ab123456';
        obj2.Role_User_Name__c = u.id;
        update obj2;
        system.assertEquals(obj2.QuickLook_ID__c,'ab123456');
        Test.stopTest();
        
    }
    @isTest
    static void Test4(){
        Test.startTest();
        user u = [select id,quicklook_Id__c from User where quicklook_Id__c = 'ab123456' limit 1 ];
       
        ASM_Role_Hierarchy__c obj2 = [select id,action__c,QuickLook_ID__c,Role_User_Name__c,Role_Name__c from ASM_Role_Hierarchy__c  where Role_Name__c = 'Account Support Manager' limit 1];
        System.debug('this is obj2 before '+obj2);
        //obj2.Action__c = 'Overwrite';
        obj2.QuickLook_ID__c='ab123456';
        obj2.Role_User_Name__c = u.id;
        obj2.Role_Name__c ='Account Director';
        update obj2;
        system.assertEquals(obj2.QuickLook_ID__c,'ab123456');
        ASM_Role_Hierarchy__c obj3 = [select id,action__c,QuickLook_ID__c,Role_User_Name__c from ASM_Role_Hierarchy__c limit 1];
        System.debug('this is obj2 after '+obj3);
        Test.stopTest();
        
    }
    @isTest
    static void Test3(){
        Test.startTest();
        ASM_Role_Hierarchy__c obj3 = [select id,action__c from ASM_Role_Hierarchy__c limit 1];
        system.assert(obj3.id!=null);
        obj3.Action__c = 'delete';
        delete obj3;
        Test.stopTest();
    }
    @isTest
    static void test5(){
        Test.startTest();
        Account acc =[Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%acctest%'];
        system.assert(acc!=null);
        ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ac123456',Role_Name__c = 'Customer Advocate');
        database.Insert( obj1,false);
         system.assertEquals(obj1.QuickLook_ID__c,'ac123456');
        Test.stopTest();
    }
    @isTest
    static void test6(){
        Test.startTest();
        ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = 'abc', QuickLook_ID__c='ac123456',Role_Name__c = 'Customer Advocate');
     
        database.Insert( obj1,false);
        system.assertEquals(obj1.QuickLook_ID__c,'ac123456');
        Test.stopTest();
    }
    @isTest
    static void test7(){
        Test.startTest();
        Account acc =[Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%acctest%'];
        system.assert(acc!=null);
        ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='kk123456',Role_Name__c = 'Customer Advocate');
        database.Insert( obj1,false);
        system.assertEquals(obj1.Master__c,acc.Master_Customer_Number__c);
        Test.stopTest();
    }
    @isTest
    static void test8(){
        Test.startTest();
        Account acc =[Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%acctest%'];
        ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c,Role_Name__c = 'Customer Advocate');
        database.Insert( obj1,false);
        ASM_Role_Hierarchy__c obj2 = new ASM_Role_Hierarchy__c(Role_Name__c = 'Customer Advocate');
        database.Insert( obj2,false);
        ASM_Role_Hierarchy__c obj4 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ac123456',Role_Name__c = 'PO/Billing Person',action__c='Overwrite');
        Insert obj4; 
        system.assert(acc!=null);
        Test.stopTest();
    }
    @isTest
    static void test9(){
        Test.startTest();
        Account acc =[Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%acctest%'];
        NCR_Employee_Detail__c nc =[Select id from NCR_Employee_Detail__c where quicklook_id__C='ac123456'];
       
        ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ad123456',Role_Name__c = 'PO/Billing Person');
        database.Insert( obj1,false);
        ASM_Role_Hierarchy__c obj2 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ad123456',Role_Name__c = 'Customer Advocate');
        database.Insert( obj2,false);
        obj1.NCR_Employee_Detail__c = nc.id;
        update obj1;
        ASM_Role_Hierarchy__c obj3 = [select id,action__c,QuickLook_ID__c,Role_User_Name__c,Role_Name__c,NCR_Employee_Detail__c from ASM_Role_Hierarchy__c  where Role_Name__c = 'Customer Advocate' limit 1];
        obj3.NCR_Employee_Detail__c = nc.id;
        update obj3;
        ASM_Role_Hierarchy__c obj4 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ac123456',Role_Name__c = 'PO/Billing Person',Action__c='Delete');
        database.Insert(obj4,false);
    
         system.assertEquals(obj4.Master__c,acc.Master_Customer_Number__c);
        Test.stopTest();
    }
    @isTest
    static void Test10(){
        Test.startTest();
        user u = [select id,quicklook_Id__c from User where quicklook_Id__c = 'ab123456' limit 1 ];
        
        ASM_Role_Hierarchy__c obj2 = [select id,action__c,QuickLook_ID__c,Role_User_Name__c,Role_Name__c from ASM_Role_Hierarchy__c  where Role_Name__c = 'Customer Advocate' limit 1];
        System.debug('this is obj2 before '+obj2);
        //obj2.Action__c = 'Overwrite';
        obj2.QuickLook_ID__c='ab123456';
        obj2.Role_User_Name__c = u.id;
        update obj2;
        system.assertEquals(obj2.QuickLook_ID__c,'ab123456');
        Test.stopTest();
         
    }
    @isTest
    static void Test11(){
        Test.startTest();
        User Usr = [Select Id from User Where Name = 'iPaas Administrator'];
        System.runAs(Usr){               
            Account acc =[Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%acctest%'];
            
            ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ac123456',Role_Name__c = 'Customer Advocate');
            database.Insert( obj1,false);
            system.assertEquals(obj1.Master__c,acc.Master_Customer_Number__c);
        }         
        Test.stopTest();
    }
}