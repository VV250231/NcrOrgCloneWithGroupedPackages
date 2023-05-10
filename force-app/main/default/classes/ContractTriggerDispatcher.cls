public with sharing class ContractTriggerDispatcher extends TriggerHandlerBase{    
    
    ContractTriggerHandler triggerHandler = new ContractTriggerHandler((List<Contract>)Trigger.new, (Map<Id, Contract>)Trigger.oldMap);
    public override void afterUpdate(){
        triggerHandler.handleAfterUpdate();
    }

    public override void beforeUpdate(){
        triggerHandler.handleBeforeUpdate();
    }
}