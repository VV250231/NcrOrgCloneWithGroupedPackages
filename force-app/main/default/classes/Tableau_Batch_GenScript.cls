global class Tableau_Batch_GenScript implements Database.Batchable<sObject>,Database.Stateful{
    
    global Integer recordsProcessod = 0 ;
    global String exception_s = 'NA' ;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
         String Query = 'Select id from Tableau__c '+ (Test.isRunningTest() ?' LIMIT 1':'');
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<Tableau__c> TableauObject){
        
        recordsProcessod = recordsProcessod + TableauObject.size();
        
        try{ 
            update TableauObject;
        }
        catch(exception e){
            exception_s =  e+'' ;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
        string m_tp = 'sk250817@ncr.com' ;
        string m_sub = 'Tableau Script Status : UserSet Script Generated ';
        string m_body = 'Total records processed : '+recordsProcessod + 
            '<br> </br>  User Set process has been completed.'+
            '<br> </br> Date Time Executed : '+ Date.today() +
            '<br> </br> if any, exceptions :: '+exception_s;        
        if(!test.isRunningTest())
        Tableau_Scheduler.sendemail(m_tp,m_sub,m_body,4);
       
     }
    
    
}