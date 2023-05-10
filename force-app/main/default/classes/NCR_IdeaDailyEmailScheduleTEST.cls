@isTest
private class NCR_IdeaDailyEmailScheduleTEST {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 12 ? 2023';

   static testmethod void test() {
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new NCR_IdeaDailyEmailSchedule());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
       
       System.assert(ct!=null);

      
      Test.stopTest();

   }
}