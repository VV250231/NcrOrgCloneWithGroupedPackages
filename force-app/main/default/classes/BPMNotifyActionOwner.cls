/*
##################################################################################################
# Project Name..........: BPM Automation
# File............................: BPMNotifyActionOwner.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 01/16/2020(MM/DD/YYYY)                                                                              
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 11/10/2020(MM/DD/YYYY)
# Description...............: This class is used for sending BPM Notification and scheduling them in time based workflow
                              named 'BPM Automation' on changing field 'Alert Next Date Time' on BPM_Annuity__c Object.
##################################################################################################
*/
public class BPMNotifyActionOwner{
    public static boolean isFirst = true;
    //*************************************Aging History Calculation(New code added by Varsha on 18th May)
   	static Map<Id,Map<String,Set<String>>> bpmIDWithUserMap = new Map<Id,Map<String,Set<String>>>(); // to store all the action owner quicklookid which needs to be in TO
    static Set<String> qlIdInTo = new Set<String>();
    public static void createAgingHistory(List<BPM_Annuity__c> bpmList, List<String> oldHoldReasons,Set<Id> bpmIds){
        Map<Id,String> masterBpmMap = new Map<Id,String>();
        Map<Id,String> reasonTypesMap = new Map<Id,String>();
        Map<String,String> reasonWithActionOwnerMap = new Map<String,String>();
        Set<String> actnOwnrs = new Set<String>();
        Map<String,String> quicklookIdMap = new Map<String,String>();
        Map<Id,BPM_Annuity__c> bpmMap = new Map<Id,BPM_Annuity__c>();
        String[] defSWOwnr = BPM_Configuration__c.getValues('Software Action Owner').values__c.split(',');
        String[] defActnOwnr = BPM_Configuration__c.getValues('Default Action Owner').values__c.split(',');
        String[] invalActnOwnr = BPM_Configuration__c.getValues('Invalid Hold Reason Action Owner').values__c.split(',');
        String[]  definvalSWAO = BPM_Configuration__c.getValues('Invalid Hold Reason SW Action Owner').values__c.split(',');
        Decimal SWAmt = Decimal.valueOf(BPM_Configuration__c.getValues('Software Unbilled Amount Threshold').values__c);
		Decimal HWAmt = Decimal.valueOf(BPM_Configuration__c.getValues('Hardware Unbilled Amount Threshold').values__c);
        for(BPM_Annuity__c bpm : bpmList){
            bpmMap.put(bpm.id,bpm);
            if(!String.isBlank(bpm.Cust_Nbr_CH__c)){
                masterBpmMap.put(bpm.id,bpm.Cust_Nbr_CH__c);
            }
            if(!String.isBlank(bpm.Hold_Reason_Type__c)){
                reasonTypesMap.put(bpm.id,bpm.Hold_Reason_Type__c);
            }	
            if(bpm.SW_Unbilled_Amount__c>SWAmt){
                actnOwnrs.addall(defSWOwnr);
                actnOwnrs.addall(definvalSWAO);
            }
            actnOwnrs.addall(defActnOwnr);
            actnOwnrs.addall(invalActnOwnr);
        }
        for(BPM_Action_Owner__mdt meta : [Select Action_Owner__c,Notification_Sequential_Order__c,Reason_Type__c,CCPerson__c from BPM_Action_Owner__mdt where Reason_Type__c in :reasonTypesMap.values()]){
            reasonWithActionOwnerMap.put(meta.Reason_Type__c,meta.Action_Owner__c+'-'+meta.CCPerson__c+'-'+meta.Notification_Sequential_Order__c); 
        	actnOwnrs.addall(meta.Action_Owner__c.split(','));
        }
        Map<String,Map<String,List<String>>> masterWithActionOwner = new Map<String,Map<String,List<String>>>(); // to store master and their related action owners with roles as key
        /* to get multiple associated Roles with Account Support*/
        for(ASM_Role_Hierarchy__c role : [Select Master__c,Role_User_Qlook_Id__c,Role_Name__c,User_name__c from ASM_Role_Hierarchy__c where Master__c in:masterBpmMap.values() and role_name__c in:actnOwnrs]){
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
            String master;
            if(masterBpmMap.containskey(bpmId)){
                master= masterBpmMap.get(bpmId);
            }
            if(masterWithActionOwner.containskey(master)){
                APOC = masterWithActionOwner.get(master);
            }
            if(bpmMap.get(bpmId).HW_Other_Unbilled_Amount__c>HWAmt){
                if(reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmId))!=null){
                    String[] actionOwnerWithNotif = reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmId)).split('-');
                    popActnOwnr(actionOwnerWithNotif[0].split(','),APOC,bpmId);
                    /* IF there is no appropriate action owner in Account Support to send email then send to PO always*/
                    if(!bpmIDWithUserMap.containskey(bpmId)){
                        popActnOwnr(defActnOwnr,APOC,bpmId);
                    }
                    if(bpmMap.get(bpmId).SW_Unbilled_Amount__c>SWAmt){
                        popActnOwnr(defSWOwnr,APOC,bpmId);
                    }
                }
                else if(reasonTypesMap.get(bpmId)!=null){
                    popActnOwnr(invalActnOwnr,APOC,bpmId);
                }
            }
            else if(bpmMap.get(bpmId).SW_Unbilled_Amount__c>SWAmt){
                if(reasonWithActionOwnerMap.get(reasonTypesMap.get(bpmId))!=null){
                    popActnOwnr(defSWOwnr,APOC,bpmId);
                    if(!bpmIDWithUserMap.containskey(bpmId)){
                        popActnOwnr(defActnOwnr,APOC,bpmId);
                    }  
                }
                else if(reasonTypesMap.get(bpmId)!=null){
                    popActnOwnr(defSWOwnr,APOC,bpmId);
                    if(!bpmIDWithUserMap.containskey(bpmId)){
                        popActnOwnr(defActnOwnr,APOC,bpmId);
                    } 
                    popActnOwnr(definvalSWAO,APOC,bpmId);
                }
            }
        }
        Map<String,User> qlIdUsrMap = new Map<String,User>();
        Map<String,CA_Hierarchy__c> qlIdCAMap = new Map<String,CA_Hierarchy__c>();
        if(!qlIdInTo.isEmpty()){
            for(User u : [Select Id,Quicklook_ID__c,Manager_Level_01__c,Manager_Level_02__c,Manager_Level_03__c,Manager_Level_04__c,Manager_Level_05__c from user where Quicklook_ID__c in:qlIdInTo]){
                qlIdUsrMap.put(u.Quicklook_ID__c,u);
            }
            for(CA_Hierarchy__c ca : [Select CA_QuicklookId__c,Manager1_Name__c,Manager2_Name__c,Manager3_Name__c,Manager4_Name__c from CA_Hierarchy__c where CA_QuicklookId__c in :qlIdInTo]){
                qlIdCAMap.put(ca.CA_QuicklookId__c,ca);
            }
        }
        List<BPM_Aging_History__c> bpmHisList = new List<BPM_Aging_History__c>(); 
        for(BPM_Annuity__c bpm : bpmList){
            if(bpmIDWithUserMap.get(bpm.Id)!=null){
                for(String role : bpmIDWithUserMap.get(bpm.Id).keyset()){
                    for(string qlid : bpmIDWithUserMap.get(bpm.Id).get(role)){
                        if(quicklookIdMap.containskey(QLid+','+role)){
                            BPM_Aging_History__c bpmhis = new BPM_Aging_History__c();
                            bpmhis.Customer_Name__c = bpm.Cust_Name_CH_BPM__c;
                            bpmhis.Contract_Number__c = bpm.Contract_Nbr_CH_BPM__c;
                            bpmhis.Full_Contract_Nbr__c = bpm.Full_Contract_Nbr_CH__c;
                            bpmhis.Customer_Nbr__c = bpm.Cust_Nbr_CH__c;
                            bpmhis.Hold_Reason_Type__c = bpm.Hold_Reason_Type__c;
                            bpmhis.Action_Owner__c = quicklookIdMap.get(QLid+','+role);
                            bpmhis.Action_Owner_Role__c = role;
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
                            bpmhis.Hold_Reason_Type_Start_Date__c = System.today();
                            bpmhis.BPM_Annuity__c = bpm.id;
                            bpmHisList.add(bpmhis);
                        } 
                    }
                }
            }
        }
       	List<BPM_Aging_History__c> bpmHistoryListUpdate = new List<BPM_Aging_History__c>(); 
        if(oldHoldReasons!=null){
            for(BPM_Aging_History__c bpmHistory : [Select id,Hold_Reason_Type_End_Date__c,BPM_Annuity__c from BPM_Aging_History__c where Hold_Reason_Type__c in: oldHoldReasons and Hold_Reason_Type_End_Date__c=null and BPM_Annuity__c in :bpmIds]){
                bpmHistory.Hold_Reason_Type_End_Date__c= System.today();
                bpmHistoryListUpdate.add(bpmHistory);
            }
            if(!bpmHistoryListUpdate.isEmpty()){
               update bpmHistoryListUpdate;
            }
        }
        if(!bpmHisList.isEmpty()){
            insert bpmHisList;
        }
    }
    public static void popActnOwnr(String[] actnOwnr,Map<String,List<String>> APOC,Id bpmId){
        for(String str : actnOwnr){
            if(APOC!=null&&APOC.containskey(str)){
                if(!bpmIDWithUserMap.containskey(bpmId)){
                    bpmIDWithUserMap.put(bpmId,new Map<String,Set<String>>());
                    bpmIDWithUserMap.get(bpmId).put(str,new Set<String>());
                    bpmIDWithUserMap.get(bpmId).get(str).addall(APOC.get(str));
                }
                else{
                    bpmIDWithUserMap.get(bpmId).put(str,new Set<String>());
                    bpmIDWithUserMap.get(bpmId).get(str).addall(APOC.get(str));
                }
           		qlIdInTo.addall(APOC.get(str));
            }
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