global class batchAccTeamDelete implements Database.Batchable<sObject> {
    List<Id> users = new List<Id>();
    global batchAccTeamDelete() {}
    
    global batchAccTeamDelete(List<Id> u) {
        users = u;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //return DataBase.getQueryLocator([SELECT Id from AccountTeamMember where userID in :users]);
        return DataBase.getQueryLocator([SELECT Id from AccountTeamMember where userID in (Select Id from User where IsActive = false and LastModifiedDate = TODAY)]);
    }
    global void execute(Database.BatchableContext BC,List<AccountTeamMember> scopeAcc) {
        delete scopeAcc;
    }
    global void finish(Database.BatchableContext BC) {
    }
}