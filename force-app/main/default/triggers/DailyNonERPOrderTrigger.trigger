trigger DailyNonERPOrderTrigger on Daily_Non_ERP_Order__c (before insert, before update) {
     new DailyNonERPOrderTriggerDispatcher().run();
}