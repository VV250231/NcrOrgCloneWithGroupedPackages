public class Co_Op_TriggerHandler {

    public static void isBeforeInsert(List<Co_Op__c> newCoOps){
        if(Trigger.isBefore && Trigger.isInsert){
        User u = [SELECT Id, Name, ContactId, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        for (Co_Op__c  coOp : newCoOps) {
            if (coOp.Account__c == null && u.AccountId != null)
                coOp.Account__c  = u.AccountId;
            if (coOp.Contact__c == null && u.ContactId != null)
                coOp.Contact__c = u.ContactId;
            coOp.Interact_Tools_Email__c = 'Partner.ResourceCenter@ncr.com';  // this line of code written in populateInteractToolEmailTrigger
        }
    }
    }
}