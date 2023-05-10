/* Description.....: This trigger is part of our One Trigger Per Object intiative. Please do not write any business logic inside this trigger.
 * Created by......: RK250519
 * Created Date....: 29 June 2021.
 * 
 */ 
trigger ZQuoteTrigger on zqu__Quote__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('ZQuoteTrigger')){
      new QuoteTriggerDispatcher().run();
    }else{
        System.debug('Skip ZQuoteTrigger');
    }
}