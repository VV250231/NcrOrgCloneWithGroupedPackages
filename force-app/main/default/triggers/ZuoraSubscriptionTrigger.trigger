/**************************************
  Author ...............: Sanjay Pandit
  Date Created .........: 22-Sep-2020
  Last Modified By .....:
  Last Modified Date ...: 
  Description ..........: SC2015_AGL-5787, Trigger Consolidation  (SubscriptionTrigger/QuoteIDOnSubscription/UpdateSubscriptionChargesInZuora)
***************************************/
trigger ZuoraSubscriptionTrigger on Zuora__Subscription__c (before insert, before update,after insert,after update, after delete) {
    ZuoraSubscriptionTriggerHelper zuoraSubscription=new ZuoraSubscriptionTriggerHelper();
    
    if(Trigger.isAfter)
    {
        //For UpdateSubscription Charges in Zuora
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            zuoraSubscription.onAfterInsertUpdateSubscriptionChargesInZuora(Trigger.New);
        }
        
        //For SubscriptionTrigger
        if(Trigger.isDelete)
        {
             zuoraSubscription.onAfterDeleteSubscriptionTrigger(Trigger.Old);
        }
    }
    
    //For QuoteIDOnSubscription
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            zuoraSubscription.onBeforeInserUpdateQuoteIDOnSubscription(Trigger.New);
        }
    }
}