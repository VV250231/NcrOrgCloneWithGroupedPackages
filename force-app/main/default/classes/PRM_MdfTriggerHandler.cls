public without sharing class PRM_MdfTriggerHandler {
    
    /*Created By	Tim Sherwood,  05/05/2009 
    * fill partner Account__c name on request.
    * before insert, update.
    */
    public void updatePartnerAccountInfo(List<SFDC_MDF__c> newRecords) {
        
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        //Loop through each fund request and create a Set of all the UserIds for the fund request owners 
        for (SFDC_MDF__c fundRequest : newRecords) {
            //Figure out the owner ids of the fund requests 
            ownerIds.add(fundRequest.OwnerId);
        }
        
        //Create a map of the owernids to their partner accounts
        Map<Id,User> partnerAccts = new Map<Id,User>([Select Id, Contact.Account.Id, AccountId from User where id in :ownerIds]);
        
        //Now loop through each fund request to set the Partner Account Id on the request
        for (SFDC_MDF__c fundRequest : newRecords) {
            
            //Only update the value for records that have an owner = partnerAccount
            if ((partnerAccts.get(fundRequest.OwnerId).Contact.Account.Id != NULL) && (fundRequest.Account__c == NULL)) {
                fundRequest.Account__c = partnerAccts.get(fundRequest.OwnerId).Contact.Account.Id;
            }
        }
        
        for (SFDC_MDF__c fr : newRecords) {
            if (fr.Account__c != null){
                accountIds.add(fr.Account__c);
            }
        }

        Map<Id,Account> actIdToAct  = new Map<Id,Account>([SELECT Id, Name, OwnerId, Owner.ManagerId, Account_Region__c, Partner_Industry__c,
                                      Partner_Type__c FROM Account WHERE Id IN : accountIds]);

        
        for (SFDC_MDF__c fr : newRecords) {
            if (actIdToAct.containsKey(fr.Account__c)) {
                if (actIdToAct.get(fr.Account__c).OwnerId != null){
                    fr.CAM__c = actIdToAct.get(fr.Account__c).OwnerId;
                }

                if (actIdToAct.get(fr.Account__c).OwnerId != null && actIdToAct.get(fr.Account__c).Owner.ManagerId != null) {
                    fr.RCL__c = actIdToAct.get(fr.Account__c).Owner.ManagerId;
                }

                if (actIdToAct.get(fr.Account__c).Account_Region__c != null) {
                    fr.Region__c = actIdToAct.get(fr.Account__c).Account_Region__c;
                }

                if (actIdToAct.get(fr.Account__c).Partner_Industry__c != null) {
                    fr.LOB__c = actIdToAct.get(fr.Account__c).Partner_Industry__c;
                }

                if (actIdToAct.get(fr.Account__c).Partner_Type__c != null) {
                    fr.Account_Partner_Type__c = actIdToAct.get(fr.Account__c).Partner_Type__c;
                }
            }
        }
    }
    
 
    // When partner user create MDF Request it get shared with CAM and RCL 
    //by OWD - Grand Access by User Hirarchy.
    // Now suppose someone manully change CAM OR RCL on Request then Request should be shared with this
    //New User.
    public void updateMDFSharing(Map<id,SFDC_MDF__c> oldMap, Map<id,SFDC_MDF__c> newMap) {
        List<SFDC_MDF__Share> newMdfShrs = new List<SFDC_MDF__Share>();
        List<SFDC_MDF__Share> oldMdfShrs = new List<SFDC_MDF__Share>();
        List<SFDC_MDF__c> newList = new List<SFDC_MDF__c>();
        newList = newMap.values();
        Set<Id> userOrGroupIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        
        for (SFDC_MDF__c mdfReq : newList) {
            
                // Collect Old Sharing Records of CAM
                if (oldMap.get(mdfReq.Id).CAM__c != null && mdfReq.CAM__c != oldMap.get(mdfReq.Id).CAM__c) {
                    userOrGroupIds.add(oldMap.get(mdfReq.Id).CAM__c);
                    parentIds.add(mdfReq.Id);

                }
                // Collect Old Sharing Record of RCL
                if (oldMap.get(mdfReq.Id).RCL__c != null && mdfReq.RCL__c != oldMap.get(mdfReq.Id).RCL__c) {
                    userOrGroupIds.add(oldMap.get(mdfReq.Id).RCL__c);
                    parentIds.add(mdfReq.Id);
                }
                
                if (mdfReq.CAM__c != null && mdfReq.CAM__c != oldMap.get(mdfReq.Id).CAM__c) {
                    SFDC_MDF__Share mdfCAMShr = new SFDC_MDF__Share();
                    mdfCAMShr.UserOrGroupId = mdfReq.CAM__c;
                    mdfCAMShr.AccessLevel = 'Edit';
                    mdfCAMShr.ParentId = mdfReq.Id;
                    mdfCAMShr.RowCause = Schema.SFDC_MDF__Share.RowCause.Channel_Account_Manager__c;
                    newMdfShrs.add(mdfCAMShr);
                }

                if (mdfReq.RCL__c != null && mdfReq.RCL__c != oldMap.get(mdfReq.Id).RCL__c) {
                    SFDC_MDF__Share mdfRCLShr = new SFDC_MDF__Share();
                    mdfRCLShr.UserOrGroupId = mdfReq.RCL__c;
                    mdfRCLShr.AccessLevel = 'Edit';
                    mdfRCLShr.ParentId = mdfReq.Id;
                    mdfRCLShr.RowCause = Schema.SFDC_MDF__Share.RowCause.Regional_Channel_Leader__c;
                    newMdfShrs.add(mdfRCLShr);
                }
        }
        
        // Delete old sharing
        oldMDFShrs = [SELECT Id FROM SFDC_MDF__Share WHERE ParentId IN : parentIds AND userOrGroupId IN : userOrGroupIds AND 
                      (RowCause =: Schema.SFDC_MDF__Share.RowCause.Channel_Account_Manager__c OR
                       RowCause =: Schema.SFDC_MDF__Share.RowCause.Regional_Channel_Leader__c
                      )
                     ];
        
        try {
            // Delete old sharing
            if (oldMDFShrs.size() > 0) {
                delete oldMDFShrs;
            }

            // Insert New Sharing
            if (newMdfShrs.size() > 0) {
                Database.SaveResult[] lsr = Database.insert(newMdfShrs,false);
            }
        } catch (Exception ex) {
            System.debug('Error Message:'+ex.getMessage());
        }

    }
    /*
    //not bulkified
    public void reassignApproverOnChange (Map<id,SFDC_MDF__c> oldMap, Map<id,SFDC_MDF__c> newMap) {
        for(SFDC_MDF__c req:newMap.values()){
            if(req.CAM__c <> oldMap.get(req.Id).CAM__c){
                reassignApproverOnChangeNew(req.Id, req.CAM__c, req.RCL__c, true, false);
            }
            if(req.RCL__c <> oldMap.get(req.Id).RCL__c){
                reassignApproverOnChangeNew(req.Id, req.CAM__c, req.RCL__c, false, true);
            }
        }
        
    }

    
    private void reassignApproverOnChangeNew(String targetObjectId, String camUserId, String rclUserId, Boolean isCAMChanged, Boolean isRCLChanged){
        //String errorMsg=null;
        String actorId=null; 
        List<ProcessInstanceWorkItem> workItems = [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstanceId,p.OriginalActorId,p.Id,p.ActorId FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId =: targetObjectId AND p.ProcessInstance.Status='Pending'];
        if(workItems!=null && workItems.size()>0){ 
            String status=workItems.get(0).ProcessInstance.status;
            String processInstanceId=workItems.get(0).ProcessInstanceId;
            if(status!=null && status=='Pending'){
                Integer rejectedCount=0;
                Integer approvedCount=0;
                List<ProcessInstanceStep>  steps = [SELECT  Id, StepStatus, Comments, StepNodeId  FROM ProcessInstanceStep where ProcessInstanceId=: processInstanceId order by CreatedDate desc];
                if(steps!=null && steps.size()>0){
                   for(ProcessInstanceStep step:steps){
                       if(step.StepStatus=='Approved' ) approvedCount++;  
                       if(step.StepStatus=='Rejected' )  rejectedCount++;
                   }
                }
                
                
                // 1. REJECTED count>0 then assume record is "Rejected" by CAM/RCL/Operation Team
                // 2. APPROVED count=0 then assume record is "Pending" for CAM
                // 3. APPROVED count=1 then assume record is "Pending" for RCL and "Approved" by CAM 
                // 4. APPROVED count>1 then assume record is "Pending" for Opertaion Team and "Approved" by CAM & RCL
                
                if(rejectedCount>0){ //REJECTED count>0 then assume record is "Rejected" by CAM/RCL/Operation Team 
                    //Throw  error as "You can't change the CAM/RCL as record is already Rejected."
                    System.debug('You cant change the CAM/RCL as record is already Rejected.');
                    //errorMsg = 'You cant change the CAM/RCL as record is already Rejected.';
                } else if(approvedCount>0){
                    if(approvedCount==0){ //APPROVED count=0 then assume record is "Pending" for CAM  
                        //Set the CAM user for 'Reassigned' 
                        if(isCAMChanged) actorId =camUserId;  
                    }else if(approvedCount==1){ //APPROVED count=1 then assume record is "Pending" for RCL and "Approved" by CAM  
                        //1. if change in CAM then error
                         //  . else if Assign the RCL user to actorID
                        
                        if(isCAMChanged) {
                            //Throw error as "You can't change the CAM as first level request already Approved/Rejected."
                            System.debug('You cant change the CAM as first level request already Approved/Rejected.');
                            //errorMsg = 'You cant change the CAM as first level request already Approved/Rejected.';
                        } else if(isRCLChanged) {
                            //Set the RCL user for 'Reassigned' 
                            actorId =rclUserId; 
                        }
                    }else{//APPROVED count>1 then assume record is "Pending" for Opertaion Team and "Approved" by CAM &  
                        //if change in CAM/RCL then error always 
                        if(isCAMChanged || isRCLChanged ){
                            //Throw  error as "You can't change the CAM/RCL as first/second level request already Approved/Rejected."
                            System.debug('You cant change the CAM/RCL as first/second level request already Approved/Rejected.');
                            //errorMsg = 'You cant change the CAM/RCL as first/second level request already Approved/Rejected.';
                        }
                    }
                    
                }else{
                    //Default always assume fisrt step
                    //Set the CAM user for 'Reassigned' 
                     if(isCAMChanged) actorId =camUserId;  
                }
            }
        }  
        
        if(actorId!=null){ 
            User u1 = [SELECT id,Name FROM User  Where id=: actorId];
            System.debug('New Actor Name#'+u1.name);
            
            workItems.get(0).ActorId  =actorId; 
            update workItems; 
            System.debug('Trigger FundRequestAfterInsertAfterUpdate AFTER UPDATE: Reassigned the record to approver:'+actorId);
        }else{
            System.debug('1New Actor Name# NULL');
        }
    } */
    
}