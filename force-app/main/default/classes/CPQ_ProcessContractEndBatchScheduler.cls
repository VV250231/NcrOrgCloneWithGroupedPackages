global with sharing class CPQ_ProcessContractEndBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CPQ_ProcessContractEndBatch processContractEndBatch = new CPQ_ProcessContractEndBatch();
        if(!Test.isRunningTest()) {
            Database.executeBatch(processContractEndBatch,1);
        }
    }
}