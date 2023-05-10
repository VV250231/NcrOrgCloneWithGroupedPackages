global class AbortSalesOrderJobs implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
       
        Set<String> apexClassNames = new Set<String>{'SalesBacklogOrdersDailySyncUp', 'SalesOrdersBacklogBatch'};
        Set<String> apexClassIds = new Set<String>();
         
        for(ApexClass a:  [SELECT Id FROM ApexClass WHERE Name IN :apexClassNames]) {
            apexClassIds.add(a.Id);    
        }
        
        if (!apexClassIds.isEmpty()) {
            List<AsyncApexJob> asynJobList = [SELECT Id, Status, JobType, ApexClassID FROM AsyncApexJob 
                                              WHERE JobType = 'BatchApex' and ApexClassID IN :apexClassIds 
                                              and Status IN ('Holding', 'Queued','Preparing', 'Processing')];
                                              
            for(AsyncApexJob asyncJob : asynJobList) {
                System.abortJob(asyncJob.Id);
            }
        }
   
    }
    
}