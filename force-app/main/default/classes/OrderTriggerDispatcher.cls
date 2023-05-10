public with sharing class OrderTriggerDispatcher extends TriggerHandlerBase{
   
    public override void afterUpdate(){
        OrderTriggerHandler triggerHandler =new OrderTriggerHandler((List<Order>)Trigger.new, (map<Id, Order>)Trigger.oldMap);
        triggerHandler.handleAfterUpdate();
    }
}