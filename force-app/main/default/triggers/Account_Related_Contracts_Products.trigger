trigger Account_Related_Contracts_Products on Contract (after insert, after update, after delete,before delete,before update) {
    //CATM Trigger
    
    if (Automation_Setting__c.getInstance().Skip_Trigger__c) {return;}
    Map<Id, Account> updateAccMap =  new Map<Id, Account>();
   
    system.debug('Entered into trigger');
    set<ID>AccIds = new set<ID>();
    //if(Account_Related_ContractsHandler.recursiveFlag==false ){
    //Account_Related_ContractsHandler.recursiveFlag=true ;
    
    if(Trigger.isAfter && (trigger.isinsert)){
        system.debug('Insert');
        List<Contract> newCtrLst = new List<Contract>();
        
        for(Contract contr : trigger.new){
            //If contract is a CT record
            if(contr.CATM_Record__c && (contr.Status == 'Activated' || contr.Status == 'At Risk')) 
                AccIds.add(contr.AccountId);
                
            if(contr.Status == 'Activated' || contr.Status == 'At Risk' && String.isNotBlank(contr.Products__c))
                newCtrLst.add(contr);
            
        }
        system.debug('reached here');
        system.debug(AccIds);
        if(!AccIds.isEmpty())  Account_Related_ContractsHandler.sumCOntracts(AccIds, updateAccMap);  
        if(!newCtrLst.isEmpty())  Account_Related_ContractsHandler.allContractedproducts (newCtrLst, updateAccMap);
    } 
    
    if(Trigger.isAfter && (trigger.isupdate)){ 
        system.debug('Update');
        List<Contract> newCtrLst = new List<Contract>();
        Set<String> ctrSts = new Set<String>{'Activated', 'At Risk'};
        
        for(Contract contr:trigger.new){
            if(contr.CATM_Record__c){
                AccIds.add(contr.AccountId);
                system.debug('AccIds'+AccIds);
                if(trigger.oldmap.get(contr.id).AccountId != null &&trigger.oldmap.get(contr.id).AccountId != contr.AccountId  ){
                    AccIds.add(trigger.oldmap.get(contr.id).AccountId);
                    system.debug('AccIds'+AccIds);
                }
            } 
            
            Contract oldContr = trigger.oldmap.get(contr.id);
            
            if (contr.AccountId != oldContr.AccountId || (contr.Status != oldContr.Status && (ctrSts.contains(contr.status) || ctrSts.contains(oldContr.Status))) || contr.Products__c != oldContr.Products__c) {
                newCtrLst.add(contr);       
            }
        }
        
        if(!AccIds.isEmpty()) Account_Related_ContractsHandler.sumCOntracts(AccIds, updateAccMap);
        if(!newCtrLst.isEmpty()) Account_Related_ContractsHandler.allContractedproducts (newCtrLst, updateAccMap); 
    }
    
    if(trigger.isAfter && (trigger.isdelete || trigger.isundelete)){ 
        for(Contract contr : trigger.old){
            if(contr.CATM_Record__c && (contr.Status == 'Activated' || contr.Status == 'At Risk')) AccIds.add(contr.AccountId);
        } 
        Account_Related_ContractsHandler.sumCOntracts(AccIds, updateAccMap);     
        Account_Related_ContractsHandler.allContractedproducts (Trigger.new, updateAccMap);
    }
    
    //Gray - get count of all active contracts
    if(trigger.isAfter) {
        Set<Id> accIds = new Set<Id>();
        
        if( trigger.isInsert || trigger.isundelete) {
            for(Contract c: trigger.new) {
                if (c.CATM_Record__c) accIds.add(c.AccountId);  
            }    
        }
        else if(trigger.isUpdate) {            
            for(Contract c: trigger.new) {
                if (c.CATM_Record__c != trigger.oldMap.get(c.Id).CATM_Record__c || c.CATM_Record__c==TRUE && c.CATM_NDA__C != trigger.oldMap.get(c.Id).CATM_NDA__C) accIds.add(c.AccountId);   
            }    
            
        } else if( trigger.isdelete) {            
            for(Contract c: trigger.old) {
                if (c.CATM_Record__c) accIds.add(c.AccountId);  
            }    
        }
        
        if(!accIds.isEmpty()) Account_Related_ContractsHandler.countOfContracts(accIds, updateAccMap);
    }
    
    if(!updateAccMap.isEmpty()) {
        list<Database.SaveResult> results = Database.update(updateAccMap.values(),false);
    }
}