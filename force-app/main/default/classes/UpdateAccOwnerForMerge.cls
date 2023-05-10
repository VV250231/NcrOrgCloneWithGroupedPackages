public class UpdateAccOwnerForMerge implements Database.Batchable<MergeWrapper>, Database.Stateful {
    List<MergeWrapper> mergeMCNLst;
    Map<Integer, MergeWrapper> mergeItemByIndex;
    List<String> srvAccts;
    
    public UpdateAccOwnerForMerge(List<MergeWrapper> mergeMCNLst) {
      this.mergeMCNLst = mergeMCNLst;
        this.mergeItemByIndex = new Map<Integer, MergeWrapper>();
        integer index = 0;
        
        for(MergeWrapper item : this.mergeMCNLst) {
            item.Index = index;
            this.mergeItemByIndex.put(item.Index, item);  
            index++;
        }        
    }
    
    public Iterable<MergeWrapper> start(Database.BatchableContext bc) {
        return new MergeIterable(mergeMCNLst);          
    }
    
    
    public void execute(Database.BatchableContext bc, List<MergeWrapper> scope) {
        Map<String, Account> mcnAccMap = new Map<String, Account>();
        List<Account> updtAccts = new List<Account>(); 
        List<AccountTeamMember> accTeamMbrLst = new List<AccountTeamMember>();
        
        for(MergeWrapper mw : scope) {
          MergeWrapper mrgItem = this.mergeItemByIndex.get(mw.Index); 
            
            if(String.isNotBlank(mrgItem.vctmMCN) && String.isNotBlank(mrgItem.srcMCN)) {
              mcnAccMap.put(mrgItem.vctmMCN, null);
                mcnAccMap.put(mrgItem.srcMCN, null);
            }
        }
        
        List<Account> accLst = [SELECT Id, Name, Master_Customer_Number__c, OwnerId, Owner.Quicklook_ID__c, 
                                (Select Id, UserId from AccountTeamMembers)
                                FROM ACCOUNT WHERE Master_Customer_Number__c IN :mcnAccMap.keySet()];
        
        for(Account acc : accLst) {
          mcnAccMap.put(acc.Master_Customer_Number__c, acc);    
        }
        
        for(MergeWrapper mw : scope) {
          MergeWrapper mrgItem = this.mergeItemByIndex.get(mw.Index); 
            
            if(String.isNotBlank(mrgItem.vctmMCN) && String.isNotBlank(mrgItem.srcMCN)) {
                Account vctmAcc = mcnAccMap.get(mrgItem.vctmMCN);
                Account srcAcc = mcnAccMap.get(mrgItem.srcMCN);
                
                if(vctmAcc != null && srcAcc != null) {
                  if(vctmAcc.owner.Quicklook_ID__c != 'adminnsc' && vctmAcc.owner.Quicklook_ID__c != 'nscadmin' && srcAcc.ownerId !=  vctmAcc.ownerId) {
                         if(srcAcc.owner.Quicklook_ID__c == 'adminnsc' || srcAcc.owner.Quicklook_ID__c == 'nscadmin') {
                            srcAcc.ownerId =  vctmAcc.ownerId;
                            updtAccts.add(srcAcc);
                             
                         } else {
                             Boolean atmfound = false;
                             
                             if(srcAcc.AccountTeamMembers != null) {
                                 for(AccountTeamMember atm : srcAcc.AccountTeamMembers) {
                                     if(atm.UserId == vctmAcc.ownerId) {
                                       atmfound = true;
                                        break;
                                     }   
                                 }   
                             }
                             
                             if(!atmfound) {
                               AccountTeamMember vctmATM = new AccountTeamMember(UserId=vctmAcc.ownerId, AccountId=srcAcc.Id, TeamMemberRole='Solution Sales Specialist');
                                vctmATM.AccountAccessLevel = 'Edit' ;
                                vctmATM.OpportunityAccessLevel = 'Read';
                                vctmATM.CaseAccessLevel = 'None';
                                accTeamMbrLst.add(vctmATM);
                             }
                         }    
                    }
                    
                } else {
                    //error vctm or src mcn not found in SF
                }
            }
        }
        
        if(!updtAccts.isEmpty()) {
            update updtAccts;
        }
        
        if(!accTeamMbrLst.isEmpty()) {
            insert accTeamMbrLst;
        } 
    }
    
    
    public void finish(Database.BatchableContext bc) {
        System.debug('COMPLETED ##############'); 
        
    }
    
    public class MergeIterator implements Iterator<MergeWrapper> {
        private List<MergeWrapper> items;
        private Integer nextIdx;
        
        public MergeIterator(List<MergeWrapper> items)
        {
            System.debug('JobIterator Initialization ##############');
            this.items = items;
            this.nextIdx = 0;
        }
        
        public boolean hasNext()
        {
            System.debug('JobIterator hasNext CALL ###############');
            return nextIdx >= items.size() ? false : true;
        }
        
        public MergeWrapper next()
        { System.debug('JobIterator next CALL #######################');
            return items[nextIdx++];
        }
    }
    
    private class MergeIterable implements Iterable<MergeWrapper> {
        private List<MergeWrapper> iteratorItems;
        
        public MergeIterable(List<MergeWrapper> items)
        {
            iteratorItems = new List<MergeWrapper>();
            for(MergeWrapper item : items) {
        iteratorItems.add(item);                     
            }
        }
        
        public Iterator<MergeWrapper> Iterator()
        {
            return new MergeIterator(iteratorItems);
        }       
    }
    
    public class MergeWrapper {
       public Integer Index;
        public String vctmMCN;
       public String srcMCN; 
    }
}