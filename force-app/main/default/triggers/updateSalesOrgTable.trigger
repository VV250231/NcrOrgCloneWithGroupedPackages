/*
####################################################################################################################
# Project Name..........: NSC CRM 2016                                                                                                                            
# File............................:updateSalesOrgTable.trigger                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 16-12-2016                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 08-09-2017                                                                                 
# Description...............: This trigger updates the Sales Org object based on the new mapping received from DRM via iPaaS.
# Jira Story Number.........: NSCI_AGILE-2810   
####################################################################################################################
*/
trigger updateSalesOrgTable on Sales_Org_Temp__c (after update,after insert) {

    Set<String> oldOrgCodes = new Set<String>();
    Map<String, Sales_Org_Temp__c> orgcodeTempMap = new Map<String, Sales_Org_Temp__c>();
   
    
    for(Sales_Org_Temp__c  so : trigger.new) {
        if(so.Sales_Org_Code__c != null){
            orgcodeTempMap.put(so.Sales_Org_Code__c, so);
        }
    }
    
    if(!orgcodeTempMap.isEmpty()) {
    
    List<Sales_Org__c> salesOrgRecords = new List<Sales_Org__c >([Select Id,Corporate_Name__c,Functional_Group__c,Org_Code_Country_Code__c,RoR_Update_Date__c,Sales_Org_Code__c,Solution_Portfolio__c,Hierarchy_1__c,Hierarchy_2__c,Hierarchy_3__c,Hierarchy_4__c,Hierarchy_5__c,Hierarchy_6__c,Hierarchy_7__c,Hierarchy_8__c,Hierarchy_9__c,Hierarchy_10__c,Industry_Channel__c,DCode_1__c,DCode_2__c,DCode_3__c,DCode_4__c,DCode_5__c,DCode_6__c,DCode_7__c,DCode_8__c,DCode_9__c,DCode_10__c from Sales_Org__c where Sales_Org_Code__c IN :orgcodeTempMap.keySet()]);
    
    
    if(!salesOrgRecords.isEmpty()) {
        for(Sales_Org__c rec :salesOrgRecords) {
            Sales_Org_Temp__c sotemp = orgcodeTempMap.get(rec.Sales_Org_Code__c);
            
            if(sotemp != null) {
                rec.Corporate_Name__c = sotemp.Corporate_Name__c;
                rec.Functional_Group__c= sotemp.Functional_Group__c;
                rec.Org_Code_Country_Code__c= sotemp.Org_Code_Country_Code__c;
                rec.RoR_Update_Date__c= sotemp.RoR_Update_Date__c;
                rec.Is_Active_in_RoR__c = sotemp.Is_Active_in_RoR__c;
                rec.Solution_Portfolio__c = sotemp.Solution_Portfolio__c;
                rec.Hierarchy_1__c = sotemp.Hierarchy_1__c;
                rec.Hierarchy_2__c = sotemp.Hierarchy_2__c;
                rec.Hierarchy_3__c = sotemp.Hierarchy_3__c;
                rec.Hierarchy_4__c = sotemp.Hierarchy_4__c;
                rec.Hierarchy_5__c = sotemp.Hierarchy_5__c;
                rec.Hierarchy_6__c = sotemp.Hierarchy_6__c;
                rec.Hierarchy_7__c = sotemp.Hierarchy_7__c;
                rec.Hierarchy_8__c = sotemp.Hierarchy_8__c;
                rec.Hierarchy_9__c = sotemp.Hierarchy_9__c;
                rec.Hierarchy_10__c = sotemp.Hierarchy_10__c;
                rec.Industry_Channel__c= sotemp.Industry_Channel__c;
                
                rec.DCode_1__c= sotemp.DCode_1__c;
                rec.DCode_2__c= sotemp.DCode_2__c;
                rec.DCode_3__c= sotemp.DCode_3__c;
                rec.DCode_4__c= sotemp.DCode_4__c;
                rec.DCode_5__c= sotemp.DCode_5__c;
                rec.DCode_6__c= sotemp.DCode_6__c;
                rec.DCode_7__c= sotemp.DCode_7__c;
                rec.DCode_8__c= sotemp.DCode_8__c;
                rec.DCode_9__c= sotemp.DCode_9__c;
                rec.DCode_10__c= sotemp.DCode_10__c;
                
                
                oldOrgCodes.add(rec.Sales_Org_Code__c);
            } 
        }
        update salesOrgRecords;
        
        for(String orgCode : oldOrgCodes) {
            orgcodeTempMap.remove(orgCode);
        }
    }
    
    User nscAdminUser;
    
    if(!orgcodeTempMap.isEmpty()) {
        List<User> nscAdminUserList = [SELECT Id, Quicklook_ID__c FROM USER WHERE Quicklook_ID__c = 'nscadmin' LIMIT 1];
        
        if(!nscAdminUserList.isEmpty() ) {
            nscAdminUser = nscAdminUserList.get(0);
        }
    }
    
        List<Sales_Org__c> newSalesOrgsList = new List<Sales_Org__c>();
        
        for(Sales_Org_Temp__c  sotemp : orgcodeTempMap.values()) {
            Sales_Org__c so = new Sales_Org__c();
            so.Name = sotemp.Corporate_Name__c;
            so.Sales_Org_Code__c = sotemp.Sales_Org_Code__c;
            so.Corporate_Name__c  = sotemp.Corporate_Name__c;
            so.Functional_Group__c = sotemp.Functional_Group__c;
            so.Org_Code_Country_Code__c= sotemp.Org_Code_Country_Code__c;
            so.RoR_Update_Date__c = sotemp.RoR_Update_Date__c;
            so.Is_Active_in_RoR__c = sotemp.Is_Active_in_RoR__c;
            so.Solution_Portfolio__c = sotemp.Solution_Portfolio__c;
            so.Hierarchy_1__c = sotemp.Hierarchy_1__c;
            so.Hierarchy_2__c = sotemp.Hierarchy_2__c;
            so.Hierarchy_3__c = sotemp.Hierarchy_3__c;
            so.Hierarchy_4__c = sotemp.Hierarchy_4__c;
            so.Hierarchy_5__c = sotemp.Hierarchy_5__c;
            so.Hierarchy_6__c = sotemp.Hierarchy_6__c;
            so.Hierarchy_7__c = sotemp.Hierarchy_7__c;
            so.Hierarchy_8__c = sotemp.Hierarchy_8__c;
            so.Hierarchy_9__c = sotemp.Hierarchy_9__c;
            so.Hierarchy_10__c = sotemp.Hierarchy_10__c;
            so.Industry_Channel__c= sotemp.Industry_Channel__c;
            
            so.DCode_1__c= sotemp.DCode_1__c;
            so.DCode_2__c= sotemp.DCode_2__c;
            so.DCode_3__c= sotemp.DCode_3__c;
            so.DCode_4__c= sotemp.DCode_4__c;
            so.DCode_5__c= sotemp.DCode_5__c;
            so.DCode_6__c= sotemp.DCode_6__c;
            so.DCode_7__c= sotemp.DCode_7__c;
            so.DCode_8__c= sotemp.DCode_8__c;
            so.DCode_9__c= sotemp.DCode_9__c;
            so.DCode_10__c= sotemp.DCode_10__c;
            
            so.OwnerId = nscAdminUser.Id;
            so.IsPrimary__c = true;
            
            newSalesOrgsList.add(so);
        }
        
        if(!newSalesOrgsList.isEmpty()) {
            insert newSalesOrgsList;
        }
    }
    
}