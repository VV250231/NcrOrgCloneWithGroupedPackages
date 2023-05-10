trigger AccountExceptionTrigger on Account_Exception__c (before insert, after update)
{
    AccountExceptionHandler objHandler = new AccountExceptionHandler();
    
    if(trigger.isBefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new);
    }
    else if(trigger.isAfter && trigger.isUpdate && !System.isFuture())
    {
        objHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
    }
    
}