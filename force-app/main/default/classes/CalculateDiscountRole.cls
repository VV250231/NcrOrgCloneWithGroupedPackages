/*
####################################################################################################################
# Project Name..........: NEW CO 2020                                                                                                                        
# File............................:CalculateDiscountRole.cls                                                             
# Created by................: Yogesh Singh                                                                       
# Created Date...........: 19-12-2020                                                                                  
# Last Modified by......: Yogesh Singh                                                                           
# Description...............: This class calculates Discount Role of all users.
####################################################################################################################
*/

global class CalculateDiscountRole implements Database.Batchable < sObject > , Database.Stateful { 
    String email;
    public Map<id, User> uTMap;
    List <String> errLst = new List<string>();  
    Set<Id> uSetIds = new Set<Id>();  
    integer sccssCnt =0, errCnt = 0;
    String errMsg = '';
    
    public CalculateDiscountRole(Map<id, User> uPMap){
        uTMap = uPMap;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        Set<Id> UGIds = new Set<Id>();
        List<User> uList =[Select id,Discount_Role__c,Manager.Discount_Role__c,Manager.Manager.Discount_Role__c,
                           Manager.Manager.Manager.Discount_Role__c, Manager.Manager.Manager.Manager.Discount_Role__c,
                           Manager.Manager.Manager.Manager.Manager.Discount_Role__c, 
                           Manager.Manager.Manager.Manager.Manager.Manager.Discount_Role__c,Manager_Global_Id__c,
                           Manager_Level_01_ID__c,Manager_Level_02_ID__c,Manager_Level_03_ID__c,Manager_Level_04_ID__c,
                           Manager_Level_05_ID__c,Manager_Level_06_ID__c from User where id IN:uTMap.KeySet()];
        for(User u : uList){
            if(u.Discount_Role__c == 'RVP'){
                uSetIds.add(u.Id);
            }else if(u.Manager.Discount_Role__c =='RVP'){
                uSetIds.add(u.Manager.Id);
            }else if(u.Manager.Manager.Discount_Role__c =='RVP'){
                uSetIds.add(u.Manager.Manager.id);
            }else if(u.Manager.Manager.Manager.Discount_Role__c =='RVP'){
                uSetIds.add(u.Manager.Manager.Manager.id);
            }else if(u.Manager.Manager.Manager.Manager.Discount_Role__c =='RVP'){
                uSetIds.add(u.Manager.Manager.Manager.Manager.id);
            }else if(u.Manager.Manager.Manager.Manager.Manager.Discount_Role__c =='RVP'){
                uSetIds.add(u.Manager.Manager.Manager.Manager.Manager.id);
            }else if(u.Manager.Manager.Manager.Manager.Manager.Manager.Discount_Role__c =='RVP'){
                uSetIds.add(u.Manager.Manager.Manager.Manager.Manager.Manager.id);
            }
        }
        return Database.getQueryLocator([Select id,Managerid,Manager_Global_Id__c,Global_Id__c,Manager_Level_01__c,Manager_Level_01_ID__c,Manager_Level_02__c,Manager_Level_02_ID__c,Manager_Level_03__c,Manager_Level_03_ID__c,Manager_Level_04__c,Manager_Level_04_ID__c,Manager_Level_05__c,Manager_Level_05_ID__c,
                                         Manager_Level_06__c,Manager_Level_06_ID__c, 
                                         Name,Discount_Role__c,isActive from User where isActive=true and id IN:uSetIds]);
    }
    global void execute(Database.BatchableContext BC, List <User> usrList) {
        List < User > updateUsrList = new List < User > ();
        Set<String> uGlbId = new Set<String>();
        Set<String> uMId = new Set<String>();
        Map<Id, User> uMap = new Map<Id, User>();
        for(User u : usrList) {
            uMap.put(u.Id, u);
        }
        
        
        String errStr = DiscountRoleOnUserHierarchy.discountRoleOnUser(uMap);
        if(String.isNotEmpty(errStr)) {
            errMsg += errStr;    
        }
       
    }
    global void finish(Database.BatchableContext BC) {
        String[] toAddresses = new String[] {
             'NI230017@ncr.com', 'pb185126@ncr.com', 'ys250288@ncr.com'
        };
     
        String mailBdy = '';
        String mailSub = '', mailHeader = '', mailSubHdr = '';
        
        if (String.isNotEmpty(errMsg)) {
            mailHeader = 'Discount Role Batch Process Failed';
            mailSub = mailHeader;
            mailSubHdr = 'Discount Role Batch Process Failed for below users';
            mailBdy = errMsg;
            
        } else {
            if(!uSetIds.isEmpty()) {
                mailHeader = 'Discount Role Batch Process completed Successfully';
                mailSub = mailHeader;
                mailSubHdr = 'Discount Role Batch Process completed Successfully for below users'; 
                
                List<User> succUsrs = [Select Id, Name from User where Id IN :uTMap.keySet()];
                for (User u : succUsrs) {
                    mailBdy += u.Name + '-' + u.Id + '\n';
                } 
            }
        }
      
        if(String.isNotEmpty(mailHeader)) {
            /*EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
            String EmailBody=template.HtmlValue;            
            CommonUtility.sendEmail(mailSub,mailHeader,mailSubHdr,mailBdy,EmailBody,toAddresses);*/
            EmailUtility.sendEmail(mailSub,mailHeader,mailSubHdr,mailBdy,toAddresses); // EBA_SF-1266
        }
        
    }
}