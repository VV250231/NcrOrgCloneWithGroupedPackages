/*
##################################################################################################
# Project Name..........: BPM Automation
# File............................: BPMNotifyActionOwnerBatch.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 01/16/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 11/20/2020 (MM/DD/YYYY)
# Description...............: This class is used for sending BPM Notification and scheduling them in time based workflow
named 'BPM Automation' on changing field 'Alert Next Date Time' on BPM_Annuity__c Object.
##################################################################################################
*/

public class BPMNotifyActionOwnerBatch implements Database.Batchable<sObject>, schedulable{
    Map<String, String> unbilledAmountEmailCriteria = new Map<String, String>();
    Map<Id,Decimal> bpmUnbilledAmtMap = new Map<Id,Decimal>();
    Set<Id> bpmIdSet = new Set<Id>();
    Map<Id,Map<String,Set<String>>> bpmIDWithUserMap = new Map<Id,Map<String,Set<String>>>(); // to store all the action owner quicklookid which needs to be in TO
    Map<Id,Set<String>>  bpmIDWithCCUserMap = new Map<Id,Set<String>>(); // to store all the action owner quicklookid which needs to be in CC
    Map<Id,String> roleActionOwner = new Map<Id,String>();
    Set<String> quicklookIdInTo = new Set<String>();
    Set<String> CAquicklookIdInTo = new Set<String>();
    static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'otc.bpm@ncr.com'];
    static String schTime = BPM_Configuration__c.getValues('Time-Based Scheduling Time').values__c;
    static String znSwtch = BPM_Configuration__c.getValues('TimeZoneSwitcher').values__c;
    static String[] bccAddrss = BPM_Configuration__c.getValues('BPM BCC ADDRESS LIST').values__c.split(',');
    public BPMNotifyActionOwnerBatch(){
        System.debug('Base'); // No need to remove this debug we are doing it for empty block 
    }
    public BPMNotifyActionOwnerBatch(Set<Id> bpmIdSet){
        this.bpmIdSet = bpmIdSet;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(!bpmIdSet.isEmpty()){
            return Database.getQueryLocator('Select id,Cust_Nbr_CH__c,Hold_Reason_Type__c,Notification_Attempt__c,Unbilled_Amt__c,SW_Unbilled_Amount__c,HW_Other_Unbilled_Amount__c from BPM_Annuity__c where Id in :bpmIdSet and BPMWorkflowCriteriaForHoldReason__c=true');
        }else{
            return Database.getQueryLocator('Select id,Cust_Nbr_CH__c,Hold_Reason_Type__c,Notification_Attempt__c,Unbilled_Amt__c,SW_Unbilled_Amount__c,HW_Other_Unbilled_Amount__c from BPM_Annuity__c where Email_Sent__c=true and BPMWorkflowCriteriaForHoldReason__c=true');
        }
    }
    public void execute(Database.BatchableContext BC, List<BPM_Annuity__c> scope){
        Map<Id,String> reasonTypesMap = new Map<Id,String>(); // for storing BPM Object id and its reason types
        Map<Id,Decimal> notificationAttemptMap = new Map<Id,Decimal>(); // for storing notification attempt for multiple bpm object
        Map<Id,String> masterBpmMap = new Map<Id,String>(); // used to store master number(MCN) with BPM Object Id
        Map<String,String> reasonWithActionOwnerMap = new Map<String,String>(); // to store action owner w.r.t reason types from metadata named 'BPM Action Owner Targeted Alert'
        Map<String,String> quicklookIdMap = new Map<String,String>(); // to store action owner's quicklookid with his mail and name separated by ','
        Map<Id,Map<String,Set<String>>> bpmIDWithUserMapForInvalid = new Map<Id,Map<String,Set<String>>>();
        Map<Id,String> bpmIDToNameUserMapForInvalid = new Map<Id,String>();
        Map<Id,BPM_Annuity__c> bpmMap = new Map<Id,BPM_Annuity__c>();
        Decimal SWAmt = Decimal.valueOf(BPM_Configuration__c.getValues('Software Unbilled Amount Threshold').values__c);
        Decimal HWAmt = Decimal.valueOf(BPM_Configuration__c.getValues('Hardware Unbilled Amount Threshold').values__c);
        for(BPM_Stop_Email_Alert__mdt obj : [Select Email_Id__c, label FROM BPM_Stop_Email_Alert__mdt]){
            unbilledAmountEmailCriteria.put(obj.Label,obj.Email_Id__c);
        } 
        // List<BPM_Annuity__c> bpmListToChange = new List<BPM_Annuity__c>(); as condition is already checked in trigger
        for(BPM_Annuity__c bpm : scope){
            if(!String.isBlank(bpm.Cust_Nbr_CH__c)){
                masterBpmMap.put(bpm.id,bpm.Cust_Nbr_CH__c);
            }
            reasonTypesMap.put(bpm.id,bpm.Hold_Reason_Type__c);
            notificationAttemptMap.put(bpm.id,bpm.Notification_Attempt__c+1);
            // bpmListToChange.add(bpmObj);
            bpmUnbilledAmtMap.put(bpm.id,bpm.Unbilled_Amt__c);
            bpmMap.put(bpm.id,bpm);
        }
        for(BPM_Action_Owner__mdt meta : [Select Action_Owner__c,Notification_Sequential_Order__c,Reason_Type__c,CCPerson__c from BPM_Action_Owner__mdt where Reason_Type__c in :reasonTypesMap.values()]){
            reasonWithActionOwnerMap.put(meta.Reason_Type__c,meta.Action_Owner__c+'-'+meta.CCPerson__c+'-'+meta.Notification_Sequential_Order__c); 
        }
        
        Map<String,Map<String,List<String>>> masterWithActionOwner = new Map<String,Map<String,List<String>>>(); // to store master and their related action owners with roles as key
        /* to get multiple associated Roles with Account Support*/
        for(ASM_Role_Hierarchy__c role : [Select Master__c,Role_User_Qlook_Id__c,Role_Name__c,User_name__c from ASM_Role_Hierarchy__c where Master__c in:masterBpmMap.values()]){
            if(role.Role_Name__c!= null && role.Role_User_Qlook_Id__c!=null){
                String Qlid = role.Role_User_Qlook_Id__c.toLowerCase(); 
                String rolename = role.Role_Name__c;
                if(!masterWithActionOwner.containsKey(role.Master__c)){
                    masterWithActionOwner.put(role.Master__c,new Map<String,List<String>>());
                    masterWithActionOwner.get(role.Master__c).put(rolename,new List<String>{Qlid});
                    quicklookIdMap.put(Qlid+','+rolename, role.User_name__c);
                }
                else{
                    if(!masterWithActionOwner.get(role.Master__c).containskey(rolename)){
                        masterWithActionOwner.get(role.Master__c).put(rolename,new List<String>{Qlid});
                        quicklookIdMap.put(Qlid+','+rolename, role.User_name__c);  
                    }
                    else{
                        masterWithActionOwner.get(role.Master__c).get(rolename).add(Qlid);
                        quicklookIdMap.put(Qlid+','+rolename, role.User_name__c);
                    }
                }
            }      
        }
        
        for(Id bpmId : masterBpmMap.keyset()){
            Map<String,List<String>> APOC;
            String master = masterBpmMap.get(bpmId);  
            if(masterWithActionOwner.containskey(master)){
                APOC = masterWithActionOwner.get(master);
            }
            String[] actnOwnr = BPM_Configuration__c.getValues('Default Action Owner').values__c.split(',');
            String[] defSWOwnr = BPM_Configuration__c.getValues('Software Action Owner').values__c.split(',');
            String[] rolesAftr3Attmpt = BPM_Configuration__c.getValues('NotificationToRolesAfterThreeAttempts').values__c.split(',');
            String[] invalCCPrsn = BPM_Configuration__c.getValues('Invalid Hold Reason CC Person').values__c.split(',');
            String[] invalActnOwnr = BPM_Configuration__c.getValues('Invalid Hold Reason Action Owner').values__c.split(',');
            String[] invalSWOwnr =BPM_Configuration__c.getValues('Invalid Hold Reason SW Action Owner').values__c.split(',');
            if(reasonTypesMap.containskey(bpmId)){
                if(bpmMap.get(bpmId).HW_Other_Unbilled_Amount__c>HWAmt){
                    if(reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmId))!=null){
                        String[] actionOwnerWithNotif = reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmId)).split('-');
                        String roles = '';
                        roles = popActnOwnrs(actionOwnerWithNotif[0].split(','),APOC,bpmId,roles);
                        /* IF there is no appropriate action owner in Account Support to send email then send to PO always*/
                        if(!bpmIDWithUserMap.containskey(bpmId)){
                            roles = popActnOwnrs(actnOwnr,APOC,bpmId,roles);
                        }
                        if(bpmMap.get(bpmId).SW_Unbilled_Amount__c>SWAmt){
                            roles = popActnOwnrs(defSWOwnr,APOC,bpmId,roles);
                        }
                        if(roles.length()>0){
                            roleActionOwner.put(bpmId,roles.substring(0, roles.length()-3));
                        }
                        popCCOwnrs(actionOwnerWithNotif[1].split(','),APOC,bpmId);
                        if(bpmMap.get(bpmId).Notification_Attempt__c+1>=3){
                            popCCOwnrs(rolesAftr3Attmpt,APOC,bpmId);
                        }
                    }
                    
                    /*If hold reason type is not in the valid hold reason type*/
                    else{
                        if(bpmMap.get(bpmId).Notification_Attempt__c+1>0){
                            String roles = '';
                            roles = popActnOwnrs(invalActnOwnr,APOC,bpmId,roles);
                            if(bpmMap.get(bpmId).SW_Unbilled_Amount__c>SWAmt){
                                roles = popActnOwnrs(defSWOwnr,APOC,bpmId,roles);
                            }
                            if(roles.length()>0){
                                roleActionOwner.put(bpmId,roles.substring(0, roles.length()-3));
                            }
                            popCCOwnrs(invalCCPrsn,APOC,bpmId);
                            
                            if(bpmMap.get(bpmId).Notification_Attempt__c+1>=3){
                                popCCOwnrs(rolesAftr3Attmpt,APOC,bpmId);
                            }
                        }
                        else{
                            String roles = '';
                            for(String str : invalActnOwnr){
                                if(APOC?.containskey(str)){
                                    roles = roles + str + ' | ';
                                    if(!bpmIDWithUserMapForInvalid.containskey(bpmId)){
                                        bpmIDWithUserMapForInvalid.put(bpmId,new Map<String,Set<String>>());
                                        bpmIDWithUserMapForInvalid.get(bpmId).put(str,new Set<String>());
                                        bpmIDWithUserMapForInvalid.get(bpmId).get(str).addall(APOC.get(str));
                                    }
                                    else{
                                        bpmIDWithUserMapForInvalid.get(bpmId).put(str,new Set<String>());
                                        bpmIDWithUserMapForInvalid.get(bpmId).get(str).addall(APOC.get(str));
                                    }
                                    if(str=='Customer Advocate'){
                                        CAquicklookIdInTo.addall(APOC.get(str));
                                    }else{
                                        quicklookIdInTo.addall(APOC.get(str));
                                    }
                                }
                            }
                            
                            if(roles.length()>0){
                                roleActionOwner.put(bpmId,roles.substring(0, roles.length()-3));
                            }
                            popCCOwnrs(invalCCPrsn,APOC,bpmId);
                        }
                    }
                }
                else if(bpmMap.get(bpmId).SW_Unbilled_Amount__c>SWAmt){
                    if(reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmId))!=null){
                        String roles = '';
                        roles = popActnOwnrs(defSWOwnr,APOC,bpmId,roles);
                        /* IF there is no appropriate action owner in Account Support to send email then send to PO always*/
                        if(!bpmIDWithUserMap.containskey(bpmId)){
                            roles = popActnOwnrs(actnOwnr,APOC,bpmId,roles);
                        }
                        if(roles.length()>0){
                            roleActionOwner.put(bpmId,roles.substring(0, roles.length()-3));
                        }
                        popCCOwnrs(invalSWOwnr,APOC,bpmId); //adding Customer Advocate in CC
                        popCCOwnrs(invalCCPrsn,APOC,bpmId); //adding POC_Others in CC
                        if(bpmMap.get(bpmId).Notification_Attempt__c+1>=3){
                            popCCOwnrs(rolesAftr3Attmpt,APOC,bpmId);
                        }
                    }
                    else{
                        if(bpmMap.get(bpmId).Notification_Attempt__c+1>0){
                            String roles = '';
                            roles = popActnOwnrs(defSWOwnr,APOC,bpmId,roles);
                            if(!bpmIDWithUserMap.containskey(bpmId)){
                                roles = popActnOwnrs(actnOwnr,APOC,bpmId,roles);    
                            }
                            roles = popActnOwnrs(invalSWOwnr,APOC,bpmId,roles); //adding customer advocate in TO
                            if(roles.length()>0){
                                roleActionOwner.put(bpmId,roles.substring(0, roles.length()-3));
                            }
                            popCCOwnrs(invalCCPrsn,APOC,bpmId); //adding POC_Other in CC
                            if(bpmMap.get(bpmId).Notification_Attempt__c+1>=3){
                                popCCOwnrs(rolesAftr3Attmpt,APOC,bpmId);
                            }
                        }
                        else{
                            String roles = '';
                            for(String str : defSWOwnr){
                                if(APOC?.containskey(str)){
                                    roles = roles + str + ' | ';
                                    bpmIDWithUserMapForInvalid.put(bpmId,new Map<String,Set<String>>());
                                    bpmIDWithUserMapForInvalid.get(bpmId).put(str,new Set<String>());
                                    bpmIDWithUserMapForInvalid.get(bpmId).get(str).addall(APOC.get(str));
                                    if(str=='Customer Advocate'){
                                        CAquicklookIdInTo.addall(APOC.get(str));
                                    }else{
                                        quicklookIdInTo.addall(APOC.get(str));
                                    }
                                }
                            }
                            /* IF there is no appropriate action owner in Account Support to send email then send to PO always*/
                            if(!bpmIDWithUserMapForInvalid.containskey(bpmId)){
                                for(String str : actnOwnr){
                                    if(APOC?.containskey(str)){
                                        roles = roles + str + ' & ';
                                        bpmIDWithUserMapForInvalid.put(bpmId,new Map<String,Set<String>>());
                                        bpmIDWithUserMapForInvalid.get(bpmId).put(str,new Set<String>());
                                        bpmIDWithUserMapForInvalid.get(bpmId).get(str).addall(APOC.get(str));
                                        quicklookIdInTo.addall(APOC.get(str));
                                    }
                                }
                            }
                            for(String str : invalSWOwnr){
                                if(APOC?.containskey(str)){
                                    roles = roles + str + ' & ';
                                    bpmIDWithUserMapForInvalid.get(bpmId).put(str,new Set<String>());
                                    bpmIDWithUserMapForInvalid.get(bpmId).get(str).addall(APOC.get(str));
                                    if(str=='Customer Advocate'){
                                        CAquicklookIdInTo.addall(APOC.get(str));
                                    }else{
                                        quicklookIdInTo.addall(APOC.get(str));
                                    }
                                }
                            }
                            if(roles.length()>0){
                                roleActionOwner.put(bpmId,roles.substring(0, roles.length()-3));
                            }
                            popCCOwnrs(invalCCPrsn,APOC,bpmId); //adding POC_Other in CC
                        }
                    }
                }
            }
        }
        if(!bpmIDWithUserMapForInvalid.isEmpty()){
            Map<Id,Map<String,Set<String>>> bpmIDToNameUserMapForInvalidFinal = removingToFromEmail(bpmIDWithUserMapForInvalid,bpmUnbilledAmtMap,unbilledAmountEmailCriteria);
            bpmIDToNameUserMapForInvalid = gettingUsersName(bpmIDToNameUserMapForInvalidFinal,quicklookIdMap);
            Map<Id,Set<String>> bpmIDToUserMapNew = new Map<Id,Set<String>>();
            for(Id bpmId : bpmIDToNameUserMapForInvalidFinal.keyset()){
                for(String str : bpmIDWithUserMapForInvalid.get(bpmId).keyset()){
                    if(!bpmIDToUserMapNew.containskey(bpmId)){
                        bpmIDToUserMapNew.put(bpmId,bpmIDToNameUserMapForInvalidFinal.get(bpmId).get(str));
                    }else{
                        bpmIDToUserMapNew.get(bpmId).addall(bpmIDToNameUserMapForInvalidFinal.get(bpmId).get(str));
                    }
                }
            }
            sendEmailNotificationForInvalidHoldReason(bpmIDToNameUserMapForInvalid,getEmailFromQLID(bpmIDToUserMapNew),reasonTypesMap,bpmMap,roleActionOwner,bpmUnbilledAmtMap,unbilledAmountEmailCriteria,getEmailFromQLID(bpmIDWithCCUserMap));
        }
        Map<string,Map<Integer,String>> managerHierarchy = new Map<String,Map<Integer,String>>();// to store user managers global id with user's quicklook id
        Set<string> managerSet = new Set<String>();// to make unique set of all the global ids fetch from above
        //fetching all the users and their managers global id - whom notification has to go out
        Map<String,Map<Integer,String>> mngrEmail = new Map<String,Map<Integer,String>>();// to store managers email match with their global id to action owner's quciklookid
        Map<String,Map<Integer,String>> CAmngrEmail = new Map<String,Map<Integer,String>>();
        Map<String,User> qlIdUsrMap = new Map<String,User>();
        Map<String,CA_Hierarchy__c> qlIdCAMap = new Map<String,CA_Hierarchy__c>();
        for(User usrObj : [Select Id,Quicklook_ID__c,Manager_Level_01_ID__c,Manager_Level_02_ID__c,Manager_Level_03_ID__c,Manager_Level_04_ID__c,Manager_Level_05_ID__c,Manager_Level_01__c,Manager_Level_02__c,Manager_Level_03__c,Manager_Level_04__c,Manager_Level_05__c from user where Quicklook_ID__c in:quicklookIdInTo]){
            qlIdUsrMap.put(usrObj.Quicklook_ID__c,usrObj);
            usrObj.Quicklook_ID__c=usrObj.Quicklook_ID__c.toLowerCase();
            if(!managerHierarchy.containskey(usrObj.Quicklook_ID__c)){
                managerHierarchy.put(usrObj.Quicklook_ID__c,new Map<Integer,String>());
                if(usrObj.Manager_Level_01_ID__c!=null){
                    managerHierarchy.get(usrObj.Quicklook_ID__c).put(1,usrObj.Manager_Level_01_ID__c);
                    managerSet.add(usrObj.Manager_Level_01_ID__c);
                }
                if(usrObj.Manager_Level_02_ID__c!=null){
                    managerHierarchy.get(usrObj.Quicklook_ID__c).put(2,usrObj.Manager_Level_02_ID__c);
                    managerSet.add(usrObj.Manager_Level_02_ID__c);
                }
                if(usrObj.Manager_Level_03_ID__c!=null){
                    managerHierarchy.get(usrObj.Quicklook_ID__c).put(3,usrObj.Manager_Level_03_ID__c);
                    managerSet.add(usrObj.Manager_Level_03_ID__c);
                }
                if(usrObj.Manager_Level_04_ID__c!=null){
                    managerHierarchy.get(usrObj.Quicklook_ID__c).put(4,usrObj.Manager_Level_04_ID__c);
                    managerSet.add(usrObj.Manager_Level_04_ID__c);
                }
                if(usrObj.Manager_Level_05_ID__c!=null){
                    managerHierarchy.get(usrObj.Quicklook_ID__c).put(5,usrObj.Manager_Level_05_ID__c);
                    managerSet.add(usrObj.Manager_Level_05_ID__c);
                }               
            }
        }
        Map<String,String> mngrQuicklookId = new Map<String,String>();
        //fetching quicklook id of all the managers from NCR Employee Object and appending @ncr.com to their quicklook id to send them escalations
        if(!managerSet.isEmpty()){
            for(NCR_Employee_Detail__c ncrEmp : [Select Quicklook_ID__c,Global_ID__c from NCR_Employee_Detail__c  where Global_ID__c in: managerSet and InActive__c=false limit 50000]){
                mngrQuicklookId.put(ncrEmp.Global_ID__c,ncrEmp.Quicklook_ID__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
            }
        }
        for(String quicklookid :managerHierarchy.keyset()){
            Map<Integer,String> usrQLIDWithManagers = new Map<Integer,String>();
            if(managerHierarchy.containskey(quicklookid)){
                usrQLIDWithManagers = managerHierarchy.get(quicklookid);
            }
            for(Integer position : usrQLIDWithManagers.keyset()){
                if(mngrQuicklookId.get(usrQLIDWithManagers.get(position))!=null){
                    if(!mngrEmail.containskey(quicklookid)){
                        mngrEmail.put(quicklookid,new Map<Integer,String>());
                        mngrEmail.get(quicklookid).put(position,mngrQuicklookId.get(usrQLIDWithManagers.get(position)));
                    }
                    else{
                        mngrEmail.get(quicklookid).put(position,mngrQuicklookId.get(usrQLIDWithManagers.get(position)));
                    }
                }
            }
        }        
        //fetching CA's hierarchy stored in different object -- till now only managers levels upto two are present
        for(CA_Hierarchy__c ca : [Select CA_QuicklookId__c,Manager1_Quicklookid__c,Manager2_Quicklookid__c,Manager3_Quicklookid__c,Manager4_Quicklookid__c,Manager1_Name__c,Manager2_Name__c,Manager3_Name__c,Manager4_Name__c from CA_Hierarchy__c where CA_QuicklookId__c in: CAquicklookIdInTo ]){
            if(ca.CA_QuicklookId__c!=null){
                ca.CA_QuicklookId__c=ca.CA_QuicklookId__c.toLowerCase();
                qlIdCAMap.put(ca.CA_QuicklookId__c,ca);
                if(!CAmngrEmail.containskey(ca.CA_QuicklookId__c)){
                    CAmngrEmail.put(ca.CA_QuicklookId__c,new Map<Integer,String>());
                    if(ca.Manager1_Quicklookid__c!=null){
                        CAmngrEmail.get(ca.CA_QuicklookId__c).put(1,ca.Manager1_Quicklookid__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
                    }
                    if(ca.Manager2_Quicklookid__c!=null){
                        CAmngrEmail.get(ca.CA_QuicklookId__c).put(2,ca.Manager2_Quicklookid__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
                    }
                    if(ca.Manager3_Quicklookid__c!=null){
                        CAmngrEmail.get(ca.CA_QuicklookId__c).put(3,ca.Manager3_Quicklookid__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
                    }
                    if(ca.Manager4_Quicklookid__c!=null){
                        CAmngrEmail.get(ca.CA_QuicklookId__c).put(4,ca.Manager4_Quicklookid__c+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c);
                    }
                }
            }
        }
        Map<Id,Map<String,Set<String>>> bpmIDToUserMap = removingToFromEmail(bpmIDWithUserMap,bpmUnbilledAmtMap,unbilledAmountEmailCriteria);
        Map<Id,Set<String>> bpmIDToUserMapNew = new Map<Id,Set<String>>();
        for(Id bpmId : bpmIDToUserMap.keyset()){
            for(String str : bpmIDToUserMap.get(bpmId).keyset()){
                if(!bpmIDToUserMapNew.containskey(bpmId)){
                    bpmIDToUserMapNew.put(bpmId,bpmIDToUserMap.get(bpmId).get(str));
                }else{
                    bpmIDToUserMapNew.get(bpmId).addall(bpmIDToUserMap.get(bpmId).get(str));
                }
            }
        }
        Map<Id,String> bpmIDToNameUserMap = gettingUsersName(bpmIDToUserMap,quicklookIdMap);
        Map<Id,Set<String>> bpmIDCCUserMap = gettingAllManagers(bpmIDToUserMapNew,notificationAttemptMap,mngrEmail,CAmngrEmail,getEmailFromQLID(bpmIDWithCCUserMap));    
        if(!bpmIDToUserMap.isEmpty())
            sendEmailNotification(bpmMap,bpmIDToNameUserMap,notificationAttemptMap,getEmailFromQLID(bpmIDToUserMapNew),quicklookIdMap,bpmIDCCUserMap,roleActionOwner,reasonTypesMap,reasonWithActionOwnerMap,bpmUnbilledAmtMap,unbilledAmountEmailCriteria);
        if(!bpmIDWithUserMapForInvalid.isEmpty()){
            updtActnOwnrs(reasonTypesMap,quicklookIdMap,bpmIDWithUserMapForInvalid,qlIdUsrMap,qlIdCAMap);
        }else{
            updtActnOwnrs(reasonTypesMap,quicklookIdMap,bpmIDWithUserMap,qlIdUsrMap,qlIdCAMap);
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
    	System.debug('BPM Notify Job Finished');    
    }
    public static Map<Id,Set<String>> getEmailFromQLID(Map<Id,Set<String>> bpmIDWithQLIDS){
        Map<Id,Set<String>>  bpmIDWithEmails = new Map<Id,Set<String>>();
        if(!bpmIDWithQLIDS.isEmpty()){
            for(Id bpmId : bpmIDWithQLIDS.keyset()){
                bpmIDWithEmails.put(bpmId,new Set<String>());
                for(String QLid : bpmIDWithQLIDS.get(bpmId)){
                    bpmIDWithEmails.get(bpmId).add(QLid+BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c); 
                }
            }
        }
        return bpmIDWithEmails;
    }
    public static void sendEmailNotification(Map<Id,BPM_Annuity__c> bpmMap,Map<Id,String> bpmIDToNameUserMap,Map<Id,Decimal> notificationAttemptMap,Map<Id,Set<String>> bpmIDToUserMap,Map<String,String> quicklookIdMap,Map<Id,Set<String>> bpmIDCCUserMap,Map<Id,String> roleActionOwner,Map<Id,String> reasonTypesMap, Map<String,String> reasonWithActionOwnerMap,Map<Id,Decimal> bpmUnbilledAmtMap,Map<String, String> unbilledAmountEmailCriteria){
        List<BPMNotificationLog__c> bpmlogs= new List<BPMNotificationLog__c>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage[] dummyemails = new List<Messaging.SingleEmailMessage> (); 
        Contact c = [select id, Email from Contact where id =:BPM_Configuration__c.getValues('BPMContactIdForNotifyActionOwner').values__c];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Standard Template'];
        List<BPM_Annuity__c> bpmListToupdate = new List<BPM_Annuity__c>();
        for(Id bpmId : bpmIDToUserMap.keyset()){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(c.id);
            message.setSaveAsActivity(false); 
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(bpmId);
            dummyemails.add(message); 
        }
        try{
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(dummyemails); // roll back so that original email not send
            Database.rollback(sp);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        for (Messaging.SingleEmailMessage message : dummyEmails){
            Id bpmId = message.getWhatId();
            String mailMessage = message.getHTMLBody();
            string roleName;
            String actionownername;
            Integer notificationAttempt;
            if(bpmIDToNameUserMap.containskey(bpmId)){
                String names = bpmIDToNameUserMap.get(bpmId);
                if(names.length()>0){
                    names = names.substring(0, names.length()-3);
                    actionownername = names;
                    roleName = roleActionOwner.get(bpmId);
                }
                if(mailMessage!=null){
                    mailMessage = mailMessage.replace('#name', names);
                }
                
                
                if(notificationAttemptMap.containsKey(bpmId)){
                    notificationAttempt=Integer.valueOf(notificationAttemptMap.get(bpmId)); 
                }
                if(mailMessage!=null){
                    mailMessage = mailMessage.replace('#notificationAttempt',String.valueof(notificationAttempt));
                }
            }
            Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
            List<String> toaddress;
            if(bpmIDToUserMap.containskey(bpmId)){
                toaddress = new List<String>();
                toaddress.addall(bpmIDToUserMap.get(bpmId));
                message1.setToAddresses(toaddress);
            }
            message1.setSaveAsActivity(false); 
            message1.setSubject(message.getSubject());
            message1.setHtmlBody(mailMessage);
            if ( owea.size() > 0 ) {
                message1.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            List<String> ccaddress;
            if(bpmIDCCUserMap.containskey(bpmId)){
                ccaddress = new List<String>();
                ccaddress.addall(removeNullFromList(bpmIDCCUserMap.get(bpmId)));
                if(bpmUnbilledAmtMap.containskey(bpmId)){
                    List<String> newCcAddresses = getEmailListToSend(ccaddress, bpmUnbilledAmtMap.get(bpmId), true,unbilledAmountEmailCriteria);
                    message1.setCcAddresses(newCcAddresses);
                }else{
                    message1.setCcAddresses(ccaddress);
                }
            }
            message1.setBccAddresses(bccAddrss);
            message1.setWhatId(bpmId);
            String[] toaddressFinal =message1.getToAddresses();
            if(toaddressFinal!=null){
                if(toaddressFinal.size()>0){
                    if(bpmMap.get(bpmId)!=null){
                        BPM_Annuity__c bpmObj = new BPM_Annuity__c(Id =bpmId);
                        if(reasonTypesMap.containskey(bpmObj.id)){
                            bpmObj.Email_Sent__c = false;
                            bpmObj.Contract_On_Hold__c = true;
                            if(schTime!=null){
                                DateTime inTime = DateTime.newInstanceGMT(System.today(), Time.newInstance(Integer.valueOf(schTime.split(',')[0]), Integer.valueOf(schTime.split(',')[1]), 0, 0));
                                Long minDiff = (DateTime.valueOf(inTime.formatGMT('yyyy-MM-dd HH:mm:ss')).getTime() - DateTime.valueOf(inTime.format('yyyy-MM-dd HH:mm:ss', znSwtch)).getTime()) / 1000 / 60;
                                bpmObj.Alert_Next_Date_Time__c = inTime.addMinutes(minDiff.intValue());
                            }
                            bpmObj.SendAdhocMail__c = false;
                            bpmObj.Notification_Attempt__c = notificationAttempt;
                            if(reasonWithActionOwnerMap.containskey(reasonTypesMap.get(bpmObj.id))){
                                // bpmUnbilledAmtMap.put(bpmObj.id,bpmObj.Unbilled_Amt__c);
                                String[] actionOwnerWithNotif = reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmObj.id)).split('-');
                                bpmObj.Sequence_Order__c = Integer.valueOf(actionOwnerWithNotif[2]);
                                bpmObj.Alert_Next_Date_Time__c = (bpmObj.Notification_Attempt__c>6 ? bpmObj.Alert_Next_Date_Time__c + 15  : bpmObj.Alert_Next_Date_Time__c + Integer.valueOf(actionOwnerWithNotif[2]));
                                //bpmObj.Alert_Next_Date_Time__c = (bpmObj.Notification_Attempt__c>6 ? bpmObj.Alert_Next_Date_Time__c.addminutes(15)  : bpmObj.Alert_Next_Date_Time__c.addminutes(Integer.valueOf(actionOwnerWithNotif[2])));
                            } 
                            else{
                                bpmObj.Sequence_Order__c = 7;
                                bpmObj.Alert_Next_Date_Time__c = (bpmObj.Notification_Attempt__c>6 ? bpmObj.Alert_Next_Date_Time__c + 15  : bpmObj.Alert_Next_Date_Time__c + Integer.valueOf(BPM_Configuration__c.getValues('Invalid Hold Desc Alert Interval').values__c));
                                //bpmObj.Alert_Next_Date_Time__c = (bpmObj.Notification_Attempt__c>6 ? bpmObj.Alert_Next_Date_Time__c.addminutes(15)  : bpmObj.Alert_Next_Date_Time__c.addminutes(7));
                            }
                            String d=bpmObj.Alert_Next_Date_Time__c.format('EEEE');
                            if(d=='Saturday'){
                                bpmObj.Alert_Next_Date_Time__c +=2;
                            }
                            if(d=='Sunday'){
                                bpmObj.Alert_Next_Date_Time__c +=1;
                            }
                            bpmListToupdate.add(bpmObj);
                        }
                    }
                    messages.add(message1);
                    BPMNotificationLog__c log = new BPMNotificationLog__c(BPM_Annuity__c=bpmId,ToPerson__c=String.valueof(toaddressFinal).substring(1,String.valueOf(toaddressFinal).length()-1),Notification_Number__c=String.valueof(notificationAttempt),Notification_Sent_Date__c=System.now(),Action_Owner_Name__c=actionOwnerName,Action_Owner_Role_Name__c=roleName,Hold_Reason_Type__c=reasonTypesMap.get(bpmid));
                    String[] ccAddressFinal = message1.getCCAddresses();
                    if(ccAddressFinal!=null){
                        log.CCPerson__c=String.valueOf(ccAddressFinal).substring(1,String.valueOf(ccAddressFinal).length()-1);
                    }
                    bpmlogs.add(log);
                }
            }
        }
        if(!bpmListToupdate.isEmpty()){
            update bpmListToupdate;
        }
        if(!bpmlogs.isEmpty()){
            insert bpmlogs;
        }
        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            for(Messaging.SendEmailResult rslt : results){
                if (rslt.success) 
                {
                    // update bpmListToUpdate;
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
            }
        }
    }
    
    //********************For remove emailIds from SendEmail List on conditional Basis*****************************//
    public static List<String> getEmailListToSend(List<String> emailList, Decimal unbilledAmount, Boolean isEmail,Map<String, String> unbilledAmountEmailCriteria){
        String domainName = BPM_Configuration__c.getValues('BPM Email - added into QLID').values__c.toLowerCase();   
        
        List<String> newEmailList = new List<String>();
        for(String emailObj : emailList){
            newEmailList.add(emailObj.toLowerCase());
        }
        List<String> allQuicklookIds = new List<String>();
        for(String unbilledAmountObj : unbilledAmountEmailCriteria.keyset()){
            if(unbilledAmountObj!='never'){
                if(unbilledAmount != null && unbilledAmount < Integer.valueof(unbilledAmountObj)){
                    allQuicklookIds.addall(unbilledAmountEmailCriteria.get(unbilledAmountObj).toLowerCase().deleteWhitespace().split(','));
                }
            }
            else{
                allQuicklookIds.addall(unbilledAmountEmailCriteria.get(unbilledAmountObj).toLowerCase().deleteWhitespace().split(','));
            }
        }
        if(isEmail){
            for(String quickLookId : allQuicklookIds){
                if(newEmailList.contains(quickLookId+domainName)){
                    newEmailList.remove(newEmailList.indexOf(quickLookId+domainName));
                }
            }
        }
        else{
            for(String quickLookId : allQuicklookIds){
                if(newEmailList.contains(quickLookId)){
                    newEmailList.remove(newEmailList.indexOf(quickLookId));
                }
            }
        }
        return newEmailList;
    }
    //*************************************End Here*********************************************//
    
    //********************************************Remove Null from List**************************
    public static List<String> removeNullFromList(Set<String> emailList){
        List<String> newEmailList = new List<String>();
        for(String str:emailList){
            if(str!=null){
                newEmailList.add(str);
            }
        }
        return newEmailList;
    }
    public static Map<Id,String> gettingUsersName(Map<Id,Map<String,Set<String>>> bpmIDMap,Map<String,String> quicklookIdMap){
        Map<Id,String> bpmIDToNameUserMap = new Map<Id,String>();
        if(!bpmIDMap.isEmpty()){
            for(Id bpmId : bpmIDMap.keyset()){
                String username='';
                for(String role : bpmIDMap.get(bpmId).keyset()){
                    for(string qlid : bpmIDMap.get(bpmId).get(role)){
                        if(quicklookIdMap.containskey(QLid+','+role)){
                            username += quicklookIdMap.get(QLid+','+role)+'{'+role+'}'+' | ';
                        } 
                    }
                }
                bpmIDToNameUserMap.put(bpmId,username);
            }
        }
        return bpmIDToNameUserMap;
    }
    public static Map<Id,Map<String,Set<String>>> removingToFromEmail(Map<Id,Map<String,Set<String>>> bpmIDMap,Map<Id,Decimal> bpmUnbilledAmtMap,Map<String, String> unbilledAmountEmailCriteria){
        Map<Id,Map<String,Set<String>>>  bpmIdEmailList = new Map<Id,Map<String,Set<String>>>();
        if(!bpmIDMap.isEmpty()){
            for(Id bpmId : bpmIDMap.keyset()){
                List<String> qlookIdList = new List<String>();
                bpmIdEmailList.put(bpmId,new Map<String,Set<String>>());
                for(String str : bpmIDMap.get(bpmId).keyset()){
                    qlookIdList.addAll(bpmIDMap.get(bpmId).get(str));
                    Set<String> newEmailsToSend = new Set<String>();
                    newEmailsToSend.addall(getEmailListToSend(qlookIdList, bpmUnbilledAmtMap.get(bpmId), false,unbilledAmountEmailCriteria));
                    bpmIdEmailList.get(bpmId).put(str,newEmailsToSend);
                }
            }
        }
        return bpmIdEmailList;
    }
    //********************************************Remove Null from List**************************
    public static Map<Id,Set<String>> gettingAllManagers(Map<Id,Set<String>> bpmIDWithUserMap,Map<Id,decimal> notificationAttemptMap,Map<String,Map<Integer,String>> mngrEmail,Map<String,Map<Integer,String>> CAmngrEmail,Map<Id,Set<String>> bpmIDCCUserMap){
        if(!bpmIDWithUserMap.isEmpty()){
            for(Id bpmId : bpmIDWithUserMap.keyset()){
                Double notificationAttempt;
                if(notificationAttemptMap!=null){
                    if(notificationAttemptMap.containsKey(bpmId)){
                        notificationAttempt=notificationAttemptMap.get(bpmId); 
                    }
                }
                for(String QLid:bpmIDWithUserMap.get(bpmId)){
                    Map<Integer,String> managerPostWithEmailMap = new Map<Integer,String>();
                    Map<Integer,String> CAmanagerPostWithEmailMap = new Map<Integer,String>();
                    if(mngrEmail.containskey(QLid)){
                        managerPostWithEmailMap = mngrEmail.get(QLid);
                    }
                    if(notificationAttemptMap!=null){
                        if(CAmngrEmail.containskey(QLid)){
                            CAmanagerPostWithEmailMap = CAmngrEmail.get(QLid);
                        }
                    }
                    if(notificationAttempt>=2){
                        if(!bpmIDCCUserMap.containskey(bpmId)){
                            bpmIDCCUserMap.put(bpmId,new Set<String>{managerPostWithEmailMap.get(1)});
                        }else{
                            bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(1)); 
                            bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(1));
                        }
                    }
                    if(notificationAttempt==3){
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(2));
                    }
                    if(notificationAttempt==4){
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(3));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(3));
                    }
                    if(notificationAttempt==5){
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(3));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(4));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(3));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(4));
                    }
                    if(notificationAttempt>=6){
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(3));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(4));
                        bpmIDCCUserMap.get(bpmId).add(managerPostWithEmailMap.get(5));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(1));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(2));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(3));
                        bpmIDCCUserMap.get(bpmId).add(CAmanagerPostWithEmailMap.get(4));
                    }
                }  
            }
        }
        return bpmIDCCUserMap;
    }
    
    public static void sendEmailNotificationForInvalidHoldReason(Map<Id,String> bpmIDToNameUserMap,Map<Id,Set<String>> bpmIDToUserMap,Map<Id,String> reasonTypesMap,Map<Id,bpm_annuity__C> bpmMap,Map<Id,String> roleActionOwner, Map<Id,Decimal> bpmUnbilledAmtMap,Map<String, String> unbilledAmountEmailCriteria,Map<Id,Set<String>> bpmCCMap){
        List<BPMNotificationLog__c> bpmlogs= new List<BPMNotificationLog__c>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage[] dummyemails = new List<Messaging.SingleEmailMessage> (); 
        Contact c = [select id, Email from Contact where id =:BPM_Configuration__c.getValues('BPMContactIdForNotifyActionOwner').values__c];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'BPMInvalidHoldReasonTemplate'];
        List<BPM_Annuity__c> bpmListToupdate = new List<BPM_Annuity__c>();
        for(Id bpmId : bpmIDToUserMap.keyset()){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(c.id);
            message.setSaveAsActivity(false); 
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(bpmId);
            dummyemails.add(message); 
        }
        try{
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(dummyemails); // roll back so that original email not send
            Database.rollback(sp);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        for (Messaging.SingleEmailMessage message : dummyEmails){
            Id bpmId = message.getWhatId();
            String mailMessage = message.getHTMLBody();
            string roleName;
            String actionownername;
            if(bpmIDToNameUserMap.containskey(bpmId)){
                String names = bpmIDToNameUserMap.get(bpmId);
                if(names.length()>0){
                    names = names.substring(0, names.length()-3);
                    actionownername = names;
                    roleName = roleActionOwner.get(bpmId);
                }
                if(mailMessage!=null){
                    mailMessage = mailMessage.replace('#name', names);
                }
                
                
            }
            Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
            List<String> toaddress;
            if(bpmIDToUserMap.containskey(bpmId)){
                toaddress = new List<String>();
                toaddress.addall(bpmIDToUserMap.get(bpmId));
                message1.setToAddresses(toaddress);
                List<String> ccaddress;
                if(bpmCCMap.containskey(bpmId)){
                    ccaddress = new List<String>();
                    ccaddress.addall(removeNullFromList(bpmCCMap.get(bpmId)));
                    if(bpmUnbilledAmtMap.containskey(bpmId)){
                        List<String> newCcAddresses = getEmailListToSend(ccaddress, bpmUnbilledAmtMap.get(bpmId), true,unbilledAmountEmailCriteria);
                        message1.setCcAddresses(newCcAddresses);
                    }else{
                        message1.setCcAddresses(ccaddress);
                    }
                }
            }
            message1.setSaveAsActivity(false); 
            message1.setSubject(message.getSubject());
            message1.setHtmlBody(mailMessage);
            if ( owea.size() > 0 ) {
                message1.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            message1.setBccAddresses(bccAddrss);
            message1.setWhatId(bpmId);
            String[] toaddressFinal =message1.getToAddresses();
            if(toaddressFinal!=null){
                if(toaddressFinal.size()>0){
                    messages.add(message1);
                    BPMNotificationLog__c log = new BPMNotificationLog__c(BPM_Annuity__c=bpmId,ToPerson__c=String.valueof(toaddressFinal).substring(1,String.valueOf(toaddressFinal).length()-1),Notification_Sent_Date__c=System.now(),Action_Owner_Name__c=actionOwnerName,Action_Owner_Role_Name__c=roleName,Hold_Reason_Type__c=reasonTypesMap.get(bpmid),Notification_Number__c='0');
                    bpmlogs.add(log);
                    String[] ccAddressFinal = message1.getCCAddresses();
                    if(ccAddressFinal!=null){
                        log.CCPerson__c=String.valueOf(ccAddressFinal).substring(1,String.valueOf(ccAddressFinal).length()-1);
                    }
                    BPM_Annuity__c bpmObj = new BPM_Annuity__c(ID =bpmId);
                    bpmObj.Email_Sent__c = false;
                    bpmObj.SendAdhocMail__c = false;
                    bpmObj.Contract_On_Hold__c = true;
                    if(schTime!=null){
                        DateTime inTime = DateTime.newInstanceGMT(System.today(), Time.newInstance(Integer.valueOf(schTime.split(',')[0]), Integer.valueOf(schTime.split(',')[1]), 0, 0));
                        Long minDiff = (DateTime.valueOf(inTime.formatGMT('yyyy-MM-dd HH:mm:ss')).getTime() - DateTime.valueOf(inTime.format('yyyy-MM-dd HH:mm:ss', znSwtch)).getTime()) / 1000 / 60;
                        bpmObj.Alert_Next_Date_Time__c = inTime.addMinutes(minDiff.intValue());
                    }
                    bpmObj.Sequence_Order__c = 7;
                    bpmObj.Notification_Attempt__c = bpmMap.get(bpmId).Notification_Attempt__c+1;
                    bpmObj.Alert_Next_Date_Time__c = (bpmObj.Notification_Attempt__c>6 ? bpmObj.Alert_Next_Date_Time__c + 15  : bpmObj.Alert_Next_Date_Time__c + Integer.valueOf(BPM_Configuration__c.getValues('Invalid Hold Desc Alert Interval').values__c));
                    //bpmObj.Alert_Next_Date_Time__c = (bpmObj.Notification_Attempt__c>6 ? bpmObj.Alert_Next_Date_Time__c.addminutes(15)  : bpmObj.Alert_Next_Date_Time__c.addminutes(7));
                    String d=bpmObj.Alert_Next_Date_Time__c.format('EEEE');
                    System.debug(d);
                    if(d=='Saturday'){
                        bpmObj.Alert_Next_Date_Time__c +=2;
                    }
                    if(d=='Sunday'){
                        bpmObj.Alert_Next_Date_Time__c +=1;
                    }
                    bpmListToUpdate.add(bpmObj);
                }
            }
        }
        
        if(!bpmlogs.isEmpty()){
            insert bpmlogs;
        }
        if(!bpmListToUpdate.isEmpty()){
            update bpmListToUpdate;
        } 
        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new BPMNotifyActionOwnerBatch());
    }
    public string popActnOwnrs(String[] actnOwnr,Map<String,List<String>> aproles,Id bpmId,String roles){
        for(String str : actnOwnr){
                if(aproles!= null && aproles.containskey(str)){  //monika            
                roles = roles + str + ' & ';
                if(!bpmIDWithUserMap.containskey(bpmId)){
                    bpmIDWithUserMap.put(bpmId,new Map<String,Set<String>>());
                    bpmIDWithUserMap.get(bpmId).put(str,new Set<String>());
                    bpmIDWithUserMap.get(bpmId).get(str).addall(aproles.get(str));
                }
                else{
                    bpmIDWithUserMap.get(bpmId).put(str,new Set<String>());
                    bpmIDWithUserMap.get(bpmId).get(str).addall(aproles.get(str));
                }
                if(str=='Customer Advocate'){
                    CAquicklookIdInTo.addall(aproles.get(str));
                }else{
                    quicklookIdInTo.addall(aproles.get(str));
                }
            }                       
            
        }
        return roles;
    }
    public void popCCOwnrs(String[] actnOwnr,Map<String,List<String>> APOC,Id bpmId){
        for(String str : actnOwnr){
            if(APOC!= null && APOC.containskey(str)){ //monika
                if(roleActionOwner.get(bpmId)!= null && !roleActionOwner.get(bpmId).split(' & ').contains(str)){ //monika
                    if(!bpmIDWithCCUserMap.containskey(bpmId)){
                        bpmIDWithCCUserMap.put(bpmId,new Set<String>());
                        bpmIDWithCCUserMap.get(bpmId).addall(APOC.get(str));
                    }
                    else{
                        bpmIDWithCCUserMap.get(bpmId).addall(APOC.get(str));
                    }
                }
            }
        }
    }
    public void updtActnOwnrs(Map<Id,String> reasons,Map<String,String> quicklookIdMap,Map<Id,Map<String,Set<String>>> bpmUserMap,Map<String,User> qlIdUsrMap,Map<String,CA_Hierarchy__c> qlIdCAMap){
        List<BPM_Aging_History__c> bpmHisList = new List<BPM_Aging_History__c>();
        List<BPM_Aging_History__c> delbpm = new List<BPM_Aging_History__c>();
        Map<Id,BPM_Aging_History__c> bpmHisMap = new Map<Id,BPM_Aging_History__c>();
        for(BPM_Aging_History__c ah : [Select id, Customer_Name__c,Contract_Number__c,Full_Contract_Nbr__c,Customer_Nbr__c,Hold_Reason_Type__c,Hold_Reason_Type_Start_Date__c,BPM_Annuity__c from BPM_Aging_History__c where Hold_Reason_Type_End_Date__c=null and BPM_Annuity__c in:bpmUserMap.keyset() and Hold_Reason_Type__c in:reasons.values() ]){
            bpmHisMap.put(ah.BPM_Annuity__c,ah);
            delbpm.add(ah);
        }
        for(Id b : bpmUserMap.keyset()){
            if(bpmUserMap.get(b)!=null){
                for(String role : bpmUserMap.get(b).keyset()){
                    for(string qlid : bpmUserMap.get(b).get(role)){
                        if(quicklookIdMap.containskey(QLid+','+role)){
                            BPM_Aging_History__c ah = bpmHisMap.get(b);
                            BPM_Aging_History__c bpmhis = new BPM_Aging_History__c();
                            if(ah!=null){
                                bpmhis.Customer_Name__c = ah.Customer_Name__c;
                                bpmhis.Contract_Number__c = ah.Contract_Number__c;
                                bpmhis.Full_Contract_Nbr__c = ah.Full_Contract_Nbr__c;
                                bpmhis.Customer_Nbr__c = ah.Customer_Nbr__c;
                                bpmhis.Hold_Reason_Type__c = ah.Hold_Reason_Type__c;
                                bpmhis.Action_Owner__c = quicklookIdMap.get(QLid+','+role);
                                bpmhis.Action_Owner_Role__c = role;
                                bpmhis.Hold_Reason_Type_Start_Date__c = ah.Hold_Reason_Type_Start_Date__c;
                                bpmhis.BPM_Annuity__c = ah.BPM_Annuity__c;
                                if(role=='Customer Advocate'){
                                    if(qlIdCAMap.get(QLid)!=null){
                                        bpmhis.Manager1_Name__c = qlIdCAMap.get(QLid).Manager1_Name__c;
                                        bpmhis.Manager2_Name__c = qlIdCAMap.get(QLid).Manager2_Name__c;  
                                        bpmhis.Manager3_Name__c = qlIdCAMap.get(QLid).Manager3_Name__c;
                                        bpmhis.Manager4_Name__c = qlIdCAMap.get(QLid).Manager4_Name__c;
                                    }else{
                                        popMngr(bpmhis,qlIdUsrMap,QLid);
                                    }
                                }else{
                                    popMngr(bpmhis,qlIdUsrMap,QLid);
                                }
                                System.debug(bpmhis);
                                bpmHisList.add(bpmhis);
                            }
                        }
                    }
                    
                }
            }
        }
        if(!bpmHisList.isEmpty()){
            insert bpmHisList;
        }
        if(!delbpm.isEmpty()){
            delete delbpm;
        }
    }
    public static BPM_Aging_History__c popMngr(BPM_Aging_History__c bhis,Map<String,User> qlIdUsrMap,String QLid){
        if(qlIdUsrMap.get(QLid)!=null){
            bhis.Manager1_Name__c = qlIdUsrMap.get(QLid).Manager_Level_01__c;
            bhis.Manager2_Name__c = qlIdUsrMap.get(QLid).Manager_Level_02__c; 
            bhis.Manager3_Name__c = qlIdUsrMap.get(QLid).Manager_Level_03__c;
            bhis.Manager4_Name__c = qlIdUsrMap.get(QLid).Manager_Level_04__c;
            bhis.Manager5_Name__c = qlIdUsrMap.get(QLid).Manager_Level_05__c;
        }
        return bhis;
    }
    
}