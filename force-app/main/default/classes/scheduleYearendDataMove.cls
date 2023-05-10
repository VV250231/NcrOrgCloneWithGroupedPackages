global class scheduleYearendDataMove implements Schedulable {
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new YearendDataMove()); 
   }
}