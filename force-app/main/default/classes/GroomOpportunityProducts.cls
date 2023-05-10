global class GroomOpportunityProducts implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Product2Id, Topline_Product_Lkp__c FROM OpportunityLineItem where Topline_Product_Lkp__c = null or Market_Product_PriceBookEntryId__c = null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> OLIList) {
         update OLIList;
         
    }
    global void finish(Database.BatchableContext bc){
    }
    
    @future
    public static void groomdata(Set<Id> oliIds) {
         List<OpportunityLineItem> oli = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIds];
         update oli;
    }
}