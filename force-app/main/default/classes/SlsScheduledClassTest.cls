/*
####################################################################################################################
# Project Name..........: Sales Order Reporting                                                                                                                       
# File............................:SlsScheduledClassTest.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 28-01-2018                                                                                 
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 28-01-2018                                                                                 
# Description...............: This is the testclass of class SlsScheduledClass
####################################################################################################################
*/
@istest
Private Class SlsScheduledClassTest{
    private static testMethod void  myTest() {
        Test.startTest();   
        NSC_Support_Error_Notification__c n = new NSC_Support_Error_Notification__c(name='NSC Job Failure',ToEmailAddresses__c = 'test@test.com');
        insert n;
        SlsScheduledClass sh1 = new SlsScheduledClass();      
        String sch = '0 0 23 * * ?';
        String s = system.schedule('Test check', sch, sh1);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :s];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();    
    }
}