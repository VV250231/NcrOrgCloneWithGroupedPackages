/**
History:
* =========================
* Developer        Date        Description
* --------------------------------------------------------------------------------------------------

* Rahul Gaira     01/08/2016     Created the class.: VF page for Approval History section
* Rahul Gaira     10/08/2016     modified the code to add the Approval and Disapproval logic
* Rahul Gaira     1/10/2016      Modified the code to make it generic for the Deal Registration and add the Deal Registration functionality.
* Shiv Mahla      16-Aug-2017    Modified the code to set Rejection reason for engineer record for partal access and dignostic reason.
Monika            19-12-2022     EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
*/

global class ApprovalHistoryPageController 
{
    //public List<String> ReasonsforRejection;
    public String SelectedReason {get; set;}
    public boolean renderComment{get;set;}
    public boolean rejectionReason{get;set;}
    public String Comment{get;set;}
    public Engineers__c eng {get;set;}
    public Deal_Registration__c dealReg{get;set;}
    // public static Id engId {get;set;}
    public  static Id recordId {get;set;}
    public List<ProcessInstance> allPIList;
    public List<ProcessInstanceStep> piStepList;
    public List<ProcessInstanceNode> piNodeList;
    public List<List<string>> displayList {get;set;}
    public Set<Id> userIdSet;
    public List<User> userList;
    public String ActorName;
    public String OriginalActorName;
    public String LongDate;
    public Boolean showTable {get;set;}
    public Boolean showLink {get;set;}
    public Id ProcessInstanceWorkitemId {get;set;}      
    public Boolean isApprover {get;set;}
    public String AccStr {get;set;}
    public Boolean isPartnerCentral {get;set;}
    public Boolean DiagnosticFlag{get;set;}
    public Boolean PoratlLoginFlag{get;set;}
    public Boolean EngineerFlag{get;set;}
    Public Boolean DealRegFlag{get;set;}
    // public Map<Id,String> nodeIdToNodeNameMap {get; set;} //sequenceToNodeNameMap
    public Map<Id,String> sequenceToNodeNameMap {get; set;}
    public String sobjtype;
    public String approvalProcessDeveloperName {get;set;}
    
    private Map<String, String> mapGroupIdToName = new Map<String, String>();
    Set<Id> setGroupId = new Set<Id>();
    private Map<Id, Set<Id>> mapGroupIdTolstMember = new Map<Id, Set<Id>>();
    private Map<Id, Group> mapIdToGroup = new Map<Id, Group>([Select Id, Name from Group]);
    //Constructor for the Approval reject and Accept Page 
    public ApprovalHistoryPageController() 
    {
        // Changes done by Yogesh- EBA_SF-1732
        //Id recordIdFromUrl =  ApexPages.currentPage().getParameters().get('id');
        Id recordIdFromUrl = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
        //End Changes 
        sobjtype = recordIdFromUrl.getsObjectType().getDescribe().getName();
        if(sobjtype == 'Engineers__c') {
            EngineerFlag = true;
            eng = [Select id , Name, Owner.name,Email_Address__c,First_Name__c, Last_Name__c,Partner_Account__c,owner.email,Type_of_Portal_Access__c,Engineer_ID__c,Web_Portal_login_ID__c 
                   from Engineers__c Where id =: recordIdFromUrl ];
            if(eng.Type_of_Portal_Access__c != null && eng.Type_of_Portal_Access__c.containsIgnoreCase('Diagnostic'))
                DiagnosticFlag = true;
            if(eng.Type_of_Portal_Access__c != null && eng.Type_of_Portal_Access__c.containsIgnoreCase('Portal'))
                PoratlLoginFlag = true;   
        }         
        else if(sobjtype == 'Deal_Registration__c') 
        {
            dealReg =[Select id, Name,Name_of_Account_Financial_Institution__c,Channel_Partner_Company_Name__c,Channel_Partner_Key_Contact__c,OwnerID,owner.email,
                      End_Customer_Company_Name__c,End_Customer_Key_Contact_Name__c,
                      Estimated_Close_Date__c,Is_this_part_of_an_RFP__c,NCR_Account_Manager__c,Partner_Company_Name__c,Partner_Contact__c,
                      Primary_Contact_Name__c,Primary_Contact_NameText__c,Projected_Opportunity_Value__c 
                      From Deal_Registration__c 
                      Where id =: recordIdFromUrl ] ;
            DealRegFlag = true;
        }   
        ProcessInstanceWorkitemId =  ApexPages.currentPage().getParameters().get('piwd');
        List<ProcessInstanceWorkitem> PIWitems = [SELECT Id, ProcessInstance.ProcessDefinition.DeveloperName 
                                                  FROM ProcessInstanceWorkitem WHERE Id =: ProcessInstanceWorkitemId];
        if (PIWitems.size() > 0)
            approvalProcessDeveloperName = PIWitems[0]. ProcessInstance.ProcessDefinition.DeveloperName;                                        
    }
    
    public PageReference renderComment() 
    {
        comment = '';
        renderComment = (SelectedReason == 'Others');
        return null;
    }
    
    public PageReference rejectEngineerFinal()
    {
        PageReference ref;
        if(sobjtype == 'Engineers__c')
        {
            if(selectedReason == 'Others' && (Comment == '' || Comment == null))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Rejection reason is required before rejection');ApexPages.addMessage(myMsg);
            } 
            else
            {
                System.debug('SelectedReason '+ SelectedReason ); 
                if(String.isNotBlank(ApexPages.currentPage().getParameters().get('id') ))
                {
                    Engineers__c objEng = new Engineers__c(Id = ApexPages.currentPage().getParameters().get('id'));
                    if (approvalProcessDeveloperName == 'Type_of_Portal_Access_Diagnostics') { // condition added by shiv
                        
                        if (SelectedReason == 'Others') {
                            objEng.Rejection_Reason_of_Diagnostic_Request__c = comment;
                        } else {
                            objEng.Rejection_Reason_of_Diagnostic_Request__c = SelectedReason;
                        }
                        
                    } else if (approvalProcessDeveloperName == 'CertifiedPersonnelMandatoryDocs') { // codition added by shiv earliar it was objEng.Rejection_Reason__c = SelectedReason;
                        if (SelectedReason == 'Others') {
                            objEng.Rejection_Reason_of_Portal_Access__c = comment;
                        } else {
                            objEng.Rejection_Reason_of_Portal_Access__c = SelectedReason;
                        }
                    }
                    objEng.Engineer_ID__c = eng.Engineer_ID__c;
                    objEng.Web_Portal_login_ID__c = eng.Web_Portal_login_ID__c;
                    
                    update objEng;
                }
                reject();
                //sendEmail();
                // Submit the request for approval 
                ref = new PageReference('/'+ eng.id);
            } 
        }
        else if(sobjtype == 'Deal_Registration__c')
        {
            
            if(selectedReason == '' || selectedReason == null )
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Rejection reason is required before rejection');    ApexPages.addMessage(myMsg);
            } 
            else
            {
                dealreg.VisualTemplate__c = selectedReason; update dealreg;
                reject();sendEmailDealRegistration(); ref = new PageReference('/'+ dealreg.id);
            }
        }
        return ref;
    }
    
    public void reject()
    {
        //  ProcessInstanceWorkitemId =  ApexPages.currentPage().getParameters().get('piwd');
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        if (sobjtype == 'Engineers__c' && SelectedReason == 'Others') // condition added by shiv and put origenal code in else part
            req2.setComments(comment );
        else
            req2.setComments(SelectedReason );
        req2.setAction('Reject');
        req2.setWorkitemId(ProcessInstanceWorkitemId);
        
        Approval.ProcessResult result2 = Approval.process(req2); 
    }
    
    
    public List<SelectOption> getReasonsforRejection() 
    {
        List<SelectOption> objNames = new List<SelectOption>();
        
        if(sobjtype =='Engineers__c')
        {
            objNames.add(new SelectOption('User already exists','User already exists'));
            objNames.add(new SelectOption('User needs to complete certifications' ,'User needs to complete certifications'));
            objNames.add(new SelectOption('User name mismatch','User name mismatch'));
            objNames.add(new SelectOption('User email address mismatch','User email address mismatch '));
            objNames.add(new SelectOption('Others','Others'));
        }
        else if(sobjtype == 'Deal_Registration__c') 
        {
            objNames.add(new SelectOption('This was a previous NCR Account within the past 8 years, does not qualify','This was a previous NCR Account within the past 8 years, does not qualify'));objNames.add(new SelectOption('This is an existing named account does not qualify' ,'This is an existing named account does not qualify'));
            objNames.add(new SelectOption('Value is insufficient to qualify for Deal Registration','Value is insufficient to qualify for Deal Registration'));objNames.add(new SelectOption('Region or country is not part of the Deal Registration Program','Region or country is not part of the Deal Registration Program '));
        }
        return objNames;
    }
    
    public void RejectEngineer() 
    {
        rejectionReason =true;
    }
    
    public PageReference cancel()
    {
        PageReference ref;
        if(sobjtype =='Engineers__c')
            ref = new PageReference ('/'+ eng.id);
        else if(sobjtype == 'Deal_Registration__c')
            ref = new PageReference ('/'+ dealreg.id);
        return ref;
    }
    
    public PageReference ApproveEngineer() 
    {
        if(sobjtype == 'Engineers__c')
        {
            update eng;
        }
        PageReference ref = null;
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(Comment);
        req2.setAction('Approve');
        req2.setWorkitemId(ProcessInstanceWorkitemId );
        
        // Submit the request for approval 
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // create the Contact Record
        if(sobjtype == 'Engineers__c'){
            ref = approvalProcessDeveloperName == 'CertifiedPersonnelMandatoryDocs' ? EngineerToContactConversion() : new PageReference ('/'+ eng.id);
            //sendemail();
            
        }
        else if(sobjtype == 'Deal_Registration__c'){ ref = new PageReference ('/'+ dealReg.id); 
            // ref = DealRegOpportunityConversion();
        }
        
        return ref;
    }
    
    public PageReference EngineerToContactConversion()
    {
        PageReference ref; Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        //creating the partner user
        //Create contact
        Contact contactInstannce = new Contact();
        contactInstannce.recordtypeId =devRecordTypeId ;contactInstannce.FirstName = eng.First_name__c;contactInstannce.Lastname = eng.Last_Name__c;contactInstannce.Email = eng.Email_Address__c;
        contactInstannce.AccountId = eng.Partner_Account__c;contactInstannce.Title ='Engineer';contactInstannce.Decision_Maker__c ='Not involved';contactInstannce.Level__c ='Individual Contributor';
        contactInstannce.Business_Function__c ='Customer Support/Service';contactInstannce.Portal_User__c = true;contactInstannce.Profile_Status__c ='Active';contactInstannce.Portal_Login_Status__c ='Active';
        contactInstannce.Survey_Flag__c ='No-Customer Opt Out';contactInstannce.Reason__c ='Channel directive';contactInstannce.Web_Portal_Login__c= eng.Web_Portal_login_ID__c;
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Insert contactInstannce;eng.Contact__c = contactInstannce.Id;update eng; ref = new PageReference ('/'+ eng.id);         
        }
        catch(Exception e){
            Database.rollback(sp); ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getmessage());ApexPages.addMessage(myMsg);
        }
        return ref;
        
    }
    
    
    public ApprovalHistoryPageController(ApexPages.StandardController controller)
    {
        allPIList = new List<ProcessInstance>();
        //get the partner detail
        if(ApexPages.currentPage().getUrl().containsignorecase('PartnerCentral'))
            isPartnerCentral = true;
        else
            isPartnerCentral = false;
        
        piNodeList = new List<ProcessInstanceNode>(); 
        //get the value of Mode
        
        sequenceToNodeNameMap = new Map<Id,String>();
        
        sobjtype= controller.getRecord().getsObjectType().getDescribe().getName();
        System.debug('sobjtype__>'+ sobjtype);
        //Initialize Oppty
        if(sobjtype== 'Deal_Registration__c'){
            this.dealreg= (Deal_Registration__c)controller.getRecord();recordId = dealReg.Id;
        }
        else if(sobjtype == 'Engineers__c'){
            this.eng = (Engineers__c)controller.getRecord();
            recordId= eng.Id;
            
        }
        
        //Get all the Process Instance records. 
        
        allPIList = [Select Id,CompletedDate , 
                     (Select Id, OriginalActorId, ActorId, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                     (Select Id, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                     (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC) 
                     From ProcessInstance p WHERE TargetObjectId =: recordId ORDER BY CreatedDate DESC];        
        
        piStepList = new List<ProcessInstanceStep>();
        displayList = new List<List<String>>();
        userList = new List<User>();
        userIdSet = new Set<Id>();
        ActorName = null;
        OriginalActorName = null;
        showTable = true;
        showLink = true;
        ProcessInstanceWorkitemId = null;
        isApprover = false;
        AccStr = ' ';
        List<User>  userList  = [Select id , name from User Where id =: UserInfo.getUserId() AND  Profile.Name ='System Administrator'];
        
        if (allPIList.size() == 0)
            showTable = false;
        else
        {
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
                            setGroupId.add(piWI.OriginalActorId);
                        else
                            userIdSet.add(piWI.OriginalActorId);
                        
                        if(strOriginalActorObjectName == 'Group')
                            setGroupId.add(piWI.ActorId);
                        else
                            userIdSet.add(piWI.ActorId);
                    }
                }
            }
            for(GroupMember objGM: [Select Id, GroupId, Group.Name, UserOrGroupId From GroupMember where GroupId IN: setGroupId])
            {
                mapGroupIdToName.put(objGM.GroupId, objGM.Group.Name);
                if(objGM.UserOrGroupId != null )
                {
                    String strUserId = String.valueOf(objGM.UserOrGroupId);
                    if(strUserId.startsWith('005'))
                    {
                        userIdSet.add(objGM.UserOrGroupId);
                        
                        if(!mapGroupIdTolstMember.containsKey(objGM.GroupId))
                            mapGroupIdTolstMember.put(objGM.GroupId, new Set<Id>{objGM.UserOrGroupId});
                        else
                            mapGroupIdTolstMember.get(objGM.GroupId).add(objGM.UserOrGroupId);
                    }
                }
            }
            for (ProcessInstance pi: allPIList)
            {
                //if the Approval Process is Pending for approval, there will be Workitem associated with Process Instance.
                if (pi.Workitems.size() > 0)
                {
                    
                    //Added for loop to go over all the WorkItems and add all the Approvers in case of multiple Approvers
                    /*for(ProcessInstanceWorkitem piWI : pi.Workitems)
{
String strOriginalActorObjectName = piWI.OriginalActorId.getSObjectType().getDescribe().getName();
String strActorObjectName = piWI.ActorId.getSObjectType().getDescribe().getName();
if(strOriginalActorObjectName == 'Group')
setGroupId.add(piWI.OriginalActorId);
else
userIdSet.add(piWI.OriginalActorId);

if(strOriginalActorObjectName == 'Group')
setGroupId.add(piWI.ActorId);
else
userIdSet.add(piWI.ActorId);
}

for(GroupMember objGM: [Select Id, GroupId, Group.Name, UserOrGroupId From GroupMember where GroupId IN: setGroupId])
{
mapGroupIdToName.put(objGM.GroupId, objGM.Group.Name);
if(objGM.UserOrGroupId != null )
{
String strUserId = String.valueOf(objGM.UserOrGroupId);
if(strUserId.startsWith('005'))
{
userIdSet.add(objGM.UserOrGroupId);

if(!mapGroupIdTolstMember.containsKey(objGM.GroupId))
mapGroupIdTolstMember.put(objGM.GroupId, new Set<Id>{objGM.UserOrGroupId});
else
mapGroupIdTolstMember.get(objGM.GroupId).add(objGM.UserOrGroupId);
}
}
}*/
                    
                    //List<User>  userList  = [Select id , name from User Where id =: UserInfo.getUserId() AND  Profile.Name ='System Administrator'];
                    Boolean allowLink = userList != null && !userList.isEmpty()  ? true: false;
                    
                    if ((userIdSet.contains(UserInfo.getUserId()) )|| allowLink   )
                    {
                        showLink = true;isApprover = true;
                    }
                    else
                    {
                        showLink = false;
                    }
                }
                
                //All the Approval process steps apart from pending step -> Process Instance Steps
                if (pi.Steps.size() > 0)
                {
                    for(Integer i=0;i<pi.Steps.size();i++)
                    {
                        userIdSet.add(pi.Steps[i].OriginalActorId);
                        userIdSet.add(pi.Steps[i].ActorId); 
                    }
                }
            }
            
            //Get all the users listed in the Approval Process
            userList = [SELECT Id, Name, DelegatedApproverId FROM User WHERE Id IN :userIdSet];
            Map<Id, User> IdUserMap = new Map<Id, User>();
            for(Id pId: userIdSet)
            {
                for(User u: userList)
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
                        if(!Test.isRunningTest() && setGroupMemberUserId.contains(UserInfo.getUserId()) && IdUserMap.get(UserInfo.getUserId()) != null && (UserInfo.getUserId() == IdUserMap.get(UserInfo.getUserId()).DelegatedApproverId))
                        {
                            showLink = true; isApprover = true;
                        }
                    }
                    else if(UserInfo.getUserId() == IdUserMap.get(pi.Workitems[0].ActorId).DelegatedApproverId)
                    {
                        showLink = true;isApprover = true;
                    }
                }
            } 
            System.debug('------------IdUserMap----'+IdUserMap);           
        }
        System.debug('------------mapGroupIdTolstMember----'+mapGroupIdTolstMember);
        System.debug('------------mapGroupIdToName----'+mapGroupIdToName);
        System.debug('------------userIdSet----'+userIdSet);
        ApprovalHisoryTable();
    }
    
    /*ApprovalHistoryTable()
- Adds all the values to a List<List<String>> to show in tabular format    
*/
    public void ApprovalHisoryTable()
    {        
        List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>();
        piStepList = new List<ProcessInstanceStep>();
        String pstepName;   
        
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
                        
                        System.debug('---------w.OriginalActorId----------------------'+w.OriginalActorId);
                        System.debug('---------mapGroupIdToName.get(w.OriginalActorId)----------------------'+mapGroupIdToName.get(w.OriginalActorId));     
                        System.debug('---------ActorName----------------------'+strActorName);
                        System.debug('---------OriginalActorName----------------------'+strOriginalActorName);  
                        for (User u: userList)
                        {
                            if(w.ActorId == u.Id && strActorName == 'User') ActorName = u.Name;
                            if(w.OriginalActorId == u.Id && strOriginalActorName == 'User') OriginalActorName = u.Name;
                        }
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
                        stepName =  sequenceToNodeNameMap.get(pii.ProcessNodeId);stepStat = 'Approved';
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
                        stepName =  sequenceToNodeNameMap.get(pii.ProcessNodeId);stepStat = 'Rejected';
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
                stepName = 'Approval Request Recalled'; stepStat = 'Recalled';
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
            
            System.debug('---------s.ActorId----------------------'+s.ActorId);
            System.debug('---------s.OriginalActorId----------------------'+s.OriginalActorId);
            //System.debug('---------mapGroupIdToName----------------------'+mapGroupIdToName); 
            //System.debug('---------mapGroupIdToName.get(s.OriginalActorId)----------------------'+mapIdToGroup.get(s.OriginalActorId).Name);  
            
            System.debug('---------ActorName----------------------'+ActorName);
            System.debug('---------OriginalActorName----------------------'+OriginalActorName);
            
            for (User u: userList)
            {
                if(s.ActorId == u.Id && strSActorName == 'User') ActorName = u.Name;
                if(s.OriginalActorId == u.Id && strSOriginalActorName == 'User') OriginalActorName = u.Name;
            }
            
            System.debug('---------ActorName-after---------------------'+ActorName);
            System.debug('---------OriginalActorName--after--------------------'+OriginalActorName);
            
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
        System.debug('displayList-------------'+ displayList);
    }
    
    
    public void sendEmail()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //Set list of people who should get the email
        List<String> sendTo = new List<String>();sendTo.add(Eng.owner.email);
        if(Eng.owner.email != Eng.Email_Address__c)
            sendTo.add(Eng.Email_Address__c);mail.setToAddresses(sendTo);
        
        //Set who the email is sent from
        mail.setReplyTo('nonReply@ncr.com');mail.setSenderDisplayName('Non- Reply ');
        
        // (Optional) Set list of people who should be CC'ed
        List<String> ccTo = new List<String>();
        //  Set email contents - you can use variables!
        mail.setSubject('Request:Disaproval of Engineer'+ eng.name+ 'conversion to Contact');String body ='<Html><body>' +'Dear ' + Eng.Owner.Name + ', '+'</br></br>';
        
        System.debug('SelectedReason '+ SelectedReason );
        if(comment == null || comment == ''){
            body += 'The request was denied due to ' +  SelectedReason + ' and you will be able to edit and resubmit the request.'+ '</Html></body>';
        }else {
            body += 'The request was denied due to ' +  comment+ ' and you will be able to edit and resubmit the request.'+ '</Html></body>';
        }
        mail.setHtmlBody(body);Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {mail};
             if(!sendTo.isEmpty()){ 
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
             }
    }
    
    
    public void sendEmailDealRegistration()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //Query Email
        List<EmailTemplate> emailtemp =[Select id from EmailTemplate Where Name ='Deal Registration Rejection Email Template'];
        
        //Set list of people who should get the email
        List<String> sendTo = new List<String>();sendTo.add(Dealreg.owner.email);mail.setToAddresses(sendTo); 
        
        //Set who the email is sent from
        
        mail.setTemplateID(emailtemp[0].Id); mail.setSaveAsActivity(false); mail.setWhatId(dealreg.id);mail.setTargetObjectId(dealReg.OwnerId);
        
        // (Optional) Set list of people who should be CC'ed
        List<String> ccTo = new List<String>();
        //  Set email contents - you can use variables!
        System.debug('mail'+ mail);
        if(!sendTo.isEmpty()){
        List<Messaging.SingleEmailMessage> mails=new List<Messaging.SingleEmailMessage>();
         mails.add(mail);
        Messaging.sendEmail(mails);
        }
        
        /*   
// Pick a dummy Contact
Contact c = [select id, Email from Contact where email <> null limit 1];
// Construct the list of emails we want to send
List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();

Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
msg.setTemplateId( [select id from EmailTemplate where Name ='Deal Registration Rejection Email Template'].id );
msg.setWhatId(dealreg.id);
msg.setTargetObjectId(c.id);
msg.setToAddresses(new List<String>{'random_address@ncr.com'});
lstMsgs.add(msg);

// Send the emails in a transaction, then roll it back
Savepoint sp = Database.setSavepoint();
Messaging.sendEmail(lstMsgs);
Database.rollback(sp);

// For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
// contents to a new SingleEmailMessage. Then send those new messages.
List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
for (Messaging.SingleEmailMessage email : lstMsgs) {
Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
List<String> sendTo = new List<String>();
sendTo.add(Dealreg.owner.email);
emailToSend.setToAddresses(sendTo);
emailToSend.setPlainTextBody(email.getPlainTextBody());
emailToSend.setHTMLBody(email.getHTMLBody());
emailToSend.setSubject(email.getSubject());
lstMsgsToSend.add(emailToSend);
}
Messaging.sendEmail(lstMsgsToSend);
*/
    }
}