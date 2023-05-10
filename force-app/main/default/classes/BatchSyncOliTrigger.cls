/*
*********************************************************
Apex Class Name    : BatchSyncOliTrigger
Created Date       : 
@description       : This class is used to resync all data in Opportunity Product and Product Schedule custom objects from standard objects 
@author            : IDC, NSC
Modification Log:
Ver   Date         Author                       Modification
1.0   07-18-2019   Ajay Dixit                   Last Version
1.0   11-13-2021   Puneet Bhatia                Removed SyncOli queueable call replaced with syncLineItems method, sending single email for erros 
												and retry locked records from finish method  
*********************************************************
*/
global class BatchSyncOliTrigger implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer numofrecords;
    List <String> errorMsgList = new List <string>();
    Set<id> retryOppIds = new Set<id>();
    Set<id> OppIds = new Set<id>();
    Datetime lastRunDatetime;
    Datetime currentDatetime;
    
    public BatchSyncOliTrigger() {}
    
    public BatchSyncOliTrigger(Datetime lastRunDatetime) {
    	this.lastRunDatetime = lastRunDatetime;    
    }
    
    public BatchSyncOliTrigger(Set<id> OppIds) {
    	this.OppIds = OppIds;   
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id from Opportunity';
        
        if(lastRunDatetime != null) {
            System.debug('lastRunDatetime>>' + lastRunDatetime);
            currentDatetime = Datetime.now();
        	query += ' WHERE LastmodifiedDate >= : lastRunDatetime AND LastmodifiedDate <= :currentDatetime'	;	    
        } else if(!OppIds.isEmpty()) {
       		query += ' WHERE Id IN :OppIds';		         
        }
        query += ' order by CreatedDate';  
        System.debug('query>>' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<id> setid=new Set<id>();        
        for(Sobject s:scope){
            setid.add(s.id);
        }
        new SyncOli(setid).syncLineItems(errorMsgList, retryOppIds);
        
        //System.enqueueJob(new SyncOli(setid));
        
    }
    
    global void finish(Database.BatchableContext BC){
        if(!errorMsgList.isEmpty()) {
        	 new SyncOli().sendEmail(errorMsgList, 'Please retrigger or resolve issue for each individual Records below:');    
        } else {
        	if(currentDatetime != NULL) {
            	SyncOLI_Config__c cnfg = SyncOLI_Config__c.getValues('Org_Config');
                cnfg.LastRun_Datetime__c = currentDatetime;                
                update cnfg;
            }    
        }
        
        if(!retryOppIds.isEmpty()) {            
            BatchSyncOliTrigger syncOli = new BatchSyncOliTrigger(retryOppIds);
      	    Database.executeBatch(syncOli);        
        } else {
        	
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            message.toAddresses = new String[] {'ad250024@ncr.com', 'pb185126@ncr.com'};
                message.subject =  'batch finished for triggering SyncOli';
            
            message.htmlbody ='SyncOLI trigger finished';        
            
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
        }
    }
}