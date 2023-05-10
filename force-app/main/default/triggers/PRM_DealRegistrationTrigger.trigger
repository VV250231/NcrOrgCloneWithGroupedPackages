trigger PRM_DealRegistrationTrigger on Deal_Registration__c (before insert, after insert, before update, after update) {  
    new PRM_DealRegistrationDispatcher().run();
}