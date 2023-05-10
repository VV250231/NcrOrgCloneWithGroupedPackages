trigger OrderProductTrigger on OrderItem (after insert, after update) {
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('OrderProductTrigger')){
        new OrderProductTriggerDispatcher().run(); 
    }
}