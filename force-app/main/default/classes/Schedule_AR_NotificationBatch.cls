public class Schedule_AR_NotificationBatch implements Schedulable {
    public void execute(SchedulableContext sc) {
        AR_NotificationBatch batch = new AR_NotificationBatch();
        ID batchprocessid = Database.executeBatch(batch);   
    }
    
}