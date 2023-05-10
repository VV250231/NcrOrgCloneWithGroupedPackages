public class AR_NotificationBatch implements Database.Batchable<sObject>{
    /* This batch class un-freeze the records which are locked from last 15 days from the previous notification.*/
    public Integer successCounter = 0;
    public Integer failureCounter = 0; 
    public String Status = '';
    public Exception[] errorslist = new Exception[0];
    public integer totalSizeRecords=0;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Dues_Notification_Status__c,Last_Notification_Date__c,Prior_Value_of_Dues_Notification_Status__c, Is_Record_freeze_for_Notification__c,Stage_1_Notification_Date__c,Stage_2_Notification_Date__c,Stage_3_Notification_Date__c,Stage_4_Notification_Date__c FROM Credit_Detail__c WHERE Is_Record_freeze_for_Notification__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Credit_Detail__c> creditDetails = new List<Credit_Detail__c>();
        try {
            for (sObject rec : scope) {
                Credit_Detail__c cd = (Credit_Detail__c)rec;
                if (cd.Last_Notification_Date__c != null) {
                    if (cd.Last_Notification_Date__c.daysBetween(System.today()) >= 15) {
                        cd.Is_Record_freeze_for_Notification__c = false;
                        creditDetails.add(cd);
                    }
                } else {
                    cd.Is_Record_freeze_for_Notification__c = false;
                    creditDetails.add(cd);
                }
                
            }
        
            update creditDetails;
            successCounter++;
        } catch(Exception ex) {
            failureCounter++;
            errorslist.add(ex);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        //Id batchJobId = Database.executeBatch(new AR_NotificationBatch(), 200);
        //AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        string emailBodytoReplaced = 'Total number of records ==> '+totalSizeRecords
                +'<Br/>Number of batch completed ==> '+successCounter
                +'<Br/>Number of batch failed ==> '+failureCounter;
            
            string emailHeader = 'Batch Job Succeeded';
            
            if(failureCounter!=0) {
                emailHeader='Batch Job Failed'; 
                emailBodytoReplaced += '<Br/><Br/> Fix the record and re-run the batch by using below command <Br/> <p style="color:blue">AR_NotificationBatch batch = new AR_NotificationBatch ();<Br/>database.executebatch(batch, 200);</p>';
                integer n=1;
                for(Exception e : errorslist) {  
                    emailBodytoReplaced += n+'.'+' '+'Exception Occured:' + e.getMessage() + '<Br/>' + e.getStackTraceString()+'<Br/>';
                    n++;
                    
                }
            }
            
            string emailSubject = emailHeader+' For AR_NotificationBatch ';
            string emailSubHeader = emailHeader+' For AR_NotificationBatch ';
            EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
            String EmailBody=template.HtmlValue;
            
            CommonUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,(Label.BatchClassEmailNotification).split(',')); 
    }
}