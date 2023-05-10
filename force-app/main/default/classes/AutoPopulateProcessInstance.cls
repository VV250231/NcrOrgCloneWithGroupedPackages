public class AutoPopulateProcessInstance implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        String pendingProcessInstance = 'SELECT Id, TargetObjectId, ProcessDefinition.Name, (SELECT ProcessNodeName, NodeStatus, CreatedDate FROM Nodes WHERE NodeStatus=\'Pending\' Order by CreatedDate DESC LIMIT 1) FROM ProcessInstance WHERE TargetObject.Type = \'Deal_Registration__c\' AND Status = \'Pending\'';
        return Database.getQueryLocator(pendingProcessInstance);
    }   
    public void execute(Database.BatchableContext bc, List<ProcessInstance> pendProcessInstance){
        Set<Id> dealsIdSet = new Set<Id>();
        for (ProcessInstance proInstance : pendProcessInstance) {
            dealsIdSet.add(proInstance.TargetObjectId);
        }
        Map<Id,Deal_Registration__c> idToDealMap = new Map<Id,Deal_Registration__c>([SELECT Id,Approval_Step__c,Current_Approval_Submission_date_time__c, Is_Workflow_Scheduled_for_Sales_Leader__c FROM Deal_Registration__c WHERE Id IN :dealsIdSet]);
        List<Deal_Registration__c> dealsToUpdate = new List<Deal_Registration__c>();
        
        for(ProcessInstance processIntanceObj :pendProcessInstance){
            Deal_Registration__c deal = idToDealMap.get(processIntanceObj.TargetObjectId);
            if (processIntanceObj.ProcessDefinition.Name != 'Extension Approval 1.0') {
                for(ProcessInstanceNode piNode :processIntanceObj.Nodes){
                    if(deal.Approval_Step__c != piNode.ProcessNodeName || deal.Current_Approval_Submission_date_time__c != piNode.CreatedDate){
                        deal.Approval_Step__c = piNode.ProcessNodeName;
                        deal.Current_Approval_Submission_date_time__c = piNode.CreatedDate;
                        if (deal.Approval_Step__c == 'Sales Leader Approval') {
                            deal.Is_Workflow_Scheduled_for_Sales_Leader__c = TRUE;
                        } else {
                            deal.Is_Workflow_Scheduled_for_Sales_Leader__c = false;
                        }
                        deal.Approval_Process_Definition_Name__c = processIntanceObj.ProcessDefinition.Name;
                        dealsToUpdate.add(deal);
                    }
                }
            } else {
                for(ProcessInstanceNode piNode :processIntanceObj.Nodes){
                    if(deal.Approval_Step__c != piNode.ProcessNodeName || deal.Current_Approval_Submission_date_time__c != piNode.CreatedDate){
                        deal.Approval_Step__c = piNode.ProcessNodeName;
                        deal.Current_Approval_Submission_date_time__c = piNode.CreatedDate;
                        deal.Approval_Process_Definition_Name__c = processIntanceObj.ProcessDefinition.Name;
                        dealsToUpdate.add(deal);
                    }
                }
            }
            
        }
        if(!dealsToUpdate.isEmpty()){
            update dealsToUpdate;
        }
    }
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));    
    }
}