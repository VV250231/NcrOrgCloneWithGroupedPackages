//update the method parameters to add additonal trigger contexts: after insert, after update, after delete
trigger qtcQuoteTrigger on SBQQ__Quote__c (before insert, before update, after insert, after update, after delete) {
    CPQ_Trigger__mdt triggerConfiguration = [ 
        SELECT Is_Active__c 
        FROM CPQ_Trigger__mdt 
        WHERE DeveloperName = 'qtcQuoteTrigger' LIMIT 1 ];
    
    if (triggerConfiguration.Is_Active__c) {
        CPQTriggerControl.cpqSpclHdlgNew=true;
        
        qtcQuoteTriggerHandler triggerHandler = new qtcQuoteTriggerHandler(Trigger.new, Trigger.oldMap);
        if( Trigger.isBefore ){
            if( Trigger.isInsert ){
                triggerHandler.handleBeforeInsert();
            } 
            else if( Trigger.isUpdate ){
                triggerHandler.handleBeforeUpdate();
            }
        }
        else if( Trigger.isAfter ){
            if( Trigger.isUpdate ){
                triggerHandler.handleAfterUpdate();
            }
        }    
        //Add the Oppty Trigger logic here
        
        if(Trigger.isAfter){
            if(!System.isFuture() && !System.isBatch() && Limits.getQueueableJobs()==0 && CheckRecursive.runQ2OppSyncOnce()){
                System.enqueueJob(new cpq_QteToOppSync((List<SBQQ__Quote__c>)Trigger.New, (Map<id,SBQQ__Quote__c>)Trigger.oldMap));        
            }  
            // Dharmendra added on 07-Dec-2021
            if(Trigger.isUpdate){
                System.debug('Quote Trigger IsUpdate');
                if( !System.isFuture() && !System.isBatch() && Limits.getQueueableJobs()<Limits.getLimitQueueableJobs()  && Limits.getFutureCalls() < Limits.getLimitFutureCalls() ){
                    Boolean billSiteUpdated = false;
                    List<SBQQ__Quote__c> newList=new List<SBQQ__Quote__c>();
                    Map<id,SBQQ__Quote__c> oldMap = new Map<id,SBQQ__Quote__c>();
                    for(SBQQ__Quote__c tQuote : Trigger.new){
                        SBQQ__Quote__c oldQuote = Trigger.oldMap.get(tQuote.Id);
                        if(tQuote.qtc_Bill_To_Site__c != oldQuote.qtc_Bill_To_Site__c){ 
                            newList.add(tQuote);
                            oldMap.put(tQuote.Id,oldQuote);
                        }
                    }
                    if(newList.size()>0){
                        System.debug('Calling CPQMyNcrRequestAsync from trigger ');
                        System.enqueueJob(new CPQMyNcrRequestAsync(newList,oldMap));
                    }
                }  
            }
        }
    }
}