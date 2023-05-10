@isTest(seeAllData=true)
public class NCR_SendDailyIdeaSummaryConTest {
    static testmethod void testDailyEmailDigest() {
        
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        // Find Idea Zone
        List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
        Idea idea = new Idea();
        idea.title='Title';
        idea.body='Body';
        idea.communityid = zones[0].id;
        insert idea;
        Idea i=[Select id,title,communityid,body from Idea where title='Title'];
        NCR_SendDailyIdeaSummaryCon vfpcConObj = new NCR_SendDailyIdeaSummaryCon();
        System.assert(i.title==idea.title);
    }
}