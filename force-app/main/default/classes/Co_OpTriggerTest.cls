@isTest
public class Co_OpTriggerTest {
    
    Public Static User getUser()
    {
        
       User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    private static Account createAccount(){
       
        Account act = new Account();
        act.Name = 'Partner Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'RETAIL:CHANNEL';
        act.Account_Region__c = 'EMEA';
        act.Master_Customer_Number__c = '91663446';
        return act;
    }
    
    private static Contact createContact(Id AccountID){
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'test@gmail.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        return con;
        
    }
    
    private static User createUser(Id ContactId){
          //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        User u1 = new User();
        u1.ContactId = contactId;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        return u1;   
    }
    public static testmethod void testPopulateAccountInfo() {

        Account acc = createAccount();
       System.runAs(getUser()){
        insert acc;
        System.assertNotEquals(acc.id, null,'Account is null');
        }        
        Contact con = createContact(acc.id);
        insert con;
        user u = createUser(con.Id);
        insert u;
         
        system.runAs(u) {
            // Insert Co-Op Request
            Co_Op__c coOpReq = new Co_Op__c();
            coOpReq.Activity_Name__c = 'Co Op Req';
            coOpReq.Activity_Start_Date__c = System.today();
            coOpReq.Activity_End_Date__c = System.today();
            insert coOpReq;
        }
    }
    
     public static testmethod void testPopulateInteractTool() {
        // Insert Co-Op Request
        Co_Op__c coOpReq = new Co_Op__c();
        coOpReq.Activity_Name__c = 'Co Op Req';
        coOpReq.Interact_Tools_Email__c = 'Partner.ResourceCenter@ncr.com';
        coOpReq.Activity_Start_Date__c = System.today();
        coOpReq.Activity_End_Date__c = System.today();
        insert coOpReq;
         System.assertNotEquals(coOpReq.Id, null,'Co-Op Request is null');
    }
}