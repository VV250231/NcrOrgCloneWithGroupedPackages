@isTest(SeeAllData=true)
public class NCR_IdeaDailyEmailBatchTest {
    static testmethod void testBatch() {
        // Find profile Id of Fis
        List<profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = '61 DI Community Members'];
        List<User> users = [SELECT Id, Name, DI_Fi_Domain__c, DI_Fi_Name__c FROM User WHERE ProfileId =: profiles[0].Id LIMIT 5];
        
        // Insert Subscribers
        List<DI_Idea_Exchange_Daily_Digest__c> subscribers = new List<DI_Idea_Exchange_Daily_Digest__c>();
        for (User u : users) {
            subscribers.add(new DI_Idea_Exchange_Daily_Digest__c(DI_User__c=u.Id,DI_Subscribe_for_daily_digest__c=true));
        }
        
        insert subscribers;
        
        User u=[Select id, name from User where profile.name='61 DI Community Members' limit 1];
        System.assert(u.id!=null);
        Test.startTest();
        NCR_IdeaDailyEmailBatch batchObj = new NCR_IdeaDailyEmailBatch();
        Database.executeBatch(batchObj);
        Test.stopTest();
    }
}