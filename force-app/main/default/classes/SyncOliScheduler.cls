public Class SyncOliScheduler implements Schedulable {
    public void execute (SchedulableContext sc) { 
       SyncOLI_Config__c cnfg = SyncOLI_Config__c.getValues('Org_Config');
       Datetime lastRunDatetime = cnfg.LastRun_Datetime__c; 
        
       if(lastRunDatetime != null) {
           BatchSyncOliTrigger syncOli = new BatchSyncOliTrigger(lastRunDatetime);
       	   Database.executeBatch(syncOli);          
       } else {
       		BatchSyncOliTrigger syncOli = new BatchSyncOliTrigger();
     		Database.executeBatch(syncOli);         
       }
                   
    }
}