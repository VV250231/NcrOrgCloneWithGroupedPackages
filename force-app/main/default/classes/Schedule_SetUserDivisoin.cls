global class Schedule_SetUserDivisoin implements Schedulable {
   global void execute(SchedulableContext sc) {
      Batch_SetUserDivision b = new Batch_SetUserDivision(); 
      database.executebatch(b);
   }

}