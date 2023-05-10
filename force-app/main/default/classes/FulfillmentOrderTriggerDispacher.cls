/****************************************************************************************************************
*   ClassName :   FulfillmentOrderTriggerDispacher
*   Description :   
*   Author      :   DP250110
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
****************************************************************************************************************/

public class FulfillmentOrderTriggerDispacher extends TriggerHandlerBase {
	private static FulfillmentOrderTriggerHandler foTriggerHdlr;
   
    public override void afterInsert(){
        foTriggerHdlr = (foTriggerHdlr != null) ? foTriggerHdlr : new FulfillmentOrderTriggerHandler();
        foTriggerHdlr.afterUpdateInsertFO((List<qtc_FulfillmentOrder__c>)Trigger.New,(Map<Id,qtc_FulfillmentOrder__c>)Trigger.oldMap,false);
    }
    
    public override void afterUpdate(){
    	foTriggerHdlr = (foTriggerHdlr != null) ? foTriggerHdlr : new FulfillmentOrderTriggerHandler();  
        foTriggerHdlr.afterUpdateInsertFO((List<qtc_FulfillmentOrder__c>)Trigger.New,(Map<Id,qtc_FulfillmentOrder__c>)Trigger.oldMap,true);
    }
 
}