public class AutoPopulateProcessInstanceScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AutoPopulateProcessInstance(), 200);
    }
}