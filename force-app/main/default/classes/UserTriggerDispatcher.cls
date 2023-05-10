/****************************************************************************************************************
* Author        :   Yogesh Singh    
* Param         :   User  :   User
* Return        :   
* Description   : combined the Multipile trigger into single Trigger - Sprint 13--- 2020  

****************************************************************************************************************/
/************************************************************************************************* 
* Update By		:   Pankaj Kashyap For Story : EBA_SF-1628 // 9 Dec 2021
* Param         :   User  :   
* Return        :   
* Description   :   Add a check for on line 683 
*************************************************************************************************/

public class UserTriggerDispatcher extends TriggerHandlerBase{
    private static UserTriggerHandler UsrHandlr; //UsrHandlr
    /****************************************************************************************************************  
* Description   : Start before Insert Event   
****************************************************************************************************************/
    public override void beforeInsert() {
        UsrHandlr = (UsrHandlr != null) ? UsrHandlr : new UserTriggerHandler();
        List<User> uList = (List<User>) Trigger.New;
        UsrHandlr.UserCreationAutomation(uList);       //   Project Name - NSC Sales Central, Created by: Shephalika Belapurkar                                                                               
        UsrHandlr.SelectDoNotDeactivatebyDefault(uList);  //   Project Name - ------------------, Created by: Dev Admin                                                                                    
        UsrHandlr.CalculateIsManagerFlag(uList);     //   Project Name - NSC CRM 2017, Sales Order Reporting, Created by: Mudasir Rashid                                                                               
        UsrHandlr.CalculateRegionHierarchy(uList);    //   Project Name - Sales Order Reporting, Created by: Mudasir Rashid                                                                               
        UsrHandlr.updateUser(uList);            //Project Name - ---------------------, Created by: Admin NSC
        UsrHandlr.updateStartDateAndManager(uList);
        
    }   
    /****************************************************************************************************************  
* Description   : End before Insert Event   
****************************************************************************************************************/
    /****************************************************************************************************************  
* Description   : Start After Insert Event   
****************************************************************************************************************/
    public override void afterInsert() {
        UsrHandlr = (UsrHandlr != null) ? UsrHandlr : new UserTriggerHandler();
        List<User> uSList = new List<User>();
        List<User> uList = (List<User>) Trigger.New;
        UsrHandlr.UserTriggerAiAuAfterInsert(uList); //Project Name - ---------------------, Created by: Shiv Mahla                                                                      
      //  UsrHandlr.AddUserToPramataGroup(uList);     //Project Name - ---------------------, Created by: Mudasir Rashid 
        //Santosh
        List<User> prtnrUsersForSharing = new List<User>();
        Set<Id> ICMUserIds = new Set<Id>();
        if(DiscountRoleOnUserHierarchy.isTrue){
            DiscountRoleOnUserHierarchy.isTrue=false;
            DiscountRoleOnUserHierarchy.discountRoleOnUInsert(uList);
        }
        
        for(User u : uList){
            if(u.isActive && u.ContactId != null && (!u.IsBPMUser__c)){
                uSList.add(u);                
            }
            if(u.CPQ_Pilot__c && u.isActive && u.ContactId != null && (u.UserType == 'Partner' || u.UserType == 'Power Partner' || u.UserType=='PowerPartner' ) ){
                prtnrUsersForSharing.add(u); 
            }
            if(u.ICM_User__c && u.isActive && u.Usertype=='Standard') {
            	ICMUserIds.add(u.Id);    
            }
        }
        if(!uSList.isEmpty())
            UsrHandlr.portalRoleBasedAccess(uSList);  //Project Name - ---------------------, Created by: Shiv Mahla         
        if(!System.isFuture() && !System.isBatch() && !prtnrUsersForSharing.isEmpty())
            UserTriggerHandler.insertUsersInAccountTeam(prtnrUsersForSharing,false);
        
        if(!ICMUserIds.isEmpty()) {
            if(!System.isFuture() && !System.isBatch() && !System.isQueueable()) {
        		UserTriggerHandler.asgnICMPrmSetinFtr(ICMUserIds, null); 
            } else {
            	UserTriggerHandler.asgnICMPrmSet(ICMUserIds, null);     
            }
        }
    }
    /****************************************************************************************************************  
* Description   : End After Insert Event   
****************************************************************************************************************/
    /****************************************************************************************************************  
* Description   : Start before Update Event   
****************************************************************************************************************/
    public override void beforeUpdate() {
        UsrHandlr = (UsrHandlr != null) ? UsrHandlr : new UserTriggerHandler();
        List<User> uList = (List<User>) Trigger.New;
        UsrHandlr.SAMLAutoProvisioning(uList,(Map<Id,User>)Trigger.OldMap);
        USER_Masking_Helper.maskall(uList);          //Project Name - ---------------------, Created by: Sagar Kinja                                                                     
        UsrHandlr.CalculateIsManagerFlag(uList);    //   Project Name - Sales Order Reporting, Created by: Mudasir Rashid
        UsrHandlr.CalculateRegionHierarchy(uList);
        UsrHandlr.updateUser(uList);
        UsrHandlr.updateStartDateAndManagerOnUpdate(uList, (Map<Id,User>)Trigger.OldMap);
        //Changes For UpdateUSer
        for(Id userid : Trigger.NewMap.keyset()){
            If(!((User)Trigger.newMap.get(userId)).IsPortalEnabled && ((User)Trigger.OldMap.get(userId)).IsPortalEnabled){
                String TempString ='_'+ ((User)trigger.newMap.get(userId)).FederationIdentifier;
                if(TempString .length() > 8) {
                    TempString = TempString.substring(0, 8);
                }
                ((User)trigger.newMap.get(userId)).FederationIdentifier = TempString ;
                ((User)trigger.newMap.get(userId)).Quicklook_ID__c = TempString ;
            }
        }
    }
    //End UpdateUser
    
