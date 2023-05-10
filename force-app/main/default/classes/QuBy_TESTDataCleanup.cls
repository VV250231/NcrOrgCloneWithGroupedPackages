/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: QuBy_TESTDataCleanup.cls                                  
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 23-08-2016
# Description...........: TEST CLASS for QuBy_DataCleanup                         
##################################################################################################*/
@isTest
private class QuBy_TESTDataCleanup {  
    static testmethod void test(){
        Test.StartTest();
        QuBy_DataCleanup sh1 = new QuBy_DataCleanup();
        String sch = '0 0 0 15 3 ? 2023';
        String jobID=system.schedule('Testing', sch, sh1);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest(); 
    }
}