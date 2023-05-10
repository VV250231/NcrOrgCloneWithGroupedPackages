trigger OrderActivationEventTrigger on qtcOrderActivation__e (after insert) {
    OrderActivationEventTriggerHandler handler = new OrderActivationEventTriggerHandler(Trigger.new, Trigger.oldMap);
    if(Trigger.isAfter && Trigger.isInsert){
        handler.handleAfterInsert();
    }
}