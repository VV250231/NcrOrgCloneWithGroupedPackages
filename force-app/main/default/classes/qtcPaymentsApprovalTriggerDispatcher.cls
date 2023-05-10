public with sharing class qtcPaymentsApprovalTriggerDispatcher extends TriggerHandlerBase{

    public override void afterUpdate(){
        qtcPaymentsApprovalTriggerHandler triggerHandler = new qtcPaymentsApprovalTriggerHandler((List<qtc_PaymentsApproval__c>)Trigger.new, (Map<Id, qtc_PaymentsApproval__c>)Trigger.oldMap);
        triggerHandler.handleAfterUpdate();
    }
}