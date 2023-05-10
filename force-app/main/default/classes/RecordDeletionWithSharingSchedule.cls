global class RecordDeletionWithSharingSchedule implements Schedulable, Database.AllowsCallouts {
  String query;
    Boolean allOrNone;
    public RecordDeletionWithSharingSchedule(String query,Boolean allOrNone)
    {
        this.query=query;
        this.allOrNone=allOrNone;
    }
    
  global void execute(SchedulableContext context) { 
        system.debug('QueryInScheduler: '+query);

       RecordDeletionWithSharing p = new RecordDeletionWithSharing(query,allOrNone);
        database.executeBatch(p);
  }
}