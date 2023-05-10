@istest
class scheduleProfileTrackBatchClassTest {
    public static testMethod void testschedule() {
        Test.StartTest();
        scheduleProfileTrackBatchClass runjob = new scheduleProfileTrackBatchClass();
        String sch = '0 0 0,4,8,12,16,20 * * ?';
        String job1=system.schedule('Customize App changes', sch, runjob );
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }
}