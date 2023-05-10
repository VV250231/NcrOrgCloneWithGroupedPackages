public  class PRM_ApprovalHistoryController 
{
  @AuraEnabled
    public static List<HistoryDetails> getApprovalHistory(String recId)
    {
      List<HistoryDetails> lstHistoryDetails = new List<HistoryDetails>();
        List<ProcessInstance> allPIList = new List<ProcessInstance>();
        List<ProcessInstanceNode> piNodeList = new List<ProcessInstanceNode>(); 
        List<ProcessInstanceStep> piStepList = new List<ProcessInstanceStep>();
        
        Map<Id, String> sequenceToNodeNameMap = new Map<Id, String>();
        List<List<String>> displayList = new List<List<String>>();
        
        Map<Id, Group> mapIdToGroup = new Map<Id, Group>([Select Id, Name from Group]); 
       Id ProcessInstanceWorkitemId;
        String ActorName;
      String OriginalActorName;
      String LongDate;
        allPIList = [Select Id,CompletedDate , 
                        (Select Id, OriginalActorId,OriginalActor.Name, ActorId, Actor.Name, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                        (Select Id, StepStatus, OriginalActorId, OriginalActor.Name, Actor.Name, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                        (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC) 
                    From ProcessInstance p WHERE TargetObjectId =: recId ORDER BY CreatedDate DESC];        
        
               
        //ApprovalHisoryTable();
        
        List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>();
        piStepList = new List<ProcessInstanceStep>();
        String pstepName;   
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> setGroupId = new Set<Id>();
         
        for (ProcessInstance pi: allPIList)
      {
            //if the Approval Process is Pending for approval, there will be Workitem associated with Process Instance.
            if (pi.Workitems.size() > 0)
            {
               /*for(ProcessInstanceNode pin: pi.Nodes) {
                    if(pin.NodeStatus == 'Pending'  )
                    {
                        // Do nothing
                    }
                } commented empty block */
                                    
                //Added for loop to go over all the WorkItems and add all the Approvers in case of multiple Approvers
                for(ProcessInstanceWorkitem piWI : pi.Workitems)
                {
                  String strOriginalActorObjectName = piWI.OriginalActorId.getSObjectType().getDescribe().getName();
                  String strActorObjectName = piWI.ActorId.getSObjectType().getDescribe().getName();
                  if(strOriginalActorObjectName == 'Group')
                  {
                    setGroupId.add(piWI.OriginalActorId);
                  }
                  else
                      userIdSet.add(piWI.OriginalActorId);
                      
                    if(strOriginalActorObjectName == 'Group')
                    {
                    setGroupId.add(piWI.ActorId);
                    }
                  else
                      userIdSet.add(piWI.ActorId);
                }
            }
      }
        for(GroupMember objGM: [Select Id, GroupId, Group.Name, UserOrGroupId From GroupMember where GroupId IN: setGroupId])
                {
                  
                  if(objGM.UserOrGroupId != null )
                  {
                    String strUserId = String.valueOf(objGM.UserOrGroupId);
                    if(strUserId.startsWith('005'))
                    {
                      userIdSet.add(objGM.UserOrGroupId);
                    }
                  }
                }
       for (ProcessInstance pi: allPIList)
      {
            //if the Approval Process is Pending for approval, there will be Workitem associated with Process Instance.
            /*if (pi.Workitems.size() > 0)
            {
               /*for(ProcessInstanceNode pin: pi.Nodes) {
                    if(pin.NodeStatus == 'Pending'  )
                    {
                        // Do nothing
                    }
                } commented empty block */
                                    
                //Added for loop to go over all the WorkItems and add all the Approvers in case of multiple Approvers
              /*  for(ProcessInstanceWorkitem piWI : pi.Workitems)
                {
                  String strOriginalActorObjectName = piWI.OriginalActorId.getSObjectType().getDescribe().getName();
                  String strActorObjectName = piWI.ActorId.getSObjectType().getDescribe().getName();
                  if(strOriginalActorObjectName == 'Group')
                  {
                    setGroupId.add(piWI.OriginalActorId);
                  }
                  else
                      userIdSet.add(piWI.OriginalActorId);
                      
                    if(strOriginalActorObjectName == 'Group')
                    {
                    setGroupId.add(piWI.ActorId);
                    }
                  else
                      userIdSet.add(piWI.ActorId);
                }
                
                for(GroupMember objGM: [Select Id, GroupId, Group.Name, UserOrGroupId From GroupMember where GroupId IN: setGroupId])
                {
                  
                  if(objGM.UserOrGroupId != null )
                  {
                    String strUserId = String.valueOf(objGM.UserOrGroupId);
                    if(strUserId.startsWith('005'))
                    {
                      userIdSet.add(objGM.UserOrGroupId);
                    }
                  }
                }
            }*/
                
                
            //All the Approval process steps apart from pending step -> Process Instance Steps
            if(pi.Steps.size() > 0)
            {
                for(Integer i=0;i<pi.Steps.size();i++)
                {
                    userIdSet.add(pi.Steps[i].OriginalActorId);
                    userIdSet.add(pi.Steps[i].ActorId); 
                }
            }
        }
        
        List<User> userList = [SELECT Id, Name, DelegatedApproverId FROM User WHERE Id IN :userIdSet];
        
        if(allPIList.size()>0)
        {
            for(ProcessInstance pi: allPIList)
            {
                //if the Engineers is pending to be approved, get the list of Workitems and add to the Display List.
                if(pi.Workitems.size() > 0)
                {
                    List<string> tempHeaderList = new List<String>();
                    Id pActorId = null;
                    Id pOriginalActorId = null;
                    //Dynamically fetching the current Pending Step of active Instance and removed the Hardcoded value here
                    for(ProcessInstanceNode pin: pi.Nodes)
                    {
                        if(pin.NodeStatus == 'Pending')
                            pstepName = 'Step: '+pin.ProcessNodeName; 
                    } 
                    ProcessInstanceWorkitemId = pi.Workitems[0].Id;
                    tempHeaderList.add(pstepName);
                    tempHeaderList.add(' ');
                    tempHeaderList.add(' ');
                    tempHeaderList.add(' ');
                    tempHeaderList.add(' ');
                    tempHeaderList.add(' ');
                    tempHeaderList.add('Pending');
                    tempHeaderList.add(' ');
                    tempHeaderList.add(' ');
                    displayList.add(tempHeaderList);
                    
                    for(ProcessInstanceWorkitem w: pi.Workitems)
                    {
                      String strActorName = w.ActorId.getSObjectType().getDescribe().getName();
                      String strOriginalActorName = w.OriginalActorId.getSObjectType().getDescribe().getName();
                      System.debug('---------strActorName----------------------'+strActorName);
                  System.debug('---------strOriginalActorName----------------------'+strOriginalActorName);
                        List<string> tempList = new List<String>();
                        
                        if(strActorName == 'Group')
                          ActorName = mapIdToGroup.get(w.ActorId).Name;
                        if(strOriginalActorName == 'Group')
                          OriginalActorName = mapIdToGroup.get(w.OriginalActorId).Name;
                          
                        
                        if(strActorName == 'User')
                            ActorName = w.Actor.Name;
                        if(strOriginalActorName == 'User')
                            OriginalActorName = w.OriginalActor.Name;
                        LongDate = w.CreatedDate.format();
                        tempList.add('Approve / Reject');
                        tempList.add(LongDate);
                        tempList.add('Pending');
                        tempList.add(OriginalActorName);
                        tempList.add(ActorName);
                        tempList.add(' ');
                        tempList.add(' ');
                        tempList.add(w.OriginalActorId);
                        tempList.add(w.ActorId);
                        //tempList.add(UserInfo.getuserId());
                        //tempList.add(UserInfo.getuserId());
                        displayList.add(tempList);
                        //lstHistoryDetails.add(new HistoryDetails(tempList));
                    }
                }
                
                //Get the list of all the Process Instance Steps and add to the list. List to be processed later.
                if(pi.Steps.size() > 0)
                {
                    for (ProcessInstanceStep s: pi.Steps)
                    {
                        piStepList.add(s);
                    }
                }
                
                //For all the Nodes of an Instance - Add the node id and name to the map
                
                for(ProcessInstanceNode piNodeItem : pi.Nodes)
                {
                    sequenceToNodeNameMap.put(piNodeItem.ProcessNodeId,piNodeItem.ProcessNodeName);
                    piNodeList.add(piNodeItem);
                    
                }
            }
        }
        
        //Based on the Status of the step, the step name and the status message is added to the Display List.
        for (ProcessInstanceStep s: piStepList)
        {
            List<string> tempHeaderList ;
            String stepName = null;
            String stepStat = null; 
            //Commenting the hard coded value
            //Fetching the Step NAme and Status dynamically based on ProcessNodeID in Steps and using created Map
            
            if(s.StepStatus == 'Approved')
            {
                for(ProcessInstanceNode pii : piNodeList)
                {
                    if(s.StepNodeId == pii.ProcessNodeId )
                    {
                        stepName =  sequenceToNodeNameMap.get(pii.ProcessNodeId);
                        stepStat = 'Approved';
                    }
                }
            }
            if(s.StepStatus == 'Rejected' )
            {
                System.debug('Did i ');
                for(ProcessInstanceNode pii : piNodeList)
                {
                    System.debug('Did i 2 ');
                    if(s.StepNodeId == pii.ProcessNodeId )
                    {
                        System.debug('Did i 3 ');
                        stepName =  sequenceToNodeNameMap.get(pii.ProcessNodeId);
                        stepStat = 'Rejected';
                    }
                }
            }
            if (s.StepStatus == 'Started')
            {
                stepName = 'Approval Request Submitted';
                stepStat = ' ';
            }
            if (s.StepStatus == 'Removed')
            {
                stepName = 'Approval Request Recalled';
                stepStat = 'Recalled';
            }
            
            if(stepName != null)
            {
                tempHeaderList = new List<string>();
                tempHeaderList.add(stepName);
                tempHeaderList.add(' ');
                tempHeaderList.add(' ');
                tempHeaderList.add(' ');
                tempHeaderList.add(' ');
                tempHeaderList.add(' ');
                tempHeaderList.add(stepStat);
                tempHeaderList.add(' ');
                tempHeaderList.add(' ');
                
                if(tempHeaderList != null && tempHeaderList.size() > 0)
                  displayList.add(tempHeaderList); 
                  //lstHistoryDetails.add(new HistoryDetails(tempHeaderList));
            } 
            
            List<string> tempList = new List<String>();
            
            String strSActorName = s.ActorId.getSObjectType().getDescribe().getName();
          String strSOriginalActorName = s.OriginalActorId.getSObjectType().getDescribe().getName();
          System.debug('---------strSActorName----------------------'+strSActorName);
            System.debug('---------strSOriginalActorName----------------------'+strSOriginalActorName);
            
            if(strSActorName == 'Group')
              ActorName = mapIdToGroup.get(s.ActorId).Name;
            if(strSOriginalActorName == 'Group')
              OriginalActorName = mapIdToGroup.get(s.OriginalActorId).Name;
              
                          
              if(strSActorName == 'User')
                    ActorName = s.Actor.Name;
                if(strSOriginalActorName == 'User')
                    OriginalActorName = s.OriginalActor.Name;
            
            LongDate = s.CreatedDate.format();
            tempList.add(' ');
            tempList.add(LongDate);
            tempList.add(s.StepStatus);
            tempList.add(OriginalActorName);
            tempList.add(ActorName);
            
            if(s.Comments != null)
                tempList.add(s.Comments);
            else
                tempList.add(' ');
                
            tempList.add(' ');            
            tempList.add(s.OriginalActorId);
            tempList.add(s.ActorId);
            //tempList.add(UserInfo.getuserId());
            //tempList.add(UserInfo.getuserId());
            displayList.add(tempList);
            
        }
        for(List<String> lstAH : displayList)
          lstHistoryDetails.add(new HistoryDetails(lstAH));
        //System.debug('displayList-------------'+ displayList);
        Integer i = 0;
        for(HistoryDetails objHD : lstHistoryDetails)
        {
          System.debug('--------------i : '+  i);
          Integer j = 0;
          for(String val: objHD.lstDetail)
          {
            System.debug('-------------val-'+ j +' : '+  val);
            j = j + 1 ;
          }
          
          i = i + 1;
        }
        return lstHistoryDetails;
    }
    
    public class HistoryDetails
    {
      @AuraEnabled
      public List<String> lstDetail;
      
      public HistoryDetails(List<String> lstDetail)
      {
        this.lstDetail =  lstDetail;
      }
    }    
}