/*************************************************************************************************
*   ClassName   : PRM_MdfClaimDispatcher
*   Description :   
*   Author      :   
# Modification History.: 
Story No         Date           DevName         Description
EBA_SF-1948     20-10-2022      KAVYA SREE      Technical Debt - Apex sharing violation part 2 -PRM 
*************************************************************************************************/
public  without sharing class PRM_MdfClaimDispatcher extends TriggerHandlerBase {
    private static PRM_MdfClaimHandler mdfClaimHdlr;
    
    /* MDF Claim before Insert*/
    public override void beforeInsert() {
        mdfClaimHdlr = (mdfClaimHdlr != null) ? mdfClaimHdlr : new PRM_MdfClaimHandler();
        List<SFDC_MDF_Claim__c > newMdfClaimLst = (List<SFDC_MDF_Claim__c>)Trigger.new;
        mdfClaimHdlr.creatClaimId(newMdfClaimLst);
        mdfClaimHdlr.updateTrasactionRefOnMDFReq(newMdfClaimLst);
        mdfClaimHdlr.updateFundClaimChannelManager(newMdfClaimLst);
    }

    /* MDF Claim After Insert*/
    public override void afterInsert() {
        mdfClaimHdlr = (mdfClaimHdlr != null) ? mdfClaimHdlr : new PRM_MdfClaimHandler();
        List<SFDC_MDF_Claim__c > newMdfClaimLst = (List<SFDC_MDF_Claim__c>)Trigger.new;
        mdfClaimHdlr.totalClaimCount(newMdfClaimLst);
        mdfClaimHdlr.updateClaimInfoOnMDF(newMdfClaimLst);
        mdfClaimHdlr.updateAccrualBalanceAIAU(newMdfClaimLst);
        mdfClaimHdlr.populateFundRequestReleasedMonthAndYear((Map<Id, SFDC_MDF_Claim__c>)Trigger.newMap,null);
        if(!Test.isRunningTest()){
            BatchShareMDFClaim obj = new BatchShareMDFClaim(Trigger.newMap.KeySet());
            Database.executeBatch(obj, 1); 
        }
    }

    /* MDF Claim before Update*/
    public override void beforeUpdate() {
        mdfClaimHdlr = (mdfClaimHdlr != null) ? mdfClaimHdlr : new PRM_MdfClaimHandler();
        List<SFDC_MDF_Claim__c > newMdfClaimLst = (List<SFDC_MDF_Claim__c>)Trigger.new;
        mdfClaimHdlr.creatClaimId(newMdfClaimLst);
        mdfClaimHdlr.updateTrasactionRefOnMDFReq(newMdfClaimLst);
        mdfClaimHdlr.updateFundClaimChannelManager(newMdfClaimLst);
    }

    /* MDF Claim After Update*/
    public override void afterUpdate() {
        mdfClaimHdlr = (mdfClaimHdlr != null) ? mdfClaimHdlr : new PRM_MdfClaimHandler();
        List<SFDC_MDF_Claim__c > newMdfClaimLst = (List<SFDC_MDF_Claim__c>)Trigger.new;
        mdfClaimHdlr.totalClaimCount(newMdfClaimLst);
        mdfClaimHdlr.updateClaimInfoOnMDF(newMdfClaimLst);
        mdfClaimHdlr.updateAccrualBalanceAIAU(newMdfClaimLst);
        mdfClaimHdlr.populateFundRequestReleasedMonthAndYear((Map<Id, SFDC_MDF_Claim__c>)Trigger.newMap,(Map<Id, SFDC_MDF_Claim__c>)Trigger.oldMap);
    }
    
    /* MDF Claim after delete*/
    public override void afterDelete( ) {
        mdfClaimHdlr = (mdfClaimHdlr != null) ? mdfClaimHdlr : new PRM_MdfClaimHandler();
        List<SFDC_MDF_Claim__c > oldMdfClaimLst = (List<SFDC_MDF_Claim__c>)Trigger.old;
        mdfClaimHdlr.totalClaimCount(oldMdfClaimLst);
    }
}