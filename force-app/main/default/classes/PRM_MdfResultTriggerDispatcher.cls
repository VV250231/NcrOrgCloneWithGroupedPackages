public with sharing class PRM_MdfResultTriggerDispatcher extends TriggerHandlerBase {
    private static PRM_MdfResultTriggerHandler mdfResultHdlr;
    
    public override void beforeInsert() {
        mdfResultHdlr = (mdfResultHdlr != null) ? mdfResultHdlr : new PRM_MdfResultTriggerHandler();
        List<Partner_Fund_ROI__c  > newmdfResultLst = (List<Partner_Fund_ROI__c >)Trigger.new;
        mdfResultHdlr.updatePartnerInfo(newmdfResultLst);

    }

    public override void afterInsert() {
        mdfResultHdlr = (mdfResultHdlr != null) ? mdfResultHdlr : new PRM_MdfResultTriggerHandler();
        List<Partner_Fund_ROI__c  > newmdfResultLst = (List<Partner_Fund_ROI__c >)Trigger.new;
        PopulateTotalMDFROI.PopulateTotalROIfromPFROI(newmdfResultLst);

    }

    public override void beforeUpdate() {
        mdfResultHdlr = (mdfResultHdlr != null) ? mdfResultHdlr : new PRM_MdfResultTriggerHandler();
        List<Partner_Fund_ROI__c  > newmdfResultLst = (List<Partner_Fund_ROI__c >)Trigger.new;
        mdfResultHdlr.updatePartnerInfo(newmdfResultLst);
        
    }

    public override void afterUpdate() {
        mdfResultHdlr = (mdfResultHdlr != null) ? mdfResultHdlr : new PRM_MdfResultTriggerHandler();
        List<Partner_Fund_ROI__c  > newmdfResultLst = (List<Partner_Fund_ROI__c >)Trigger.new;
        PopulateTotalMDFROI.PopulateTotalROIfromPFROI(newmdfResultLst);

    }
}