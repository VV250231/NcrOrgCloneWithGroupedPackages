public class HierarchyInitialSetup implements Database.Batchable<SObject> {
    final Set<String> avlRecTypes = new Set<String>{Label.RT_Acc_Enterprise, Label.RT_Acc_Customer, Label.RT_Acc_Partner};
    public Database.queryLocator start(Database.BatchableContext bc) {
        return Database.getqueryLocator([SELECT Id, From_Party_Number__c, To_Party_Number__c, Relationship_Name__c, 
                                         Relationship_Code__c,Relationship_Status__c,Start_Date__c,End_Date__c, 
                                         RelatedParty_Retry_Count__c, IsProcessed__c
                                         FROM Hierarchy_Relation__c WHERE IsProcessed__c = false]);
    }
    
    public void execute(Database.BatchableContext bc, List<Hierarchy_Relation__c> relList) {
        
        Account parentAccount;
        Hierarchy_Relation__c rel;
        Boolean parentNotfoundRetry = false;
        Set<String> retryAccIds = new Set<String>();
        List<String> errLst = new List<string>();
        String EPPrtyNbr = null;
        Boolean recalcHrchy = false;
        
        CheckRecursive.checkOppOrgUpdtBtchRun(); 
        
        if(!relList.isEmpty()) rel = relList.get(0);
        
        if(rel != NULL && rel.Relationship_Name__c.equalsIgnoreCase('Domestic Ultimate')) {
            if(String.isNotBlank(rel.From_Party_Number__c) && String.isNotBlank(rel.To_Party_Number__c)) {
                Account exstFromCst = getExistCstmrDetail(rel.From_Party_Number__c); 
                String DU_DUNSNbr = rel.To_Party_Number__c;
                
                 if (exstFromCst != NULL && (exstFromCst.DUNS__c != DU_DUNSNbr &&  (exstFromCst.Domestic_Ultimate_Lookup__c == NULL || exstFromCst.Domestic_Ultimate_Lookup__r.DUNS__c != DU_DUNSNbr))) {
                    List<Account> prntDUCstmr = UpdateAccountGlobalUltimate.getPrntCstmrAccts(null, DU_DUNSNbr); 
                    
                    if(!prntDUCstmr.isEmpty()) {
                        exstFromCst.Domestic_Ultimate_Lookup__c = prntDUCstmr.get(0).Id; 
                        update exstFromCst;
                    } else {
                        rel.RelatedParty_Retry_Count__c = rel.RelatedParty_Retry_Count__c + 1;
                        rel.Error__c = 'DU DUNS# not found';
                        // retry for parent Account and throw error after certain retry attempts
                    }
                }     
            }
        }
        
        if(rel != NULL && rel.Relationship_Name__c.equalsIgnoreCase('Enterprise Parent') && rel.Relationship_Code__c.equalsIgnoreCase('Enterprise Child of')) {
            if(String.isNotBlank(rel.From_Party_Number__c) && String.isNotBlank(rel.To_Party_Number__c)) {
                Account exstFromCst = getExistCstmrDetail(rel.From_Party_Number__c);
                
                if(exstFromCst != NULL) {
                    if(exstFromCst.ParentId != null) {
                        if(rel.End_Date__c <= Date.today() || rel.Relationship_Status__c != 'A') {
                            if (rel.To_Party_Number__c == exstFromCst.Parent.Customer_Number__c) {   
                                populateEPFields(exstFromCst, rel, true);  // clear all Enterprise Parent fields
                                recalcHrchy = true;
                            } 
                            
                            // if relationship change, use relationship with later end date as active relation    
                        } else if (rel.To_Party_Number__c != exstFromCst.Parent.Customer_Number__c && rel.End_Date__c > exstFromCst.cdm_Enterprise_Parent_End_Date__c) {   
                            EPPrtyNbr = rel.To_Party_Number__c;
                            recalcHrchy = true;
                        }  
                    } else {                     
                        EPPrtyNbr = rel.To_Party_Number__c;
                        recalcHrchy = true;
                    }
                }
                
                if (recalcHrchy) {
                    if (String.isNotBlank(EPPrtyNbr)) {
                        List<Account> prntAcct = UpdateAccountGlobalUltimate.getPrntCstmrAccts(EPPrtyNbr, null);
                        
                        if(prntAcct != NULL && prntAcct.size() > 0) {
                            exstFromCst.ParentId = prntAcct.get(0).Id; 
                            exstFromCst.Global_Ultimate_Lookup__c = (prntAcct.get(0).Global_Ultimate_Lookup__c != null ? prntAcct.get(0).Global_Ultimate_Lookup__c : prntAcct.get(0).Id); 
                            populateEPFields(exstFromCst, rel, false);
                        } else {
                            rel.RelatedParty_Retry_Count__c = rel.RelatedParty_Retry_Count__c + 1;
                            rel.Error__c = 'Parent not found';
                            update rel;
                            parentNotfoundRetry = true;  //parent not found, add retry logic
                        }
                    }
                    
                    if (!parentNotfoundRetry) {
                        update exstFromCst; 
                        parentAccount = exstFromCst;
                        updateHierarchy(parentAccount);                                   
                        
                    } 
                } 
                
                
                
            } 
        }
        
        // mark processed and execute next
        if(rel != null) { 
            rel.IsProcessed__c = true;
            update rel;
        }  
        
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    
    
    public Account getExistCstmrDetail(String cstmrNbr) {
        Account cstmr = null;
        if (String.isNotBlank(cstmrNbr)) {
            List<Account> cstmrLst = [SELECT Id, Customer_Number__c, ParentId, DUNS__c, 
                                      Parent.Customer_Number__c, cdm_Enterprise_Parent_End_Date__c,
                                      Global_Ultimate_Lookup__c, Global_Ultimate_Lookup__r.DUNS__c,
                                      Domestic_Ultimate_Lookup__c, Domestic_Ultimate_Lookup__r.DUNS__c
                                      FROM Account WHERE Customer_Number__c = :cstmrNbr LIMIT 1];
            if(!cstmrLst.isEmpty()) cstmr = cstmrLst.get(0);
        }
        return cstmr;
    }
    
    public void populateEPFields(Account updCstmr, Hierarchy_Relation__c entPrntRel, Boolean isClearEP) {
        if (isClearEP) {
            updCstmr.ParentId = null;
            updCstmr.Global_Ultimate_Lookup__c = null;
            updCstmr.cdm_Enterprise_Parent_Start_Date__c = null;
            updCstmr.cdm_Enterprise_Parent_End_Date__c = null;
            updCstmr.cdm_Enterprise_Parent_Number__c = '';
            updCstmr.cdm_Enterprise_Parent_Status__c = '';    
        } else {
            updCstmr.cdm_Enterprise_Parent_Start_Date__c = entPrntRel.Start_Date__c;
            updCstmr.cdm_Enterprise_Parent_End_Date__c = entPrntRel.End_Date__c;
            updCstmr.cdm_Enterprise_Parent_Number__c = entPrntRel.To_Party_Number__c;
            updCstmr.cdm_Enterprise_Parent_Status__c = (entPrntRel.Relationship_Status__c != NULL && entPrntRel.Relationship_Status__c == 'A') ? 'Active' : 'Inactive';         
        }
    }
    
    public void updateHierarchy(Account parentAccount) {
        
        Set<Id> parentAcctIds = new Set<Id>{parentAccount.Id};
            Set<Id> childAcctIds = new Set<Id>();
        Map<Id, Account> childAccMap = new Map<Id, Account>();
        
        UpdateAccountGlobalUltimate.ChildAccounts(childAccMap,parentAcctIds,childAcctIds);
        
        if(!childAcctIds.isEmpty()) {
            
            List<Account > childAccList = [SELECT Id, Customer_Number__c, Global_Ultimate_Lookup__c FROM Account WHERE RecordType.Name IN :avlRecTypes AND Id IN :childAcctIds];
            
            for (Account acc : childAccList ) {
                acc.Global_Ultimate_Lookup__c = (parentAccount.Global_Ultimate_Lookup__c != NULL) ? parentAccount.Global_Ultimate_Lookup__c : parentAccount.Id;
            }
            
            update childAccList;
            
        }
    }
}