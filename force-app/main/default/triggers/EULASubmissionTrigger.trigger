trigger EULASubmissionTrigger on EULA_submission__c (before Insert) {
    
     Set<Id> AccountIds = new Set<Id>();
     User currentUser = [SELECT Id, Contact.AccountId, Contact.Account.OwnerId, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
     for(EULA_submission__c es : Trigger.new){
     
     // Account Detail
     if (currentUser.Contact.AccountId != null){
        es.Account__c = currentUser.Contact.AccountId;
     }
     // Contact Detail
      if (currentUser.ContactId != null){
         es.Contact__c = currentUser.ContactId;
      } 
    
    // CAM Detail
    if (currentUser.ContactId != null){
         es.CAM__C = currentUser.Contact.Account.OwnerId;
      } 
     }
}