@isTest
public class IncentiveProgramListConTest {
    public static testMethod void testListCon() {
        // Insert Partner Account
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
        act.Partner_Industry__c ='Retail';
        act.Partner_Program_Level__c = 'ELITE';
        System.runas(TestRecordsFactory.getUser()){
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
        
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
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
        
        Incentive_All_Program_Config__c newConfig = new Incentive_All_Program_Config__c();
        newConfig.Name = 'IncentiveProgram';
        newConfig.Passed_date__c = System.today();
        newConfig.Partner_Levels_for_Annual_Incentive__c = 'ELITE';
        newConfig.Partner_Levels_for_Quarterly_Incentive__c = 'ELITE';
        insert newConfig;
        
        system.runAs(u1) {
            IncentiveProgramListCon controller = new IncentiveProgramListCon();
            controller.selectedProgram = 'Quarterly Sales Incentive';
            PageReference prObj = controller.next();
            System.assert(prObj.getParameters().get('id')=='Quarterly Sales Incentive');
        }
        system.runAs(u1) {
            IncentiveProgramListCon controller1 = new IncentiveProgramListCon();
            controller1.selectedProgram = 'Annual Quota Incentive';
            PageReference prObj1 =controller1.next();
            System.assert(prObj1.getParameters().get('id')=='Annual Quota Incentive');
        }
        system.runAs(u1) {
            IncentiveProgramListCon controller2 = new IncentiveProgramListCon();
            controller2.selectedProgram = 'null';
            PageReference prObj2 = controller2.next();
            System.assert(prObj2==null);
        }
    }
}