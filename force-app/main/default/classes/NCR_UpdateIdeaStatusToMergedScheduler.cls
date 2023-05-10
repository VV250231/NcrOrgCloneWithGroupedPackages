global class NCR_UpdateIdeaStatusToMergedScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      NCR_UpdateIdeaStatusToMerged b = new NCR_UpdateIdeaStatusToMerged ();
      database.executebatch(b);
   }
}