global class scheduleProfileTrackBatchClass implements Schedulable {
    global void execute(SchedulableContext ctx) {
        profileTrackerBatchClass p = new profileTrackerBatchClass();
        if(!Test.isRunningTest()){database.executeBatch(p);}
        
    }  
}