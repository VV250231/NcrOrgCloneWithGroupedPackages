trigger UsageSummaryTrigger on blng__UsageSummary__c (after insert, after update) {
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('UsageSummaryTrigger')){
        new UsageSummaryTriggerDispatcher().run(); 
    }
}