global class batchOppTeamDelete implements Database.Batchable<sObject> {
    List<Id> users = new List<Id>();
    global batchOppTeamDelete() {}
    global batchOppTeamDelete(List<Id> u) {
        users = u;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //return DataBase.getQueryLocator([SELECT Id from OpportunityTeamMember where userID in :users]);
        return DataBase.getQueryLocator([SELECT Id from OpportunityTeamMember where userID in (Select Id from User where IsActive = false and LastModifiedDate = TODAY)]);
    }
    global void execute(Database.BatchableContext BC,List<OpportunityTeamMember> scopeMem) {
        delete scopeMem;
    }
    global void finish(Database.BatchableContext BC) {
    }
}