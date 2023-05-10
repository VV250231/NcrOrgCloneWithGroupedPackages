trigger ContractTrigger on Contract (after update, before update) {
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('ContractTrigger')){
        new ContractTriggerDispatcher().run(); 
    }
}