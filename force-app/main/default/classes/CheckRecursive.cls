/*
 *Author: sm250665
 */
public with sharing class CheckRecursive
{
   /*
    * @return Boolean
    * Purpose : To avoid Recursion in class or trigger.
    */
   public static boolean run = true;
    public static boolean runOppRelatedObj = true;
   public static boolean copyBillingAccountRun = true;
   public static boolean runCreateIdeaHistory = true;
   public static boolean runStatusChangeNotification = true;
   public static boolean sendOppOwnerNotification = true;
   public static boolean runCalcACV = true;
   public static boolean usmOutBoundCallRun = true;
   public static Set<Id> QuoteRatePlanChrgUpdateSet = new Set<Id>();
   private static boolean leadConversionRun = true;
   //public static boolean RunOppValidationOnce = false;
   
   public static integer validateOppTriggerRunCount = 0;
   public static boolean oppAmountValidation = true;
   public static boolean OppSOCUpdtBatchRun = true;
    
   //add by RK250519 to stop recursive call of triggers when add product on quote
   public static boolean showErrorOnQuoteWizard = true;
   public static boolean UpdateQuoteBundleDetail = true;
   public static boolean insertQuoteProduct = true;
   public static boolean defaultChannelOfficeField = true;
   public static boolean PopulateNextTierRevenue = true;
   public static boolean enrollForChannelProgram = true;
   public static boolean UpdateDealStatusPartnerTerminated = true;
   public static boolean OpportunityTriggercheck = true;
   public static boolean OpportunityTriggerbypass = true;
    public static boolean runQLICalcOnce = true;
        public static boolean cpqSpclHdlg = false;
    public static boolean runQ2OppSyncOnce=true;
    public static boolean setAutoPOSValue = false;
    //Ajay--EBA_SF-1352--**/
    public static boolean cpq_OppAfterRunOnce = true;
    public static boolean cpq_OppBfrRunOnce = true;
    
    public static boolean runDfltSlsOrgOnce = true;
    
    //add by RK250519 lead conversion issue(syncToServiceNow method in contacttriggerdispatcher class)
    public static boolean syncToServiceNowchk = true;
    public static boolean BEFOREINSERTUpdateDIContact_Fieldchk = true;
    public static boolean BEFOREUPDATEUpdateDIContact_Fieldchk = true;
    public static boolean RenewalQuotechk1 = true;
    public static boolean RenewalQuotechk2 = true;
    
    public static boolean runRenewalQuotechk2()
    {
        if(RenewalQuotechk2)
        {
            RenewalQuotechk2=false;
            return true;
        }else
        {
            return RenewalQuotechk2;
        }
    }
    public static boolean runRenewalQuotechk1()
    {
        if(RenewalQuotechk1)
        {
            RenewalQuotechk1=false;
            return true;
        }else
        {
            return RenewalQuotechk1;
        }
    }
    public static boolean runsyncToServiceNowchk()
    {
        if(syncToServiceNowchk)
        {
            syncToServiceNowchk=false;
            return true;
        }else
        {
            return syncToServiceNowchk;
        }
    }
    public static boolean runBEFOREINSERTUpdateDIContact_Fieldchk()
    {
        if(BEFOREINSERTUpdateDIContact_Fieldchk)
        {
            BEFOREINSERTUpdateDIContact_Fieldchk=false;
            return true;
        }else
        {
            return BEFOREINSERTUpdateDIContact_Fieldchk;
        }
    }
    public static boolean runBEFOREUPDATEUpdateDIContact_Fieldchk()
    {
        if(BEFOREUPDATEUpdateDIContact_Fieldchk)
        {
            BEFOREUPDATEUpdateDIContact_Fieldchk=false;
            return true;
        }else
        {
            return BEFOREUPDATEUpdateDIContact_Fieldchk;
        }
    }
    //end
    
    public static boolean runOppRelatedObject() {
        if(runOppRelatedObj){
            runOppRelatedObj = false;
            return true;
        }
        else
            return runOppRelatedObj;
    }
    
    public static boolean runOpportunityTriggercheck()
    {
        if(OpportunityTriggercheck)
        {
            OpportunityTriggercheck=false;
            return true;
        }else
        {
            return OpportunityTriggercheck;
        }
    }
    public static boolean runshowErrorOnQuoteWizard()
    {
        if(showErrorOnQuoteWizard)
        {
            showErrorOnQuoteWizard=false;
            return true;
        }else
        {
            return showErrorOnQuoteWizard;
        }
    }
    public static boolean runUpdateQuoteBundleDetail()
    {
        if(UpdateQuoteBundleDetail)
        {
            UpdateQuoteBundleDetail=false;
            return true;
        }else
        {
            return UpdateQuoteBundleDetail;
        }
    }
    public static boolean runinsertQuoteProduct()
    {
        if(insertQuoteProduct)
        {
            insertQuoteProduct=false;
            return true;
        }else
        {
            return insertQuoteProduct;
        }
    }
    public static boolean rundefaultChannelOfficeField()
    {
        if(defaultChannelOfficeField)
        {
            defaultChannelOfficeField=false;
            return true;
        }else
        {
            return defaultChannelOfficeField;
        }
    }
    public static boolean runPopulateNextTierRevenue()
    {
        if(PopulateNextTierRevenue)
        {
            PopulateNextTierRevenue=false;
            return true;
        }else
        {
            return PopulateNextTierRevenue;
        }
    }
    public static boolean runenrollForChannelProgram()
    {
        if(enrollForChannelProgram)
        {
            enrollForChannelProgram=false;
            return true;
        }else
        {
            return enrollForChannelProgram;
        }
    }
    public static boolean runUpdateDealStatusPartnerTerminated()
    {
        if(UpdateDealStatusPartnerTerminated)
        {
            UpdateDealStatusPartnerTerminated=false;
            return true;
        }else
        {
            return UpdateDealStatusPartnerTerminated;
        }
    }
    
    //end of Code - By RK250519
    
    public static boolean runOnce()
    {
        if(run)
        {
             run=false;
             return true;
        }else
        {
            return run;
        }
    }
    public static boolean usmOutBoundCallRunCheck()
    {
        if(usmOutBoundCallRun)
        {
             usmOutBoundCallRun=false;
             return true;
        }else
        {
            return usmOutBoundCallRun;
        }
    }
    
    public static boolean runCopyBillingAccountOnce()
    {
        if(copyBillingAccountRun) {
            copyBillingAccountRun = false;
            return true;
        }else {
            return copyBillingAccountRun;
        }
    }
    
    public static boolean runCreateIdeaHistoryOnce() {
        if (runCreateIdeaHistory) {
            runCreateIdeaHistory = false;
            return true;
        } else {
          return runCreateIdeaHistory;
        }
    }
    
    public static boolean runStatusChangeNotificationOnce() {
        if (runStatusChangeNotification) {
            runStatusChangeNotification = false;
            return true;
        } else {
          return runStatusChangeNotification;
        }
    }
    
    public static boolean runSendEmailToOppOwnerOnce() {
        if(sendOppOwnerNotification) {
            sendOppOwnerNotification = false;
            return true;
        } else {
            return sendOppOwnerNotification;
        }
    }
    
    public static boolean runCalcACVOnce() {
        if(runCalcACV) {
            runCalcACV = false;
            return true;
        } else {
            return runCalcACV ;
        }
    }
   
    
    public static Map<Id, Boolean> getProcessedChargeMap(Set<Id> QRPCIds) {
        Map<Id, Boolean> zChargeProcessedMap = new Map<Id, Boolean>();
        
        for(Id chargeId : QRPCIds) {
            if (QuoteRatePlanChrgUpdateSet.contains(chargeId)) {
                zChargeProcessedMap.put(chargeId, true);    
            } else {
                zChargeProcessedMap.put(chargeId, false);
            }     
        }
        return zChargeProcessedMap;  
    }
    
    public static void addChargeToProcessedSet(Set<Id> QRPCIds) {
        QuoteRatePlanChrgUpdateSet.addAll(QRPCIds);  
    }
    
    public static boolean runValiateOppTrigger() {
        if (validateOppTriggerRunCount > 1) {
            return false;    
        }
        return true;
    } 
    
    public static void addValOppTriggerRun() {
        validateOppTriggerRunCount++;
    }
    
    public static boolean runoppAmountValidation() {
         if(oppAmountValidation) {
            oppAmountValidation = false;
            return true;
        } else {
            return oppAmountValidation ;
        }
    }
    
    public static void resetOppAmountValidation() {
        oppAmountValidation = true;    
    }
    
    public static boolean checkLeadConversionRun() {
         if(leadConversionRun) {
            leadConversionRun= false;
            return true;
        } else {
            return leadConversionRun;
        }
    }
    
    public static boolean checkOppOrgUpdtBtchRun() {
         if(OppSOCUpdtBatchRun) {
            OppSOCUpdtBatchRun = false;
            return true;
        } else {
            return OppSOCUpdtBatchRun;
        }
    }
    // CPQ quote line recalc once
    public static boolean runQLICalcOnce() {
        if(runQLICalcOnce) {
            runQLICalcOnce=false;
            return true;
        } else {
            return runQLICalcOnce;
        }
    }
    // CPQ quote line recalc once
    public static boolean runQ2OppSyncOnce() {
        if(runQ2OppSyncOnce) {
            runQ2OppSyncOnce=false;
            return true;
        } else {
            return runQ2OppSyncOnce;
        }
    }
    
     // CPQ quote line recalc once
    public static boolean runDfltSlsOrgOnce() {
        if(runDfltSlsOrgOnce) {
            runDfltSlsOrgOnce=false;
            return true;
        } else {
            return runDfltSlsOrgOnce;
        }
    }
}