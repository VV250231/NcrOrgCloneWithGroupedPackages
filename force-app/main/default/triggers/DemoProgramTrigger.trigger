trigger DemoProgramTrigger on Demo_Program__c (before insert) {
    
    if(trigger.isBefore && trigger.isInsert)
    {
        // Find current user contactId and AccountId.
        User u = [SELECT Id, AccountId, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        List<Account> actLst = new List<Account>();
        if (u.AccountId != null) {
            actLst= [SELECT OwnerId,Account_Country_Code__c FROM Account WHERE Id =: u.AccountId LIMIT 1];
        }
        for (Demo_Program__c demo : Trigger.New) {
            if (u.AccountId != null) {
                demo.Partner_Account__c = u.AccountId;
                if (actLst.size()>0)
                demo.Channel_Account_Manager__c = actLst[0].OwnerId;
            }  
            if (u.ContactId != null) {
                demo.Partner_Contact__c = u.ContactId;
            }
        }       
    }
        
}