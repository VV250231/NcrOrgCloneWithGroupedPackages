/*
##################################################################################################
# Class Name............................:UserTriigerHandler                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
global class UserTriigerHandler {
 
    @future
    public static void updateContact(List<Id> userIds, Boolean isInsert, Boolean isUpdate) {
        Map<Id,User> contactIdToUser = new Map<Id,User>();
        List<user> users = [Select Id, Name, ContactId FROM User WHERE Id IN : userIds];
        for (User u : users) {
            if (u.ContactId != null) {
                contactIdToUser.put(u.ContactId, u);
            }
        }       
        if (isInsert) {
            if (contactIdToUser.keySet().size() > 0) {
                List<Contact> contacts = [SELECT Id, Name, Partner_User__c FROM Contact WHERE Id IN : contactIdToUser.keySet()];
                List<Contact> conToUpdate = new List<Contact>();
                
                for (Contact c : contacts) {
                    if (contactIdToUser.get(c.Id)!= null) {
                        c.Partner_User__c = contactIdToUser.get(c.Id).Id;
                        conToUpdate.add(c);
                    }
                }
                
                if (conToUpdate.size() > 0)
                    update conToUpdate;
            }
        } else if (isUpdate) {
            List<Contact> contacts = [SELECT Id, Name, Partner_User__c FROM Contact Where Partner_User__c IN : userIds];
            List<Contact> conToUpdate = new List<Contact>();
            for (Contact con : contacts) {
                con.Partner_User__c = null;
                conToUpdate.add(con);
            }
            if (conToUpdate.size() > 0)
                update conToUpdate;
        }
    }
    
    public void addUserstoHSGGroup(List<Id> userIds) {
        List<GroupMember> GMlist = new List<GroupMember>();
        
        if((!userIds.isEmpty()) && (HSGUserGroup != null)) {           
            for(Id userId : userIds) {
                GroupMember GM = new GroupMember();
                GM.GroupId = HSGUserGroup.Id;
                GM.UserOrGroupId = userId;
                GMList.add(GM);     
            }
        }
        
        if(!GMList.isEmpty()) {
            insert GMList;
        }
    }
    
    
    public void removeUsersFromHSGGroup(List<Id> userIds) {
        if((!userIds.isEmpty()) && (HSGUserGroup != null)) { 
            List<GroupMember> GMlist = [SELECT Id FROM GroupMember WHERE GroupId = :HSGUserGroup.Id and UserOrGroupId IN :userIds];
            
            if(!GMList.isEmpty()) {
                delete GMList;
            }
        }   
    }
    
    @future
    public static void updateHSGGroupUsersWithFuture(Map<Id, Id> newUserProfIdMap, Map<Id, Id> oldUserProfIdMap) {
        updateHSGGroupUsers(newUserProfIdMap, oldUserProfIdMap); 
    }
     
     
    
    public static void updateHSGGroupUsers(Map<Id, Id> newUserProfIdMap, Map<Id, Id> oldUserProfIdMap) {
        List<Id> HSGUserIds = new List<Id>();
        List<Id> nonHSGUserIds = new List<Id>();
        UserTriigerHandler handlerObj = new UserTriigerHandler();
        Map<Id, Profile> HSGProfileMap = new Map<Id, Profile>([SELECT Id FROM Profile WHERE NAME IN ('54 Hosted Solutions Sales Operations','55 Hosted Solutions Sales', 'Cloned 54 Hosted Solutions Sales Operations for DS Admin')]);
        
        if (newUserProfIdMap != null &&  newUserProfIdMap.size() > 0) {
            if (oldUserProfIdMap != null &&  oldUserProfIdMap.size() > 0) { // user update run
                for (Id newUserId : newUserProfIdMap.keySet()) { 
                    Id newUserPrfId = newUserProfIdMap.get(newUserId);
                    Id oldUserPrfId = oldUserProfIdMap.get(newUserId);
                    
                    if ((!HSGProfileMap.containsKey(oldUserPrfId)) && (HSGProfileMap.containsKey(newUserPrfId))) {
                        HSGUserIds.add(newUserId); // add user to HSG group    
                    }
            
                    if (HSGProfileMap.containsKey(oldUserPrfId) && (!HSGProfileMap.containsKey(newUserPrfId))) {
                        nonHSGUserIds.add(newUserId); // remove user from HSG group
                    }  
                }    
            } else { // user insert run
                for (Id newUserId : newUserProfIdMap.keySet()) { 
                    Id newUserPrfId = newUserProfIdMap.get(newUserId);
                    
                    if (HSGProfileMap.containsKey(newUserPrfId)) {
                        HSGUserIds.add(newUserId); // add user to HSG group    
                    }
                }
            }
        }
  
        if (!HSGUserIds.isEmpty()) {
            handlerObj.addUserstoHSGGroup(HSGUserIds);  
        }
        
        if (!nonHSGUserIds.isEmpty()) {
            handlerObj.removeUsersFromHSGGroup(nonHSGUserIds);  
        }
    } 
    
    public Group HSGUserGroup {
        get {
            if (HSGUserGroup == null) {
                HSGUserGroup = [SELECT Id, Name FROM Group WHERE Name = 'Hosted Solutions Users Group' LIMIT 1]; 
            }
            return HSGUserGroup;
        }
        set;
    }
    
    
}