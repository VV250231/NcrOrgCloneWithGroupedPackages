global class Schedule_Credit_Detail_clean implements Schedulable {
    global void execute(SchedulableContext sc) {
            Credit_Detail_Clean rollup = new Credit_Detail_Clean(true);
            ID batchprocessid = Database.executeBatch(rollup);   
        
    }  
}