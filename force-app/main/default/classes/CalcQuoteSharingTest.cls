@isTest
private class CalcQuoteSharingTest { 
    @testSetup static void setup() {
        Profile DIprofile = [SELECT Id FROM Profile WHERE Name = '62 DI Account Manager' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        
        List<User> DIUserList = TestRecordsFactory.createUsers(DIprofile.Id, 'Ztest', 2);
        
        User adminUser = new User(Id = DIUserList.get(0).Id, ProfileId=adminProfile.id);
        update adminUser;
    }
    
    
    static testMethod void runSharingTest() {
        User DIUser = [SELECT Id FROM User WHERE Profile.Name = '62 DI Account Manager' and IsActive=true LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive=true LIMIT 1];
        
        Account a = TestRecordsFactory.createAccount();
        AccountTeamMember accTeamMember = TestRecordsFactory.createAccountTeamMember(a.Id, DIUser.Id);
        
        zqu__Quote__c q = new zqu__Quote__c(name = 'test-quote', zqu__Account__c = a.id, zqu__Status__c = 'QA Processing Complete', OwnerId = DIUser.Id);
        insert q;
        
        q.OwnerId = adminUser.Id;
        update q;
        
        Test.startTest();
        String TEST_CRON_EXP = '0 25 * * * ?';
        String jobID = System.schedule('Test Quote Sharing with Account Team', TEST_CRON_EXP, new CalcQuoteSharing());
        Database.executeBatch(new QuoteSharingController());
        Test.stopTest();
        List<zqu__Quote__Share> zqList = [select id from zqu__Quote__Share where parentId=:q.id];
        System.assert(zqList.size()>0);
    }
    
    
}