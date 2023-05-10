Public Class CalcQuoteSharing implements schedulable {
        
    public void execute (SchedulableContext sc) {   
       QuoteSharingController quoteShr = new QuoteSharingController(sc.getTriggerId());
       Database.executeBatch(quoteShr);                  
    }
}