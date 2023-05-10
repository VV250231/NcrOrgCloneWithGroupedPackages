/*************************************************************************************************
*   ClassName :   UserDeactivateNotification
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
*************************************************************************************************/
public without sharing class UserDeactivateNotification {
    public static Boolean isfrst = true;
    public static Boolean manUpdt = true;
    public static Boolean dorun = true;//this is a flag which will stop the all execution if it is false and used if we are deactivating a user 
    //the APOC_MassUpdateAllRolesHandler trigger so we are getting too many queuable jobs added in the queue so it will resolve this error
    public static Map<Id,list<wrap>> wrapdata {get;set;}
    public static Map<Id,Integer> lstSize{get;set;}
    public static void validateUser(Set<User> usrS){
        if(dorun){
            UserDeactivateNotification.isfrst = false;
            List<ASM_Role_Hierarchy__c> APOCL = new List<ASM_Role_Hierarchy__c>();
            try{
                APOCL = [select Role_User_Name__c,User_Name__c,Role_Name__c,Role_User_Qlook_Id__c,Account__c,id,Role_User_Name__r.ManagerId,Role_User_Name__r.Manager.Email,Account_Name__c,Master__c from ASM_Role_Hierarchy__c where Role_User_Name__c  =:usrS and Role_User_Name__c!=null order by Role_User_Name__c];         
            }catch(Exception e){
                System.debug('Exception Occured'+e.getMessage());
            }
            Map<Id,ASM_Role_Hierarchy__c> APOCRecM = new Map<Id,ASM_Role_Hierarchy__c>();
            for(ASM_Role_Hierarchy__c ar :APOCL){
                APOCRecM.put(ar.role_user_name__c,ar);
            }
            Set<Id> usrIdS = new Set<Id>();
            for(User usr: usrS){
                if(APOCRecM.get(usr.id)!=null && userinfo.getName()!=Label.AdmUser){
                    if(manUpdt){
                        usr.isactive.addError(System.Label.APOCUserMsg);
                    }
                }else{
                    usrIdS.add(usr.id); 
                }
            }
            if(!usrIdS.isEmpty()){
                System.enqueueJob(new userUpdtQueue(usrIdS)); 
            }
        }
    }
    public static void userNotification(Set<Id> UIdSet){
        String rs='';
        List<ASM_Role_Hierarchy__c> APOCL = new List<ASM_Role_Hierarchy__c>();  
        try{
            APOCL = [select Role_User_Name__r.Manager.Isactive,Role_User_Name__c,User_Name__c,Role_Name__c,Role_User_Qlook_Id__c,Account__c,id,Role_User_Name__r.ManagerId,Role_User_Name__r.Manager.Email,Account_Name__c,Master__c,Role_User_Name__r.Manager_Level_01_ID__c,Role_User_Name__r.Manager_Level_01__c,Role_User_Name__r.Contingent_Manager_Id__c from ASM_Role_Hierarchy__c where Role_User_Name__c  =:UIdSet and Role_User_Name__c!=null order by Role_User_Name__c];         
        }catch(Exception ex){
            System.debug('Exception Occured'+ex.getMessage());
        }
        List<ASM_Role_Hierarchy__c> roles = new List<ASM_Role_Hierarchy__c>();
        Map<Id,NCR_Employee_Detail__c> usrM = new Map<Id,NCR_Employee_Detail__c>();
        Map<Id,List<Wrap>> usrWrapM = new Map<Id,List<Wrap>>();
        APOC_MassUpdateAllRolesHandler.stopNotification = true;
        if(!APOCL.isEmpty()){ 
            String mngrId;
            Map<String,String> CAQLidM = new Map<String,String>();
            Map<String,String> QLidM = new Map<String,String>();
            Map<String,NCR_Employee_Detail__c> ncrEmpM = new Map<String,NCR_Employee_Detail__c>();
            for(ASM_Role_Hierarchy__c ar : APOCL){
                if(ar.Role_Name__c=='Customer Advocate'){
                    if(ar.Role_User_Name__r.Contingent_Manager_Id__c!=null){
                        mngrId =ar.Role_User_Name__r.Contingent_Manager_Id__c;
                    }else{
                        mngrId =ar.Role_User_Name__r.Manager_Level_01_ID__c;
                    }
                    CAQLidM.put(ar.Role_User_Qlook_Id__c.toLowerCase(),mngrId); 
                }else{
                    mngrId =ar.Role_User_Name__r.Manager_Level_01_ID__c;
                    QLidM.put(ar.Role_User_Qlook_Id__c.toLowerCase(),mngrId);
                }
                ncrEmpM.put(mngrId,null);
            }
            for(NCR_Employee_Detail__c ncrEmp : [Select Quicklook_ID__c,Global_ID__c,User_name__c from NCR_Employee_Detail__c  where Global_ID__c in: ncrEmpM.keyset() and Global_ID__c!=null and InActive__c=false limit 50000]){
                ncrEmpM.put(ncrEmp.Global_ID__c,ncrEmp);
            }
            for(ASM_Role_Hierarchy__c ar : APOCL){
                string ql = ar.Role_User_Qlook_Id__c.toLowerCase();
                Id ud = ar.Role_User_Name__c;
                if(CAQLidM.get(ql)!=null){
                    if(ncrEmpM.get(CAQLidM.get(ql))!=null){
                        if(!usrM.containskey(ud)){
                            usrM.put(ud,ncrEmpM.get(CAQLidM.get(ql)));
                            usrWrapM.put(ud,new List<Wrap>());
                        }
                        usrWrapM.get(ud).add(new wrap(ar.User_Name__c,ql,ar));
                        ar.QuickLook_ID__c = ncrEmpM.get(CAQLidM.get(ql))?.QuickLook_ID__c;
                        roles.add(ar);
                    }
                }else{
                    if(ncrEmpM.get(QLidM.get(ql))!=null){
                        if(!usrM.containskey(ud)){
                            usrM.put(ud,ncrEmpM.get(QLidM.get(ql)));
                            usrWrapM.put(ud,new List<Wrap>());
                        }
                        usrWrapM.get(ud).add(new wrap(ar.User_Name__c,ql,ar));
                        ar.QuickLook_ID__c = ncrEmpM.get(QLidM.get(ql))?.QuickLook_ID__c;
                        roles.add(ar);
                    }
                }
            }
            rs=sendMail(usrWrapM,usrM);
        }
        System.debug('roles'+roles);
        if(!roles.isEmpty()&&rs=='S'){
            Database.executeBatch(new UserDeactivateNotificationBatch(roles));
        }        
    }
    public static string sendMail(Map<Id,List<Wrap>> wrL,Map<Id,NCR_Employee_Detail__c> usrM){
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='RetiredQuicklookNotificationTemplate'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help.apoc@ncr.com'];
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        lstSize = new Map<Id,Integer>();
        System.debug('wrL'+wrL);
        //divOfRecords(wrL);
        wrapdata = wrL;
        for(Id uid:usrM.keyset()){
            if(usrM.get(uid)!=null){
                lstSize.put(uid,wrL.get(uid).size());
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(mail!=null){
                    mail.setWhatId(uid);
                    mail.setTargetObjectId(uid);
                    mail.setToAddresses(new List<String>{usrM.get(uid).Quicklook_ID__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c});
                    if(wrL.get(uid).size()>5){
                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                        PageReference pref = page.APOCDeactivateAlertPDF;
                        pref.getParameters().put('Id',uid);
                        pref.setRedirect(true);
                        Blob b;
                        if(Test.isRunningTest()) { 
                            b = blob.valueOf('Unit.Test');
                        } else {
                            b = pref.getContent();
                        }
                        attach.setFileName('APOC.xls');
                        attach.setBody(b);
                        attach.setContentType('application/vnd.ms-excel');
                        attach.setInline(false);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
                    }
                    mail.setTemplateId(et.id);
                    mail.setSaveAsActivity(false);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setBccAddresses(BPM_Configuration__c.getValues('APOCBCC').values__c.split(','));
                    if ( !owea.isEmpty() ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    mails.add(mail);
                }
            }
        }
        System.debug('mails'+mails.size());
        String r ='F';
        if(!mails.isEmpty()){
            if(System.Label.APOCStopNotificationForReassign =='false'){
                Messaging.SendEmailResult[] rs=Messaging.sendEmail(mails);
                if(rs[0].isSuccess()){
                    r='S';
                }
            }
        }
        return r;
    }
    
    public class wrap{
        public String UserName{get;set;}
        public String QuicklookId{get;set;}
        public ASM_Role_Hierarchy__c accSup {get;set;}
        public String  retiredDate {get;set;}
        public wrap(String UserName,String QuicklookId,ASM_Role_Hierarchy__c acc){
            this.UserName = UserName;
            this.QuicklookId = QuicklookId;
            retiredDate = Datetime.now().format('MMM dd,yyyy');
            this.accSup= acc;
        }
    }
    public static void UpdtRole(List<ASM_Role_Hierarchy__c> roles){
        List<Database.SaveResult> res = Database.update(roles,false);
        List<ASM_Role_Hierarchy__c> APOCLDlt = new List<ASM_Role_Hierarchy__c>();
        for(Integer i=0;i<res.size();i++){
            if (!res.get(i).isSuccess()){
                if(res.get(i).getErrors().get(0).getMessage().contains('DUPLICATE')){
                    APOCLDlt.add(new ASM_Role_Hierarchy__c(id =roles.get(i).id));
                }
            }
        }
        if(!APOCLDlt.isEmpty()){
            delete APOCLDlt;
        }
    }
    public class userUpdtQueue implements Queueable,Database.allowscallouts {
        Set<Id> uidSet;  
        public userUpdtQueue(Set<Id> uidSet) {
            this.uidSet= uidSet;
        }
        public void execute(QueueableContext con) {
            userNotification(uidSet);
        }
        
    }
}