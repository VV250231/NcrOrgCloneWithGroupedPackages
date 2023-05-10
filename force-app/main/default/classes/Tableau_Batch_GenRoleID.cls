global class Tableau_Batch_GenRoleID implements Database.Batchable<sObject>,Database.Stateful{
    
    global Integer recordsProcessod = 0 ;
    global String exception_s = 'NA' ;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String Query = 'Select id from TableauSubRoleIDs__c '+ (Test.isRunningTest() ?' LIMIT 1':'');
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<TableauSubRoleIDs__c> ScriptObject){
        
        recordsProcessod = recordsProcessod + ScriptObject.size();
        
        try{ 
            update ScriptObject;
        }
        catch(exception e){
            exception_s =  e+'' ;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
        string m_tp = 'sk250817@ncr.com' ;
        string m_sub = 'Tableau Script Status : SubRoleID Script Generated ';
        string m_body = 'Total records processed : '+recordsProcessod + 
            '<br> </br> Sub Role ID process has been completed.'+
            '<br> </br>  Proceeding to Script generation .....' +
            '<br> </br> if any, exceptions :: '+exception_s+
            '<br></br> Date Time Executed: '+Date.today();   
        
        Tableau_Scheduler.sendemail(m_tp,m_sub,m_body,3);
        
    }
   
}