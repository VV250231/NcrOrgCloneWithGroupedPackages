public class UpdateAccountGlobalUltimate implements Database.Batchable<SObject>, Database.Stateful {
    Account parentAccount;
    Hierarchy_Relation__c rel;
    String scoreSchedulerId;
    Boolean parentNotfoundRetry = false;
    Set<String> retryAccIds = new Set<String>();
    List<String> errLst = new List<string>();
    final Set<String> avlRecTypes = new Set<String>{Label.RT_Acc_Enterprise, Label.RT_Acc_Customer, Label.RT_Acc_Partner};
        
    public UpdateAccountGlobalUltimate(String schedulejobID) {
        scoreSchedulerId = schedulejobID;
    }
    
    public UpdateAccountGlobalUltimate() {
               System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
  
    public Database.queryLocator start(Database.BatchableContext bc) {
        Set<Id> parentAcctIds = new Set<Id>{parentAccount.Id};
            Set<Id> childAcctIds = new Set<Id>();
        Map<Id, Account> childAccMap = new Map<Id, Account>();
        
        CheckRecursive.checkOppOrgUpdtBtchRun(); // avoid Accounr Service now future call
        
        ChildAccounts(childAccMap,parentAcctIds,childAcctIds); // Recursive function to avoid soql in for loop 
        
        //system.debug('@@@@s21'+childAcctIds);
        //system.debug(childAcctIds.size());
        
        return Database.getqueryLocator([SELECT Id, Customer_Number__c, Global_Ultimate_Lookup__c FROM Account WHERE RecordType.Name IN :avlRecTypes AND Id IN :childAcctIds]);
    }
    
     public void execute(Database.BatchableContext bc, List<Account> accLst) {
         for (Account acc : accLst) {
            acc.Global_Ultimate_Lookup__c = (parentAccount.Global_Ultimate_Lookup__c != NULL) ? parentAccount.Global_Ultimate_Lookup__c : parentAccount.Id;
         }
         
         Database.SaveResult[] results = Database.update(accLst,false);
         integer j=0;
         
         if (results != null) {
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        Database.Error[] errs = sr.getErrors();
                        for(Database.Error err : errs) {
                            if (err.getStatusCode() == System.StatusCode.UNABLE_TO_LOCK_ROW) {
                                retryAccIds.add(accLst[j].Id);   
                            } else {  
                                errLst.add('Global Ultimate Update failed for Enterprise Account :' + accLst[j].Customer_Number__c +' due to Error: '+err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                    j++;
                }
            }
     }
    
     public void finish(Database.BatchableContext bc) {
         markRelAsPrcssd(); 
     }
    
    public static void ChildAccounts(Map<Id, Account> childAccMap, Set<Id> parentAcctIds,Set<Id> childAcctIds)
    { 
        final Set<String> avlRecTypes1 = new Set<String>{Label.RT_Acc_Enterprise, Label.RT_Acc_Customer, Label.RT_Acc_Partner};
            childAccMap = new Map<Id, Account>([SELECT Id, Customer_Number__c from Account where RecordType.Name IN :avlRecTypes1 AND (ParentId IN :parentAcctIds or Parent.ParentId IN :parentAcctIds) and Id Not IN :parentAcctIds]);
        
        if (childAccMap.isEmpty())
        {
                    System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
        }
        else
        {
            parentAcctIds.clear();
            parentAcctIds.addAll(childAccMap.keySet()); 
            childAcctIds.addAll(childAccMap.keySet());
            ChildAccounts(childAccMap,parentAcctIds,childAcctIds);
        }
    } 
    
     public void processRelation() {
        String EPPrtyNbr = null;
        Boolean recalcHrchy = false;
         
        List<Hierarchy_Relation__c> relList = [SELECT Id, From_Party_Number__c, To_Party_Number__c, Relationship_Name__c, 
                                              Relationship_Code__c,Relationship_Status__c,Start_Date__c,End_Date__c, 
                                              RelatedParty_Retry_Count__c, ROR_Update_Date_Time__c, IsProcessed__c
                                              FROM Hierarchy_Relation__c WHERE IsProcessed__c = false 
                                              ORDER BY CreatedDate Asc LIMIT 1];
        
        if(!relList.isEmpty()) this.rel = relList.get(0);
         
         if(this.rel != NULL && rel.Relationship_Name__c.equalsIgnoreCase('Domestic Ultimate')) {
            if(String.isNotBlank(rel.From_Party_Number__c) && String.isNotBlank(rel.To_Party_Number__c)) {
                Account exstFromCst = getExistCstmrDetail(rel.From_Party_Number__c); 
                String DU_DUNSNbr = rel.To_Party_Number__c;
                
               if (exstFromCst != NULL && (exstFromCst.DUNS__c != DU_DUNSNbr &&  (exstFromCst.Domestic_Ultimate_Lookup__c == NULL || exstFromCst.Domestic_Ultimate_Lookup__r.DUNS__c != DU_DUNSNbr))) {
                    List<Account> prntDUCstmr = getPrntCstmrAccts(null, DU_DUNSNbr); 
                    
                    if(!prntDUCstmr.isEmpty()) {
                        exstFromCst.Domestic_Ultimate_Lookup__c = prntDUCstmr.get(0).Id;   
                    } else {
                        rel.RelatedParty_Retry_Count__c = rel.RelatedParty_Retry_Count__c + 1;
                        rel.Error__c = 'DU DUNS# not found';
                        // retry for parent Account and throw error after certain retry attempts
                    }
                }     
            }
         }
        
        if(this.rel != NULL && rel.Relationship_Name__c.equalsIgnoreCase('Enterprise Parent') && rel.Relationship_Code__c.equalsIgnoreCase('Enterprise Child of')) {
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
                        List<Account> prntAcct = getPrntCstmrAccts(EPPrtyNbr, null);
                        
                        if(!prntAcct.isEmpty()) {
                            exstFromCst.ParentId = prntAcct.get(0).Id; 
                            exstFromCst.Global_Ultimate_Lookup__c = (prntAcct.get(0).Global_Ultimate_Lookup__c != null ? prntAcct.get(0).Global_Ultimate_Lookup__c : prntAcct.get(0).Id); 
                            populateEPFields(exstFromCst, rel, false);
                        } else {
                            rel.RelatedParty_Retry_Count__c = rel.RelatedParty_Retry_Count__c + 1;
                            update rel;
                            parentNotfoundRetry = true;  //parent not found, add retry logic
                        }
                    }
                    
                    if (!parentNotfoundRetry) {
                        Database.SaveResult result = Database.update(exstFromCst);                                    
                        if (!result.isSuccess()) {                           
                            for(Database.Error err : result.getErrors()) {
                                if (err.getStatusCode() == System.StatusCode.UNABLE_TO_LOCK_ROW) {
                                    //retryAccIds.add(accLst[j].Id);   
                                    //retry same relationship
                                    System.debug(err.getMessage());
                                }     
                            }
                        } else {
                            this.parentAccount = exstFromCst;
                            Database.executeBatch(this, 20);  
                        }
                    } else {
                        // retry same relationship
                        markRelAsPrcssd();
                    }
                } else {
                    // if no need to recalculate then mark relation as processed
                    markRelAsPrcssd();      
                }
            } 
        }
         
          markRelAsPrcssd(); 
     }
    
     public static Account getExistCstmrDetail(String cstmrNbr) {
        Account cstmr = null;
        if (String.isNotBlank(cstmrNbr)) {
            List<Account> cstmrLst = [SELECT Id, Customer_Number__c, ParentId, DUNS__c, RoR_Update_Date_Time__c, 
                                          Parent.Customer_Number__c, cdm_Enterprise_Parent_End_Date__c,
                                          Global_Ultimate_Lookup__c, Global_Ultimate_Lookup__r.DUNS__c,
                                          Domestic_Ultimate_Lookup__c, Domestic_Ultimate_Lookup__r.DUNS__c
                                          FROM Account WHERE Customer_Number__c = :cstmrNbr LIMIT 1 FOR UPDATE];
            if(!cstmrLst.isEmpty()) cstmr = cstmrLst.get(0);
        }
        return cstmr;
    }
    
     // Query Enterprise Parent or DU Customer
    public static List<Account> getPrntCstmrAccts(String EPPrtyNbr, String dmstcDUNS) {
        String cstmrQuery = 'SELECT Id, DUNS__c, Customer_Number__c, Global_Ultimate_Lookup__c FROM Account WHERE RecordType.Name = \'Enterprise\'';
        
        if (String.isNotBlank(EPPrtyNbr) && String.isNotBlank(dmstcDUNS)) {
            cstmrQuery += ' AND (DUNS__c = :dmstcDUNS OR Customer_Number__c = :EPPrtyNbr)';      
        } else if(String.isNotBlank(EPPrtyNbr)) {
            cstmrQuery += ' AND Customer_Number__c = :EPPrtyNbr';        
        } else if(String.isNotBlank(dmstcDUNS)) {
            cstmrQuery += ' AND DUNS__c = :dmstcDUNS';     
        } 
        return (List<Account>) Database.query(cstmrQuery);
    }
    
     public static void populateEPFields(Account updCstmr, Hierarchy_Relation__c entPrntRel, Boolean isClearEP) {
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
    
    public void markRelAsPrcssd() {
         if(this.rel != null) {
             rel.IsProcessed__c = true;
             update rel;
         }  
     
        if (!Test.isRunningTest() && String.isNotBlank(scoreSchedulerId)) {
            System.abortJob(scoreSchedulerId); // aborting current scheduled job
            System.debug(scoreSchedulerId);
            List<CronTrigger> ctLst =  [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :scoreSchedulerId];
            System.debug(ctLst);
        }
        
        
         Integer openRelCount = [SELECT count() FROM Hierarchy_Relation__c WHERE IsProcessed__c = false];
         
        if (!Test.isRunningTest() && openRelCount > 0) {
          Datetime nextSchdTime = Datetime.now().addMinutes(1);                 
          System.schedule('Account Hierarchy Calculation', '0 ' + nextSchdTime.minute() + ' ' + nextSchdTime.hour() + ' ' + nextSchdTime.day() + ' ' +  nextSchdTime.format('MMM').toUpperCase() + ' ? ' + nextSchdTime.year(), new ScheduleAccountGUUpdate());
        }
    }
}