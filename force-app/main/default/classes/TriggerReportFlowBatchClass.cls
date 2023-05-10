/****************************************************************************************************************
*   ClassName   : TriggerReportFlowBatchClass
*   Description : Use to edit Email Tracking records . so that flow can be triggerd.  
*   Author      : Md Raza 
*   Version     : Initial
# Modification History.: 
Story No#         Date            DevName                Description
05 Aug 2022     Md Raza                Use to edit Email Tracking records . so that flow can be triggerd.
****************************************************************************************************************/
global class TriggerReportFlowBatchClass Implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
       //conversion of time zones
        DateTime dtTime=DateTime.now();
        TimeZone tz = UserInfo.getTimeZone(); 
        Integer offset=tz.getOffset(dtTime);
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone('America/New_York');
        integer offsetTotargetTZ = targetTZ.getOffset(dtTime);
        integer correction = offsetTotargetTZ- offset;
        DateTime targetDT = dtTime.addMinutes(correction / (1000 * 60));
        Time currentTime = Time.newInstance(targetDT.hour(), targetDT.minute(), targetDT.second(), targetDT.millisecond());
        /*End*/
        return Database.getQueryLocator([SELECT Id,Is_Batch_Triggered_on_End_Date__c,Start_Date__c,End_Date__c,Schedule_Time__c,Frequency__c,NextBatchDate__c,(SELECT Id,updatedByBatch__c FROM Email_Recipient__r ) FROM Schedule_External_Report__c where NextBatchDate__c =:Date.valueof(targetDT) and schedule_time__c <=:currentTime and schedule_time__c >=:currentTime.addMinutes(-30) and Is_Batch_Triggered_on_End_Date__c=false ]);
    }
    global void execute(Database.BatchableContext BC, list<Schedule_External_Report__c> srList){
        List<Email_Recipient__c> listToBeUpdated = new List<Email_Recipient__c>();
        List<Schedule_External_Report__c> nextBatchDateUpdate = new List<Schedule_External_Report__c>();
     
        for(Schedule_External_Report__c src: srList){
                if(src.Email_Recipient__r.size()>0){
                    for(Email_Recipient__c et : src.Email_Recipient__r){ 
                        if(et.updatedByBatch__c == true){
                            et.updatedByBatch__c = false;
                        }
                        else if(et.updatedByBatch__c == false){
                            et.updatedByBatch__c = true;
                        }
                        listToBeUpdated.add(et);
                    }
                    if(src.Frequency__c == 'Daily' && src.NextBatchDate__c != null){
                        src.NextBatchDate__c = src.NextBatchDate__c.addDays(1);
                    }
                    else if(src.Frequency__c == 'Weekly' && src.NextBatchDate__c != null){
                        src.NextBatchDate__c = src.NextBatchDate__c.addDays(7);
                    }
                    else if(src.Frequency__c == 'Monthly' && src.NextBatchDate__c != null){
                        src.NextBatchDate__c = src.NextBatchDate__c.addMonths(1);
                    }
                    else if(src.Frequency__c == 'Quarterly' && src.NextBatchDate__c != null){
                        src.NextBatchDate__c = src.NextBatchDate__c.addMonths(3);
                    }
                    else if(src.Frequency__c == 'Yearly' && src.NextBatchDate__c != null){
                        src.NextBatchDate__c = src.NextBatchDate__c.addYears(1);
                    }
                    if(src.NextBatchDate__c <= src.End_Date__c){
                        nextBatchDateUpdate.add(src);
                    }
                    else{
                        src.NextBatchDate__c = src.NextBatchDate__c.addDays(-1);
                       src.Is_Batch_Triggered_on_End_Date__c = true;
                        nextBatchDateUpdate.add(src);
                    }
                       
                }
        }
        if(listToBeUpdated.size()>0){
            update listToBeUpdated;
        }
        if(nextBatchDateUpdate.size()>0){
            update nextBatchDateUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        string cronID = system.scheduleBatch(new TriggerReportFlowBatchClass(), 'Schedule External Report Batch', 10, 1);
    }
}