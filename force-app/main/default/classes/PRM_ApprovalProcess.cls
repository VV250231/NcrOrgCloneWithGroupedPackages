public class PRM_ApprovalProcess {
    
    @AuraEnabled
    public static List<ApprovalDetail> getApprovalHistory(String targetObjId) {
        
        Set<Id> actorIds = new Set<id>();
        List<processInstaceCls> processInstaceLst = new List<processInstaceCls>();        
        List<ApprovalDetail> approvalDetailList = new List<ApprovalDetail>();
        List<ProcessInstance> proInstances = new List<ProcessInstance>();
        proInstances = [SELECT Id, CompletedDate, LastActorId, LastActor.Name, ProcessDefinitionId,ProcessDefinition.Name, Status, TargetObjectId,
                        (SELECT Id, ActorId, Actor.Name, OriginalActor.Name, Comments, IsPending, OriginalActorId, ProcessInstanceId, ProcessNodeId, ProcessNode.Name,
                         RemindersSent, StepStatus, TargetObjectId, CreatedDate FROM StepsAndWorkitems ORDER BY CreatedDate DESC
                        ),
                        (Select  Id, IsDeleted, LastActorId,LastActor.Name,CompletedDate, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC)
                        FROM ProcessInstance WHERE TargetObjectId = :targetObjId
                       ];
        Set<Id> actorUserIds = new Set<Id>();
        Set<Id> actorQueueIds = new Set<Id>();
        //below line will go inside the below loop
        ApprovalDetail appDetail = new ApprovalDetail();
        for (ProcessInstance pi : proInstances) {
            
            
            appDetail.showApprovalProcess = true;
            Map<String,List<ProcessInstanceHistory>> nodeIdToStepsAndWorkitemsMap = new Map<String,List<ProcessInstanceHistory>>();
            Map<String,String> actorIdToWorkItem = new Map<String,String>();
            for (ProcessInstanceHistory pih : pi.StepsAndWorkitems) {
                if(nodeIdToStepsAndWorkitemsMap.containsKey(pih.ProcessNodeId)) {
                    nodeIdToStepsAndWorkitemsMap.get(pih.ProcessNodeId).add(pih);
                } else {
                    nodeIdToStepsAndWorkitemsMap.put(pih.ProcessNodeId,new List<ProcessInstanceHistory>());
                    nodeIdToStepsAndWorkitemsMap.get(pih.ProcessNodeId).add(pih);
                }
                // Collect Actor Id if step is in pending state
                if (pih.IsPending == true) {
                    actorIds.add(pih.ActorId);
                    actorIdToWorkItem.put(pih.ActorId,pih.Id);
                }
                
            }
            
            if (actorIdToWorkItem.size() > 0) {
                if (actorIdToWorkItem.containsKey(userInfo.getUserId()))
                appDetail.workItemId = actorIdToWorkItem.get(userInfo.getUserId());
                else
                  appDetail.workItemId = actorIdToWorkItem.values()[0];  
            }
            
            if (actorIdToWorkItem.containsKey(userInfo.getUserId())) {
                appDetail.showApproveBtn = true;
            }
            
            if (actorIds.size() > 0) {
                for(Id actId: actorIds) {
                    if (actId.getSObjectType().getDescribe().getName()== 'Group') {
                        // Code is not supporting queue approval process yet. In future code needs to be modified to support Queue as well.
                        actorQueueIds.add(actId);
                    } else {
                       actorUserIds.add(actId);
                    }
                }   
            }         
            
            appDetail.processInstaceId = pi.Id;
            appDetail.completedDate = pi.CompletedDate;
            appDetail.lastActorId = pi.LastActorId;
            appDetail.lastActorName = pi.LastActor.Name;
            appDetail.processDefinitionId = pi.ProcessDefinitionId;
            appDetail.processDefinitionName = pi.ProcessDefinition.Name;
            appDetail.status = pi.Status;
            appDetail.targetObjectId = pi.TargetObjectId;
            
            processInstaceCls processInstaceObj = new processInstaceCls();
            processInstaceObj.processInstaceId = pi.Id;
            processInstaceObj.completedDate = pi.CompletedDate;
            processInstaceObj.lastActorId = pi.LastActorId;
            processInstaceObj.lastActorName = pi.LastActor.Name;
            processInstaceObj.processDefinitionId = pi.ProcessDefinitionId;
            processInstaceObj.processDefinitionName = pi.ProcessDefinition.Name;
            processInstaceObj.status = pi.Status;
            processInstaceObj.targetObjectId = pi.TargetObjectId;
            
            for (ProcessInstanceNode node : pi.Nodes) {
                processInstanceNodeClass processInsNode = new processInstanceNodeClass();
                processInsNode.processInstaceId = node.ProcessInstanceId;
                processInsNode.completedDate = node.CompletedDate;
                processInsNode.lastActorId = node.LastActorId;
                processInsNode.lastActorName = node.LastActor.Name;
                processInsNode.processNodeId = node.ProcessNodeId;
                processInsNode.processNodeName = node.ProcessNodeName;
                processInsNode.nodeStatus = node.NodeStatus;
                
                processInstaceObj.processInstanceNode.add(processInsNode);
            }
            
            List<ApprovalHistoryDetail> startStepLst = new List<ApprovalHistoryDetail>();
            List<ApprovalHistoryDetail> workItemLst = new List<ApprovalHistoryDetail>();
            List<ApprovalHistoryDetail> completedStepLst = new List<ApprovalHistoryDetail>();
            for (ProcessInstanceHistory pih : pi.StepsAndWorkitems) {
                ApprovalHistoryDetail detail = new ApprovalHistoryDetail();               
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
                        startStepLst.add(detail);
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
                        completedStepLst.add(detail);
                    }
                } else {
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
                    workItemLst.add(detail);
                }              
            }  
            appDetail.appHistoryDetailLst.addAll(workItemLst);
            appDetail.appHistoryDetailLst.addAll(completedStepLst);
            appDetail.appHistoryDetailLst.addAll(startStepLst);
            
        }
		approvalDetailList.add(appDetail);
        List<GroupMember> queueMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : actorQueueIds];
        return approvalDetailList;
    }
    
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
    
    public class ApprovalDetail {
        @AuraEnabled public Boolean showLink;
        
        @AuraEnabled public Boolean isApprover;
        @AuraEnabled public Boolean showApprovalProcess = false;
        
        @AuraEnabled public Id processInstaceId;       
        @AuraEnabled public DateTime completedDate;
        @AuraEnabled public Id lastActorId;
        @AuraEnabled public String lastActorName;
        @AuraEnabled public Id processDefinitionId;
        @AuraEnabled public String processDefinitionName;
        @AuraEnabled public String status;
        @AuraEnabled public Id targetObjectId;
        @AuraEnabled public String workItemId;
        @AuraEnabled public Boolean showApproveBtn = false;
        
        @AuraEnabled
        public List<ApprovalHistoryDetail> appHistoryDetailLst = new List<ApprovalHistoryDetail>();
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
        
        // Nodes should be added into the list into the descending order of their creation
        @AuraEnabled
        public List<processInstanceNodeClass> processInstanceNode = new List<processInstanceNodeClass>();
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
    
    public class ApprovalHistoryDetail {
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