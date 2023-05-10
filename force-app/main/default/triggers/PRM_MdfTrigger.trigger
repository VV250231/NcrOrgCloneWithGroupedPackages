trigger PRM_MdfTrigger on SFDC_MDF__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new PRM_MdfTriggerDispatcher().run();
}