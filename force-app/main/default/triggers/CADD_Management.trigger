trigger CADD_Management on Deming__c (before insert, before update, after insert, after update) {
if(Trigger.isInsert && Trigger.isBefore) {
       CADD_ManagementHandler.isBeforeInsert(Trigger.new,null);
    }
    
    if(Trigger.isInsert && Trigger.isAfter) {  
       CADD_ManagementHandler.isAfterInsert(Trigger.new,null);
       CADD_ManagementHandler.manageDemingTeamSharing(Trigger.new,null);
    }
    
    if((Trigger.isUpdate && Trigger.isBefore)){
         CADD_ManagementHandler.isBeforeUpdate(Trigger.new,Trigger.old);
    }

    
    if((Trigger.isUpdate && Trigger.isAfter)) { 
        CADD_ManagementHandler.manageDemingTeamSharing(Trigger.new,Trigger.old);
        CADD_ManagementHandler.isAfterUpdate(Trigger.new,Trigger.old,Trigger.oldMap);
    }
    
       
}