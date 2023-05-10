public without sharing class RecordDeletionWithoutSharing implements Database.Batchable<sObject>,Database.Stateful{
	String query;
    Boolean allOrNone;
    public RecordDeletionWithoutSharing(String query,Boolean allOrNone)
    {
        this.query=query;
        this.allOrNone=allOrNone;
    }
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<sObject> deletionList)
    {
        Database.delete(deletionList,allOrNone);
    }
    public void finish(Database.BatchableContext bc)
    {
        Data_Clean_up_Utility_Logs__c dc= new Data_Clean_up_Utility_Logs__c();
       
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors,ExtendedStatus,JobItemsProcessed,TotalJobItems, CreatedBy.Email, CreatedBy.Name
                              FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
         dc.Job_Name__c=a.id;
        dc.Status__c=a.Status;
        if(a.status !='completed') dc.Failure_Reason__c=a.ExtendedStatus;
        dc.Query_Executed__c=query;
        
        if(dc !=null)
            insert dc;
        
        if(a.Status!='Completed' || Test.isRunningTest() ){
        BatchUtil.emailService(a);
        }
    }
}