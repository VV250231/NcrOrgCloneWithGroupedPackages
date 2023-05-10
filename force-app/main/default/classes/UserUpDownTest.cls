/*  covers the following class:-
* UserUpExtension
* UserDownExtension
* APOCReassignmentBatch	
*/
@isTest
private class UserUpDownTest {
    @TestSetUp
    public static void unitTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];  
        User userObj = new User(Alias = 'commuser', Email='testkk@testorg.com', quicklook_Id__c = 'zz123456',
                                EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='stand5555@testorg.com');
        insert userObj;
        Map<Id, ASM_Role_Hierarchy__c> oldMap = new Map<Id, ASM_Role_Hierarchy__c>();
        // Account accObj = new Account(Name = 'Test', Master_Customer_Number__c = '13308');
        //insert accObj;''
        User Usr = [Select Id from User Where Name = 'Soup User'];
        Contact con;
        Contact con1;
        Account acc;
        System.runAs(Usr){
            acc=TestRecordsFactory.createAccount('abc');
            System.debug('acc 1 '+acc);
            con = new Contact(Firstname='test10',lastname='test',AccountId=acc.id,email='standarduser@testorg.com');
            insert con;
            con1 = new Contact(Firstname='test12',lastname='test0',AccountId=acc.id,email='standarduser1@testorg.com');
            insert con1;
            List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
            bpmConfList.add(new BPM_Configuration__c(Name='APOCMail',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCBCC',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
            bpmConfList.add(new BPM_Configuration__c(Name='BPM Email - added into QLID',values__C='@ncr.com.invalid'));
            bpmConfList.add(new BPM_Configuration__c(Name='BPMProfile',values__C='BPM Partner Community User'));
            
            insert bpmConfList;
            List<NCR_Employee_Detail__c> ncrlist = new List<NCR_Employee_Detail__c>();
            
            NCR_Employee_Detail__c n = new NCR_Employee_Detail__c(Name='User1',Quicklook_ID__c='ab123456',Global_ID__c='1000',Contingent_Manager__c='1001',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n);
            NCR_Employee_Detail__c n1 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='aa123456',Global_ID__c='1001',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n1);
            NCR_Employee_Detail__c n2 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='zz123456',Global_ID__c='1002',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n2);
            NCR_Employee_Detail__c n3 = new NCR_Employee_Detail__c(Name='User3',Quicklook_ID__c='ac123456',Global_ID__c='1003',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n3);
            insert ncrlist;
            //acc.Active_Account__c = true;
            //update acc;
            ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='zz123456',Role_Name__c = 'PO/Billing Person');
            Insert obj;
            ASM_Role_Hierarchy__c obj1 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ac123456',Role_Name__c = 'Customer Advocate');
            Insert obj1;
            APOCReassignmentBatch sh1 = new APOCReassignmentBatch();
            Database.executeBatch(sh1);
            List<UpDownGrade__c> upList = new List<UpDownGrade__c>();
            upList.add(new UpDownGrade__c(Name='UpProfiles',value__c='BPM Partner Community User'));
            upList.add(new UpDownGrade__c(Name='UpErrMsgStd',value__c='you cannot upgrade this user.'));//you cannot upgrade this user.
            upList.add(new UpDownGrade__c(Name='UserLink',value__c='/{0}{1}'));
            upList.add(new UpDownGrade__c(Name='DwnErrMsg',value__c='This user is already downgraded.'));
            upList.add(new UpDownGrade__c(Name='DwnErrMsgStd',value__c='You cannot downgrade the salesforce community license'));
            upList.add(new UpDownGrade__c(Name='PrtnrAccId',value__c=acc.id));
            upList.add(new UpDownGrade__c(Name='UsrNotFndMsg',value__c='Process completed but unable to validate the user'));
            insert upList;
            insert new BPM_Configuration__c(Name='CAHierarchyJobReciever',Values__c='test@test.com');
        }
        Profile p1 = [SELECT Id FROM Profile WHERE Name='BPM Partner Community User'];
        User u = new User(Alias = 'standt', Email='testss@testorg.com', quicklook_Id__c = 'xx123456',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/Los_Angeles', ManagerId = userObj.id, UserName='stand101010@testorg.com',ContactId=con.Id);
        System.runAs(Usr){
            insert u; 
        }
        
        User u1 = new User(Alias = 'standt', Email='testss@testorg.com', quicklook_Id__c = 'ac123456',
                           EmailEncodingKey='UTF-8', LastName='Testing0', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id, 
                           TimeZoneSidKey='America/Los_Angeles', ManagerId = userObj.id, UserName='ac123456test@testorg.com',ContactId=con1.Id);
        System.runAs(Usr){
            insert u1; 
        }
        System.debug('u !!'+u.id);
        System.debug('userObj !!'+userObj.id);
        System.assertNotEquals(userObj.id, u.id);
        
    }
    static testMethod void upgradetest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r = [Select id from UserRole where name='SFDC Admin'];
        
        User u =[Select id from user where quicklook_Id__c = 'zz123456'];  
        UserUpExtension ud = new UserUpExtension(new ApexPages.StandardController(u));
        ud.upgrade();
        User u1 =[Select id from user where quicklook_Id__c = 'xx123456'];
        UserUpExtension ud1 = new UserUpExtension(new ApexPages.StandardController(u1));
        ud1.upgrade();
        ud1.getStndrdPrfl();
        ud1.getselectedrole();
        ud1.slctdPrf = p.id;
        ud1.slctdRole = r.id;
        ud1.save();
        Test.startTest();
        ud1.createUsr();
        Test.stoptest();
        ud1.cancel();
        System.assertEquals(ud1.slctdPrf, p.id);
    }
    static testMethod void upgradetest1() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r = [Select id from UserRole where name='SFDC Admin'];
        User u1 =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email,User_Profile__c from user where quicklook_Id__c = 'xx123456'];
        UserUpExtension ud1 = new UserUpExtension(new ApexPages.StandardController(u1));
        ud1.slctdPrf = p.id;
        ud1.slctdRole = r.id;
        ud1.qlid='test01';
        ud1.lname='test';
        ud1.uname='testfinal@test.com';
        ud1.usr=u1;
        ud1.createUsr();
        System.assertEquals(ud1.slctdPrf, p.id);
    }
    static testMethod void upgradetest2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r = [Select id from UserRole where name='SFDC Admin'];
        User userObj = new User(Alias = 'commuser', Email='standarduser1@testorg.com', quicklook_Id__c = 'xx1234xx',
                                EmailEncodingKey='UTF-8', LastName='Testing0', Firstname='test0', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='stand0000@testorg.com');
        insert userObj;
        User u1 =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email,User_Profile__c from user where quicklook_Id__c = 'xx123456'];
        UserUpExtension ud1 = new UserUpExtension(new ApexPages.StandardController(u1));
        ud1.slctdPrf = p.id;
        ud1.slctdRole = r.id;
        ud1.qlid='xx1234';
        ud1.lname='test';
        ud1.uname='test1111@test.com';
        ud1.usr=u1;
        ud1.createUsr();
        System.assertEquals(ud1.slctdPrf, p.id);
    }
    static testMethod void downgradetest() {
        User u =[Select id,quicklook_Id__c from user where quicklook_Id__c = 'xx123456'];  
        UserDownExtension ud = new UserDownExtension(new ApexPages.StandardController(u));
        ud.downgrade();
        User u1 =[Select id,quicklook_Id__c from user where quicklook_Id__c = 'xx123456'];
        UserDownExtension ud1 = new UserDownExtension(new ApexPages.StandardController(u1));
        ud1.downgrade();
        ud1.save();
        Test.startTest();
        ud1.createCon();
        ud1.getUsr();
        Test.stoptest();
        ud1.cancel();
        System.assertEquals(u1.quicklook_Id__c, 'xx123456');
    }
    static testMethod void downgradetest1() {
        User u1 =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email,User_Profile__c from user where quicklook_Id__c = 'zz123456'];
        UserDownExtension ud1 = new UserDownExtension(new ApexPages.StandardController(u1));
        ud1.qlid='zz1234';
        ud1.lname='test';
        ud1.uname='test2222@test.com';
        ud1.usr=u1;
        ud1.isAPOCUsr = true;
        ud1.createCon();
        ud1.getUsr();
    }
    static testMethod void downgradetest2() {
        User u1 =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email,User_Profile__c from user where quicklook_Id__c = 'zz123456'];
        UserDownExtension ud1 = new UserDownExtension(new ApexPages.StandardController(u1));
        ud1.qlid='zz123456';
        ud1.lname='test';
        ud1.uname='test3333@test.com';
        ud1.usr=u1;
        ud1.isAPOCUsr = true;
        ud1.getUsr();
    }
    static testMethod void downgradetest3() {
        User u1 =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email,User_Profile__c from user where quicklook_Id__c = 'xx123456'];
        UserDownExtension ud1 = new UserDownExtension(new ApexPages.StandardController(u1));
        ud1.qlid='xx1234';
        ud1.lname='test';
        ud1.uname='test4444@test.com';
        ud1.usr=u1;
        ud1.isAPOCUsr = true;
        ud1.createCon();
    }
    static testMethod void apocBatchTest() {
        Test.StartTest();
        APOCReassignmentBatch sh1 = new APOCReassignmentBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('test', sch, sh1); 
        Test.stopTest(); 
    }
    static testMethod void apocBatchTest1() {
        User us =[Select id,quicklook_id__c from User where quicklook_id__c='ac123456'];
        ASM_Role_Hierarchy__c obj1 =[Select id,Role_User_Qlook_Id__c,QuickLook_ID__c,Role_User_Name__c from ASM_Role_Hierarchy__c where QuickLook_ID__c='ac123456'];
        System.assert(obj1.Role_User_Qlook_Id__c ==obj1.QuickLook_ID__c);
        System.assert(obj1.Role_User_Name__c!=null);
        Test.StartTest();
        us.quicklook_id__c ='ad123456';
        update us;
        Database.executeBatch(new APOCReassignmentBatch(us.id));
        //System.assert(obj1.Role_User_Qlook_Id__c ==obj1.QuickLook_ID__c);
        Test.stopTest(); 
    }
    
}