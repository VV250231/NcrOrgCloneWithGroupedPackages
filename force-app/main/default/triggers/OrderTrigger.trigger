trigger OrderTrigger on Order (after update) {
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('OrderTrigger')){
        new OrderTriggerDispatcher().run(); 
    }
}