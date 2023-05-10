@isTest(SeeAllData=true)
public class createCampaignMemberForLiveChatLeadTest {
    static testmethod void myTestMethod1() {
        List<Campaign> campaigns = [SELECT Id FROM Campaign LIMIT 1];
        if (campaigns.size() > 0) {
            Lead l = new Lead();
            l.FirstName = 'test';
            l.lastName = 'User';
            l.Sys_Campaign_Id__c = campaigns[0].Id;
            l.company = 'NCR';
            insert l;
            Lead l1=[Select Id, lastName from Lead where lastName ='User' LIMIT 1];
      		System.assert(l1.id!=null);
            
        }
    }
}