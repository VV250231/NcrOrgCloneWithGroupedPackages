public without sharing class APOC_MassUpdateAllRolesHandler {
    public static boolean isDeleteForOverwrite = false; // It is used when no notification should send out when action is delete and overwrite
    public static boolean isInsertFromUI = false; //Used to send notification if role is inserted from community using reassign button only
    public static boolean stopafterworkflow = true; // used to when we need to stop function to be rerun after workflow rule
    public static boolean stopNotification = false;
    public static boolean runonce = true;
    public static Map<Id,wrapper> wrapdata {get;set;}
    public static Contact c = [select id, Email from Contact where id =:BPM_Configuration__c.getValues('BPMContactIdForNotifyActionOwner').values__c];
    public static Account acc = [Select Id FROM Account Where Master_Customer_Number__c =: BPM_Configuration__c.getValues('APOCAccount').values__c for update];
    //this method is used to validate that PO/Billing Person Should be mandatory
    public static void validatePO(List<ASM_Role_Hierarchy__c> roles){
        Map<String,Set<String>> masterWithRoleNameMap = new Map<String,Set<String>>();
        List<ASM_Role_Hierarchy__c> POList = new List<ASM_Role_Hierarchy__c>();

        for(ASM_Role_Hierarchy__c role:roles){
            if(role.Action__c!='Delete'){
                if(!masterWithRoleNameMap.containskey(role.Master__c)){
                    masterWithRoleNameMap.put(role.Master__c,new Set<String>{role.Role_Name__c});
                }else{
                    masterWithRoleNameMap.get(role.Master__c).add(role.Role_Name__c);
                }
            }
        }
        for(ASM_Role_Hierarchy__c role : [Select Role_Name__c,Master__c from ASM_Role_Hierarchy__c where Master__c in: masterWithRoleNameMap.keyset()]){
            if(masterWithRoleNameMap.get(role.Master__c)!=null){
                masterWithRoleNameMap.get(role.Master__c).add(role.Role_Name__c);
            }
        }
        System.debug('masterWithRoleNameMap'+masterWithRoleNameMap);
        for(ASM_Role_Hierarchy__c role:roles){
            if(masterWithRoleNameMap.containskey(role.Master__c)){
                if(!masterWithRoleNameMap.get(role.Master__c).contains('PO/Billing Person')){  //eba_sf-1359
                   if(BPM_Configuration__c.getValues('excProfileId').values__c.split(',').contains(userinfo.getProfileId())){
                   //if(userinfo.getProfileId() == system.label.etb_exception_profile){
                        ASM_Role_Hierarchy__c POobj = new ASM_Role_Hierarchy__c();
                        POobj.QuickLook_ID__c =BPM_Configuration__c.getValues('BPMDefaultPOQLID').values__c;
                        POobj.Master__c = role.Master__c;
                        POobj.Role_Name__c = 'PO/Billing Person';
                        POList.add(POobj);
                        masterWithRoleNameMap.get(role.Master__c).add(POobj.Role_Name__c);
                    }
                    else{
                        role.addError(system.label.APOC_Err1);
                    }
                }
  // Error msg for custom label APOC_Err1            
 // Atleast one PO/Billing Person is mandatory to insert the roles.           
            }
        }
         if(!POList.isEmpty()){
            insert POList;
        }
        
    }
    // This method will handle import from excel file with role,master number and quicklookid only
    public static void assignReference(List<ASM_Role_Hierarchy__c> roles,Map<Id,ASM_Role_Hierarchy__c> roleMap){
        //if(runonce){
          //  runonce = false;
        List<Contact> conL = new List<Contact>();
        Map<String,Id> masterMap = new Map<String,Id>();
        Map<String,NCR_Employee_Detail__c> quicklookIdMap = new Map<String,NCR_Employee_Detail__c>();  // changed for EBA_SF-1264 by Varsha
        Map<Id,Id> UserIDMap = new Map<Id,Id>();
        Set<String> roleMCNSet = new Set<String>();
        for(ASM_Role_Hierarchy__c role :roles){
            if(role.Master__c!=null){
            	masterMap.put(role.Master__c,null);
            }
            if(roleMap!=null){
                if(role.Role_User_Name__c!=roleMap.get(role.id).Role_User_Name__c){
                    System.debug('role changed from UI'+ role.Role_User_Name__r.Name);
                    UserIDMap.put(role.Id,role.Role_User_Name__c);
                }
                else if(role.NCR_Employee_Detail__c!=roleMap.get(role.id).NCR_Employee_Detail__c||role.QuickLook_ID__c!=null){
                	role.Role_User_Name__c = null;
                    quicklookIdMap.put(role.QuickLook_ID__c.tolowerCase(),null); 
                }
                /*else if(role.QuickLook_ID__c!=null){
                    quicklookIdMap.put(role.QuickLook_ID__c.tolowerCase(),null); 
                }*/
            }
            else{
                if(role.QuickLook_ID__c!=null){
                    quicklookIdMap.put(role.QuickLook_ID__c.tolowerCase(),null); 
                }
            }
        }
        for(Account acc : [Select id,Master_Customer_Number__c,Active_Account__c from Account where Master_Customer_Number__c in:masterMap.keyset()]){
            masterMap.put(acc.Master_Customer_Number__c,acc.Id);
        }
        // changed for EBA_SF-1264 - line 69 -78 by Varsha
        Map<String, User> userMap = new Map<String,User>();
        Set<Id> userIds = new Set<Id>();
        Set<User> uSet = new Set<User>();
        Map<Id,String> qlMap = new Map<Id,String>();
        for(User u : [Select id,FirstName,QuickLook_ID__c,LastName,Username,isactive,usertype,User_Profile__c,isportalenabled from User where (quicklook_id__c in:quicklookIdMap.keyset() OR id in :UserIDMap.values())]){
            qlMap.put(u.id,u.QuickLook_ID__c.tolowerCase());
            if(u.IsActive){
                if(u.usertype!='csnonly'){
                    userMap.put(u.QuickLook_ID__c.tolowerCase(),u);
                    if(u.User_Profile__c!=BPM_Configuration__c.getValues('BPMProfile').values__c){
                    	userIds.add(u.id);
                    }
                }
                else{
                   uSet.add(u); 
                }
            }else{
                uSet.add(u); 
            }
        }
        
        // changed for EBA_SF-1264 - line 70 -73 by Varsha
        for(NCR_Employee_Detail__c nce : [Select id,QuickLook_ID__c,user_name__c from NCR_Employee_Detail__c where (quicklook_id__c in:quicklookIdMap.keyset() OR quicklook_id__c in:qlMap.values()) and InActive__c=false]){
            quicklookIdMap.put(nce.QuickLook_ID__c.tolowerCase(),nce);
        }
        System.debug('masterMap'+masterMap);
        System.debug('quicklookIdMap'+quicklookIdMap);
        Set<string> uniQLSet = new Set<String>();
        for(ASM_Role_Hierarchy__c role :roles){
            if(role.Action__c!='Delete'){
                if(masterMap.get(role.Master__c)!=null){
                    role.Account__c = masterMap.get(role.Master__c);
                } 
                else{
                    role.adderror(system.label.APOC_Err3);
                }
                //Error msg for custom label APOC_Err3
                //No account is found in database with providing master number or account is inactive
               	if(UserIDMap.get(role.Id)!=null&&roleMap!=null){
                    role.QuickLook_ID__c = qlMap.get(UserIDMap.get(role.Id));
                }
                if(role.QuickLook_ID__c!=null){
                    String ql;
                   // if(role.QuickLook_ID__c!=null){
                        ql = role.QuickLook_ID__c.toLowercase();
                    //}else{
                      //  ql = role.Role_User_Qlook_Id__c.tolowerCase();
                    //}
                    System.debug('ql*****'+ql);
                    System.debug('quicklookIdMap*****'+quicklookIdMap);
                    if(quicklookIdMap.get(ql)!=null){
                        NCR_Employee_Detail__c nc;
                        nc = quicklookIdMap.get(ql);   
                        //}
                        role.NCR_Employee_Detail__c = nc.Id;//changed for EBA_SF-1264 by Varsha
                        if(userMap.get(ql)!=null){
                            role.Role_User_Name__c = userMap.get(ql).Id;//changed for EBA_SF-1264 by Varsha
                        }else if(!qlMap.values().contains(ql)){
                            System.debug('first contact');
                            if(!uniQLSet.contains(ql)){
                                uniQLSet.add(ql);
                            	Contact con =  new Contact(accountId = acc.Id, LastName = nc.User_Name__c, Email = nc.Quicklook_ID__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c, IsBPMCommunityUser__c = true, Quicklook_ID__c = nc.Quicklook_ID__c);
                            	conL.add(con);
                            }
                        }
                    }
                    else{
                        string err= String.format(System.Label.APOC_Err4, new List<String>{ql});
                        role.adderror(err); 
                    }
                }
                
            }
            //Error msg for custom label APOC_Err4
            //No active employee is found in salesforce with providing quicklookid
            System.debug('Role_Name__c---'+role.Role_Name__c);
            System.debug('Master__c----'+role.Master__c);
            if(role.Role_Name__c!=null&&role.Master__c!=null){           
                if(role.QuickLook_ID__c!=null){
                    if(role.Action__c=='Delete'){
                        role.RoleMCNId__c =  role.Role_Name__c + role.Master__c + role.QuickLook_ID__c;
                    }else{
                        role.External_Id__c = role.Role_Name__c + role.Master__c + role.QuickLook_ID__c;
                        role.RoleMCNId__c = role.Role_Name__c + role.Master__c;
                    }
                }  
                /*else if(role.Action__c=='Overwrite'){
                    role.RoleMCNId__c = role.Role_Name__c + role.Master__c; // This is external Id used to overwrite the existing roles and we delete them on backend if file is uploaded
                }*/else{
                    role.addError(system.label.APOC_Err2);
                }
            }
            else{
               role.addError(system.label.APOC_Err2);
            }
 //Master Number or QuicklookId is missing to assign new roles.
            if(role.Action__c == 'Overwrite'){
                roleMCNSet.add(role.RoleMCNId__c);
            }
        }
        List<ASM_Role_Hierarchy__c> rolesDelete = new List<ASM_Role_Hierarchy__c>();
        //delete all the roles with existing roles and new will be created
        for(ASM_Role_Hierarchy__c role : [Select id from ASM_Role_Hierarchy__c where RoleMCNId__c in:roleMCNSet]){
            rolesDelete.add(role);
        }
        System.debug('rolesDelete size'+rolesDelete.size());
        if(!rolesDelete.isEmpty()){
            isDeleteForOverwrite = true; // dont want to send the notification so make it true
            delete rolesDelete;
        }
        if(!uSet.isEmpty()||!conL.isEmpty()||!userIds.isEmpty()){
            System.enqueueJob(new UserCrtnQueue(uSet,conL,userIds));
        }
        /*}else{
            for(ASM_Role_Hierarchy__c role :roles){
                role.External_Id__c = role.Role_Name__c + role.Master__c + role.QuickLook_ID__c;
                role.RoleMCNId__c = role.Role_Name__c + role.Master__c;    
            }    
        }*/
    }
    //this function will used to handle delete on after insert from import button only(excel file upload)
    public static void handleDelete(List<ASM_Role_Hierarchy__c> roles){
        Set<String> roleMCNSet = new Set<String>();
        List<ASM_Role_Hierarchy__c> rolesDelete = new List<ASM_Role_Hierarchy__c>();
        for(ASM_Role_Hierarchy__c role :roles){
            if(role.Action__c == 'Delete'){
                roleMCNSet.add(role.RoleMCNId__c);
                //rolesDelete.add(role);
            }
        }
        if(!roleMCNSet.isEmpty()){
            for(ASM_Role_Hierarchy__c role : [Select id from ASM_Role_Hierarchy__c where (External_Id__c in: roleMCNSet or RoleMCNId__c in:roleMCNSet)]){
                rolesDelete.add(role);
            }
        }
        if(!rolesDelete.isEmpty()){
            isDeleteForOverwrite = true; // dont want to send the notification so make it true
            delete rolesDelete;
        }
    }
    //Send notification when an account is reassigned to any other user and create reassign history as well
    public static void sendNotificationToUser(List<ASM_Role_Hierarchy__c> newroles,Map<Id,ASM_Role_Hierarchy__c> oldroleMap){
        if(stopafterworkflow){
            stopafterworkflow=false;
            wrapdata = new Map<Id,Wrapper>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate et = [SELECT Id, Name, Subject, Body,DeveloperName FROM EmailTemplate WHERE DeveloperName ='APOCReassignmentTemplate'];
            Map<Id,String> OldCAaccRoleMap = new Map<Id,String>();
            Map<Id,String> OldUseraccRoleMap = new Map<Id,String>();
            Set<ASM_Role_Hierarchy__c> roles = new Set<ASM_Role_Hierarchy__c>();
            Map<String,CA_Hierarchy__c> CAEmailMap = new Map<String,CA_Hierarchy__c>();
            Map<String,String> userEmailMap = new Map<String,String>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help.apoc@ncr.com'];
            List<ReassignDataHistory__c> dataHistoryList = new List<ReassignDataHistory__c>();
            for(ASM_Role_Hierarchy__c role : newroles){
                if(role.Role_Name__c==oldroleMap.get(role.id).Role_Name__c){ 
                    if(role.NCR_Employee_Detail__c != oldroleMap.get(role.id).NCR_Employee_Detail__c &&oldroleMap.get(role.id).NCR_Employee_Detail__c!=null){
                        roles.add(role);
                        if(oldroleMap.get(role.id).Role_User_Qlook_Id__c != null){
                            if(role.Role_Name__c == 'Customer Advocate'){
                                OldCAaccRoleMap.put(role.id,oldroleMap.get(role.id).Role_User_Qlook_Id__c.toLowerCase()); 
                            }
                            else{
                                OldUseraccRoleMap.put(role.id,oldroleMap.get(role.id).Role_User_Qlook_Id__c.toLowerCase());
                            }
                        }
                    }
                }
                else if(role.Role_Name__c!=oldroleMap.get(role.id).Role_Name__c){
                    if(role.NCR_Employee_Detail__c != oldroleMap.get(role.id).NCR_Employee_Detail__c){
                        roles.add(role);
                        if(oldroleMap.get(role.id).Role_User_Qlook_Id__c != null){
                            if(role.Role_Name__c == 'Customer Advocate'){
                                OldCAaccRoleMap.put(role.id,oldroleMap.get(role.id).Role_User_Qlook_Id__c.toLowerCase()); 
                            }
                            else{
                                OldUseraccRoleMap.put(role.id,oldroleMap.get(role.id).Role_User_Qlook_Id__c.toLowerCase());
                            }
                        }
                    }
                    else{
                        ReassignDataHistory__c dataHistoryObj = New ReassignDataHistory__c(Account__c = role.Account__c, Account_Point_of_Contacts__c = role.id, User__c = role.LastModifiedById, Role_Name__c = '', Old_Value__c = oldroleMap.get(role.id).Role_Name__c, New_Value__c = role.Role_Name__c,Action_Taken__c='Role Updated' );
                        dataHistoryList.add(dataHistoryObj);
                    }
                    
                }
            }
         
            for(CA_Hierarchy__c obj :[select id,CA_QuicklookId__c,Manager1_Email__c from CA_Hierarchy__c where CA_QuicklookId__c in:OldCAaccRoleMap.values() ]){
                CAEmailMap.put(obj.CA_QuicklookId__c.toLowerCase(),obj);
            }
            System.debug('CAEmailMap'+CAEmailMap);
            System.debug('OldUseraccRoleMap'+OldUseraccRoleMap);
            for(NCR_Employee_Detail__c usr : [Select Manager_Global_ID__c, Quicklook_ID__c from NCR_Employee_Detail__c where Quicklook_ID__c in:OldUseraccRoleMap.values()]){
                userEmailMap.put(usr.Quicklook_ID__c,usr.Manager_Global_ID__c);
            }
            Map<String,String> managerMap = new Map<String,String>();
            for(NCR_Employee_Detail__c usr : [Select Global_ID__c, Quicklook_ID__c from NCR_Employee_Detail__c where Global_ID__c in:userEmailMap.values()]){
                managerMap.put(usr.Global_ID__c,usr.Quicklook_ID__c);
            }
            System.debug('userEmailMap'+userEmailMap);
            for(ASM_Role_Hierarchy__c role : roles){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> sendTo = new List<String>();
                String newOwn = role.User_Name__c;
                String oldOwn = oldroleMap.get(role.id).User_Name__c;
                ReassignDataHistory__c dataHistoryObj = New ReassignDataHistory__c(Account__c = role.Account__c, Account_Point_of_Contacts__c = role.id, User__c = role.LastModifiedById, Role_Name__c = role.Role_Name__c, Old_Value__c = oldOwn, New_Value__c = newOwn,Action_Taken__c='User Updated' );
                dataHistoryList.add(dataHistoryObj);
                if(role.Email2__c!=null){
                    sendTo.add(role.Email2__c);
                    mail.setWhatId(role.Id);
                    mail.setTargetObjectId(c.Id);
                }
                if(oldroleMap.get(role.id).Email2__c!=null){
                    sendTo.add(oldroleMap.get(role.id).Email2__c);
                }
                if(role.Role_Name__c=='Customer Advocate'){
                    if(OldCAaccRoleMap.containskey(role.id)){
                        if(CAEmailMap.containskey(OldCAaccRoleMap.get(role.id))){
                            if(CAEmailMap.get(OldCAaccRoleMap.get(role.id)).Manager1_Email__c!=null)
                                sendTo.add(CAEmailMap.get(OldCAaccRoleMap.get(role.id)).Manager1_Email__c);
                        }
                    }
                }else{
                    if(OldUseraccRoleMap.containskey(role.id)){
                        if(userEmailMap.containskey(OldUseraccRoleMap.get(role.id))){
                            if(managerMap.get(userEmailMap.get(OldUseraccRoleMap.get(role.id)))!=null){
                                sendTo.add(managerMap.get(userEmailMap.get(OldUseraccRoleMap.get(role.id)))+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
                            }
                        }
                    }
                }
                wrapdata.put(role.Id,new wrapper(oldroleMap.get(role.id),role,'Reasssign'));
                System.debug('this is wrapper '+wrapdata);
                if ( !owea.isEmpty() ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setTemplateId(et.id);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(sendTo);
                mail.setUseSignature(false); 
                mail.setBccSender(false); 
                mail.setTreatTargetObjectAsRecipient(false);
                //mail.setBccAddresses(new List<String>{'vp250252@ncr.com','gr185126@ncr.com'});
                mails.add(mail);
                System.debug('sendTo---> '+sendTo);
            }
            if(System.Label.APOCStopNotificationForReassign =='false' && !stopNotification){
                Messaging.sendEmail(mails);
                System.debug('Emails Send Succesfully');
            }
            System.debug('dataHistoryList'+dataHistoryList);
            if(!dataHistoryList.isEmpty()){
                insert dataHistoryList;
            }
        }
    }
    //Send notification when a new role is assigned to an user using reassign button from community only and to create reassign history as well
    public static void createReassignforInsert(List<ASM_Role_Hierarchy__c> roles){
        System.debug('isInsertFromUI outside if'+isInsertFromUI);
        if(isInsertFromUI){ 
            wrapdata = new Map<Id,Wrapper>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<ReassignDataHistory__c> dataHistoryList = new List<ReassignDataHistory__c>();
            EmailTemplate et = [SELECT Id, Name, Subject, Body,DeveloperName FROM EmailTemplate WHERE DeveloperName ='APOCReassignmentTemplate'];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help.apoc@ncr.com'];
            for(ASM_Role_Hierarchy__c role : roles){
                ReassignDataHistory__c dataHistoryObj = New ReassignDataHistory__c(Account__c = role.Account__c, Account_Point_of_Contacts__c = role.id, User__c =userInfo.getUserId(), Role_Name__c = role.Role_Name__c, Old_Value__c = '', New_Value__c = role.User_Name__c ,Action_Taken__c='Role Created');
                System.debug('dataHistoryObj for insert'+dataHistoryObj);
                dataHistoryList.add(dataHistoryObj);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if ( !owea.isEmpty() ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(role.Id);
                mail.setTargetObjectId(c.id);
                if(role.email2__c!=null){
                    wrapdata.put(role.Id, new wrapper(role,role,'newRoles'));
                    mail.setToAddresses(new List<String> {role.Email2__c});
                    //mail.setBccAddresses(new List<String>{'vp250252@ncr.com','gr185126@ncr.com'});
                    mail.setTemplateId(et.id);
                    mail.setSaveAsActivity(false);
                    mail.setUseSignature(false); 
                    mail.setBccSender(false); 
                    mail.setTreatTargetObjectAsRecipient(false);
                }
                
                mails.add(mail);
            }
            if(!dataHistoryList.isEmpty()){
                database.insert(dataHistoryList,true);
            }
            if(System.Label.APOCStopNotificationForReassign =='false' && !stopNotification){
                Messaging.sendEmail(mails);
            }
        }
    }
    //Send notification when a role is deleted from account using reassign button from community only and to create reassign history as well
    public static void createReassignforDelete(List<ASM_Role_Hierarchy__c> roles){
        if(!isDeleteForOverwrite){
            wrapdata = new Map<Id,Wrapper>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate et = [SELECT Id, Name, Subject, Body,DeveloperName FROM EmailTemplate WHERE DeveloperName ='APOCReassignmentTemplate'];
            Map<Id,String> OldCAaccRoleMap = new Map<Id,String>();
            Map<Id,String> OldUseraccRoleMap = new Map<Id,String>();
            Map<String,CA_Hierarchy__c> CAEmailMap = new Map<String,CA_Hierarchy__c>();
            Map<String,String> userEmailMap = new Map<String,String>();
            List<ReassignDataHistory__c> dataHistoryList = new List<ReassignDataHistory__c>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help.apoc@ncr.com'];
            for(ASM_Role_Hierarchy__c role : roles){
                ReassignDataHistory__c dataHistoryObj = New ReassignDataHistory__c(Account__c = role.Account__c, Account_Point_of_Contacts__c = role.id, User__c = userInfo.getUserId(), Role_Name__c = role.Role_Name__c, Old_Value__c = role.User_Name__c, New_Value__c = '' ,Action_Taken__c='Role Deleted');
                System.debug('dataHistoryObj for delete'+dataHistoryObj);
                dataHistoryList.add(dataHistoryObj);
                if(role.Role_User_Qlook_Id__c!=null){
                    if(role.Role_Name__c == 'Customer Advocate'){
                        OldCAaccRoleMap.put(role.id,role.Role_User_Qlook_Id__c.toLowerCase()); 
                    }
                    else{
                        OldUseraccRoleMap.put(role.id,role.Role_User_Qlook_Id__c.toLowerCase());
                    }
                }
                
            } 
            System.debug('OldUseraccRoleMap '+OldUseraccRoleMap);
            for(CA_Hierarchy__c obj :[select id,CA_QuicklookId__c,Manager1_Email__c from CA_Hierarchy__c where CA_QuicklookId__c in:OldCAaccRoleMap.values() ]){
                CAEmailMap.put(obj.CA_QuicklookId__c.toLowerCase(),obj);
            }
            System.debug('CAEmailMap'+CAEmailMap);
            for(NCR_Employee_Detail__c usr : [Select Manager_Global_ID__c, Quicklook_ID__c from NCR_Employee_Detail__c where Quicklook_ID__c in:OldUseraccRoleMap.values()]){
                userEmailMap.put(usr.Quicklook_ID__c,usr.Manager_Global_ID__c);
            }
            Map<String,String> managerMap = new Map<String,String>();
            for(NCR_Employee_Detail__c usr : [Select Global_ID__c, Quicklook_ID__c from NCR_Employee_Detail__c where Global_ID__c in:userEmailMap.values()]){
                managerMap.put(usr.Global_ID__c,usr.Quicklook_ID__c);
            }
            System.debug('userEmailMap'+userEmailMap);
            for(ASM_Role_Hierarchy__c role : roles){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                if(role.Email2__c!=null){
                    sendTo.add(role.Email2__c);
                    mail.setWhatId(role.Id);
                    mail.setTargetObjectId(c.id);
                }
                if(role.Role_Name__c=='Customer Advocate'){
                    if(OldCAaccRoleMap.containskey(role.id)){
                        if(CAEmailMap.containskey(OldCAaccRoleMap.get(role.id))){
                            if(CAEmailMap.get(OldCAaccRoleMap.get(role.id)).Manager1_Email__c!=null){
                                sendTo.add(CAEmailMap.get(OldCAaccRoleMap.get(role.id)).Manager1_Email__c);
                            }
                        }
                    }
                }else{
                    if(OldUseraccRoleMap.containskey(role.id)){
                        if(userEmailMap.containskey(OldUseraccRoleMap.get(role.id))){
                            if(managerMap.get(userEmailMap.get(OldUseraccRoleMap.get(role.id)))!=null){
                                sendTo.add(managerMap.get(userEmailMap.get(OldUseraccRoleMap.get(role.id)))+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
                            }
                        }
                    }
                }
                System.debug('sendTo'+sendTo);
                if ( !owea.isEmpty() ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    //mail.setBccAddresses(new List<String>{'vp250252@ncr.com','gr185126@ncr.com'});
                }
                wrapdata.put(role.Id, new wrapper(role,role,'delete'));
                if(!sendTo.isEmpty()){
                    mail.setTemplateId(et.id);
                    mail.setSaveAsActivity(false);
                    mail.setToAddresses(sendTo);
                    mail.setUseSignature(false); 
                    mail.setBccSender(false); 
                    mail.setTreatTargetObjectAsRecipient(false);
                }
                mails.add(mail);
            }
            if(!dataHistoryList.isEmpty()){
                insert dataHistoryList;
            }
            if(System.Label.APOCStopNotificationForReassign =='false' && !stopNotification){
                Messaging.sendEmail(mails);
            }
        }
       
    } 
    public class wrapper{
        public ASM_Role_Hierarchy__c accSupOld {get;set;}
        public ASM_Role_Hierarchy__c accSupNew {get;set;}
        public String  emailtype {get;set;}
        public String currentUser{get;set;}
        public wrapper(ASM_Role_Hierarchy__c accSupOld,ASM_Role_Hierarchy__c accSupNew,String emailtype){
            this.accSupOld = accSupOld;
            this.accSupNew = accSupNew;
            this.emailtype = emailtype;
            this.currentUser = UserInfo.getName();
        }
    }
    public class UserCrtnQueue implements Queueable {
        Set<User> usrSet;
        Set<Id> userIds;
       	List<Contact> clst;
        public UserCrtnQueue(Set<User> usrSet,List<Contact> clst,Set<Id> userIds) {
            this.usrSet = usrSet;
            this.userIds = userIds;
            this.clst= clst;
        }
        public void execute(QueueableContext context) {
            PermissionSet pset = [SELECT Id from PermissionSet where name ='BPM_Community'];
            Set<Id> userIdsPerm = new Set<Id>();
            for(PermissionSetAssignment p:[SELECT AssigneeId from PermissionSetAssignment where PermissionSetId =: pset.ID AND AssigneeId in: userIds]){
                userIdsPerm.add(p.AssigneeId);
            }
            List<PermissionSetAssignment> pList = new List<PermissionSetAssignment>();
            for(Id i: userIds){
                if(!userIdsPerm.contains(i)){
                    PermissionSetAssignment ps = new PermissionSetAssignment(PermissionSetId = pset.Id, AssigneeId = i); 
                    pList.add(ps);
                }
            }
            if(!pList.isEmpty()){
                insert pList; 
            }
            List<user> ulst = new List<user>();
            if(!usrSet.isEmpty()){
                for(User u : usrSet){
                    if(u.User_Profile__c!=BPM_Configuration__c.getValues('BPMProfile').values__c||(u.User_Profile__c==BPM_Configuration__c.getValues('BPMProfile').values__c&&!(u.isportalEnabled))){
                        String ms = '-'+string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,2);
                        User us = new User(id = u.id,lastname = u.lastname+'-INACTIVE',Username = u.Username+ms,Quicklook_ID__c = u.Quicklook_ID__c+ms,IsActive = false);
                        ulst.add(us);
                        Contact con = new Contact(Firstname=u.FirstName,Lastname=u.LastName,Quicklook_ID__c=u.Quicklook_ID__c,accountId = acc.Id,Email = u.Quicklook_ID__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c, IsBPMCommunityUser__c = true);
                        clst.add(con); 
                        System.debug('second'+con);
                    }
                    else{
                        User us = new User(id = u.id,isActive=true);
                        ulst.add(us);
                    }
               }
            }
            if(!ulst.isEmpty()){
                UserDeactivateNotification.dorun = false;//prevent the userdeactivation logic to not run
                database.update(ulst,false);
                Database.executeBatch(new APOCReassignmentBatch());
            }
            if(!clst.isEmpty()){
                if(!Test.isRunningTest()){
                	System.enqueueJob(new ConCrtnQueue(clst));
                }
            }
        }
    }
    public class ConCrtnQueue implements Queueable {
    	List<Contact> clst;  
        public ConCrtnQueue(List<Contact> clst) {
            this.clst= clst;
        }
        public void execute(QueueableContext con) {
            System.debug('clst'+clst);
            database.insert(clst,false);
        }
        
    }
}