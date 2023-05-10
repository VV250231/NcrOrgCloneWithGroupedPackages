global class SalesBacklogOrdersSyncUpSchdl implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
       
        Database.executeBatch(new SalesBacklogOrdersDailySyncUp() , 5 ) ;
    }
    
}