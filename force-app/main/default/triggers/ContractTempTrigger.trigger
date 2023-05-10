trigger ContractTempTrigger on Contract (before insert, before update) {
    if(FeatureManagement.checkPermission('ETL_PreventOverwrite')){
        Set<Id> oppIds = new Set<Id>();
        for(Contract c:trigger.new){
            if(c.Opportunity__c!=null)
                oppIds.add(c.Opportunity__c);
        }
        if (oppIds.isEmpty()) return;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([Select Id, Products__c From Opportunity Where Id in :oppIds]);
        for(Contract c:trigger.new){
            if(c.Opportunity__c!=null)
                c.Products__c = oppMap.get(c.Opportunity__c).Products__c;
        }
    }
}