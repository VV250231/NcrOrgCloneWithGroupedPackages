trigger PartnerOpportunityTrigger on Partner_Opportunity__c (before Insert) {
    
    Set<Id> AccountIds = new Set<Id>();
     for(Partner_Opportunity__c po : Trigger.new){
        AccountIds.add(po.Partner_Account__c);
     }
     
     Map<Id,Account> IdToAccount = new Map<Id,Account>([SELECT Id,OwnerId,Name FROM Account WHERE Id IN : AccountIds]);
     
     for(Partner_Opportunity__c po : Trigger.new){
         Account a = IdToAccount.get(po.Partner_Account__c);
         po.CAM__c = a.OwnerId;
     }
}