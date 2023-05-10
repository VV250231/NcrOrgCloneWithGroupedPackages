public with sharing class CPQ_ProcessContractEndBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public Database.QueryLocator  start(Database.BatchableContext bc) {
        String query = 'SELECT Id, SBQQ__Quote__c, qtc_Bill_To_Account__r.Site_Number__c, Is_Processed_By_Contract_End_Batch__c FROM Contract WHERE (EndDate <= Today OR qtc_Termination_Date__c <= Today) AND (Is_Processed_By_Contract_End_Batch__c = false)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, list<Contract> contracts) {
        List<Contract> contractToUpdate = new List<Contract>();
        for (Contract contractRec : contracts) {
            if (contractRec.qtc_Bill_To_Account__c != null) {
                GenerateLegalDocumentService.myNcrCallout(contractRec.SBQQ__Quote__c, contractRec.qtc_Bill_To_Account__r.Site_Number__c);
                contractRec.Is_Processed_By_Contract_End_Batch__c = true;
                contractToUpdate.add(contractRec);
            }
        }

        if (!contractToUpdate.isEmpty()) {
            update contractToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc){
        // Not yet decided anything for final block
    }
}