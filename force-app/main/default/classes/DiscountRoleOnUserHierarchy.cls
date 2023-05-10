public with sharing class DiscountRoleOnUserHierarchy {
    public static boolean isTrue =true;
    public static void discountRoleOnUInsert(List<User> uList){
        Map<id, User> uIdSet = new Map<Id, User>();
        for(User u : uList){
            if (u.ManagerId !=null) {
                uIdSet.put(u.id, u);
            }
        }
        if(!uIdSet.isEmpty()){
            if(!System.isBatch() && !System.isFuture()){
                CalculateDiscountRole uBatch = new CalculateDiscountRole(uIdSet);
                Database.executeBatch(uBatch);
            }
        }
    }
    public static void discountRoleOnUupdate(List<User> uList, Map<Id, User> uOldMap){
        Map<id, User> uIdSet = new Map<Id, User>();
        Set<Id> oldMgrIds = new Set<Id>();
        
        for(User u : uList){
            if(u.Discount_Role__c!=uOldMap.get(u.id).Discount_Role__c ){
                uIdSet.put(u.id, u);
            }
            
            if(u.ManagerId != uOldMap.get(u.id).ManagerId) {
                 uIdSet.put(u.id, u);
                 
                 if(uOldMap.get(u.id).ManagerId != NULL) {
                     oldMgrIds.add(uOldMap.get(u.id).ManagerId);  
                 }
            }
        }
        
        if(!uIdSet.isEmpty()){ 
            if(!System.isBatch() && !System.isFuture()){
                if(!oldMgrIds.isEmpty()) {
                    Map<Id, User> oldMgrMap = new Map<Id, User>([SELECT Id, Name from User WHERE Id IN :oldMgrIds AND isActive=true and Discount_Role__c != NULL]);
                    uIdSet.putAll(oldMgrMap);
                }
                CalculateDiscountRole uBatch = new CalculateDiscountRole(uIdSet);
                Database.executeBatch(uBatch);
            }
        }
    }
    
    public static String discountRoleOnUser(Map<Id, User> uMap) { 
        List < User > updateUsrList = new List < User > ();
        Set<String> uGlbId = new Set<String>();
        Set<String> uMIds = new Set<String>();
        Set<String> uM2Ids = new Set<String>();
        Set<String> uM3Ids = new Set<String>();
        Set<String> uM4Ids = new Set<String>();
        Set<String> uM5Ids = new Set<String>();
        String err = '';
        List<User> uList =[Select id,Managerid,Manager_Global_Id__c,Global_Id__c, 
                           Name,Discount_Role__c,isActive from User where ManagerId IN:uMap.keySet() and isActive =true];
        if(uList.size()>0){
            for (User usrObj: [Select id,Discount_Role__c,Global_ID__c,ManagerId,Manager.Manager.Id,Manager.Manager.Manager.Id from User where id IN:uMap.keySet()]) {
                System.debug('UserDetails'+usrObj.Discount_Role__c + usrObj.ManagerId + usrObj.id);
                if(usrObj.Discount_Role__c!=null) {
                    uGlbId.add(usrObj.id);
                    uMIds.add(usrObj.ManagerId);
                    uM2Ids.add(usrObj.Manager.Manager.Id);
                    uM3Ids.add(usrObj.Manager.Manager.Manager.Id);
                }
            }
            Set<String> m1LIds = new Set<String>();
            Map<String, User> mLMap = new Map<String, User>();
            for(User u :[Select id,Managerid,Manager_Global_Id__c,Manager.Manager.Id,Manager.Manager.Manager.Id,
                         Manager.Manager.Manager.Manager.Id,Manager.Manager.Manager.Manager.Manager.Id,
                         Manager.Manager.Manager.Manager.Manager.Manager.Id,Global_Id__c,
                         Name,Discount_Role__c,isActive from User where isActive=true and (Managerid IN:uGlbId
                                                                                           OR Manager.Manager.Id IN:uGlbId
                                                                                           OR Manager.Manager.Manager.Id IN:uGlbId 
                                                                                           OR Manager.Manager.Manager.Manager.Id IN:uGlbId 
                                                                                           OR Manager.Manager.Manager.Manager.Manager.Id IN:uGlbId 
                                                                                           OR Manager.Manager.Manager.Manager.Manager.Manager.Id IN:uGlbId)]){
                                                                                               mLMap.put(u.Id, u);   
                                                                                           }
            Set<String> AdL2Setids = new Set<String>();
            Set<String> AdL3Setids = new Set<String>();
            Set<String> AdL4Setids = new Set<String>();
            Set<String> AdL5Setids = new Set<String>();
            Set<String> AdL6Setids = new Set<String>();
            Set<String> AMSetids = new Set<String>();
            Set<String> SalesSetids = new Set<String>();
            for(User u : mLMap.values()){
                if((mLMap.containsKey(u.Manager.Manager.Id)) || (mLMap.containsKey(u.Manager.Manager.Manager.Id)) || (mLMap.containsKey(u.Manager.Manager.Manager.Manager.Id)) || (mLMap.containsKey(u.Manager.Manager.Manager.Manager.Manager.Id)) || (mLMap.containsKey(u.Manager.Manager.Manager.Manager.Manager.Manager.Id))){
                    AdL2Setids.add(u.Manager.Manager.Id);AdL3Setids.add(u.Manager.Manager.Manager.Id);AdL4Setids.add(u.Manager.Manager.Manager.Manager.Id);AdL5Setids.add(u.Manager.Manager.Manager.Manager.Manager.Id);AdL6Setids.add(u.Manager.Manager.Manager.Manager.Manager.Manager.Id);
                }if(mLMap.containsKey(u.ManagerId) ){
                    AMSetids.add(u.ManagerId);    
                }
            }
            Set<Id> sIds = new Set<id>();
            for(User u : [Select id,Managerid,Global_Id__c,Profile.Name,
                          Name,Discount_Role__c,isActive,Manager.Discount_Role__c from User 
                          where isActive=true and (ID IN:AdL2Setids 
                                                   OR ID IN: AdL3Setids OR ID IN:AdL4Setids 
                                                   OR ID IN:AdL5Setids OR ID IN:AdL6Setids)]){
                                                       if(u.Profile.Name != null && !uMap.ContainsKey(u.id) && u.Profile.Name !='BPM Partner Community User' && u.Profile.Name !='AR Collector' && !uMIds.contains(u.id) && !uM2Ids.contains(u.id) && !uM3Ids.contains(u.id)){
                                                           if(u.Discount_Role__c!='RVP' && (u.Manager.Discount_Role__c!='AM' || u.Manager.Discount_Role__c!='AD')){
                                                               if(u.Manager.Discount_Role__c =='RVP'){ sIds.add(u.id); u.Discount_Role__c ='AD';updateUsrList.add(u);
                                                                                                     }else{
                                                                                                         sIds.add(u.id); u.Discount_Role__c ='AM';updateUsrList.add(u);
                                                                                                     }
                                                           }
                                                       }
                                                   }
            Set<Id> s1Ids = new Set<Id>();
            for(User u : [Select id,Managerid,Global_Id__c,Profile.Name,Manager.Discount_Role__c,
                          Name,Discount_Role__c,isActive from User where isActive=true and ID IN:AMSetids]){
                              if(u.Profile.Name !=null && !uMap.ContainsKey(u.id) && u.Profile.Name !='BPM Partner Community User' && u.Profile.Name !='AR Collector' && u.Discount_Role__c !='RVP'){
                                  if(!sIds.Contains(u.id) && !uMIds.contains(u.id) && !uM2Ids.contains(u.id) && !uM3Ids.contains(u.id)){
                                      if(u.Discount_Role__c!='RVP' && (u.Manager.Discount_Role__c!='AM' || u.Manager.Discount_Role__c!='AD')){  s1Ids.add(u.Id);
                                          u.Discount_Role__c ='AM'; updateUsrList.add(u);
                                      }
                                  }
                              }
                          }
            for(User u : [Select id,Managerid,Global_Id__c,Profile.Name,Manager.Discount_Role__c,
                          Name,Discount_Role__c,isActive from User where isActive=true and ID IN:mLMap.KeySet()]){
                              if(u.Profile.Name !=null && !uMap.ContainsKey(u.id) && u.Profile.Name !='BPM Partner Community User' && u.Profile.Name !='AR Collector'){
                                  if(!s1Ids.contains(u.Id) && !sIds.contains(u.Id) && !uMIds.contains(u.id) && !uM2Ids.contains(u.id) && !uM3Ids.contains(u.id)){
                                      if(u.Discount_Role__c!='RVP' && (u.Manager.Discount_Role__c!='AM' || u.Manager.Discount_Role__c!='AD')){
                                          u.Discount_Role__c ='Sales';updateUsrList.add(u);
                                      }
                                  } 
                              }
                          }
            if(!updateUsrList.isEmpty()) {
                try {                    
                    update updateUsrList;
                    
                    if(Test.isRunningTest()) throw new CustomException('testing error');
                } catch(Exception e) {
                    err += 'Error:' + e.getMessage() + ',' + e.getStackTraceString() + '<br/><p>';
                    for(User u : updateUsrList) {
                        err += u.Name + '-' + u.Id + '<br/>';    
                    }
                    err += '</p>';
                }
            }
            
        }else{
            for(User u : [Select id,Discount_Role__c from User where id IN:uMap.keySet()]){
                u.Discount_Role__c='Sales'; updateUsrList.add(u);
            }
            if(!updateUsrList.isEmpty()){
                try {
                    update updateUsrList;
                } catch(Exception e) {    
                    err += 'Error:' + e.getMessage() + ','  + e.getStackTraceString() + '<br/><p>';
                    for(User u : updateUsrList) {
                        err += u.Name + '-' + u.Id + '<br/>';    
                    } 
                    err += '</p>';
                }
            }
        }
        return err;
    } 
    
    public class CustomException extends Exception {}
}