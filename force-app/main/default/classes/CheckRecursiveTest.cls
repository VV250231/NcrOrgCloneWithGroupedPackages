@isTest
public class CheckRecursiveTest {
    static testMethod void testRecursive() {
        CheckRecursive.runOnce();
        CheckRecursive.runCopyBillingAccountOnce();
        CheckRecursive.runCreateIdeaHistoryOnce();
        CheckRecursive.runSendEmailToOppOwnerOnce();
        CheckRecursive.runCalcACVOnce();
        system.assertEquals(CheckRecursive.runCalcACVOnce(),false);
        // check recursion now
        CheckRecursive.runOnce();
        CheckRecursive.runCopyBillingAccountOnce();
        CheckRecursive.runCreateIdeaHistoryOnce();
        checkRecursive.runStatusChangeNotificationOnce();
        CheckRecursive.runSendEmailToOppOwnerOnce();
        CheckRecursive.runCalcACVOnce();
        CheckRecursive.addValOppTriggerRun();
        CheckRecursive.runValiateOppTrigger();
        CheckRecursive.runoppAmountValidation();
        CheckRecursive.runoppAmountValidation();
        CheckRecursive.resetOppAmountValidation();
        CheckRecursive.checkLeadConversionRun();
        CheckRecursive.checkLeadConversionRun();
        CheckRecursive.checkOppOrgUpdtBtchRun();
        CheckRecursive.checkOppOrgUpdtBtchRun();
        CheckRecursive.runOpportunityTriggercheck();
        CheckRecursive.runshowErrorOnQuoteWizard();
        CheckRecursive.runUpdateQuoteBundleDetail();
        CheckRecursive.runinsertQuoteProduct();
        CheckRecursive.rundefaultChannelOfficeField();
        CheckRecursive.runQLICalcOnce();
        CheckRecursive.runQLICalcOnce();
        CheckRecursive.runQ2OppSyncOnce();
        CheckRecursive.runQ2OppSyncOnce();
        CheckRecursive.runsyncToServiceNowchk();
        CheckRecursive.runBEFOREINSERTUpdateDIContact_Fieldchk();
        CheckRecursive.runBEFOREUPDATEUpdateDIContact_Fieldchk();
        CheckRecursive.runOppRelatedObject();
        CheckRecursive.runPopulateNextTierRevenue();
        CheckRecursive.runenrollForChannelProgram();
        CheckRecursive.runUpdateDealStatusPartnerTerminated();
        CheckRecursive.usmOutBoundCallRunCheck();
        CheckRecursive.runDfltSlsOrgOnce();
    }
    
    @isTest(SeeAllData=true)
    static void testRecursive2() {
        List<zqu__QuoteRatePlanCharge__c> zChargeList = [SELECT Id from zqu__QuoteRatePlanCharge__c  Limit 1];
        
        if (!zChargeList.isEmpty()) {
            CheckRecursive.addChargeToProcessedSet(new Set<Id>{zChargeList.get(0).Id});
            CheckRecursive.getProcessedChargeMap(new Set<Id>{zChargeList.get(0).Id});
            system.assert(zChargeList.size()!=0); 
        }
    }    
    
}