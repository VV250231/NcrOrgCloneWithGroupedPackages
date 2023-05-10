/**************************************
  Author ...............: Sanjay Pandit
  Date Created .........: 22-Sep-2020
  Last Modified By .....:
  Last Modified Date ...: 
  Description ..........: SC2015_AGL-5787, Trigger Consolidation  (CalcACVandUpdateOLIs/defaultProductIdOnInsert)
***************************************/
trigger ZuoraQuoteRatePlanTrigger on zqu__QuoteRatePlan__c (before insert,after delete, after undelete, after update) {
   ZuoraQuoteRatePlanTriggerHelper zqrpHelper=new ZuoraQuoteRatePlanTriggerHelper();
    
    //Default product id insert
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            zqrpHelper.onBeforeInsertdefaultProductId(Trigger.New);
        }
    }
    
    //Call CalcACVandUpdateILIs
    if(Trigger.isAfter){
        if (Trigger.isDelete){
            zqrpHelper.OnAfterDeleteCalcACVandUpdateOLIs(Trigger.Old);
        }
        else if(Trigger.isUndelete){
             zqrpHelper.OnAfterUndeleteCalcACVandUpdateOLIs(Trigger.New);
        }
        else if(Trigger.isUpdate){
             zqrpHelper.OnAfterUpdateCalcACVandUpdateOLIs(Trigger.New,Trigger.oldMap);
        }
    }
}