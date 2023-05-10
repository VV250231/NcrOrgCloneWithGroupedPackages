/*
##################################################################################################
# Project Name..........: Easy Button                                                                     
# File..................: TestOppLinkageLogCleaner.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                   
# Created Date..........: 23-02-2015                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 23-02-2015 
# Description...........: The test class is written to test the OppLinkageLogCleaner Class.
################################################################################################
*/
@isTest
private class TestOppLinkageLogCleaner  {  
    static testMethod void logCleanerTest() {
        Log_Opportunity_Linkage__c debugObj = new Log_Opportunity_Linkage__c();
        
        debugObj.name = 'test log';
        debugObj.Application_Name__c = 'WOT_UPSERT';
        debugObj.Quote_Name_Opportunity_Detail__c = 'WOT Quote1';
        debugObj.Quote_Number__c = '1234';
        debugObj.ERP_Order_Number__c = '1234';
        debugObj.MCN__c = '1234';
        debugObj.Quote_Amount__c = 1000;
        debugObj.Quote_Currency__c = 'USD';
        debugObj.Date_Submitted__c = Datetime.now();
        debugObj.Last_Modified_Date__c = Datetime.now();
        debugObj.Version_Number__c = '1.0';
        debugObj.Status__c = 'Submitted';
        debugObj.Opportunity_Number__c = '1234';
        debugObj.Account_Country_Code__c  = 'US';
        debugObj.QuickLook_ID__c = 'test';
        
        insert debugObj;    
        
        System.assert(debugObj.Id != null);
        
        Test.startTest();
            OppLinkageLogCleaner logCleaner = new OppLinkageLogCleaner();
            Database.executeBatch(logCleaner, 1);
        Test.stopTest();
        
        System.assertEquals([SELECT COUNT() FROM Log_Opportunity_Linkage__c WHERE Id = :debugObj.Id], 0);
    }
}