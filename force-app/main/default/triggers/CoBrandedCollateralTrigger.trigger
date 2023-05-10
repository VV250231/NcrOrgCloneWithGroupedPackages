trigger CoBrandedCollateralTrigger on Co_Branded_Collateral__c (before insert, before update) {

    if(trigger.isBefore && trigger.isInsert) {
        //populate partner account and contact
        User u = [SELECT Id, AccountId, ContactId,Contact.Account.OwnerId FROM User WHERE Id =: UserInfo.getuserid() LIMIT 1] ;
        for(Co_Branded_Collateral__c rec : Trigger.new) { 
            if (u.AccountId != null) {          
                    rec.Partner_Account__c = u.AccountId;
            }
            
            if (u.ContactId != null) {
                rec.Partner_Contact__c = u.ContactId;
            }  
                   
         }
         
      }
      
 }