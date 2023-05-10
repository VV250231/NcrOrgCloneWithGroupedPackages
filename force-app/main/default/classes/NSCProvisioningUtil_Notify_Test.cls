@isTest
public class NSCProvisioningUtil_Notify_Test
{
	public static testmethod void notificationTest1()
    {
        String job1=System.schedule('ScheduleApexClassTest',
                        '0 0 0 15 3 ? 2023',
                        new NSCProvisioningUtil_Notify());
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals('0 0 0 15 3 ? 2023', ct.CronExpression);
        
    }
}