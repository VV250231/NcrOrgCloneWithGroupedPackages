global class Delete_PMDM_RequestLog implements Database.Batchable<sObject>{
    
    
    
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT ID FROM PMDM_Request_log__c WHERE Createddate = TODAY');
    }

    global void execute(Database.BatchableContext bc, List<PMDM_Request_log__c> records){
        List<PMDM_Request_log__c > RequestLogList = new List<PMDM_Request_log__c>();
        for(PMDM_Request_log__c obj : records){
            RequestLogList.add(obj); 
        }
        if(RequestLogList != null && RequestLogList.size() > 0){
            DataBase.Delete(RequestLogList);
        }
           
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));    
    }    

}