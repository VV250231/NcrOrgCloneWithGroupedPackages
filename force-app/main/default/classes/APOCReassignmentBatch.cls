/*
##################################################################################################
# Project Name..........: Account Point Of Contact(APOC)
# File............................: APOCReassignmentBatch.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 02/26/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 02/26/2020 (MM/DD/YYYY)
# Description...............: This class is used for reassigning APOC record from inactive user to active user
if there is an upgrade or downgrade(same quicklookid of user)
# JIRA Story - #EBA_SF-1092(P1: APOC: APOC record re-assignment automation) 
# test class -UserUpDownTest
##################################################################################################
*/

public class APOCReassignmentBatch implements Database.Batchable<sObject>, Database.Stateful,schedulable {
    public  Id uid;
    public APOCReassignmentBatch(){system.debug('Base');}
    public APOCReassignmentBatch(Id uid){
        this.uid = uid;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(uid!=null){
            return Database.getQueryLocator('Select id,QuickLook_ID__c,Role_User_Name__c,Role_User_Qlook_Id__c,account__c,role_name__c from ASM_Role_Hierarchy__c where Role_User_Name__c = :uid');
        }else{
        	return Database.getQueryLocator('Select id,QuickLook_ID__c,Role_User_Name__c,Role_User_Qlook_Id__c,account__c,role_name__c from ASM_Role_Hierarchy__c where Role_User_Name__r.isactive= false and ncr_employee_detail__c!=null');    
        }
    }
    //String msg=' ';
    public void execute(Database.BatchableContext BC, List<ASM_Role_Hierarchy__c> scope){
        Set<String> qlSet = new Set<String>();
        List<ASM_Role_Hierarchy__c> roles = new List<ASM_Role_Hierarchy__c>();
        //Store all the records in roles(list) and qlid in a set for which QuickLook_ID__c(text field) and Role_User_Qlook_Id__c(formula field) are not same and it is associated to an account
        for(ASM_Role_Hierarchy__c a : scope){
            if(a.Role_User_Qlook_Id__c!=null && a.account__c!=null){
                if(a.Role_User_Qlook_Id__c!=a.QuickLook_ID__c && !(a.Role_User_Qlook_Id__c.contains('-'))){
                    a.QuickLook_ID__c = a.Role_User_Qlook_Id__c;
                }
                qlSet.add(a.QuickLook_ID__c);
                roles.add(a);
            }               
        }
        //get all the active users for the quicklookId where there is an upgrade or downgrade
        Map<String,User> qlUserMap = new Map<String,User>();
        for(User u : [Select id,QuickLook_ID__c,Name from User where quicklook_id__c in:qlSet and Isactive=true and usertype!='csnonly']){
            qlUserMap.put(u.QuickLook_ID__c.tolowerCase(),u);
        }
        for(ASM_Role_Hierarchy__c a : roles){
            if(qlUserMap.get(a.QuickLook_ID__c.tolowerCase())!=null){
                a.Role_User_Name__c = qlUserMap.get(a.QuickLook_ID__c.tolowerCase()).id;
            }
        }
        APOC_MassUpdateAllRolesHandler.stopNotification = true;
        APOC_MassUpdateAllRolesHandler.runonce = false;
        database.update(roles,false);
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new APOCReassignmentBatch());
    }
    public void finish(Database.BatchableContext BC){
        /*if(msg.contains('Failed')){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(BPM_Configuration__c.getValues('CAHierarchyJobReciever').values__c.split(','));
            mail.setOrgWideEmailAddressId('0D270000000XZHr');
            mail.setPlainTextBody(msg);
            mail.setSubject('APOCReassignmentBatch Job Failed');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
                    });
        }*/
        system.debug('Base');
    }
}