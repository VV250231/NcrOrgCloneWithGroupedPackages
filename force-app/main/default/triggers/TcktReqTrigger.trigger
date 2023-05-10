trigger TcktReqTrigger on Ticket_Request__c (before update, before insert, after delete,after update) {
    if(trigger.isBefore){ 
        if(trigger.isInsert){
            TcktReqHandlr.manageNbrOfTcktsOnInsrt(Trigger.new);
        }
        if(trigger.isUpdate){
            TcktReqHandlr.manageNbrOfTcktsOnUpdt(Trigger.New,Trigger.oldMap);
        }
    }
    if(trigger.isAfter){
        if(trigger.isUpdate){
            TcktReqHandlr.setCampaingIdforOpp(Trigger.New,Trigger.oldMap);
        }
        if(trigger.isDelete){
            TcktReqHandlr.manageNbrOfTcktsOnDlt(Trigger.old);
        }
    }
}