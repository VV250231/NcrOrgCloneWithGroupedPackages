@istest
 class schedule_Process_ICM_Users_TEST {
     public static testMethod void testschedule() {
        Test.StartTest();
        schedule_Process_ICM_Users_BatchClass runjob = new schedule_Process_ICM_Users_BatchClass();
        String sch = '0 0 0,4,8,12,16,20 * * ?';
       string job1=system.schedule('ICM User changes', sch, runjob );
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }
}