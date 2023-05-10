trigger InvoiceLineTrigger on blng__InvoiceLine__c (after insert, after update) {
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('InvoiceLineTrigger')){
        new InvoiceLineTriggerDispatcher().run(); 
    }
}