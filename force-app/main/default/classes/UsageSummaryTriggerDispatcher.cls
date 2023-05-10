public with sharing class UsageSummaryTriggerDispatcher extends TriggerHandlerBase{
    public override void afterInsert(){
        UsageSummaryTriggerHandler triggerHandler = new UsageSummaryTriggerHandler((List<blng__UsageSummary__c>)Trigger.new, (Map<Id, blng__UsageSummary__c>)Trigger.oldMap);
        triggerHandler.handleAfterInsert();
    }

    public override void afterUpdate(){
        UsageSummaryTriggerHandler triggerHandler = new UsageSummaryTriggerHandler((List<blng__UsageSummary__c>)Trigger.new, (Map<Id, blng__UsageSummary__c>)Trigger.oldMap);
        triggerHandler.handleAfterUpdate();
    }
}