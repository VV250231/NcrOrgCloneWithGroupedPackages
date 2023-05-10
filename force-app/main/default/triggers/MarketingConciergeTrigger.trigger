trigger MarketingConciergeTrigger on Marketing_Concierge__c (before insert, before update) 
{

    if(trigger.isBefore && trigger.isInsert)
    {
        List<User> u = [SELECT Id, AccountId,Contact.Phone, Contact.Email, ContactId FROM User WHERE Id =: UserInfo.getuserid() LIMIT 1] ;
        for(Marketing_Concierge__c rec : Trigger.new) 
        { 
            if (u != null) 
            {          
                rec.status__c = 'Created';          
                rec.Partner_Company__c = u[0].AccountId;
                rec.Partner_Contact__c = u[0].ContactId;
                rec.Partner_Phone_Number__c = u[0].Contact.Phone;
                rec.Partner_Email_Address__c = u[0].Contact.Email;
            }  
                   
         }   
    }
    else if(trigger.isBefore && trigger.isUpdate)
    {
        for(Marketing_Concierge__c objNewMC : trigger.newMap.values()) 
        {
            Marketing_Concierge__c objOldMC = trigger.oldMap.get(objNewMC.Id);
            
            if(objNewMC.Status__c == 'Approved' && objNewMC.Status__c != objOldMC.Status__c)
            {
                objNewMC.Request_Owner__c = UserInfo.getUserId();
            }
        }
    }                    

}