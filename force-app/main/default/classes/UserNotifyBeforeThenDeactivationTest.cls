/*************************************************************************************************
* Author        :   Pankaj Kashyap  // 17/Nov/2021  
* Param         :   User  :  
* Return        :   
* Description   :   This test call will cover the  Btach UserNotifyBeforeThenDeactivationBatch
					Please refer story:SF Optimizer: User Logins(EBA_SF-1628 )
*************************************************************************************************/

@isTest(seeAllData=true) 
private class UserNotifyBeforeThenDeactivationTest { 
    static testMethod void TestMethodForDeactivation(){
       
        Test.startTest();
        // database.executeBatch(new UserNotifyBeforeThenDeactivationBatch());
         String TEST_CRON_EXP = '0 25 * * * ?';
         String jobID = System.schedule('User Deactivation Notifcation Batch', TEST_CRON_EXP, new NotifyBeforeThenDeactivationSchduler());
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
         System.assertEquals(TEST_CRON_EXP, ct.CronExpression);
         //System.schedule('User Deactivation Notifcation Batch 1', TEST_CRON_EXP, new NotifyBeforeThenDeactivationSchduler());
        Test.stopTest();
    }
}