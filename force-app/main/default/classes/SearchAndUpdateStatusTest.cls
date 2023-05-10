@isTest(seeAllData=true)

public class SearchAndUpdateStatusTest{

    static testmethod void test() {
    String CRON_EXP = '0 0 * * * ?';
    try{
     idea a=[select id from idea where ismerged=true limit 1]; 
     a.status ='Not Planned' ; 
     update a;
    } 
    catch(Exception e){
      System.debug('Error '+e.getMessage());
    }

      Test.startTest(); 
      String jobId = System.schedule('ScheduleApexClassTest1',CRON_EXP,new scheduledBatchable());
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
      System.assertEquals( CRON_EXP, ct.CronExpression);
      Test.stopTest();
       
   }
}