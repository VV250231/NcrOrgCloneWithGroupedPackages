@istest(seeAllData = true)
public class NCR_100PointDateThresholdBatchTest {
    public static testMethod void main(){
        list<idea> id = [select id, title, date__c, voteTotal, voteScore from idea where voteTotal >= 100 LIMIT 1];
        system.debug('test : '+id[0]);
        id[0].date__c = null;
        update id[0];
        Test.startTest();
        String CRON_EXP = '0 0 * * * ? ';
        
        String jobId = System.schedule('ScheduleApexClassTest1',CRON_EXP,new NCR_100PointDateThresholdBatch());
        NCR_100PointDateThresholdBatch obj = new NCR_100PointDateThresholdBatch();
        database.executeBatch(obj);
        Test.stopTest();
        idea idObj = [select date__c from idea where id=:id[0].id];
        system.assert(idObj.date__c == system.today());
    }
}