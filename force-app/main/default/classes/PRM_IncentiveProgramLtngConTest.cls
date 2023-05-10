@isTest
public class PRM_IncentiveProgramLtngConTest {
    public static testMethod void testPRM_IncentiveProgramLtngCon() {
        // Create Partner Account
        Account act = new Account();
        act.Name = 'Partner Demo Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Partnership_Status__c ='Active';
        act.Industry = 'RETAIL:SPECIALTY RETAIL';
        act.Partner_Industry__c = 'RETAIL';
        act.LOB__c = 'RETAIL';
        act.Account_Region__c = 'MEA';
        act.Partner_Program_Level__c = 'Advanced';
        act.Master_Customer_Number__c = '9166344650';
         system.runas(TestRecordsFactory.getUser())
        {
            insert act; 
        }
        //insert act;
        
        // Create Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'sm245987@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        
        // Create Community User for above contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%IPT Partner Community Login User%' Limit 1];
        User u1 = new User();
        u1.ContactId = con.Id;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.isActive =true;
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'testxcv12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        insert u1;
        
        // Insert Incentive Program
        Incentive_Program__c ip = new Incentive_Program__c();
        ip.Name = 'Quarterly Sales Incentive';
        ip.Active__c = true;
        ip.Partner_Industry__c = 'RETAIL';
        ip.Region__c = null;
        ip.Incentive_Summary__c = 'Test Summary';
        ip.Partner_Levels__c = 'Advanced';
        ip.Passed_Date__c = System.today()+1;
        ip.Program_Type__c = 'Quarterly Sales Incentive';
        ip.Terms_Conditions__c = ' Terms and conditions';
        insert ip;       
        // Test the functionality
        system.runas(u1) {
            List<Incentive_Program__c> incentivePrgs = new List<Incentive_Program__c>();
            incentivePrgs = IncentiveProgramLtngCon.getAvailableIncentivePrograms();
            system.debug('**'+incentivePrgs);
            if (incentivePrgs.size() > 0) {
                IncentiveProgramLtngCon.getIncentiveProgramDetail(incentivePrgs[0].Id);
                //system.debug('1234444'+IncentiveProgramLtngCon.submitEnrollmentReq(String.valueOf(incentivePrgs[0].Id),true));
                //IncentiveProgramLtngCon r = new IncentiveProgramLtngCon();
             // IncentiveProgramLtngCon.submitEnrollmentReq(String.valueOf(incentivePrgs[0].Id),true);
               IncentiveProgramLtngCon.Result r=  IncentiveProgramLtngCon.submitEnrollmentReq(String.valueOf(incentivePrgs[0].Id),true);
             system.assertEquals(r.state,'SUCCESS');
            }
        }
    }
}