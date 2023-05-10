public with sharing class InvoiceLineTriggerDispatcher extends TriggerHandlerBase{
   
    public override void afterInsert(){
        InvoiceLineTriggerHandler triggerHandler = new InvoiceLineTriggerHandler((List<blng__InvoiceLine__c>)Trigger.new, (map<Id, blng__InvoiceLine__c>)Trigger.oldMap);
        triggerHandler.handleAfterInsert();
    }

    public override void afterUpdate(){
        InvoiceLineTriggerHandler triggerHandler = new InvoiceLineTriggerHandler((List<blng__InvoiceLine__c>)Trigger.new, (map<Id, blng__InvoiceLine__c>)Trigger.oldMap);
        triggerHandler.handleAfterUpdate();
    }
}