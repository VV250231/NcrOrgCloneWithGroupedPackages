@isTest(seeAllData=true)

public class NCR_UpdateIdeaStatusToMergedTest{

    static testmethod void test() {
    String CRON_EXP = '0 0 * * * ? ';
    try{
    idea a=[select id from idea where ismerged=true  AND status!='Merged' limit 1];
    insert a;
    }
    catch(Exception e){
      System.debug('Error: '+e.getMessage());
    }

      Test.startTest();
      String jobId = System.schedule('ScheduleApexClassTest1',CRON_EXP,new NCR_UpdateIdeaStatusToMergedScheduler());
       System.assert(jobId!=null);
      Test.stopTest();
      
   }
}