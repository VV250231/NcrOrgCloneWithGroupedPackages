/**************************************
  Author ...............: Sanjay Pandit
  Date Created .........: 22-Sep-2020
  Last Modified By .....:
  Last Modified Date ...: 
  Description ..........: SC2015_AGL-5787, Trigger Consolidation  (CalcACVandAddOLIs/defaultChannelOfficeField)
***************************************/
trigger ZuoraQuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (before insert, after insert, before update, after update, after delete, after undelete) 
{
    ZuoraQuoteRatePlanChargeTriggerHelper zqrpcHelper=new ZuoraQuoteRatePlanChargeTriggerHelper();
    
    if(Trigger.isBefore){     
        if(Trigger.isInsert){
            zqrpcHelper.onBeforeInsertCalcACVandAddOLIs(Trigger.New);
            
            //For Default Channel Office Fields
            if(!test.isRunningTest()){
            if(checkRecursive.rundefaultChannelOfficeField()){
                zqrpcHelper.onBeforeInsertdefaultChannelOfficeField(Trigger.New);
            }
                }
        }
        else if(Trigger.isUpdate){
            zqrpcHelper.onBeforeUpdateCalcACVandAddOLIs(Trigger.New,Trigger.OldMap,Trigger.newMap);
             //For Default Channel Office Fields
             if(checkRecursive.rundefaultChannelOfficeField()){
                zqrpcHelper.onBeforeUpdatedefaultChannelOfficeField(Trigger.New);
             }
        }
    }
        
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            zqrpcHelper.onAfterInsertCalcACVandAddOLIs(Trigger.newMap);
        }
        else if(Trigger.isUpdate){
            zqrpcHelper.onAfterUpdateCalcACVandAddOLIs(Trigger.New,Trigger.oldMap,Trigger.newMap);
        }
        else if(Trigger.isDelete){
            zqrpcHelper.onAfterDeleteCalcACVandAddOLIs(Trigger.Old);
        }
        else if(Trigger.isUnDelete){
            zqrpcHelper.onAfterUnDeleteCalcACVandAddOLIs(Trigger.newMap);
        }
    }
}