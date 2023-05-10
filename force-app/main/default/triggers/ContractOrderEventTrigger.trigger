trigger ContractOrderEventTrigger on qtcContractOrder__e (after insert) {
    ContractOrderEventTriggerHandler handler = new ContractOrderEventTriggerHandler(Trigger.new, Trigger.oldMap);
    if(Trigger.isAfter && Trigger.isInsert){
        handler.handleAfterInsert();
    }
}