/*
##################################################################################################
# Project Name..........: SpringCM Identity Validation                                                                       
# File..................: TestSpringCMAuthCtlr.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                   
# Created Date..........: 24-11-2014                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 24-11-2014 
# Description...........: The test class is written to test the SpringCMAuthCtlr Class.
################################################################################################
*/
@isTest
private class TestSpringCMAuthCtlr   {  
    static testMethod void myUnitTest() {
        Account acc = new Account(Name ='test');
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(acc); 
        SpringCMAuthCtlr sprCMObj = new SpringCMAuthCtlr(stdcontroller);
        system.assertEquals(sprCMObj.validSpringCMUser, true);
    }
}