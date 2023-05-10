global class RecordDeletionWithOutSharingSchedule implements Schedulable, Database.AllowsCallouts {
  String query;
    Boolean allOrNone;
    public RecordDeletionWithOutSharingSchedule(String query,Boolean allOrNone)
    {
        this.query=query;
        this.allOrNone=allOrNone;
    }
    
  global void execute(SchedulableContext context) { 
          system.debug('QueryInScheduler: '+query);

       RecordDeletionWithoutSharing p = new RecordDeletionWithoutSharing(query,allOrNone);
        database.executeBatch(p);
  }
}