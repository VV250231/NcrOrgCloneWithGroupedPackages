trigger BillingCPQFormulaTrigger on SBQQ__QuoteLine__c (before insert, before update) {
        if( Trigger.isBefore ){
            if( Trigger.isInsert || Trigger.isUpdate){
                //ATG 08-25-2021 Deprecated class and moved logic to QCP
                //BillingCPQFormulaTriggerHandler.handleBeforeTrigger( Trigger.new );
            }
        }
}