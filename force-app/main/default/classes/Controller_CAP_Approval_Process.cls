public class Controller_CAP_Approval_Process {
    
    @AuraEnabled
    public static List<String> LoadCasedetails(id recordID){
        List <String> returningvalues = new List<string>();
        List<id> Qlook = new List<id>();
        List<Group> TempPGList = new List<Group>();
        User currentuser = [Select id, Quicklook_ID__c from User where id =: UserInfo.getUserId() limit 1];
        CAP_Form__c capobject = [Select id,Ownerid,ApprovalRequestfront__c,Customer_Name__c from CAP_Form__c where id=: recordID limit 1];
        String commentStr;
        
        List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
        for(GroupMember gm : groupMembers){
            Qlook.add(gm.UserOrGroupId);
        }
               
        String RETRUNVALUE =  'false';
        List<CAP_Form__c> capobject2 = new List<CAP_FOrm__c>([Select id,Ownerid,ApprovalRequestfront__c,Customer_Name__c from CAP_Form__c where id!=: recordID AND ApprovalRequestfront__c !=:'Not Submitted']);
        
        for(CAP_Form__c c : capobject2){
            if(c.Customer_Name__c == capobject.Customer_Name__c){
                RETRUNVALUE =  'true' ;
            }
        }
        
        if(capobject.ApprovalRequestfront__c =='Not Submitted'){
            String result = 'Not Submitted';
            returningvalues.add(result);
            Qlook.add(capobject.Ownerid);
            if(capobject.ownerid != currentuser.id){
               String accessuser = '*Only Record Owner can Submit Request';
               returningvalues.add(accessuser);
            }
           else{ 
                String accessuser = 'true';
                returningvalues.add(accessuser);
                if(RETRUNVALUE == 'true'){
                    returningvalues.add(RETRUNVALUE);
               }
            }
        } 
        else if(capobject.ApprovalRequestfront__c =='Submitted'){
            String result = 'Submitted';
            returningvalues.add(result);
            system.debug('in submitted... qlooks are ###'+Qlook);
            system.debug('in submitted... qlooks are ###'+currentuser.id);
            if(Qlook.contains(currentuser.id)){
                String accessuser = 'true';
                returningvalues.add(accessuser);
                system.debug('it containst current user id');
            }
            else{
                system.debug('it doesnt containst current user id');
                String accessuser = 'This request is under Approval';
                returningvalues.add(accessuser);
            }
        }
        else if(capobject.ApprovalRequestfront__c =='Rejected'){
            String result = 'Rejected';
            returningvalues.add(result);
            if(Qlook.contains(currentuser.id)){
                if(RETRUNVALUE == 'true'){
                    returningvalues.add(RETRUNVALUE);
                }
            }   
        }
        else {
            CAP_Form__c quote = [Select Id, (Select TargetObjectId, SystemModstamp, StepStatus, RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, CreatedDate, CreatedById, Comments, ActorId From ProcessSteps order by SystemModstamp desc limit 1 ) from CAP_Form__c where Id = :recordID];
            for (ProcessInstanceHistory ps : quote.ProcessSteps){
                commentStr = ps.comments;
            }
            returningvalues.add(commentStr);
        }
        
        
        return returningvalues;
    }
    @AuraEnabled
    public static Boolean submitforapprovals(id recordID) {
        CAP_Form__c capobject = [Select id,Ownerid,ApprovalRequestfront__c,Anticipated_Project_Start_Date__c from CAP_Form__c where id=: recordID limit 1];
        capobject.ApprovalRequestfront__c='Submitted';
        capobject.Anticipated_Project_Start_Date__c =  (capobject.Anticipated_Project_Start_Date__c < system.today()) ? system.today() : capobject.Anticipated_Project_Start_Date__c;
        update capobject;
        
        return true;
    }
    @AuraEnabled
    public static Boolean approvecapss(id recordID){
        CAP_Form__c capobject = [Select id,Ownerid,ApprovalRequestfront__c,Customer_Name__c from CAP_Form__c where id=: recordID limit 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approved CAP');
        req.setAction('Approve');
        Id workItemId = getWorkItemId(capobject.id); 
        if(workItemId == null) {
            capobject.addError(system.label.Con_Cap);
        }
        //Error msg for custom label Con_Cap
        //Error Occured in update
        else{
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
        /******************************************************************************************/
        List<id> Qlook = new List<id>();
        List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
        for(GroupMember gm : groupMembers){
            Qlook.add(gm.UserOrGroupId);
        }
        Qlook.add(capobject.Ownerid);
        List <User> u1 = [Select id, email from User where id =: qlook];
        
        List<string> tolist = new List<String>();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        //con.Email = u1[0].email;
        con.Email = 'T070121@captest.com';
        insert con;
        for (user t1 : u1){
            tolist.add(t1.email);
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage approvalemail = new Messaging.SingleEmailMessage();
        //  ---------------------------
        EmailTemplate et=[Select id,Name,DeveloperName, Subject, Body from EmailTemplate where DeveloperName =: 'CAP_Approved_CAP'];
        approvalemail.setTemplateId(et.Id); // email Template Id
        approvalemail.setTargetObjectId(con.id);
        approvalemail.setToAddresses(tolist);
        approvalemail.setWhatId(capobject.id);
        approvalemail.setSaveAsActivity(false);
        // ----------------------------
        mails.add(approvalemail);
        Messaging.sendEmail(mails);
        /******************************************************************************************/
        delete con;
        return true;
    }
    @AuraEnabled
    public static Boolean approvecustomerassurancess(id recordID)
    {
        CAP_Form__c capobject = [Select id,Ownerid,ApprovalRequestfront__c,Customer_Name__c from CAP_Form__c where id=: recordID limit 1];
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approved Customer Assurance');
        req.setAction('Approve');
        // req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
        Id workItemId = getWorkItemId(capobject.id); 
        
        if(workItemId == null) {
            capobject.addError(system.label.Con_Cap);
        }
        //Error msg for custom label Con_Cap
        //Error Occured in update
        else {
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
        /******************************************************************************************/
        List<id> Qlook = new List<id>();
        List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
        for(GroupMember gm : groupMembers) {
            Qlook.add(gm.UserOrGroupId);
        }
        Qlook.add(capobject.Ownerid);
        
        List <User> u1 = [Select id, email from User where id =: qlook];
        
        List<string> tolist = new List<String>();
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        //con.Email =  con.Email = u1[0].email;
         con.Email = 'T070121@captest.com';
        insert con;
        
        for (user t1 : u1){
            tolist.add(t1.email);
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage approvalemail = new Messaging.SingleEmailMessage();
       // --------------
        EmailTemplate et=[Select id,Name,DeveloperName, Subject, Body from EmailTemplate where DeveloperName =: 'CAP_Approved_Assurance'];
        approvalemail.setTemplateId(et.Id); // email Template Id
        approvalemail.setTargetObjectId(con.id);
        approvalemail.setToAddresses(tolist);
        approvalemail.setWhatId(capobject.id);
        approvalemail.setSaveAsActivity(false);
        // --------------
        mails.add(approvalemail);
        Messaging.sendEmail(mails);
        /******************************************************************************************/
        delete con;
        return true;
    }
    
    @AuraEnabled
    public static Boolean approveWatchlist(id recordID)
    {
        CAP_Form__c capobject = [Select id,Ownerid,ApprovalRequestfront__c,Customer_Name__c from CAP_Form__c where id=: recordID limit 1];
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approved for Watchlist');
        req.setAction('Approve');
        // req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
        Id workItemId = getWorkItemId(capobject.id); 
        
        if(workItemId == null) {
            capobject.addError(system.label.Con_Cap);
        }
        //Error msg for custom label Con_Cap
        //Error Occured in update
        else {
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
        /******************************************************************************************/
        List<id> Qlook = new List<id>();
        List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
        for(GroupMember gm : groupMembers) {
            Qlook.add(gm.UserOrGroupId);
        }
        Qlook.add(capobject.Ownerid);
        
        List <User> u1 = [Select id, email from User where id =: qlook];
        
        List<string> tolist = new List<String>();
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
       // con.Email =  con.Email = u1[0].email;
        con.Email = 'T070121@captest.com';
        insert con;
        
        for (user t1 : u1){
            tolist.add(t1.email);
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage approvalemail = new Messaging.SingleEmailMessage();
       // --------------
        EmailTemplate et=[Select id,Name,DeveloperName, Subject, Body from EmailTemplate where DeveloperName =: 'CAP_Approved_Watchlist'];
        approvalemail.setTemplateId(et.Id); // email Template Id
        approvalemail.setTargetObjectId(con.id);
        approvalemail.setToAddresses(tolist);
        approvalemail.setWhatId(capobject.id);
        approvalemail.setSaveAsActivity(false);
        // --------------
        mails.add(approvalemail);
        Messaging.sendEmail(mails);
        /******************************************************************************************/
        delete con;
        return true;
    }
    
    @AuraEnabled
    public static Boolean rejectss(id recordID){
        CAP_Form__c capobject = [Select id,Ownerid,ApprovalRequestfront__c from CAP_Form__c where id=: recordID limit 1];
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Request is Rejected');
        req.setAction('Reject');
        Id workItemId = getWorkItemId(capobject.id); 
        
        if(workItemId == null){
            capobject.addError(system.label.Con_Cap);
        }
        //Error msg for custom label Con_Cap
        //Error Occured in update
        else{
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
        return true;
        
    }
    
    @AuraEnabled
    public static Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                                                 where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            system.debug('########### workItem id received at getworkitem is  +'+ workItem);
            retVal  =  workItem.Id;
        }
        return retVal;
    }
    
    
}