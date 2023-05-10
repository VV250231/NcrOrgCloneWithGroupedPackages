@isTest
public class ExpansionRequestTriggerTest {
    
     private static Account createAccount(){
       
        Account objAccount = new Account();
        objAccount.Name = 'Partner Test Account';
        objAccount.Account_Country_Code__c = 'US';
        objAccount.Active_Account__c = true;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Industry = 'RETAIL:CHANNEL';
        objAccount.Account_Region__c = 'EMEA';
        objAccount.Master_Customer_Number__c = '91663446';
        objAccount.Partner_Industry__c = 'Financial;Retail';
        objAccount.LOB__c = 'FINANCIAL';
        objAccount.Account_Region__c = 'CLA';
        
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if(actRecordtypes.size() > 0)
            objAccount.RecordTypeId = actRecordtypes[0].Id;
            
        return objAccount;
    }
    
    private static Contact createContact(Id AccountID)
    {
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'test@gmail.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        return con;
    }
    
    private static User createUser(Id ContactId)
    {
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'IPT Partner Community Login User' Limit 1];
        User u1 = new User();
        u1.ContactId = contactId;
        u1.Username = 'wplUserTest@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test1231';
        u1.Email = 'sm245987Test@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test123451';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        return u1;   
    }
    public static testmethod void testPopulateAccountInfo() 
    {
        Account acc = createAccount();
        system.runas(TestRecordsFactory.getUser())
        {
            insert acc; 
        }
       
        
        Contact con = createContact(acc.id);
        insert con;
        
        User u = createUser(con.Id);
         
        system.runAs(u) 
        {
           
            Expansion_Request__c ex = new Expansion_Request__c();
            ex.Territory_1__c = 'Test1234';
            ex.Territories_currently_served__c = 'Test';
            ex.Discussed_this_request_with_CAM__c = 'Yes';
            insert ex;
            system.assertEquals(ex.Territory_1__c,'Test1234');
            
        }
    }
}