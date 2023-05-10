trigger Co_Op_Trigger on Co_Op__c (before insert) {
    Co_Op_TriggerHandler.isBeforeInsert(Trigger.new);
}