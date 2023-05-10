@isTest
public class AutocreatedRegHandlerTest {
    
    @testSetup static void getCommonData() {
        BPM_User_Provisioning__c customObj = new BPM_User_Provisioning__c();
        customObj.Name = 'Default User Provisioning Account';
        customObj.Master_Customer_Number__c = 'TESTMCN00001X';
        insert customObj;
        
        Account acc= TestRecordsFactory.createAccount();
    }
    
    /* This method is used for testing scenerio where contact and user is not exist and when new user is logging in using SSO. 
Then new contact and user will be created.*/
    @isTest
    public static void TestIfContactDoesNotExit(){
        Test.startTest();
        
        NCR_Employee_Detail__c ncrEmp = new NCR_Employee_Detail__c(User_Name__c = 'test', Quicklook_ID__c = 'test4321');
        insert ncrEmp;
        
        AutocreatedRegHandler1575289304186 obj = new AutocreatedRegHandler1575289304186();
        User userObj = obj.createUser(null, null, null, 'test4321', null, null);
        System.assertEquals('test4321@ncr.com', userObj.Email);
        Test.stopTest();
    }
    
    @isTest
    public static void  TestIfContactExit(){
        Test.startTest();
        
        NCR_Employee_Detail__c ncrEmp = new NCR_Employee_Detail__c(User_Name__c = 'test', Quicklook_ID__c = 'test1234');
        insert ncrEmp;
        Contact con = new Contact(LastName = 'TestCon', Email = 'test1234@ncr.com', IsBPMCommunityUser__c = false);
        insert con;
        
        AutocreatedRegHandler1575289304186 obj = new AutocreatedRegHandler1575289304186();
        User userObj = obj.createUser(null, null, null, 'test1234', null, null);
        System.assertEquals(con.LastName, userObj.lastname);
        Test.stopTest();
    }
    // If user Exist and Contact Exist then grant Community Access if user don't have community permission
    @isTest
    public static void TestIfUserExistContactExit(){
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE Name = '31 GS Sales Support'];
        User u = new User(username = 'test4321@ncr.com.dev', ProfileId = pf.Id, LastName = 'last', Email = 'test000@amamama.com.dev',
                          CompanyName = 'TEST', Title = 'test', Alias = 'test', TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', Quicklook_ID__c = 'test4321'
                         );
        insert u;
        AutocreatedRegHandler1575289304186 obj = new AutocreatedRegHandler1575289304186();
        obj.updateUser(u.Id, null, null, null, 'test4321', null, null);
        System.assertEquals(u.LastName, 'last');
        Test.stopTest();
    }
    // If user Exist and Contact does not Exist
    /*@isTest
    public static void TestIfUserExistContactDoesNotExit(){
        Test.startTest();
        Account acc= [SELECT Id FROM Account];
        
        NCR_Employee_Detail__c ncrEmp = new NCR_Employee_Detail__c(User_Name__c = 'test', Quicklook_ID__c = 'test4321');
        insert ncrEmp;
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = '31 GS Sales Support'];
        User u = new User(username = 'test4321@ncr.com.dev', ProfileId = pf.Id, LastName = 'last', Email = 'test000@amamama.com.dev',
                          CompanyName = 'TEST', Title = 'test', Alias = 'test', TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', Quicklook_ID__c = 'test4321'
                         );
        insert u;
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Contact con = new Contact(LastName = 'TestCon', AccountId = acc.Id, Email = 'test4321@ncr.com', IsBPMCommunityUser__c = false, Quicklook_ID__c = 'test4321');
            insert con;
            
            AutocreatedRegHandler1575289304186 obj = new AutocreatedRegHandler1575289304186();
            obj.updateUser(u.Id, null, null, null, 'test4321', null, null);
            Test.stopTest();
        }
    } */
}