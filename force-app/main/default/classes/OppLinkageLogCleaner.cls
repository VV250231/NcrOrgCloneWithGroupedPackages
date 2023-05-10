/*
##################################################################################################
# Project Name..........: Easy Button                                                                     
# File..................: OppLinkageLogCleaner.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                 
# Created Date..........: 19-01-2015                                                                               
# Last Modified by......: Puneet Bhatia 
# Last Modified Date....: 19-01-2015
# Description...........: The test class is used to delete older than last 6 months logs for Log Opportunity Linkage object. 
################################################################################################
*/

public class OppLinkageLogCleaner implements Database.Batchable<sObject> {
    
    public OppLinkageLogCleaner(){}
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest()){
            return Database.getQueryLocator([SELECT Id FROM Log_Opportunity_Linkage__c LIMIT 1]); 
        } else {
            return Database.getQueryLocator([SELECT Id FROM Log_Opportunity_Linkage__c WHERE CREATEDDATE < LAST_N_MONTHS:6]); 
        }  
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC){}   
}