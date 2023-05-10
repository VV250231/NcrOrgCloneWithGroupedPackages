public with sharing class  PullApprovalDataOfQuotes_RealTime
{
    
    @InvocableMethod(label='pull Approval Process Data' description='pull approval process data from quote')
    public static void pullData(list<id> qIdList)
    {
       system.debug('+++++qIdList before if'+qIdList);
        if(!qIdList.isEmpty())
        {
            PullApprvlProcssDataIntoObjProcssDtails(qIdList);
            system.debug('+++++qIdList inside if'+qIdList);
        } 
        
    }
    
    // method for calling approval process method and inserting it in the dump object  
    public static  void PullApprvlProcssDataIntoObjProcssDtails(List<id> quoteIdsList)
    {    
            String quoteStatus = System.Label.Zuora_Quote_Status;
            List<zqu__Quote__c> lstQuotes = new List<zqu__Quote__c>();
            lstQuotes = [select id,(select Id,TargetObject.name,createddate ,CompletedDate,LastActor.name,LastActorId,TargetObjectid,status FROM ProcessInstances order by createddate desc limit 1) from zqu__Quote__c where id in: quoteIdsList];
            Set<Id> setQuoteIds = new Set<id>();
            Set<Id> setProcessInstanceIds = new Set<id>();
            Map<id,ProcessInstance> mapQuoteIdProcessInstance = new Map<id,ProcessInstance>();
            Map<id,ProcessInstanceNode> mapProcessInstanceNode =  new Map<id,ProcessInstanceNode>();
            Map<id,ProcessInstanceStep> mapProcessInstanceStep = new Map<id,ProcessInstanceStep>();
            Map<id,ProcessInstanceWorkitem> mapProcessInstanceWorkitem =  new   Map<id,ProcessInstanceWorkitem>();
            Map<id,Process_Details_Zuora__c> mapQuoteIdProcessDetailObj = new Map<id,Process_Details_Zuora__c>();
            List<Process_Details_Zuora__c> lstPrcessDetailsToInsertUpdate = new List<Process_Details_Zuora__c>();
            
             system.debug('+++++inside method lstQuotes '+lstQuotes );
             system.debug('+++++inside method quoteStatus'+quoteStatus);
            // collect all the latest process instance ids and objects
            if(lstQuotes == null && lstQuotes.size() == 0)return;
            for(zqu__Quote__c objZQuotes :lstQuotes )
            {
                if(objZQuotes.ProcessInstances.size() > 0 )
                {
                    setQuoteIds.add(objZQuotes.id);
                    setProcessInstanceIds.add(objZQuotes.ProcessInstances[0].id);
                    mapQuoteIdProcessInstance.put(objZQuotes.id,objZQuotes.ProcessInstances[0]);
                    
                }
                    
            }
            
            // query all other object realted to this process instance
            if(setProcessInstanceIds != null && setProcessInstanceIds.size()  > 0)
            {
                for(ProcessInstance objPI : [SELECT Id,(select ProcessInstanceId, Comments from Steps order by createddate desc limit 1),(select ProcessInstanceId,CreatedDate,actor.name,actorid from Workitems order by createddate desc limit 1),(SELECT ProcessInstanceId,NodeStatus,ProcessNodeName FROM Nodes order by createddate desc limit 1) FROM ProcessInstance where id in: setProcessInstanceIds ])
                {
                    if(objPI.Steps.size() > 0)
                    {
                        mapProcessInstanceStep.put(objPI.id,objPI.Steps[0]);
                    }
                    
                    if(objPI.Workitems.size() > 0)
                    {
                        mapProcessInstanceWorkitem.put(objPI.id,objPI.Workitems[0]);
                    }
                    if(objPI.Nodes.size() > 0)
                    {
                        mapProcessInstanceNode.put(objPI.id,objPI.Nodes[0]);
                    }
                    
                }
            }
            
            if(setQuoteIds == null && setQuoteIds.size() == 0) return;
            // query all the process deatils corresponding to the current set of quotes, to check if process details are already there or not
            for(Process_Details_Zuora__c objProcDetails : [select id,Quote_Zuora__c from Process_Details_Zuora__c where Quote_Zuora__c in : setQuoteIds])
            {
                 mapQuoteIdProcessDetailObj.put(objProcDetails.Quote_Zuora__c,objProcDetails);
            }
            
            
            // Insert of Update process details for all the Quotes in the current context
            if(mapQuoteIdProcessInstance != null )
            {
              for(String quoteIds : mapQuoteIdProcessInstance.keyset())
              {
                  System.debug('>>>>>> quoteIds' + quoteIds);
                  Process_Details_Zuora__c objProcDetails = new Process_Details_Zuora__c();
                 //check for update
                 if(mapQuoteIdProcessDetailObj != null && mapQuoteIdProcessDetailObj.containsKey(quoteIds) == true && mapQuoteIdProcessDetailObj.get(quoteIds) != null)
                 {
                     objProcDetails.id = mapQuoteIdProcessDetailObj.get(quoteIds).id;
                 }
                 else
                 {
                     objProcDetails.Quote_Zuora__c = quoteIds;  // fill Quote_Zuora__c if its new record
                 }
                 Id idProcessInstance = mapQuoteIdProcessInstance.get(quoteIds).id;
                     
            
                     objProcDetails.Status_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status ;
                     
                     if(mapProcessInstanceNode.get(idProcessInstance) != null) {
                         if(mapProcessInstanceStep.get(idProcessInstance) != null && mapProcessInstanceStep.get(idProcessInstance).Comments != null && mapProcessInstanceStep.get(idProcessInstance).Comments != '' && mapProcessInstanceStep.get(idProcessInstance).Comments.containsIgnoreCase('Auto approved')){
                         objProcDetails.Current_Approver_Team__c = 'Sales Comp Review';
                         }
                         else{
                         objProcDetails.Current_Approver_Team__c = mapProcessInstanceNode.get(idProcessInstance).ProcessNodeName;
                         }
                     }
                     objProcDetails.Comment_Zuora__c = mapProcessInstanceStep.get(idProcessInstance)!= null ?mapProcessInstanceStep.get(idProcessInstance).Comments:null ;//mapQuoteIdProcessInstance.get(quoteIds).status != 'Pending'?mapProcessInstanceStep.get(idProcessInstance).Comments:null;
                     //objProcDetails.Comment_in_Approval_Process__c = mapProcessInstanceStep.get(idProcessInstance).Comments ;
                     objProcDetails.Current_Approver_Name_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapProcessInstanceWorkitem.get(idProcessInstance).Actor.Name :mapQuoteIdProcessInstance.get(quoteIds).LastActor.Name;
                     objProcDetails.Date_Submitted_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapProcessInstanceWorkitem.get(idProcessInstance).CreatedDate :mapQuoteIdProcessInstance.get(quoteIds).CompletedDate;
                     lstPrcessDetailsToInsertUpdate.add(objProcDetails);
              }
              
              // upsert the process details under quote
              if(lstPrcessDetailsToInsertUpdate != null && lstPrcessDetailsToInsertUpdate.size() > 0)
              {
                     System.debug('+++lstPrcessDetailsToInsertUpdate: before try ' + lstPrcessDetailsToInsertUpdate);
                    try
                    {
                     Database.UpsertResult[] resultSet = Database.upsert(lstPrcessDetailsToInsertUpdate, false) ;
                     system.debug('+++resultSet inside try after upsert call' +resultSet);
                     
                     }
                     
                     catch(Exception e)
                     {
                          System.debug('+++The following exception has occurred: ' +e.getMessage());
                     
                     }
            
             }
     }
    }
    
    
}