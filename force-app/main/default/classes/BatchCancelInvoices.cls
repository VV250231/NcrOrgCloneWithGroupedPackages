public class BatchCancelInvoices implements Database.Batchable<sObject>{
   
   //This batch class is for cancelation of Invoices
   //Batch size should be always 1, since billing supports only 1 invoice at a time
   public set<Id> setOfInvoiceIds = new set<Id>();
   public BatchCancelInvoices(set<Id> setOfInvoiceId) {
       setOfInvoiceIds = setOfInvoiceId;
   }
    
   public Database.QueryLocator start(Database.BatchableContext BC){
      //Here we are getting all the data without where clauses  
      //In execute method we update only required data
      return Database.getQueryLocator('Select Id FROM blng__Invoice__c WHERE Id IN: setOfInvoiceIds');
   }
   public void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope){
     blng.InvoiceAPI.creditInvoice(scope[0].Id, 'Cancel and Rebill');
    }
   public void finish(Database.BatchableContext BC){
   }
}