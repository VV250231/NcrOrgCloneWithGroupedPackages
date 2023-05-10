global class LeadSchdeuleApexNotifcationClass implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // awesome code here
        LeadNotificationBatchApex obj = new LeadNotificationBatchApex();
        Database.executeBatch(obj);
    }
}