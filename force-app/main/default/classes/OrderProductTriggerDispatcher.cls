public with sharing class OrderProductTriggerDispatcher extends TriggerHandlerBase{
    public override void afterInsert(){
        OrderProductTriggerHandler triggerHandler = new OrderProductTriggerHandler((List<OrderItem>)Trigger.new, (Map<Id, OrderItem>)Trigger.oldMap);
        triggerHandler.handleAfterInsert();
    }

    public override void afterUpdate(){
        OrderProductTriggerHandler triggerHandler = new OrderProductTriggerHandler((List<OrderItem>)Trigger.new, (Map<Id, OrderItem>)Trigger.oldMap);
        triggerHandler.handleAfterUpdate();
    }
}