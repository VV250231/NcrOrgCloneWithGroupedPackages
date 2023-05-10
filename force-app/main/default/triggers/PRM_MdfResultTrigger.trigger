trigger PRM_MdfResultTrigger on Partner_Fund_ROI__c (before insert,after insert, before update, after update) {
    new PRM_MdfResultTriggerDispatcher().run();
}