trigger ResellerTrigger on Reseller__c (before insert, before update) {
    
    if((Trigger.isInsert && Trigger.isBefore)) {
        ResellerTriggerHandler.populateNCRLeadOwner(Trigger.new,null);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
        ResellerTriggerHandler.updateResellerDataOnLead(Trigger.new, Trigger.old);
        ResellerTriggerHandler.populateNCRLeadOwner(Trigger.new,Trigger.oldMap);
    } 
}