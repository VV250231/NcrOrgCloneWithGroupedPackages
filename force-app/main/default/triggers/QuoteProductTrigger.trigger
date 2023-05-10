// ===========================================================================
// Object: QuoteProductTrigger
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: See DI-1551 - trigger to set the SPP Category and Interface values
// ===========================================================================
// Changes: 2017-02-14 Reid Beckett
//           Class created
// ===========================================================================

trigger QuoteProductTrigger on Quote_Product__c (before insert, before update, after insert, after update) 
{
    if(Trigger.isBefore) {
        new QuoteProductTriggerHandler().onBefore();
    }else {
        new QuoteProductTriggerHandler().onAfter();
    }
}