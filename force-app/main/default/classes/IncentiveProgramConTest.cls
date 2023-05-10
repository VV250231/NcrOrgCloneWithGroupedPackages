@isTest()
public class IncentiveProgramConTest {
    
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
    
    private static void insertcustomSetting(){
        Incentive_All_Program_Config__c newConfig = new Incentive_All_Program_Config__c();
        newConfig.Name = 'IncentiveProgram';
        newConfig.Passed_date__c = System.today() - 1;
        newConfig.Partner_Levels_for_Annual_Incentive__c = 'ELITE';
        newConfig.Partner_Levels_for_Quarterly_Incentive__c = 'ELITE';
        insert newConfig;
        
    } 
    
    static testMethod void testAnnualIncentives() {   
        insertcustomSetting();
        Account acc = createAccount();
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;   
        }
        
        Contact con = createContact(acc.id);
        insert con;
        user u = createUser(con.Id);
        insert u;
        PageReference pageRef = Page.Incentive_Program_Annual;
        pageRef.getParameters().put('id','Annual Quota Incentives');
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id','Annual Quota Incentives');
        System.runAs(u){
            IncentiveProgramCon incen = new IncentiveProgramCon();
            incen.submit();
            incen.isAgree  = true;
            List<Incentive_Program_Enrollment__c> incList = incen.getEnrolledPrograms();
            System.assert(incList.size()==0);
            incen.redirectBack();
            
        }
    }
}