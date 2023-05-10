@istest
class AutoJoinGSOCafeChatterGroupTestClass {
    
    static testmethod void test() {
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile1 = [SELECT Id FROM Profile WHERE Name = '03 PRM Admin' Limit 1];
        User u1 = new User();
        u1.Username = 'sysAdmin1@ncr.com';
        u1.UserRole= role ;
        u1.ProfileId = adminProfile1.Id;
        u1.Alias = 'admin224';
        u1.Email = 'sm2459717@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'systemAdmin1';
        u1.CommunityNickname = 'adminUser';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.Quicklook_ID__c='pk18516x';
        u1.isactive =true;
        insert u1;
        
        Datetime lastWeek = Datetime.now().addDays(-7);
        Test.setCreatedDate(u1.Id, lastWeek); 
        
        Test.startTest();
        String CRON_EXP = '0 0 0 13 12 ? 2023';
        AutoJoinGSOCafeChatterGroup a = new AutoJoinGSOCafeChatterGroup();
        system.schedule('AutoJoinGSOCafeChatterGroup', CRON_EXP, a);
        System.assert(u1.id!=null);
        Test.stopTest();
    }
}