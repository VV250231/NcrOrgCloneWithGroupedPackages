@isTest
public class BatchShareMDFClaimTest 
{
    public static testMethod void testBatchShareMDFClaim() 
    {
        
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'Partner Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663446';
        system.runAs(TestRecordsFactory.getUser()){
        insert act;
        }
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'sm245987@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        
         //Insert Partner Contact
        Contact con2 = new Contact();
        con2.lastName = 'Mahla';
        con2.Email = 'sm245987@gmail.com';
        con2.AccountId = act.Id;
        con2.Active_Contact__c = true;
        con2.Web_Portal_Login__c = 'wplUser';
        insert con2;
        
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='IPT Partner Community Login User' Limit 1];
        User u1 = new User();
        u1.ContactId = con.Id;
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
        insert u1;
        
        User u2 = new User();
        u2.ContactId = con2.Id;
        u2.Username = 'wplUser1@ncr.com';
        u2.ProfileId = portalProfile.Id;
        u2.Alias = 'test1234';
        u2.Email = 'sm2459874@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LastName = 'McTesty';
        u2.CommunityNickname = 'test123456';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'wplUser1';
        u1.isActive = true;
        insert u2;
        
        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c();
        mdf.Name= 'test-MDF';
        mdf.Activity_Date__c= Date.today();
        mdf.End_Date__c= Date.today().addDays(1);
        mdf.Activity_Type__c= 'Event - Roadshow';
        mdf.Other_Vendors_Represented__c='Micros';
        mdf.Activity_Description__c='TestDescription';
        mdf.Number_of_Leads__c= 1000;       
        mdf.Status__c='Request Created'; 
        //mdf.budget__c = budget.Id;
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        mdf.OwnerId = u1.Id;
        insert mdf;
        
        
        //create new fund claim
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
        mdfClaim.name = 'test';
        mdfClaim.Fund_Request__c = mdf.id;
        mdfClaim.Released_Month__c = 'Jan';
        mdfClaim.Released_Year__c = '2017';
        mdfClaim.OwnerId = u1.Id;
        insert mdfClaim;
        
        Test.startTest();
        Database.executeBatch(new BatchShareMDFClaim(new Set<Id>{mdfClaim.Id}));
        SFDC_MDF_Claim__Share mdfShareObj = [select id from SFDC_MDF_Claim__Share where ParentId=:mdfClaim.id];
        System.assert(mdfShareObj.id!=null);
        Database.executeBatch(new BatchShareMDF(new Set<Id>{mdf.Id}));
        Test.stopTest();
        
        Database.executeBatch(new BatchShareMDFWithPartnerUser(new Set<Id>{u2.Id}));
    }
}