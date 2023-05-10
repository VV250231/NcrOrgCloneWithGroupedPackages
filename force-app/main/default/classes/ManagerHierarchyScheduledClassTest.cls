/*
####################################################################################################################
# Project Name..........: NSC CRM 2017                                                                                                                        
# File............................:ManagerHierarchyScheduledClassTest.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 20-04-2017                                                                                 
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 20-04-2017                                                                                 
# Description...............: This is the testclass of class ManagerHierarchyScheduledClass
####################################################################################################################
*/
@istest
Private Class ManagerHierarchyScheduledClassTest{
    private static testMethod void  myTest() {
        Test.startTest();    
        ManagerHierarchyScheduledClass sh1 = new ManagerHierarchyScheduledClass();      
        String sch = '0 0 23 * * ?';
        String jobID=system.schedule('Test check', sch, sh1);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();    
    }
}