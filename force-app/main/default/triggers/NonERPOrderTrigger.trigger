trigger NonERPOrderTrigger  on Non_ERP_Order__c  (before insert, before update) {
    new NonERPOrderTriggerDispatcher().run();
}