    /****************************************************************************************************************  
* Description   : End before update Event   
****************************************************************************************************************/
    /****************************************************************************************************************  
* Description   : Start after Update Event   
****************************************************************************************************************/
    public override void afterUpdate() {
        UsrHandlr = (UsrHandlr != null) ? UsrHandlr : new UserTriggerHandler();
        List<User> uList = (List<User>) Trigger.New;
        Map<id, User> uOldMap = (Map<Id,User>)Trigger.OldMap;
        List<User> userList = new List<User>();
        List<User> uPRList = new List<User>();
        Set<String> UIdSet = new Set<String>();
        List<User> UIdList = new List<User>();
        Set<String> QlookIdSet = new Set<String>();        
        //Santosh/ajay: Partner Acc Sharing Logic
        List<id> prtnrUsersForSharing = new List<id>();
        List<id> prtnrUsersForSharingtobeRemoved = new List<id>();
        List<User> cpqPrtnrUsersForShare = new List<User>();
        List<User> cpqPrtnrUsersForUNShare = new List<User>();
        if(System.Label.APOCStopActionOnDeactivateUserTrigger =='false'){
            Set<User> UserSet = new Set<User>();
            if(UserDeactivateNotification.isfrst){
                for(User usr : uList){
                    if(((uOldMap.get(usr.id)).isActive && (!usr.isActive))){
                        UserSet.add(usr);
                    }
                }
                UserDeactivateNotification.validateUser(UserSet);  //   Project Name - BPM, Created by: Varsha Pal
            }
        }
        //  UsrHandlr.AddUserToPramataGroup(uList); // Need to anaysis because it is not in Use
        Set<id> UIdsSet = new Set<Id>();
        Set<Id> ICMUserIds = new Set<Id>(), nonICMUserIds = new Set<Id>();
        for(User u :uList){
            if((uOldMap.get(u.id)).isActive != u.IsActive){
                userList.add(u);
                UIdsSet.add(u.id);
            }
            if((u.isActive != (uOldMap.get(u.id)).isActive) && u.isActive && u.ContactId != null){
                uPRList.add(u);
            }
            if(u.CPQ_Pilot__c && u.isActive && u.ContactId != null && (u.UserType == 'Partner' || u.UserType == 'Power Partner' || u.UserType=='PowerPartner' ) && ((u.CPQ_Pilot__c && uOldMap.get(u.id).CPQ_Pilot__c==false) ||u.Partner_Owned_Accounts__c!=uOldMap.get(u.id).Partner_Owned_Accounts__c ||(u.isActive && uOldMap.get(u.id).isActive==false) )){
                cpqPrtnrUsersForShare.add(u);                
            }
            if(u.ContactId != null && (u.UserType == 'Partner' || u.UserType == 'Power Partner' || u.UserType=='PowerPartner' ) && (u.CPQ_Pilot__c==false && uOldMap.get(u.id).CPQ_Pilot__c==true)){
                cpqPrtnrUsersForUNShare.add(u); 
            }
            
            if(u.ICM_User__c && u.isActive && u.Usertype == 'Standard' 
               	&& (u.ICM_User__c != uOldMap.get(u.id).ICM_User__c || u.isActive != uOldMap.get(u.id).isActive || u.UserType !=  uOldMap.get(u.id).UserType)) {
            	ICMUserIds.add(u.Id);    
            } else if(u.ICM_User__c == false && uOldMap.get(u.id).ICM_User__c == true) {
           		nonICMUserIds.add(u.Id);     
            }
            
        }
        if(DiscountRoleOnUserHierarchy.isTrue){
            DiscountRoleOnUserHierarchy.isTrue=false;
            DiscountRoleOnUserHierarchy.discountRoleOnUupdate(uList, uOldMap);
        }
        
        if(!UIdsSet.isEmpty() && !UserNotifyBeforeThenDeactivationBatch.CheckForInactiveUser) {
            
            if(!System.isFuture() && !System.isBatch())
                UserTriggerHandler.ListOfInactiveUserinFtr(UIdsSet);
            else 
                UserTriggerHandler.ListOfInactiveUser(UIdsSet);  
        }
        UsrHandlr.updateCompensationRecords(uList, uOldMap);
        UsrHandlr.deleteteammembers(uList, uOldMap);
        UsrHandlr.UserTriggerAiAuAfterUpdate(uList, uOldMap);
        UsrHandlr.portalRoleBasedAccess(uPRList);
        //UsrHandlr.ListOfInactiveUser(uList);
        //system.debug('bawali'+prtnrUsersForSharing);
        if(!System.isFuture() && !System.isBatch() && !cpqPrtnrUsersForShare.isEmpty())
        {
            UserTriggerHandler.insertUsersInAccountTeam(cpqPrtnrUsersForShare,false);
        }        
        if(!System.isFuture() && !System.isBatch() && !cpqPrtnrUsersForUNShare.isEmpty())
        {  
            UserTriggerHandler.insertUsersInAccountTeam(cpqPrtnrUsersForUNShare,true);
        }
        
        
        if(!ICMUserIds.isEmpty() || !nonICMUserIds.isEmpty()) {
            if(!System.isFuture() && !System.isBatch() && !System.isQueueable()) {
        		UserTriggerHandler.asgnICMPrmSetinFtr(ICMUserIds,nonICMUserIds); 
            } else {
            	UserTriggerHandler.asgnICMPrmSet(ICMUserIds,nonICMUserIds);     
            }
        }
    }
    /****************************************************************************************************************  
* Description   : End after update Event   
****************************************************************************************************************/
}