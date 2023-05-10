/****************************************************************************************************************
* Author        :  Sushant
* Date          :   26-02-2022
* Param         :   
* Return        :   
* Description   :   This batch class will take the backup of 2 years of NPS score data in Account object.
*****************************************************************************************************************/
global class BackUp_Account_NPS_Score implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, NPS__c,Previous_Year_NPS__c,X2_years_old_NPS__c FROM Account WHERE NPS__c != null]
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
       for(Account account : scope){
            account.X2_years_old_NPS__c= account.Previous_Year_NPS__c;
            account.Previous_Year_NPS__c= account.NPS__c;
            account.NPS__c = null;
       }
       
       // Update the records in the database
       update scope;  
    }
    global void finish(Database.BatchableContext bc) {}
}