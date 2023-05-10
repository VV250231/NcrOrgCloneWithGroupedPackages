/*
####################################################################################################################
# Project Name..........: NSC CRM 2016                                                                                                                            
# File............................:updateSalesOrgTableTest.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 23-12-2016                                                                                  
# Last Modified by......: Mudasir Rashid                                                                             
# Last Modified Date..: 23-12-2016                                                                                 
# Description...............: This is the test class of trigger updateSalesOrgTable.trigger
# Jira Story Number.........: NSCI_AGILE-2810   
####################################################################################################################
*/
@isTest
Private Class updateSalesOrgTableTest{
    Private static testmethod void myTest(){
        Sales_Org_Temp__c  sotemp =new Sales_Org_Temp__c();
            sotemp.Name = 'Test';
            sotemp.Sales_Org_Code__c = '123456789';
            sotemp.Corporate_Name__c  = 'Test';
            sotemp.Functional_Group__c = 'Test';
            sotemp.Org_Code_Country_Code__c = 'US';
            sotemp.RoR_Update_Date__c = system.today();
            sotemp.Is_Active_in_RoR__c = true;
            sotemp.solution_Portfolio__c = 'RT';
            sotemp.Hierarchy_1__c = 'Test Hierarchy';
            sotemp.Hierarchy_2__c = 'Test Hierarchy';
            sotemp.Hierarchy_3__c = 'Test Hierarchy';
            sotemp.Hierarchy_4__c = 'Test Hierarchy';
            sotemp.Hierarchy_5__c = 'Test Hierarchy';
            sotemp.Hierarchy_6__c = 'Test Hierarchy';
            sotemp.Hierarchy_7__c = 'Test Hierarchy';
            sotemp.Hierarchy_8__c = 'Test Hierarchy';
            sotemp.Hierarchy_9__c = 'Test Hierarchy';
            sotemp.Hierarchy_10__c = 'Test Hierarchy';
            insert sotemp;
            
          Sales_Org_Temp__c  sotemp2 = [Select Id,Corporate_Name__c,Functional_Group__c,Org_Code_Country_Code__c,RoR_Update_Date__c,Sales_Org_Code__c,Solution_Portfolio__c,Hierarchy_1__c,Hierarchy_2__c,Hierarchy_3__c,Hierarchy_4__c,Hierarchy_5__c,Hierarchy_6__c,Hierarchy_7__c,Hierarchy_8__c,Hierarchy_9__c,Hierarchy_10__c from Sales_Org_Temp__c  where Sales_Org_Code__c = :sotemp.Sales_Org_Code__c ];
            sotemp2.Corporate_Name__c  = 'Test2';
            sotemp2.Functional_Group__c = 'Test2';
            sotemp2.Org_Code_Country_Code__c = 'CA';
            sotemp2.RoR_Update_Date__c = system.today();
            sotemp2.Is_Active_in_RoR__c = true;
            sotemp2.solution_Portfolio__c = 'FN';
            sotemp2.Hierarchy_1__c = 'Test Hierarchy1';
            sotemp2.Hierarchy_2__c = 'Test Hierarchy2';
            sotemp2.Hierarchy_3__c = 'Test Hierarchy3';
            sotemp2.Hierarchy_4__c = 'Test Hierarchy4';
            sotemp2.Hierarchy_5__c = 'Test Hierarchy5';
            sotemp2.Hierarchy_6__c = 'Test Hierarchy6';
            sotemp2.Hierarchy_7__c = 'Test Hierarchy7';
            sotemp2.Hierarchy_8__c = 'Test Hierarchy8';
            sotemp2.Hierarchy_9__c = 'Test Hierarchy9';
            sotemp2.Hierarchy_10__c = 'Test Hierarchy10';
            update sotemp2;
        
        Sales_Org__c salesOrgObj = [select id,solution_Portfolio__c from Sales_Org__c limit 1];
        System.assert(salesOrgObj.solution_Portfolio__c=='FN');
    }
}