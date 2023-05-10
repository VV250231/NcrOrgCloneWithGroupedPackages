global class scheduledBatchable implements Schedulable {
   global void execute(SchedulableContext sc) {
      SearchAndUpdateStatus b = new SearchAndUpdateStatus();
      database.executebatch(b);
   }
}