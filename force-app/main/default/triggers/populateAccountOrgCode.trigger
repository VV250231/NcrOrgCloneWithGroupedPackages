trigger populateAccountOrgCode on Sales_Org__c (before insert, before update, before delete, after insert) {
  
    if (Trigger.isBefore) {
        Set<String> prmrySalesOrgCodeSet = new Set<String>();
        Map<String, Sales_Org__c> prmrySalesOrgCodeVsIdMap = new Map<String, Sales_Org__c>();
        Map<String, Sales_Org__c> nonPrmrySalesOrgCodeVsIdMap = new Map<String, Sales_Org__c>();
        Set<Id> salesOrgIds = new Set<Id>();
       
        
        if (Trigger.isInsert) {
            
            for (Sales_Org__c so : Trigger.new) {       
                if (so.IsPrimary__c && String.isNotBlank(so.Sales_Org_Code__c)) {
                    if(prmrySalesOrgCodeSet.contains(so.Sales_Org_Code__c)) {
                        so.addError(string.format(system.label.popAccOrgCd2 , new list<string>{so.Sales_Org_Code__c}));//Other Primary Sales Org Record for Sales Org Code ' + so.Sales_Org_Code__c + ' found in inserted data
                        
                        if (prmrySalesOrgCodeVsIdMap.containsKey(so.Sales_Org_Code__c)) {
                            prmrySalesOrgCodeVsIdMap.get(so.Sales_Org_Code__c).addError(string.format(system.label.popAccOrgCd2 , new list<string>{so.Sales_Org_Code__c})); //Other Primary Sales Org Record for Sales Org Code ' + so.Sales_Org_Code__c + ' found in inserted data
                            prmrySalesOrgCodeVsIdMap.remove(so.Sales_Org_Code__c);
                        }                                                                                                                                                           
                    } else {
                        prmrySalesOrgCodeSet.add(so.Sales_Org_Code__c);
                        prmrySalesOrgCodeVsIdMap.put(so.Sales_Org_Code__c, so);
                    }
                }
            }
            
            Map<String, Sales_Org__c> noPrmryInputSOMap = new Map<String, Sales_Org__c>();
            
            for (Sales_Org__c so : Trigger.new) {
                if(String.isNotBlank(so.Sales_Org_Code__c) && !prmrySalesOrgCodeSet.contains(so.Sales_Org_Code__c)) {
                    noPrmryInputSOMap.put(so.Sales_Org_Code__c, so);
                }
            } 
            
            if(!noPrmryInputSOMap.isEmpty()) {
                List<Sales_Org__c> soList = [SELECT Id,Sales_Org_Code__c  from Sales_Org__c WHERE Sales_Org_Code__c IN :noPrmryInputSOMap.keySet() AND IsPrimary__c = true];       
                
                for (Sales_Org__c so : soList) {
                    noPrmryInputSOMap.remove(so.Sales_Org_Code__c);    
                }
            }
            
            for(String soc : noPrmryInputSOMap.keySet()) {
                noPrmryInputSOMap.get(soc).IsPrimary__c = true;
            }
        }
        
        if (Trigger.isUpdate) {
            for(Sales_Org__c so : Trigger.new) {
                if(so.IsPrimary__c != Trigger.oldMap.get(so.Id).IsPrimary__c) {
                    
                    if (so.IsPrimary__c) {
                        if(prmrySalesOrgCodeSet.contains(so.Sales_Org_Code__c)) {
                            so.addError(string.format(system.label.popAccOrgCd1 , new list<string>{so.Sales_Org_Code__c})); //Other Primary Sales Org Record for Sales Org Code ' + so.Sales_Org_Code__c + ' found in updated data. 
                           
                            if (prmrySalesOrgCodeVsIdMap.containsKey(so.Sales_Org_Code__c)) {
                                prmrySalesOrgCodeVsIdMap.get(so.Sales_Org_Code__c).addError(string.format(system.label.popAccOrgCd1 , new list<string>{so.Sales_Org_Code__c})); //Other Primary Sales Org Record for Sales Org Code ' + so.Sales_Org_Code__c + ' found in updated data.
                                prmrySalesOrgCodeVsIdMap.remove(so.Sales_Org_Code__c);
                            }     
                        } else {
                            salesOrgIds.add(so.Id);
                            prmrySalesOrgCodeSet.add(so.Sales_Org_Code__c);
                            prmrySalesOrgCodeVsIdMap.put(so.Sales_Org_Code__c, so);
                            if(nonPrmrySalesOrgCodeVsIdMap.containsKey(so.Sales_Org_Code__c)) nonPrmrySalesOrgCodeVsIdMap.remove(so.Sales_Org_Code__c);
                        }
                    } else if (!so.IsPrimary__c) {  
                        salesOrgIds.add(so.Id);
                        
                        if(!prmrySalesOrgCodeSet.contains(so.Sales_Org_Code__c)) {
                            nonPrmrySalesOrgCodeVsIdMap.put(so.Sales_Org_Code__c, so);    
                        } 
                    }     
                }       
            }     
        } 
        
        
        
        if(Trigger.isInsert  || Trigger.isUpdate) {
   
            if(!prmrySalesOrgCodeVsIdMap.isEmpty() || !nonPrmrySalesOrgCodeVsIdMap.isEmpty()) {
                
                List<Sales_Org__c> soList = [SELECT Id, Name, Sales_Org_Code__c,IsPrimary__c FROM Sales_Org__c 
                                             WHERE IsPrimary__c = true AND ((Sales_Org_Code__c IN :prmrySalesOrgCodeVsIdMap.keySet() 
                                             AND Id Not IN :salesOrgIds) OR (Sales_Org_Code__c IN :nonPrmrySalesOrgCodeVsIdMap.keySet() AND Id Not IN :salesOrgIds))]; 
               
    
                for (Sales_Org__c so : soList) {
                    if (prmrySalesOrgCodeVsIdMap.containsKey(so.Sales_Org_Code__c))  {
                        prmrySalesOrgCodeVsIdMap.get(so.Sales_Org_Code__c).addError(string.format(system.label.popAccOrgCd5 , new list<string>{so.Sales_Org_Code__c}));//Other Primary Sales Org Record for Sales Org Code ' + so.Sales_Org_Code__c + ' exist in System.    
                    } 
                    
                    if (nonPrmrySalesOrgCodeVsIdMap.containsKey(so.Sales_Org_Code__c)) {
                        nonPrmrySalesOrgCodeVsIdMap.remove(so.Sales_Org_Code__c);  
                    }
                } 
                 
                if (!nonPrmrySalesOrgCodeVsIdMap.isEmpty()) {
                    for (String soc : nonPrmrySalesOrgCodeVsIdMap.keySet()) {
                        nonPrmrySalesOrgCodeVsIdMap.get(soc).addError(system.label.popAccOrgCd3); //At least one Sales Org should be assigned as Primary      
                    }
                }
     
            }
        }
        
        if(Trigger.isDelete) {
             for (Sales_Org__c so : Trigger.old) {
                 if(so.IsPrimary__c) {
                     so.addError(system.label.popAccOrgCd4); //Error: Deleted Sales Org Code is Primary.
                 }
             }
        }
    }
  
    if (Trigger.isAfter && Trigger.isInsert) {
        Map<String, String> salesOrgCodeAndIdMap = new  Map<String, String>();
        
        for(Sales_Org__c so : Trigger.new) {
            if(String.isNotBlank(so.Sales_Org_Code__c) && so.IsPrimary__c) salesOrgCodeAndIdMap.put(so.Sales_Org_Code__c,so.Id);
        }
        
        if (!salesOrgCodeAndIdMap.isEmpty()) {
            Database.executeBatch(new UpdateOppSalesOrgCode(salesOrgCodeAndIdMap, 'SalesOrg'), 20);
        }
    }
}