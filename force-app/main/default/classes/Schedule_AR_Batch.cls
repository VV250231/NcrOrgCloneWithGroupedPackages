public class Schedule_AR_Batch implements Schedulable{
    public void execute(SchedulableContext sc) {
        AR_Batch batch = new AR_Batch();
        ID batchprocessid = Database.executeBatch(batch);   
    }
}