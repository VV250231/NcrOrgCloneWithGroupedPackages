/*************************************************************************************************************************************
  
# Modification History : 

Story No#         Date            DevName                   Description
EBA_SF-1210    30th Nov 2021    Saurav Gautam         Moved the Messaging.SingleEmailMessage to a workflow by Using 
                                                      NCR_EmailMessage__c object.
EBA_SF-1642     30th Nov 2021     Santosh Jha         Technical Debt for NewCo: SOQL Embedded in a Loop - Case trigger handler
EBA_SF-1895     22nd March 2022   Puneet Bhatia       Added changes to prevent Email-to-Case duplicatec case creation
**************************************************************************************************************************************/


public class CaseTriggerHandler {
    /*Related to CCADD Disputes*/
    public Set<String> getIgnoreProfileIds(){
        Set<String> ignoreProfileIds = new Set<String>();
        /*List<CCAD_Service_Ignored_Profile__c> sipList = CCAD_Service_Ignored_Profile__c.getall().values();    
for(CCAD_Service_Ignored_Profile__c sip : sipList) {
ignoreProfileIds.add(sip.Profile_Name__c.toUpperCase());
}*/
        All_profie_config__c sipList = All_profie_config__c.getValues('CCAD Service Ignored Profile');  
        for(string sip : sipList.Profile_Id__c.split(',')) {
            ignoreProfileIds.add(sip.toUpperCase());
        }
        return ignoreProfileIds; 
    }
    /*was written in CaseTrigger before EBA_SF-680 and it is related to CCADD Dispute analyst field populate*/
    public void disputeAnlystFieldPop(List<Case> cases){
        Set<String> McnSet = new Set<String>();
        Set<String> CaseOwnerIdSet = new Set<String>();
        for(Case CaseObj : cases){
            if(caseObj.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId()) {
                if(String.isBlank(CaseObj.Dispute_Analyst_Name__c)){
                    CaseObj.Dispute_Analyst_Name__c='Assigned to Queue';
                }
                if(String.isNotBlank(CaseObj.Master_Customer_Nbr__c)){
                    McnSet.add(CaseObj.Master_Customer_Nbr__c); 
                }
            }
        }
        User loginUser = [SELECT id,Name,Quicklook_ID__c, ProfileId, Profile.Name from User where Id = :Userinfo.getUserId() LIMIT 1];
        Map<String,Account> McnAccountMap = new Map<String,Account>();
        if(McnSet!= null && McnSet.Size()>0){
            for(Account AccObj : [Select id,Name,Master_Customer_Number__c  from Account where Master_Customer_Number__c IN : McnSet]){
                if(!McnAccountMap.containsKey(AccObj.Master_Customer_Number__c  )){
                    McnAccountMap.put(AccObj.Master_Customer_Number__c,AccObj);
                }      
            }
        }
        if(McnAccountMap != null && McnAccountMap.keySet().Size()>0){
            for(Case CaseObj : cases){
                if((String.isNotBlank(CaseObj.Master_Customer_Nbr__c))  && (McnAccountMap.containskey(CaseObj.Master_Customer_Nbr__c)) && (String.isNotBlank(McnAccountMap.get(CaseObj.Master_Customer_Nbr__c).Id))){
                    CaseObj.AccountId=McnAccountMap.get(CaseObj.Master_Customer_Nbr__c).Id;// This is the place AccountId is getting populated and this why AccountId(Account Name) 
                } 
                if((loginUser != NULL) && (!getIgnoreProfileIds().contains(((String) loginUser.ProfileId).toUpperCase()))){  
                    CaseObj.Dispute_Created_By_Name__c = loginUser.Name;
                    CaseObj.Dispute_CreatedBy_Qlook__c = loginUser.Quicklook_ID__c;
                    CaseObj.Dispute_Updated_By_Name__c = loginUser.Name;
                    CaseObj.Dispute_UpdatedBy_Qlook__c = loginUser.Quicklook_ID__c;
                }
            }
        }
    }
    /*was written in linkCaseWithNPSSurveyResult before EBA_SF-680 and it is related to VOC assign functionl area*/
    public void assignVOCCaseFnctnAreaLOB(List<Case> cases){
        Map<String,Map<String,VocLineOfBusiness__mdt>> FunctionAreaAndLobMap = new Map<String,Map<String,VocLineOfBusiness__mdt>>();
        Set<String> AccountFunctionalAreaSet = new Set<String>();
        Set<String> ContactIdSet= new Set<String>();
        String RecordTypeIdOfCloseTheLoopChld ='';
        RecordTypeIdOfCloseTheLoopChld = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Follow-up').getRecordTypeId();
        for(Case CaseObj : cases){
            if((String.isNotBlank(RecordTypeIdOfCloseTheLoopChld)) &&  (CaseObj.RecordTypeId == RecordTypeIdOfCloseTheLoopChld)){
                if(!AccountFunctionalAreaSet.contains(CaseObj.Functional_Area__c)){
                    AccountFunctionalAreaSet.add(CaseObj.Functional_Area__c);
                }
                
                if(String.isNotBlank(CaseObj.ContactId)){
                    ContactIdSet.add(CaseObj.ContactId);
                }
                
            }
        }
        if((AccountFunctionalAreaSet != null) && (AccountFunctionalAreaSet.size()>0)){
            FunctionAreaAndLobMap=LinkCaseWithNPSSurveyResultHandler.GetMapOfFunctionalAreaAndLob();
        }
        if((FunctionAreaAndLobMap != null) && (FunctionAreaAndLobMap.keySet().Size()>0)){
            Map<ID, Contact> AccountLobMap;
            if((ContactIdSet != null) && (ContactIdSet.size()>0)){
                
                AccountLobMap= new Map<ID, Contact>([Select id,name,Account.Name,Account.Lob__c from contact where Id IN : ContactIdSet ]);
            }
            //Code added by Naman(NK250337)
            Id salesPeopleQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Sales People' LIMIT 1].Id;
            Set<Id> userIds = new Set<Id>();
            for(GroupMember userId :[Select UserOrGroupId from GroupMember WHERE GroupId =:salesPeopleQueueId]){
                userIds.add(userId.UserOrGroupId);
            }
            for(case caseObj : cases){
                
                if((FunctionAreaAndLobMap.containsKey(caseObj.Functional_Area__c.touppercase())) && (FunctionAreaAndLobMap.get(caseObj.Functional_Area__c.touppercase()).size()>0) && (AccountLobMap != null) && (AccountLobMap.containsKey(CaseObj.ContactId)) && (String.isNotBlank(AccountLobMap.get(CaseObj.ContactId).Account.Lob__c)) && (FunctionAreaAndLobMap.get(caseObj.Functional_Area__c.touppercase()).containsKey(AccountLobMap.get(CaseObj.ContactId).Account.Lob__c.touppercase()))){
                    if(String.isNotBlank(FunctionAreaAndLobMap.get(caseObj.Functional_Area__c.touppercase()).get(AccountLobMap.get(CaseObj.ContactId).Account.Lob__c.touppercase()).RelatedQueue__c)){
                        caseObj.OwnerId=FunctionAreaAndLobMap.get(caseObj.Functional_Area__c.touppercase()).get(AccountLobMap.get(CaseObj.ContactId).Account.Lob__c.touppercase()).RelatedQueue__c;
                    }
                }
            }
        }    
    }
    /*was written in updateCaseOwnerAndAssign before EBA_SF-680 and it is related to IPT and Partner Assist record type in Case to populate subject*/
    public void updateCaseOwnerAndAssign(List<Case> cases){
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Assist' AND SobjectType='Case' LIMIT 1 ];
        RecordType rt_IPT = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'IPT_Partner' AND SobjectType='Case' LIMIT 1 ];
        for(Case c : cases){
            if(c.RecordTypeId != null && c.RecordTypeId == rt.Id){
                c.Is_Partner_Assist_Team_Case__c =  true ;
            }else if (c.RecordTypeId != null && c.RecordTypeId == rt_IPT .Id) {
                if(c.subject != null){
                    string temp =  c.category__c +'-'+ c.subject;
                    c.subject = temp;
                } else{
                    c.subject = c.category__c;
                }
            }
        }    
    }
    /*was written in CaseTrigger before EBA_SF-680 and it is related to send CCADD Dispute to CCADD(integration)*/
    public void sendDisputeToCCADD(List<Case> cases){
        String DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        List<Id> caseIdList = new List<Id>();
        //Dispute Logic CCAD via Salesforce Starts
        for(case caseObj : cases){
            if(caseObj.RecordTypeId==DisputeRecordTypeId)
                caseIdList.add(caseObj.Id); 
        }
        if(sendDisputesToCCAD.runOnce()){
            //System.debug('syncCaseToCCAD_With_Future Insert call');
            sendDisputesToCCAD.syncCaseToCCAD_With_Future(caseIdList,true);
        }
        
        //CCAD_dipsuteEmailNotifications.DisputeCreate_Notifications(Trigger.New,true);
        //Dispute Logic CCAD via Salesforce Starts Ends        
    }
    /*was written in CaseTrigger before EBA_SF-680 and it is related to CCADD Dispute analyst field populate on update*/
    public void disputeAnlystFieldPopUpdt(List<Case> cases,Map<Id,Case> oldCaseMap){
        /*List<DisputeAnalystController.PicklistWrapperClass> wrapObj = new List<DisputeAnalystController.PicklistWrapperClass>();
        Map<String,DisputeAnalystController.PicklistWrapperClass> DisputeAnayste_labelValueMap = new Map<String,DisputeAnalystController.PicklistWrapperClass>();
        if(wrapObj != null && wrapObj.size()>0){
            for(DisputeAnalystController.PicklistWrapperClass ValueObj : wrapObj ){
                DisputeAnayste_labelValueMap.put(ValueObj.value.toLowerCase(),ValueObj);
            }
        }
        
        wrapObj = DisputeAnalystController.getPicklistValues('Case', 'Dispute_Analyst_Name__c');*/
        Map<String,String> MapofDisputeIdandApiName = new Map<String,String>(); 
        Set<String> UserQuickLookSet = new Set<String>();
        
        Map<String,User> ActiveQuicklookUserMap= new Map<String,User>();
        
        for(Case CaseObj : cases){
            if(caseObj.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId()){
                if(String.isNotBlank(CaseObj.Dispute_Analyst_Name__c)  && CaseObj.Dispute_Analyst_Name__c != oldCaseMap.get(CaseObj.Id).Dispute_Analyst_Name__c){
                    if(String.isnotBlank(CaseObj.Dispute_Analyst_Name__c)){
                        UserQuickLookSet.add(CaseObj.Dispute_Analyst_Name__c.toLowercase());
                    }
                }
            }
        }
        if(UserQuickLookSet != null && UserQuickLookSet.size()>0){
            for(User UserObj : [Select id,name,Phone,Email,Quicklook_ID__c from User where Quicklook_ID__c IN : UserQuickLookSet]){
                if(!ActiveQuicklookUserMap.containsKey(UserObj.Quicklook_ID__c.tolowercase())){
                    ActiveQuicklookUserMap.put(UserObj.Quicklook_ID__c,UserObj);
                }
            }
        }
        
        //System.debug('ActiveQuicklookUserMap'+ActiveQuicklookUserMap);
        if(ActiveQuicklookUserMap != null){
            for(Case CaseObj : cases){
                if(String.isNotBlank(CaseObj.Dispute_Analyst_Name__c)  && ActiveQuicklookUserMap.containsKey(CaseObj.Dispute_Analyst_Name__c.toLowerCase())){
                    CaseObj.DisputeAnalyst__c=ActiveQuicklookUserMap.get(CaseObj.Dispute_Analyst_Name__c.tolowercase()).Id;
                    CaseObj.Dispute_Analyst_Email__c=ActiveQuicklookUserMap.get(CaseObj.Dispute_Analyst_Name__c.tolowercase()).Email;
                    CaseObj.Dispute_Analyst_Name__c=ActiveQuicklookUserMap.get(CaseObj.Dispute_Analyst_Name__c.tolowercase()).Quicklook_ID__c;
                    
                    if(String.isNotBlank(ActiveQuicklookUserMap.get(CaseObj.Dispute_Analyst_Name__c).Phone)){
                        CaseObj.Dispute_Analyst_Phone__c=ActiveQuicklookUserMap.get(CaseObj.Dispute_Analyst_Name__c.tolowercase()).Phone;
                    }
                }
            }
        }    
    }
    /*was written in CaseTrigger before EBA_SF-680 and it is related to MACC send notification if case status changes*/
    public void maccSndAlertToAgentMngr(List<Case> cases,Map<Id,Case> oldCaseMap){
        List<Case> caseList = new List<Case>();
        for(case caseObj : cases) {
            if(oldCaseMap.get(caseObj.id).Status != caseObj.Status) { 
                caseList.add(caseObj);
            }
        }
        MaccChatHandler.sendEmailNotificationToAgentManager(caseList);
    }
    /*was written in CaseTrigger before EBA_SF-680 and it is related to CCADD send disputes*/
    public void sendDisputesCCADD(List<Case> cases,Map<Id,Case> oldCaseMap){
        String DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        List<Id> caseIdList = new List<Id>();
        List<Id> caseEscalationIdList = new List<Id>();
        List<case> caseList = new List<Case>();
        List<CaseComment> ccList = new List<CaseComment>();
        Set<String> userIdSet = new Set<String>();
        for(case caseObj : cases) {
            if (caseObj.LastModifiedById != oldCaseMap.get(caseObj.id).LastModifiedById && caseObj.RecordTypeId == DisputeRecordTypeId) {
                userIdSet.add(caseObj.LastModifiedById); 
            }
        }        
        
        /****** Update Dispute Created By and Dispute Updated by only for Dispute Case Record Type ******/
        Set<Id> updateCaseId = new Set<Id>();
        if (!userIdSet.isEmpty()) {
            Map<Id,User> userMap = new Map<Id,User>([SELECT Id, ProfileId, Profile.Name, Quicklook_ID__c, Name from User where Id IN :userIdSet]);
            for(Case c : cases) {
                if(!getIgnoreProfileIds().contains(((String) userMap.get(c.LastModifiedById).ProfileId).toUpperCase())) {
                    updateCaseId.add(c.Id);     
                } 
            }
            
            if (!updateCaseId.isEmpty()) {
                List<Case> updateCaseList = [SELECT Id, LastModifiedById, Dispute_UpdatedBy_Qlook__c, Dispute_Updated_By_Name__c FROM CASE WHERE Id IN :updateCaseId];
                for(Case c : updateCaseList) {                  
                    c.Dispute_UpdatedBy_Qlook__c = userMap.get(c.LastModifiedById).Quicklook_ID__c; 
                    c.Dispute_Updated_By_Name__c = userMap.get(c.LastModifiedById).Name;
                }
                
                update updateCaseList;
            }
        }
        /****** Update Dispute Created By and Dispute Updated by only for Dispute Case Record Type *****/
        
        // Dispute Logic for  CCAD Starts        
        for(case caseObj : cases){
            if(caseObj.RecordTypeId==DisputeRecordTypeId){
                caseIdList.add(caseObj.Id);
                if(caseObj.Status=='Escalated' && (oldCaseMap.get(caseObj.id).Status != caseObj.Status)){
                    caseEscalationIdList.add(caseObj.Id);
                }  
            }
        }
        
        for(Case c: [Select Id,Status from Case where Id in :caseEscalationIdList]){
            If(c.Status=='Escalated') {
                CaseComment cc = new CaseComment();
                cc.CommentBody='ESCALATED'; 
                cc.ParentId=c.Id;
                ccList.add(cc);
            }
        }  
        if(ccList!=null)
            Insert ccList;
        
        if(DisputeUtil.getDspROR() == 'CCAD' && !caseIdList.isEmpty() && (sendDisputesToCCAD.runOnce() || Test.isRunningTest())) {
            If(!System.isFuture() && !System.isBatch()) {
                sendDisputesToCCAD.syncCaseToCCAD_With_Future(caseIdList,false);
                //System.debug('syncCaseToCCAD_With_Future call');
            }
            else {
                sendDisputesToCCAD.syncCaseToCCAD_Without_Future(caseIdList,false); 
            }
        }        
        // Dispute Logic for  CCAD Ends
        
    }
    /*was written in linkCaseWithNPSSurveyResult before EBA_SF-680 and it is related to VOC case record type*/
    public void VoCCasesRecordType(List<Case> cases,Map<Id,Case> oldCaseMap){
        List<VocRecordTypeChild__mdt> VOCRecordTypeMap = new List<VocRecordTypeChild__mdt>();
        VOCRecordTypeMap =[Select id,PickListValue__c,RecordTypeId__c,Status__c from VocRecordTypeChild__mdt]; 
        Set<String> VocRecordType = new Set<String>();
        Set<String> CloseTheLoop = new Set<String>();
        Set<String> CloseTheLoopChild= new Set<String>();
        if(VOCRecordTypeMap != Null && VOCRecordTypeMap.Size()>0){
            for(VocRecordTypeChild__mdt MetaDataObj : VOCRecordTypeMap){
                if(!VocRecordType.contains(MetaDataObj.RecordTypeId__c)){
                    VocRecordType.add(MetaDataObj.RecordTypeId__c);
                } 
            }
            for(Case CaseObj : cases){
                if(VocRecordType.contains(CaseObj.recordTypeId)){
                    if(String.isBlank(CaseObj.ParentId) && (CaseObj.IsClosed) && String.isBlank(CaseObj.CX_Case_Number__c)){
                        CloseTheLoop.add(CaseObj.id);
                    }
                    else if(String.isNotBlank(CaseObj.parentId)){
                        CloseTheLoopChild.add(CaseObj.id);
                    }
                } 
                
            }
            Map<String,List<Case>> MapOfChildCaseClose = new Map<String,List<Case>>(); 
            Map<String,Set<String>> MapOfChildCaseCloseReason = new Map<String,Set<String>>(); 
            if((CloseTheLoop != null)  && (CloseTheLoop.size()>0)){
                
                List<Case> CloseAllTheLoopChilsisNotClosed = new List<Case>();
                CloseAllTheLoopChilsisNotClosed=[Select id,Case_Close_Reason__c,isClosed,(Select id,Case_Close_Reason__c,isClosed from cases) from Case where Id  IN : CloseTheLoop];
                Integer Count = 0;
                Set<String> CloseReasonValidation = new Set<String>();
                
                if((CloseAllTheLoopChilsisNotClosed != null) && (CloseAllTheLoopChilsisNotClosed.size() >0 )){
                    
                    for(Case caseObj : CloseAllTheLoopChilsisNotClosed){ 
                        if(!MapOfChildCaseClose.containsKey(caseObj.id)){
                            MapOfChildCaseClose.put(caseObj.id, new List<Case>());
                        }
                        
                        if(!MapOfChildCaseCloseReason.containsKey(caseObj.Id)){
                            MapOfChildCaseCloseReason.put(caseObj.Id, new Set<String>());
                        }
                        
                        
                        if((caseObj.Cases != null) && (caseObj.Cases.size()>0)){
                            for(case caseObjChild : caseObj.cases){
                                if(!caseObjChild.IsClosed){MapOfChildCaseClose.get(caseObj.id).add(caseObjChild);
                                                          }
                                
                                if((String.isNotBlank(caseObjChild.Case_Close_Reason__c)) &&  caseObjChild.Case_Close_Reason__c == 'Resolution Requires Long-term Project'){MapOfChildCaseCloseReason.get(caseObj.id).add(caseObjChild.Case_Close_Reason__c);
                                                                                                                                                                           }
                                
                            }
                        }
                    }
                }
            }
            for(Case  CaseObj : cases){
                if(String.isBlank(CaseObj.ParentId)){
                    if( (CaseObj.IsClosed) && (MapOfChildCaseClose != null) && (MapOfChildCaseClose.containsKey(CaseObj.Id)) && (MapOfChildCaseClose.get(CaseObj.Id).size() >0) ){
                        CaseObj.addError(string.format(system.label.LinkCsNPS3, new List<string>{string.valueof(MapOfChildCaseClose.get(CaseObj.Id).size())})); 
                    } 
                    //Error msg for custom label LinkCsNPS3
                    //'You have '+' '+ MapOfChildCaseClose.get(CaseObj.Id).size() +' Child Case(s) that have not closed. You cannot close this case until all related child cases are closed
                    else if(VocRecordType.contains(CaseObj.recordTypeId) && (CaseObj.IsClosed)  && (String.isBlank(CaseObj.Case_Close_Reason__c))) {
                        CaseObj.Case_Close_Reason__c.addError(system.label.LinkCsNPS1);
                    }
                    //Error msg for custom label LinkCsNPS1
                    //Please Select Case Close Reason
                }
                if(String.isNotBlank(CaseObj.ParentId)){
                    if((CaseObj.isClosed)  && (String.isBlank(CaseObj.Case_Close_Reason__c)) && VocRecordType.contains(CaseObj.recordTypeId)){
                        CaseObj.Case_Close_Reason__c.addError(system.label.LinkCsNPS1);
                    }
                    if((CaseObj.isClosed) &&  ((CaseObj.Case_Close_Reason__c=='Resolution Requires Long-term Project') && String.isBlank(CaseObj.Project_Name__c))){
                        CaseObj.Project_Name__c.addError(system.label.LinkCsNPS2);
                    }
                    //Error msg for custom label LinkCsNPS2
                    //'Please enter project name or point of contact
                }
            } 
            
        }
    }
    /*was written in closeEmail before EBA_SF-680 and it is related to IPT case record type*/
    public void closeEmail(List<Case> cases, Map<Id,Case> caseOldMap){
        List<OrgWideEmailAddress> emailAddress = new List<OrgWideEmailAddress>();
        //emailAddress = [SELECT Id, address FROM OrgWideEmailAddress WHERE address = 'partner.resourcecenter@ncr.com'];
        If(Trigger.new.size() == 1){
            List<String> catLst = new List<string>();
             Set<Id> CretedId = new Set<Id>();
            List<User> users = new List<user>();
            List<Account> accounts = new List<Account>();
            for(Case ca: cases){
                catLst.add(ca.Category__c);
                CretedId.add(ca.CreatedById);
            }
            Map<String, Get_help_Configuration__mdt> catMetaMap = new Map<String, Get_help_Configuration__mdt>();
            for(Get_help_Configuration__mdt metaobj :[Select id,MasterLabel, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c from Get_help_Configuration__mdt Where MasterLabel IN: catLst]){
                catMetaMap.put(metaobj.MasterLabel, metaobj);
            }
            if(!CretedId.isEmpty())
            {  users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id IN:CretedId LIMIT 1];}
            if(!users.isEmpty()){
               accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: users[0].AccountId LIMIT 1];
            }
                EmailTemplate s = [select id from EmailTemplate where Name ='Get Help Close Notification VF'];
            List<NCR_EmailMessage__c> Ncrmails = new List<NCR_EmailMessage__c>();
            for(Case ca: cases){ 
                Case objOldCase = caseOldMap.get(ca.Id);
                //Added by Anupam: Stop email notification for Partner Assist Team "ca.Is_Partner_Assist_Team_Case__c == false"
                if(ca.status.containsIgnorecase('close') &&  objOldCase.Status != ca.Status && ca.Is_Partner_Assist_Team_Case__c == false ) 
                {
                    if( case.recordTypeId != null && Case.sObjectType.getDescribe().getRecordTypeInfosById().get(ca.RecordTypeId).getName().containsIgnoreCase('IPT') && ca.Origin !='IPT SSO')
                    {
                        List<String> ccAddressList = new  List<String>();
                        //change by santosh to avoid soql in for loop
                        //   List<Get_help_Configuration__mdt> getHelpConfiguration =[Select id, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c from Get_help_Configuration__mdt Where MasterLabel =:ca.Category__c] ;
                        If(catMetaMap  != null )
                        {
                            //change by santosh to avoid soql in for loop
                            // List<String> sendTo = getHelpConfiguration[0].Email_Send_List__c.split(',');
                            List<String> sendTo = catMetaMap.get(ca.Category__c).Email_Send_List__c.split(',');
                            sendTo.add(ca.contactEmail );
                            //change by santosh to avoid soql in for loop
                         //   List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : ca.CreatedById LIMIT 1];
                            if (users.size() > 0) 
                            {   //change by santosh to avoid soql in for loop
                               // List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: users[0].AccountId LIMIT 1];
                                if (accounts.size() > 0) 
                                {
                                    sendTo.add(accounts[0].Owner.Email);
                                }
                                
                            }
                            If(ca.cc__c != null)
                            {
                                sendTo.add(ca.cc__c);
                            }
                    
                            //Locate the contact for creating mail          
                            
                            
                            //Contact c = [select id, Email from Contact where email Like '%.com%' limit 1];
                            /*----------------Change By Saurav---Start Here----------------*/        
                            
                            Messaging.SingleEmailMessage rslt = Messaging.renderStoredEmailTemplate(s.Id,null, ca.Id);
                            /*List<NCR_EmailMessage__c> mails = new List<NCR_EmailMessage__c>();
                            NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                            ncrEmail.Recipient1__c = 'partner.resourcecenter@ncr.com';
                            String htmlBody = rslt.getHtmlBody();
                            System.debug('htmlBody'+htmlBody);
                            ncrEmail.Subject__c = rslt.getSubject();
                            ncrEmail.HTML_Body__c = htmlBody;*/
                            /*List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                            msg.setTemplateId( [select id from EmailTemplate where Name ='Get Help Close Notification VF'].id );
                            msg.setWhatId(ca.id);
                            msg.setTargetObjectId(c.id);
                            msg.setToAddresses(new List<String>{'partner.resourcecenter@ncr.com'});
                            msg.setCCAddresses(ccAddressList);*/
                            /*if (emailAddress.size() > 0) {
                                rslt.setOrgWideEmailAddressId(emailAddress[0].Id);
                            }*/
                            //mails.add(ncrEmail);
                            /*if(mails.isEmpty()){
                                insert mails;
                            }*/
                            // Send the emails in a transaction, then roll it back
                            //Savepoint sp = Database.setSavepoint();
                            //Messaging.sendEmail(mails);
                            //Database.rollback(sp);
                            
                            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
                            // contents to a new SingleEmailMessage. Then send those new messages.
                            // List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                           
                                //Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                                NCR_EmailMessage__c nemail = new NCR_EmailMessage__c();
                                System.debug('------------sendTo---------'+sendTo);
                                String htmlBdy = rslt.getHtmlBody();
                                System.debug('htmlBody'+htmlBdy);
                                nemail.Subject__c = rslt.getSubject();
                                nemail.HTML_Body__c = htmlBdy;
                                nemail.Email_Type__c = 'IPT Case Comment';
                                if(sendTo.size() > 0)
                                    nemail.Recipient1__c = sendTo[0];
                                if(sendTo.size() > 1)
                                    nemail.Recipient2__c = sendTo[1];
                                if(sendTo.size() > 2)
                                    nemail.Recipient3__c = sendTo[2];
                                if(sendTo.size() > 3)
                                    nemail.Recipient4__c = sendTo[3];
                                if(sendTo.size() > 4)
                                    nemail.Recipient5__c = sendTo[4];
                                Ncrmails.add(nemail);
                                
                                // emailToSend.setToAddresses(sendTo);
                                
                                // emailToSend.setPlainTextBody(email.getPlainTextBody());
                                // emailToSend.setHTMLBody(email.getHTMLBody());
                                // emailToSend.setSubject(email.getSubject());
                                //   if(emailAddress.size() > 0 && ca.Category__c != 'MDF') {
                                //        emailToSend.setOrgWideEmailAddressId(emailAddress[0].Id);
                                //   }
                                //    lstMsgsToSend.add(emailToSend);
                            //    Messaging.sendEmail(lstMsgsToSend);
                            
                            /*----------------Change By Saurav---End Here----------------*/        
                        }   
                    }
                }    
            }
             if(!Ncrmails.isEmpty()){
                insert Ncrmails;
            }
        }
    }
    //Callout to update ERP Cloud only if needed, ERP Callout os needed if Dispute is created or specific fields are updated for Disputes
    
    public void Dispute_syncToERPCloud(List<Case> cases,Map<Id,Case> oldCaseMap,Boolean insertCall){
        Set<Id> caseList = new Set<Id>();
        String disputRTID=NSCCommonInfoUtil.getInstance().getRecordTypeId('Case', Label.RT_Case_Dispute);
        if(insertCall){
            for(case caseObj : cases) {
                if(caseObj.RecordTypeId==disputRTID){
                    caseList.add(caseObj.Id);                   
                }
            }
        }else if(Trigger.isUpdate){
            for(case caseObj : cases) {
                if(caseObj.RecordTypeId==disputRTID){
                    if(caseObj.IsClosed && oldCaseMap.get(caseObj.id).isClosed ==False) {                                            
                        caseList.add(caseObj.id);
                    }
                }
                
            }  
        }        
        //Here we will call ERP sync
        if(caseList.size()>0 && !System.isFuture() && !System.isBatch()){
            SyncDisputeToERPCld.disputeCallout(caseList,insertCall);  
        }
    } 
   
    //handle duplicate case creation due to New case email notification
    //Added changes for story EBA_SF-1895-Multiple Case Email Notifications Clean-Up 
    public void hndlEmailtoCase(List<Case> cases){
        for(Case c : cases) {
            if(c.origin==Label.EmailOrgn && String.isNotBlank(c.subject) && c.subject.containsIgnoreCase(Label.NewCaseEmailNtfSbj)) {
                c.addError('avoid duplicate case creation');    
            }  
        }
    }
    
   //run assignment rule on new SF Support case creation
   public void runSFSupportAssignmentRule(List<Case> cases) {
         String gsRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SF Global Support').getRecordTypeId();        
         List<AssignmentRule> ARuleLst = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
         
         if (!ARuleLst.isEmpty()) {
            List<Case> uCaseLst = new List<Case>(); 
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= ARuleLst.get(0).id;
             
            for(Case c : cases) {
                if(c.RecordTypeId == gsRtId) {
                    Case uc =   new Case(Id=c.Id);
                    uc.setOptions(dmlOpts);
                    uCaseLst.add(uc);  
                }          
            } 
             
             if(!uCaseLst.isEmpty()) {
                 update uCaseLst;
             }
         }
    }
    
}