trigger ExpansionRequestTrigger on Expansion_Request__c (before insert, before update)  {
    
 
    if(trigger.isInsert && trigger.isBefore)
    {
        Set<Id> ownerIds = new Set<Id>();
        //Loop through each expansion request and create a Set of all the UserIds for the expansion request owners 
        for (Expansion_Request__c objER : Trigger.new) {
            //Figure out the owner ids of the expansion requests 
            ownerIds.add(objER.OwnerId);
        }
        
        // Find CAM
        Map<Id,User> userMap = new Map<Id,User>([Select Id,ManagerId,ContactId,Contact.Account.OwnerId, Contact.AccountId, Contact.Account.Account_Region__c, Contact.Account.Partner_Industry__c 
                                                   from User where id in :ownerIds]);
        
        Set<Id> CAMIdSet = new Set<Id>();
        Map<Id,Id> partnerUserIdToCAMId = new Map<Id,Id>();
        Map<Id,Id> partnerUserIdToContactId = new Map<Id,Id>();
        Map<Id,Id> partnerUserIdToAccountId = new Map<Id,Id>();
        
        for (User u : userMap.values()) {
            if (u.Contact.Account.OwnerId != null) {
                CAMIdSet.add(u.Contact.Account.OwnerId);
                partnerUserIdToCAMId.put(u.Id,u.Contact.Account.OwnerId);
                partnerUserIdToContactId.put(u.Id, u.ContactId);
                partnerUserIdToAccountId.put(u.Id, u.Contact.AccountId);
            }
        }
        
        
        
        Map<Id,User> CAMMap = new Map<Id,User>([Select Id,ManagerId from User where id in :CAMIdSet]);
        
        // Find CSL - Manager of CAM
        Set<Id> CSLIdSet = new Set<Id>();
        Map<Id,Id> CAMIdToCSLId = new Map<Id,Id>();
        
        for (User u : CAMMap.values()) {
            if (u.ManagerId != null) {
                CSLIdSet.add(u.ManagerId);
                CAMIdToCSLId.put(u.Id,u.ManagerId);
            }
        }
        
        Map<Id,User> CSLMap = new Map<Id,User>([Select Id,ManagerId from User where id in :CSLIdSet]);
        
        // Find CSL's Manager - channel VP
        Set<Id> VPIdSet = new Set<Id>();
        Map<Id,Id> CSLIdToVPId = new Map<Id,Id>();
        
        for (User u : CSLMap.values()) {
            if (u.ManagerId != null) {
                VPIdSet.add(u.ManagerId);
                CSLIdToVPId.put(u.Id,u.ManagerId);
            }
        }
        
         Map<Id,User> VPMap = new Map<Id,User>([Select Id,ManagerId from User where id in :VPIdSet]);
        
        //Now loop through each expansion request to set the Partner Account Id on the request
        for (Expansion_Request__c objER : Trigger.new) {
            //Update the partner account manager 
            if ((userMap.get(objER.OwnerId).Contact.Account.OwnerId != NULL)) {
                
                
                // Fill CAM
                objER.Account_Owner__c = partnerUserIdToCAMId.get(objER.OwnerId) != null ? partnerUserIdToCAMId.get(objER.OwnerId): objER.Account_Owner__c;
                objER.CSL__c = objER.Account_Owner__c != null && CAMIdToCSLId.get(objER.Account_Owner__c) != null ? CAMIdToCSLId.get(objER.Account_Owner__c) : objER.CSL__c;
                objER.Partner_Contact__c = partnerUserIdToContactId.get(objER.OwnerId) != null ? partnerUserIdToContactId.get(objER.OwnerId): objER.Partner_Contact__c;
                objER.Account_Name__c = partnerUserIdToAccountId.get(objER.OwnerId) != null ? partnerUserIdToAccountId.get(objER.OwnerId): objER.Account_Name__c ;
                objER.Channel_VP__c = objER.CSL__c != null && CSLIdToVPId.get(objER.CSL__c) != null ? CSLIdToVPId.get(objER.CSL__c) : objER.Channel_VP__c;

            
               
            }
        }
    }
}