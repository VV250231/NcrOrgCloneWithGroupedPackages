public class PRM_MdfTriggerDispatcher extends TriggerHandlerBase {
    private static PRM_MdfTriggerHandler mdfHdlr;
    
    /*MDF Before Insert*/
    public override void beforeInsert() {
        mdfHdlr = (mdfHdlr != null) ? mdfHdlr : new PRM_MdfTriggerHandler();
        List<SFDC_MDF__c > newMdfLst = (List<SFDC_MDF__c>)Trigger.new;
        mdfHdlr.updatePartnerAccountInfo(newMdfLst);
    }
    
    /* MDF After Insert*/
    public override void afterInsert() {
        mdfHdlr = (mdfHdlr != null) ? mdfHdlr : new PRM_MdfTriggerHandler();
        List<SFDC_MDF__c > newMdfLst = (List<SFDC_MDF__c>)Trigger.new;
        UpdateYTDFromRequest.UpdateYTDDataOnAccount(newMdfLst);
    }
    
    
    /*MDF after update */
    public override void afterUpdate() {
        mdfHdlr = (mdfHdlr != null) ? mdfHdlr : new PRM_MdfTriggerHandler();
        List<SFDC_MDF__c > newMdfLst = (List<SFDC_MDF__c>)Trigger.new;
        UpdateYTDFromRequest.UpdateYTDDataOnAccount(newMdfLst);
        mdfHdlr.updateMDFSharing((Map<id,SFDC_MDF__c>) Trigger.oldMap,(Map<id,SFDC_MDF__c>) Trigger.newMap);
        //mdfHdlr.reassignApproverOnChange((Map<id,SFDC_MDF__c>) Trigger.oldMap,(Map<id,SFDC_MDF__c>) Trigger.newMap);
        
    }
    
}