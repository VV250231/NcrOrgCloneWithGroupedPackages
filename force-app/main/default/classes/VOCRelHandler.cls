public class VOCRelHandler {
    
    public static void handleConAccAssoc(String conId, Set<String> inpMCNSet,String accId) {
        List<AccountContactRelation> acRel = [SELECT Account.Master_Customer_Number__c,IsActive,IsDirect,Roles from AccountContactRelation WHERE ContactId = :conId ];
        List<AccountContactRelation> inactvACRels = new List<AccountContactRelation>();
        List<AccountContactRelation> upsertRels = new List<AccountContactRelation>();
        
        List<AccountContactRelation> acRellupdate = [SELECT Id,Account.id,Account.Master_Customer_Number__c,IsActive,IsDirect,Roles from AccountContactRelation
                                                     WHERE ContactId = :conId AND Roles=null LIMIT 1];
        
       if(acRellupdate !=null && acRellupdate.size() > 0 ) {
            AccountContactRelation ac= new AccountContactRelation();
            ac.id=acRellupdate[0].Id;
            ac.IsActive= false;
            update ac;
        } 
        
         List<Account >accToUpdate = [SELECT Id,Master_Customer_Number__c FROM Account WHERE Master_Customer_Number__c IN :inpMCNSet and id !=:accId LIMIT 1];
        if(accToUpdate !=null && accToUpdate.size() > 0 ) {
            Contact c = new Contact();
            c.id= conId;
            c.AccountId= accToUpdate[0].id;
            system.debug('@@@@ccccc'+c);
              
            update c;
            inpMCNSet.remove(accToUpdate[0].Master_Customer_Number__c);
        } 
        
        
        for (AccountContactRelation acr : acRel) {
            String acMcn=acr.Account.Master_Customer_Number__c;
            if(String.isNotBlank(acMcn) && inpMCNSet.contains(acMcn)) {
                inpMCNSet.remove(acMcn);    
                
                if (!acr.IsActive) {
                    acr.IsActive = true;
                    upsertRels.add(acr);
                }
            } else  if (!acr.IsDirect && acr.Roles == 'MyNCR User') {                
                inactvACRels.add(acr); 
            }   
        }
        
        //create Related Contacts if not exist already
        if (inpMCNSet != NULL && !inpMCNSet.isEmpty()) {
            system.debug('@@@inpMCNSet: '+inpMCNSet);
            List<Account> accLst = [SELECT Id FROM Account WHERE Master_Customer_Number__c IN :inpMCNSet];           
            for(Account a : accLst) {
                upsertRels.add(new AccountContactRelation(ContactId =conId, AccountId=a.Id, Roles='MyNCR User'));     
            }
        }
        
        // upsert relationships
        system.debug('@@upsertRels: '+upsertRels);
        if(!upsertRels.isEmpty()) upsert upsertRels;       
        if(!inactvACRels.isEmpty()) delete inactvACRels;
        
        // if MCN not found in SF, send email to support team
    }
}