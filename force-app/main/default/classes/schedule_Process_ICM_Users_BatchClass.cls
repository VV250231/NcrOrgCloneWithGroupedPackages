global class schedule_Process_ICM_Users_BatchClass implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Process_ICM_Users_BatchClass p = new Process_ICM_Users_BatchClass();
        if(!Test.isRunningTest()){database.executeBatch(p);}
        
    }  
}