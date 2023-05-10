/*
#####################################################################################################################
# Project Name..........: NSC PMDM                                                                         #
# File..................: TestNotifyandCreateTask.cls                                                             #
# Version...............: 1                                                                                         #
# Created by............: Ravikant Maurya                                                                                #
# Created Date..........: 01-09-2018                                                                               #
# Last Modified by......: Ravikant Maurya                                                                               #
# Last Modified Date....: 01-09-2018                                                                                #
# Description...........: This  functionality is targeted to test NotifyandCreateTask Apex Class.                                                                    #
#####################################################################################################################
*/
@isTest
public class TestNotifyandCreateTask {
    public static testMethod void runUnitTest() {
         Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
         Product2 prod = TestRecordsFactory.createProduct();
         String pmdm_unique_key = '12345';
         prod.PMDM_Unique_Key__c = pmdm_unique_key;
         prod.End_Date__c = Date.today();
         update prod;
         PricebookEntry pbe = TestRecordsFactory.createPriceBookEntry(prod);
         OpportunityLineItem oli = TestRecordsFactory.createOpportunityLineItem(opp, pbe);
         
         DeactivatedProductReport__c dpreport = new DeactivatedProductReport__c();
         dpreport.Name = 'DeactivatedProductReportId'; 
         dpreport.ReportId__c = '12345';
         insert dpreport;
        
         NotifyandCreateTask notifyTask = new NotifyandCreateTask(pmdm_unique_key);
         ID batchprocessid = Database.executeBatch(notifyTask);
         System.assert(batchprocessid!=null);
        
    }
}