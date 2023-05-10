public class SalesOrgCodeCleanBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id, Sales_Org_Code__c, Sales_Org__c FROM Opportunity Where Sales_Org__r.IsPrimary__c = false AND Sales_Org_Code__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        Map<String, Id> orgCodeToPrimaryIdMap = new Map<String, Id>();
        Set<String> salesOrgCodeSet = new Set<String>();        
        
        for(Opportunity opp : oppList){
            salesOrgCodeSet.add(opp.Sales_Org_Code__c);
        }
        
        for(Sales_Org__c orgObj : [Select Id, Sales_Org_Code__c, IsPrimary__c FROM Sales_Org__c WHERE Sales_Org_Code__c IN : salesOrgCodeSet AND IsPrimary__c = true]){
            if(orgObj.Sales_Org_Code__c != null && orgObj.IsPrimary__c && !orgCodeToPrimaryIdMap.containsKey(orgObj.Sales_Org_Code__c)){
                orgCodeToPrimaryIdMap.put(orgObj.Sales_Org_Code__c, orgObj.Id);
            }
        }
        
        if(orgCodeToPrimaryIdMap.size() > 0){
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            for(Opportunity opp : oppList){
                if(opp.Sales_Org_Code__c != null && orgCodeToPrimaryIdMap.containsKey(opp.Sales_Org_Code__c)){
                    opp.Sales_Org__c = orgCodeToPrimaryIdMap.get(opp.Sales_Org_Code__c);
                }
                oppListToUpdate.add(opp);
            }
            if(oppListToUpdate.size() > 0){
                //Database.update(oppListToUpdate, false);
                update oppListToUpdate;
            }          
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Batch Finished');
    }
}