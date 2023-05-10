public class PRM_ApprovalProcessQueue {
    public static String wiRec; // Only used to run test class. Don't use this variable some where else. 
    
    @AuraEnabled
    public static List<processInstaceCls> getApprovalHistory(String targetObjId) {
        
        List<Group> queues = new List<Group>();
        Map<Id,List<Id>> groupIdToGroupMemberId = new Map<Id,List<Id>>();
        queues = [SELECT Id, Name, DeveloperName, Email, (SELECT GroupId,UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName IN ('DR_Retail_Queue','DR_Hospitality_Queue','DR_Financial_Queue','Channel_Operation_Deal_Registration')];
        for (Group g : queues) {
            if (!groupIdToGroupMemberId.containsKey(g.Id)) {
                groupIdToGroupMemberId.put(g.Id, new List<Id>());
            }
            for (GroupMember gm : g.GroupMembers) {
                groupIdToGroupMemberId.get(gm.GroupId).add(gm.UserOrGroupId);
            }
        }
        
        Set<Id> actorIds = new Set<id>();
        List<processInstaceCls> processInstaceLst = new List<processInstaceCls>();        
        List<ProcessInstance> proInstances = new List<ProcessInstance>();
        
        proInstances = [SELECT Id, CompletedDate, LastActorId, LastActor.Name, ProcessDefinitionId,ProcessDefinition.Name, Status, TargetObjectId,
                        (Select  Id, IsDeleted, LastActorId,LastActor.Name,CompletedDate, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC),
                        (SELECT Id, ActorId, Actor.Name, OriginalActor.Name, Comments, IsPending, OriginalActorId, ProcessInstanceId, ProcessNodeId, ProcessNode.Name,
                         RemindersSent, StepStatus, TargetObjectId, CreatedDate FROM StepsAndWorkitems ORDER BY CreatedDate DESC
                        )
                        FROM ProcessInstance WHERE TargetObjectId = :targetObjId ORDER BY CreatedDate DESC];
        
        Set<Id> actorUserIds = new Set<Id>();
        Map<Id,List<Id>> processInstaceIdToActorUserIds = new Map<Id,List<Id>>();
        Set<Id> actorQueueIds = new Set<Id>();
        Map<Id,Id> processInstaceIdToActorQueueIds = new Map<Id,Id>();
        Map<Id,Id> actorIdToWorkItemId = new Map<Id,Id>();
        
        for (ProcessInstance pi : proInstances) {
            
            // Creating object for first process instace.
            processInstaceCls processInstaceObj = new processInstaceCls();
            processInstaceObj.processInstaceId = pi.Id;
            processInstaceObj.completedDate = pi.CompletedDate;
            processInstaceObj.lastActorId = pi.LastActorId;
            processInstaceObj.lastActorName = pi.LastActor.Name;
            processInstaceObj.processDefinitionId = pi.ProcessDefinitionId;
            processInstaceObj.processDefinitionName = pi.ProcessDefinition.Name;
            processInstaceObj.status = pi.Status;
            processInstaceObj.targetObjectId = pi.TargetObjectId;
            
            // Creating list of nodes for the current instance.
            for (ProcessInstanceNode node : pi.Nodes) {
                processInstanceNodeClass processInsNode = new processInstanceNodeClass();
                processInsNode.processInstaceId = node.ProcessInstanceId;
                processInsNode.completedDate = node.CompletedDate;
                processInsNode.lastActorId = node.LastActorId;
                processInsNode.lastActorName = node.LastActor.Name;
                processInsNode.processNodeId = node.ProcessNodeId;
                processInsNode.processNodeName = node.ProcessNodeName;
                processInsNode.nodeStatus = node.NodeStatus;
                processInstaceObj.processInstanceNodeMap.put(node.ProcessNodeId,processInsNode);
            }
            
            
            for (ProcessInstanceHistory pih : pi.StepsAndWorkitems) {
                processInstanceHistorycls detail = new processInstanceHistorycls();               
                if (pih.IsPending == false) {
                    // Adding completed list of steps
                    if (pih.StepStatus == 'Started') {
                        detail.processInstanceId = pih.ProcessInstanceId;
                        detail.id = pih.Id;
                        detail.actorId = pih.ActorId;
                        detail.actorName = pih.Actor.Name;
                        detail.originalActorId = pih.OriginalActorId;
                        detail.originalActorName = pih.OriginalActor.Name;
                        detail.stepName = 'Approval Request Submitted';
                        detail.stepStatus = 'Submitted';
                        detail.createdDate = pih.CreatedDate;
                        detail.comment = pih.Comments;
                        processInstaceObj.submitStep = detail;
                    } else {
                        detail.processInstanceId = pih.ProcessInstanceId;
                        detail.id = pih.Id;
                        detail.actorId = pih.ActorId;
                        detail.actorName = pih.Actor.Name;
                        detail.originalActorId = pih.OriginalActorId;
                        detail.originalActorName = pih.OriginalActor.Name;
                        detail.stepName = pih.ProcessNode.Name;
                        detail.stepStatus = pih.StepStatus;
                        detail.createdDate = pih.CreatedDate;
                        detail.comment = pih.Comments;
                        processInstaceObj.processInstanceNodeMap.get(pih.ProcessNodeId).processStepsAndWorkitems.add(detail);
                    }
                } else {
                    String strActorObjectName = pih.ActorId.getSObjectType().getDescribe().getName();
                    
                    actorIdToWorkItemId.put(pih.ActorId, pih.Id);
                    // Adding work Item into the list
                    detail.processInstanceId = pih.ProcessInstanceId;
                    detail.id = pih.Id;
                    detail.actorId = pih.ActorId;
                    detail.actorName = pih.Actor.Name;
                    detail.originalActorId = pih.OriginalActorId;
                    detail.originalActorName = pih.OriginalActor.Name;
                    detail.stepName = pih.ProcessNode.Name;
                    detail.stepStatus = pih.StepStatus;
                    detail.createdDate = pih.CreatedDate;
                    detail.comment = pih.Comments;
                    processInstaceObj.processInstanceNodeMap.get(pih.ProcessNodeId).processStepsAndWorkitems.add(detail);
                    wiRec = pih.Id; // Only for test class. Don't use this variable some where else.
                }              
            }
            
            /* There is no good way to interate over a Map in lightning component, so I am not iterating over nodes. I am interating over the list by the help of below code.*/
            
            /* Start */
            for(processInstanceNodeClass obj: processInstaceObj.processInstanceNodeMap.values()) {
                processInstaceObj.processStepsAndWorkitemLst.addAll(obj.processStepsAndWorkitems);
            }
            processInstaceObj.processStepsAndWorkitemLst.add(processInstaceObj.submitStep);
            processInstaceLst.add(processInstaceObj);
            /*End*/
            
        }
        
        //Added by Ritesh Kumar
    	Set<String> emailSet = new Set<String>();        
        for(Deal_Registration_Approval_User__c drApprovalUser : [Select Name,Approver_Email__c from Deal_Registration_Approval_User__c]){
            if(drApprovalUser.Approver_Email__c != null){
                emailSet.add(drApprovalUser.Approver_Email__c);
            }
        }  
        
        for (processInstaceCls obj : processInstaceLst) {
            // If Actor Id is the Id of user.
            if (actorIdToWorkItemId.containsKey(userInfo.getUserId())) {
                obj.isApprover = true;
                obj.workItemId = actorIdToWorkItemId.get(userInfo.getUserId());
                system.debug('***');
            //else if ((userInfo.getUserId() == '00570000003j2ZzAAI' || userInfo.getUserId() == '00570000001RIZyAAO' || userInfo.getUserId() == '00570000003VASfAAO' || userInfo.getUserId() =='00570000003iEpsAAE') && actorIdToWorkItemId.values().size() > 0) {
            } else if ((emailSet.toString().containsIgnoreCase(UserInfo.getUserEmail())) && actorIdToWorkItemId.values().size() > 0) {
                obj.isApprover = true;
                obj.workItemId = actorIdToWorkItemId.values()[0];
            } else {
                // If Actor Id is the Id of Group, then we need to check either current user is the member of that group or not.
                for(Id actId : actorIdToWorkItemId.keySet()) {
                    system.debug('^^^'+groupIdToGroupMemberId);
                    if (groupIdToGroupMemberId.containsKey(actId) && groupIdToGroupMemberId.get(actId).contains(userInfo.getUserId())) {
                        obj.isApprover = true;
                        obj.isQueueMember = true;
                        obj.workItemId = actorIdToWorkItemId.get(actId);
                        system.debug('***');
                    }
                }
            }
        }
        
        return processInstaceLst;
    }
    
    
    /** 
* Approve OR Rejects the request
* 
*/
    
    @AuraEnabled
    public static String processRequest(String comment, String workItemId, String operation) 
    {
        try{
            String res;
            Approval.ProcessWorkitemRequest wiReq = new Approval.ProcessWorkitemRequest();
            wiReq.setWorkitemId(workItemId);
            wiReq.setAction(operation);
            wiReq.setComments(Comment);
            
            Approval.ProcessResult appProcessRes =  Approval.process(wiReq);
            
            if (operation == 'Approve')
                res = 'Approved';
            else if (operation == 'Reject')
                res = 'Rejected';
            
            return res;
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static String requestReassign(String comment, String workItemId, String targetObjId) 
    {
        try
        {
            Deal_Registration__c objDR = [Select Id, Name, Deal_Name__c, Is_Reassign_Approval_to_CAM__c,Parnter_Contact_formula__c, Master_Customer_Number__c, NCR_Account_Manager__c,NCR_Account_Manager__r.Name
                                          from Deal_Registration__c where Id =: targetObjId];
            //Deal_Registration__c objDR = new Deal_Registration__c(Id = targetObjId);
            objDR.Approval_Reassignment_Comment__c = comment;
            objDR.Is_Reassign_Approval_to_CAM__c = true;
            update objDR;
            
            ProcessInstanceWorkItem objWork = new ProcessInstanceWorkItem(id = workItemId);
            objWork.ActorId = objDR.NCR_Account_Manager__c;            
            update objWork;
            
            return 'Reassigned';
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
    }    
    @AuraEnabled
    public static boolean CheckModiffyAllPermission(){
        /*ObjectPermissions objp = [SELECT Id, ParentId, SobjectType,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Deal_Registration__c' AND Parent.ProfileId = : UserInfo.getProfileId()];
        if (objp.PermissionsModifyAllRecords) 
        return true;
        else 
        return false;*/
        boolean isPermission = false;
        User usr = [SELECT Id, Quicklook_ID__c FROM User WHERE Id  = : UserInfo.getUserId()];
        System.debug('user : '+usr);
        String[] QLIds = System.Label.Deal_Registration_ReAssign_Permission.split(',');
        System.debug('QLIds : '+QLIds);
        for(String qlid : QLIds){
            System.debug('qlid : '+qlid);
            if(qlid.equalsIgnoreCase(usr.Quicklook_ID__c)){
                isPermission =true;            }
        }
        return isPermission;
    }
    @AuraEnabled
    public static String requestReassignToUser(String comment, String workItemId, String targetObjId, String UserID) 
    { 
        try
        {
            Deal_Registration__c objDR = [Select Id, Name, Deal_Name__c, Is_Reassign_Approval_to_CAM__c,Parnter_Contact_formula__c, Master_Customer_Number__c, NCR_Account_Manager__c,NCR_Account_Manager__r.Name
                                          from Deal_Registration__c where Id =: targetObjId];
            //Deal_Registration__c objDR = new Deal_Registration__c(Id = targetObjId);
            objDR.Approval_Reassignment_Comment__c = comment;
            update objDR;
            
            ProcessInstanceWorkItem objWork = new ProcessInstanceWorkItem(id = workItemId);
            objWork.ActorId = UserID;            
            update objWork;
            
            return 'Reassigned';
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
    }    
    
    
    public class processInstaceCls {        
        @AuraEnabled public Id processInstaceId;       
        @AuraEnabled public DateTime completedDate;
        @AuraEnabled public Id lastActorId;
        @AuraEnabled public String lastActorName;
        @AuraEnabled public Id processDefinitionId;
        @AuraEnabled public String processDefinitionName;
        @AuraEnabled public String status;
        @AuraEnabled public Id targetObjectId;
        
        @AuraEnabled public Map<Id,Id> actorIdToWorkItemId = new Map<Id,Id>();
        @AuraEnabled public Boolean isApprover = false;
        @AuraEnabled public Boolean isQueueMember = false;
        @AuraEnabled public String workItemId;
        @AuraEnabled public processInstanceHistorycls submitStep; // Since this history step / process step is not associated with any instance node so specifying it seperatly.
        // Nodes should be added into the list into the descending order of their creation
        @AuraEnabled
        public Map<String,processInstanceNodeClass> processInstanceNodeMap = new Map<String,processInstanceNodeClass>();
        @AuraEnabled public List<processInstanceHistorycls> processStepsAndWorkitemLst = new List<processInstanceHistorycls>();
    }
    
    public class processInstanceNodeClass {        
        @AuraEnabled public Id processInstaceId;       
        @AuraEnabled public DateTime completedDate;
        @AuraEnabled public Id lastActorId;
        @AuraEnabled public String lastActorName;
        @AuraEnabled public Id processNodeId;
        @AuraEnabled public String processNodeName;
        @AuraEnabled public String nodeStatus;
        
        @AuraEnabled
        public List<processInstanceHistorycls> processStepsAndWorkitems = new List<processInstanceHistorycls>();
    }
    
    //ProcessInstanceHistory can help provide a unified read-only view of the ProcessInstanceStep and ProcessInstanceWorkitem objects.
    public class processInstanceHistorycls {
        @AuraEnabled public Id processInstanceId;
        @AuraEnabled public Id id;
        @AuraEnabled public Id actorId;
        @AuraEnabled public String actorName;
        @AuraEnabled public Id originalActorId;
        @AuraEnabled public String originalActorName;
        @AuraEnabled public String stepStatus;
        @AuraEnabled public String comment;
        @AuraEnabled public String stepName;
        @AuraEnabled public DateTime createdDate;
    }
    
    
}