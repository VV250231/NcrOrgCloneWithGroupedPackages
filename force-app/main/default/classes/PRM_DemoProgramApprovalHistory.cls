public  class PRM_DemoProgramApprovalHistory 
{
    @AuraEnabled
    public static ApprovalDetails getApprovalHistory(String recId)
    {
        List<HistoryDetails> lstHistoryDetails = new List<HistoryDetails>();
        List<ProcessInstance> allPIList = new List<ProcessInstance>();
        List<ProcessInstanceNode> piNodeList = new List<ProcessInstanceNode>(); 
        List<ProcessInstanceStep> piStepList = new List<ProcessInstanceStep>();
        
        Map<String, String> mapGroupIdToName = new Map<String, String>();
        Map<Id, Set<Id>> mapGroupIdTolstMember = new Map<Id, Set<Id>>();
        
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
        
        Boolean showLink = false;
        Boolean isApprover = false;
        Boolean allowLink = false;
        List<User>  userList  = [Select id , name from User Where id =: UserInfo.getUserId() AND  Profile.Name ='System Administrator'];   
        for (ProcessInstance pi: allPIList)
        {
            //if the Approval Process is Pending for approval, there will be Workitem associated with Process Instance.
            if (pi.Workitems.size() > 0)
            {
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
                    else{
                        userIdSet.add(piWI.ActorId);
                    }
                }
                
                        
                allowLink = userList != null && !userList.isEmpty();
                
                if ((userIdSet.contains(UserInfo.getUserId()) )|| allowLink   )
                {
                    showLink = true;
                    isApprover = true;
                }
                else
                {
                    showLink = false;
                }
                
            }
             
            
            //All the Approval process steps apart from pending step -> Process Instance Steps
            if (pi.Steps.size() > 0)
            {
                for(Integer i=0; i<pi.Steps.size(); i++)
                {
                    userIdSet.add(pi.Steps[i].OriginalActorId);
                    userIdSet.add(pi.Steps[i].ActorId); 
                }
            }
           
        }
        //Get all the users listed in the Approval Process
        List<User> lstUser = [SELECT Id, Name, DelegatedApproverId FROM User WHERE Id IN :userIdSet];
        Map<Id, User> IdUserMap = new Map<Id, User>();
        for(Id pId: userIdSet)
        {
            for(User u: lstUser)
            {
                if(pId == u.Id)
                    IdUserMap.put(pId,u);
            }   
        }
        
        
        
        for (ProcessInstance pi: allPIList)
        {
            if (pi.Workitems.size() > 0)
            {      
                String strActorObjName = pi.Workitems[0].ActorId.getSObjectType().getDescribe().getName();
                if(strActorObjName == 'Group')
                {
                    Set<Id> setGroupMemberUserId = mapGroupIdTolstMember.get(pi.Workitems[0].ActorId);
                    if(!Test.isRunningTest() && setGroupMemberUserId.contains(UserInfo.getUserId()) && IdUserMap.get(UserInfo.getUserId()) != null && 
                       (UserInfo.getUserId() == IdUserMap.get(UserInfo.getUserId()).DelegatedApproverId))
                    {
                        showLink = true;
                        isApprover = true;
                    }
                }
                else if(UserInfo.getUserId() == IdUserMap.get(pi.Workitems[0].ActorId).DelegatedApproverId)
                {
                    showLink = true;
                    isApprover = true;
                }
            }
        }    
        
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
       
         //Campaign Name
        Schema.DescribeFieldResult fieldResult = Demo_Program__c.Rejection_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        
        
        List<Demo_Program__c> demoReqList = [SELECT Id, Name, Partner_Account__c,Partner_Account__r.Name,Partner_Contact__c,Partner_Contact__r.Name,Approval_Step__c,                                             
                                             Region__c, Status__c, QTY__c, Product_Group_NCR_designation__c,  Demo_Price__c,
                                             MSRP__c, LT__c FROM Demo_Program__c WHERE Id =: recId ];
        
        ApprovalDetails objAD = new ApprovalDetails();
        objAD.lstHD = lstHistoryDetails;
        objAD.showLink = showLink;
        objAD.isApprover = isApprover;
        objAD.ProcessInstanceWorkitemId = ProcessInstanceWorkitemId;
        
        if(demoReqList.size() > 0) {
            objAD.objDP = demoReqList[0];
        }
        
        for( Schema.PicklistEntry f : ple)
        {
            objAD.lstRejection.add(f.getValue());
        }   
        
        return objAD;
    }
    
    @AuraEnabled
    public static String rejectDemoProgram(String comment, String strReason, String recId, String workItemId)
    {
        try{
            Demo_Program__c objDP = new Demo_Program__c(Id = recId);
            objDP.Rejection_Reason__c = strReason;
            
            update objDP; 
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            
            comment = String.isBlank(comment) ? strReason : comment ;
            req.setComments(comment );
            
            req.setAction('Reject');
            req.setWorkitemId(workItemId);
            
            Approval.ProcessResult result2 = Approval.process(req); 
            
            return 'Rejected';
        }
        catch(Exception e)
        {
            return 'Error';
        }
    }
    
    @AuraEnabled
    public static String approveDemoProgram(Demo_Program__c objDemoProgram, String comment, String recId, String workItemId, Boolean isUpdate) 
    {
        try{
            if(isUpdate)
                update objDemoProgram;
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(Comment);
            req2.setAction('Approve');
            req2.setWorkitemId(workItemId);
            Approval.ProcessResult result2 =  Approval.process(req2);
            
            return 'Approved';
        }
        catch(Exception e)
        {
            return 'Error';
        }
    }
    
       @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) 
    {
        /*  
        check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        next time (in else) we are call the appentTOFile() method
        for update the attachment with reamins chunks 
        */  
        if (fileId == '') 
        {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } 
        else 
        {
            appendToFile(parentId, fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) 
    {
        System.debug('============base64Data=========='+base64Data);
        System.debug('============contentType=========='+contentType);
        System.debug('============fileName=========='+fileName);
        System.SavePoint sp = DataBase.setSavePoint();
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        /*Attachment oAttachment = new Attachment();
        try
        { 
            oAttachment.parentId = parentId;
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            insert oAttachment;
        }
        catch(Exception ex)
        {
            Database.rollback(sp); 
        }
        
        return oAttachment.Id;*/
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = '/'+fileName; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
        insert conVer;
        
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
         
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = parentId; // you can use objectId,GroupId etc
        cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        return conVer.Id;

    }
    
    private static void appendToFile(Id parentId, Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        /*Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;*/
        
        ContentVersion conVer2 = [SELECT VersionData, ContentDocumentId FROM ContentVersion WHERE Id =:fileId];
        String strEncode1 =   EncodingUtil.base64Encode(conVer2.VersionData);
       	conVer2.VersionData = EncodingUtil.base64Decode(strEncode1 + base64Data);
        update conVer2;
      
        
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
    
    public class ApprovalDetails
    {
        @AuraEnabled
        public List<String> lstRejection;
        
        @AuraEnabled
        public List<HistoryDetails> lstHD;
        
        @AuraEnabled
        public Boolean showLink;
             
        @AuraEnabled     
        public Boolean isApprover;
        
        @AuraEnabled
        public Demo_Program__c objDP;
        
        @AuraEnabled
        public String ProcessInstanceWorkitemId;
        public ApprovalDetails()
        {
            lstRejection = new List<String>();
            //lstRejection.add('--None--');
        }
    }
}