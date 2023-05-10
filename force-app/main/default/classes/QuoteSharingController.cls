global class QuoteSharingController implements Database.Batchable<sObject> {
    String quoteSchedulerId;
    
    global QuoteSharingController() {
        System.debug('Method : QuoteSharingController');//SC2015_AGL-5809
    }
   
    global QuoteSharingController(String schedulejobID) {
        quoteSchedulerId =  schedulejobID;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> profileIds = new Set<Id>();
        Set<Id> AccountIds = new Set<Id>();
        Datetime previousDay = Datetime.now().addDays(-1);
        
        profileIds.add([SELECT Id,Name FROM Profile WHERE Name='62 DI Account Manager' LIMIT 1].get(0).Id);
        
        for(AccountTeamMember atm : [SELECT Id,AccountId FROM AccountTeamMember WHERE LastModifiedDate >= :previousDay]) {
            AccountIds.add(atm.AccountId);
        }
        System.debug('@@@@@@@@@@@' + profileIds + '>>>'+ previousDay );
        String dynamicQuoteQuery = 'SELECT Id,zqu__Account__c FROM zqu__Quote__c WHERE Owner.ProfileId IN :profileIds AND zqu__Account__c != NULL AND (zqu__Account__r.LastModifiedDate >= :previousDay OR zqu__Account__c IN :AccountIds)';
        return Database.getQueryLocator(dynamicQuoteQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<zqu__Quote__c> quoteList) {
        Map<Id, Id> quoteAccountIdMap = new  Map<Id, Id>();          
       
        for(zqu__Quote__c q :quoteList) {
            quoteAccountIdMap.put(q.Id, q.zqu__Account__c);
        }
        ZquoteExtUtil.shareQuoteWithAccandAccTeam(quoteAccountIdMap);     
    }

    global void finish(Database.BatchableContext BC) {
        if(BC.getJobID() != NULL) {
            AsyncApexJob asyncObj = [SELECT Id, Status, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =:BC.getJobID()];
            
            if(asyncObj.status == 'Completed' && quoteSchedulerId != null) { 
                System.abortJob(quoteSchedulerId );
                Datetime nextSchdTime = Datetime.now().addMinutes(10);
                integer cronMins = nextSchdTime.minute();
                if(!System.Test.isRunningTest()) {
                    System.schedule('Calculate Quote Account Sharing', '0 ' + cronMins + ' * * * ?', new CalcQuoteSharing());
                }
            }
        }
    }   

}