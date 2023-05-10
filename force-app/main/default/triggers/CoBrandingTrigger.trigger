trigger CoBrandingTrigger on Co_Branding_Request__c (before Insert) {
    List<Id> accountIds = new List<Id>();
    for(Co_Branding_Request__c cbr : Trigger.New) {
        accountIds.add(cbr.Account__c);
    }
    
    Map<Id,Account> actIdToActRecMap = new Map<Id,Account>([SELECT Id, OwnerId FROM Account WHERE Id IN : accountIds ]);
    for(Co_Branding_Request__c cbr : Trigger.New) {
        cbr.Channel_Account_Manager__c = actIdToActRecMap.get(cbr.Account__c).OwnerId;
    }
}