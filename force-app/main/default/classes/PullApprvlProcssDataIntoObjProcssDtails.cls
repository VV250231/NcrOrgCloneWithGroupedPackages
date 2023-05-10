global class PullApprvlProcssDataIntoObjProcssDtails implements Database.Batchable<sObject>
{
  
        global Database.QueryLocator start(Database.BatchableContext BC) 
        {
            String strQuery = 'select id,(select Id,TargetObject.name,createddate ,CompletedDate,LastActor.name,LastActorId,TargetObjectid,status FROM ProcessInstances order by createddate desc limit 1) from zqu__Quote__c' ; // where zqu__Status__c != ' + System.Label.Zuora_Quote_Status (Entered_Approval_Process__c = true or Is_NCR_Quote__c = false) and
          
            return Database.getQueryLocator(strQuery);
        }
        global void execute(Database.BatchableContext BC, List<zqu__Quote__c> lstQuotes) 
        {
            Set<Id> setQuoteIds = new Set<id>();
            Set<Id> setProcessInstanceIds = new Set<id>();
            Map<id,ProcessInstance> mapQuoteIdProcessInstance = new Map<id,ProcessInstance>();
            Map<id,ProcessInstanceNode> mapProcessInstanceNode =  new Map<id,ProcessInstanceNode>();
            Map<id,ProcessInstanceStep> mapProcessInstanceStep = new Map<id,ProcessInstanceStep>();
            Map<id,ProcessInstanceWorkitem> mapProcessInstanceWorkitem =  new   Map<id,ProcessInstanceWorkitem>();
            Map<id,Process_Details_Zuora__c> mapQuoteIdProcessDetailObj = new Map<id,Process_Details_Zuora__c>();
            List<Process_Details_Zuora__c> lstPrcessDetailsToInsertUpdate = new List<Process_Details_Zuora__c>();
            
            // collect all the latest process instance ids and objects
            for(zqu__Quote__c objZQuotes :lstQuotes )
            {
                if(objZQuotes.ProcessInstances.size() > 0 )
                {
                    setQuoteIds.add(objZQuotes.id);
                    setProcessInstanceIds.add(objZQuotes.ProcessInstances[0].id);
                    mapQuoteIdProcessInstance.put(objZQuotes.id,objZQuotes.ProcessInstances[0]);
                    
                }
                    
            }
            system.debug('+++++++++++setQuoteIds:::'+setQuoteIds);
            system.debug('+++++++++++setProcessInstanceIds:::'+setProcessInstanceIds);
            
            
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
             system.debug('+++++++++++mapProcessInstanceStep :::'+mapProcessInstanceStep);
              system.debug('+++++++++++mapProcessInstanceWorkitem :::'+mapProcessInstanceWorkitem);
               system.debug('+++++++++++mapProcessInstanceNode :::'+mapProcessInstanceNode);
            
            system.debug('+++++++++++map QuoteId & ProcessInstance :::'+mapQuoteIdProcessInstance );
            if(setQuoteIds == null && setQuoteIds.size() == 0) return;
            // query all the process deatils corresponding to the current set of quotes, to check if process details are already there or not
            for(Process_Details_Zuora__c objProcDetails : [select id,Quote_Zuora__c from Process_Details_Zuora__c where Quote_Zuora__c in : setQuoteIds])
            {
                 mapQuoteIdProcessDetailObj.put(objProcDetails.Quote_Zuora__c,objProcDetails);
            }
            
             system.debug('+++++++++++mapQuoteId and ProcessDetailObj :::'+mapQuoteIdProcessDetailObj);
            // Insert of Update process details for all the Quotes in the current context
            if(mapQuoteIdProcessInstance != null && mapQuoteIdProcessInstance.size() > 0)
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
            
                  if(mapProcessInstanceNode.get(idProcessInstance) != null)
                  {
                         if(mapProcessInstanceStep.get(idProcessInstance)!= null && mapProcessInstanceStep.get(idProcessInstance).Comments != null && mapProcessInstanceStep.get(idProcessInstance).Comments != '' && mapProcessInstanceStep.get(idProcessInstance).Comments.containsIgnoreCase('Auto approved')){
                         objProcDetails.Current_Approver_Team__c = 'Sales Comp Review';
                         }
                         else{
                         objProcDetails.Current_Approver_Team__c = mapProcessInstanceNode.get(idProcessInstance).ProcessNodeName;
                         }
                   }
                     objProcDetails.Comment_Zuora__c = mapProcessInstanceStep.get(idProcessInstance)!= null?mapProcessInstanceStep.get(idProcessInstance).Comments:null;
                     objProcDetails.Current_Approver_Name_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapProcessInstanceWorkitem.get(idProcessInstance).Actor.Name :mapQuoteIdProcessInstance.get(quoteIds).LastActor.Name;
                     objProcDetails.Date_Submitted_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapProcessInstanceWorkitem.get(idProcessInstance).CreatedDate :mapQuoteIdProcessInstance.get(quoteIds).CompletedDate;
                     lstPrcessDetailsToInsertUpdate.add(objProcDetails);
              }
              
              system.debug('+++++++++++lstPrcessDetailsToInsertUpdate :::'+lstPrcessDetailsToInsertUpdate );
              // upsert the process details under quote
              if(lstPrcessDetailsToInsertUpdate != null && lstPrcessDetailsToInsertUpdate.size() > 0)
              {
                     
                     Database.UpsertResult[] lstResultSet = Database.upsert(lstPrcessDetailsToInsertUpdate, false) ;
                     
                     system.debug('+++++++++++lstResultSet :::'+lstResultSet );
              }
            
            }
            
        }
       
      
        global void finish(Database.BatchableContext BC)
        {
            System.debug('Method : Finish');//SC2015_AGL-5809
        }
        
        /*
        @future
        global static void pullApprvlProcssDataforSingleQuote(Id quoteId) {
            List<zqu__Quote__c> lstQuotes = [select Id,(select Id,TargetObject.name,createddate ,CompletedDate,LastActor.name,LastActorId,TargetObjectid,status FROM ProcessInstances order by createddate desc limit 1) from zqu__Quote__c where Id = :quoteId];
            
            Set<Id> setQuoteIds = new Set<id>();
            Set<Id> setProcessInstanceIds = new Set<id>();
            Map<id,ProcessInstance> mapQuoteIdProcessInstance = new Map<id,ProcessInstance>();
            Map<id,ProcessInstanceNode> mapProcessInstanceNode =  new Map<id,ProcessInstanceNode>();
            Map<id,ProcessInstanceStep> mapProcessInstanceStep = new Map<id,ProcessInstanceStep>();
            Map<id,ProcessInstanceWorkitem> mapProcessInstanceWorkitem =  new   Map<id,ProcessInstanceWorkitem>();
            Map<id,Process_Details_Zuora__c> mapQuoteIdProcessDetailObj = new Map<id,Process_Details_Zuora__c>();
            List<Process_Details_Zuora__c> lstPrcessDetailsToInsertUpdate = new List<Process_Details_Zuora__c>();
            
            // collect all the latest process instance ids and objects
            for(zqu__Quote__c objZQuotes :lstQuotes )
            {
                if(objZQuotes.ProcessInstances.size() > 0 )
                {
                    setQuoteIds.add(objZQuotes.Id);
                    setProcessInstanceIds.add(objZQuotes.ProcessInstances[0].id);
                    mapQuoteIdProcessInstance.put(objZQuotes.id,objZQuotes.ProcessInstances[0]);
                    
                }
                    
            }
            
            if(setQuoteIds == null && setQuoteIds.size() == 0) return;
            
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
                  Process_Details_Zuora__c objProcDetails = new Process_Details_Zuora__c();
                 //check for update
                 if(mapQuoteIdProcessDetailObj != null && mapQuoteIdProcessDetailObj.containsKey(quoteIds) == true && mapQuoteIdProcessDetailObj.get(quoteIds) != null)
                 {
                     objProcDetails.id = mapQuoteIdProcessDetailObj.get(quoteIds).id;
                 }
                     Id idProcessInstance = mapQuoteIdProcessInstance.get(quoteIds).id ;
                     objProcDetails.Quote_Zuora__c = quoteIds ;
                     objProcDetails.Status_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status ;
                     objProcDetails.Current_Approver_Team__c = mapProcessInstanceNode.get(idProcessInstance).ProcessNodeName;
                     objProcDetails.Comment_Zuora__c = mapProcessInstanceStep.get(idProcessInstance).Comments ;
                     //objProcDetails.ownerId = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapQuoteIdProcessInstance.get(quoteIds).Workitems[0].ActorId :mapQuoteIdProcessInstance.get(quoteIds).LastActorId;
                     objProcDetails.Current_Approver_Name_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapProcessInstanceWorkitem.get(idProcessInstance).Actor.Name :mapQuoteIdProcessInstance.get(quoteIds).LastActor.Name;
                     objProcDetails.Date_Submitted_Zuora__c = mapQuoteIdProcessInstance.get(quoteIds).status == 'Pending'?mapProcessInstanceWorkitem.get(idProcessInstance).CreatedDate :mapQuoteIdProcessInstance.get(quoteIds).CompletedDate;
                     lstPrcessDetailsToInsertUpdate.add(objProcDetails);
              }
              
              // upsert the process details under quote
              if(lstPrcessDetailsToInsertUpdate != null && lstPrcessDetailsToInsertUpdate.size() > 0)
              {
                     Database.upsert(lstPrcessDetailsToInsertUpdate, false) ;
                   //upsert lstPrcessDetailsToInsertUpdate; // use database function
              }
            
            } 
            
        }
*/
}