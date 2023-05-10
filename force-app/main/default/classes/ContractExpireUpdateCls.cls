global class ContractExpireUpdateCls  implements Schedulable {
    
    global void execute(SchedulableContext sc){
       Database.executeBatch(new ContractExpireUpdateBatch(),2000);
    }
  
}