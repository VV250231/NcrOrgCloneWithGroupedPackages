trigger qtcPaymentsApprovalTrigger on qtc_PaymentsApproval__c (after update) {
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('qtcPaymentsApprovalTrigger')){
        new qtcPaymentsApprovalTriggerDispatcher().run(); 
    }
}