public with sharing class AR_Batch implements Database.Batchable<sObject>,Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id,iPaaS_Update_Successful__c from Credit_Detail__c WHERE iPaaS_Update_Successful__c = true');
    }

    public void execute(Database.BatchableContext bc,List<Credit_Detail__c> scope) {
        for (Credit_Detail__c cd : scope) {
            cd.iPaaS_Update_Successful__c = false;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('Base');
    }
}