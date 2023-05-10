trigger PartnerSpotlightTrigger on Partner_Spotlight__c (before insert, before update) 
{

    if(trigger.isBefore && trigger.isInsert)
    {
        List<User> u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getuserid() LIMIT 1] ;
        for(Partner_Spotlight__c rec : Trigger.new) 
        { 
            if (u != null) 
            {          
                    rec.Partner_Name__c = u[0].ContactId;
            }  
                   
         }
         
      }
      
 }