@isTest(SeeAllData=true)
public class ChatterUserSheetControllerTest {
public static testMethod void ChatterUserSheetController() {

   String CRON_EXP = '0 0 0 15 12 ? 2023';

      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ChatterUserSheetController());
       System.assertNotEquals(jobId, null,'Job not scheduled successfully');  
      // Get the information from the CronTrigger API object
  Test.stopTest();


   }
}