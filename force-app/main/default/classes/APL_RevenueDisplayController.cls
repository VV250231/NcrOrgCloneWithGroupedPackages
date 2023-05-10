public without sharing class APL_RevenueDisplayController {
    final static String HW_MAINT = 'HARDWARE MAINTENANCE'; 
    final static String SW_MAINT  = 'SW MAINTENANCE';
    final static String MGD_SRVS = 'MANAGED SERVICES';
    final static String TIME_AND_MTRLS = 'TIME AND MATERIALS';
        
    @AuraEnabled//(cacheable =true)
    public static RevenueWrapper getRevenueByCategory(String accID) {
        Map<String, Decimal> fmlAccCodeRevMap = new Map<String, Decimal>();
        RevenueWrapper revWrp = new RevenueWrapper();
        
        List<APL_Account_Revenue__c> revLst = [Select fml_account_code__c, USD_Amount__c 
                                                    from APL_Account_Revenue__c where Account__c = :accID];
        
        for(APL_Account_Revenue__c ar : revLst) {
            if(String.isNotBlank(ar.fml_account_code__c)) fmlAccCodeRevMap.put(ar.fml_account_code__c, ar.USD_Amount__c);   
        }
        
        if (!fmlAccCodeRevMap.isEmpty()) {
            Map<String, String> FMLCodevsRevCatMap = new Map<String, String>();
            for(APL_Revenue_Category_Mapping__c revCat : [SELECT Id, FML_Account_Code__c,Category__c 
                                                                FROM APL_Revenue_Category_Mapping__c 
                                                                WHERE FML_Account_Code__c IN :fmlAccCodeRevMap.keySet()]) {
                
                if(String.isNotBlank(revCat.Category__c)){
                    FMLCodevsRevCatMap.put(revCat.FML_Account_Code__c, revCat.Category__c.left(revCat.Category__c.indexOf('_'))); 
                }
            }
            
            for(String fmlCode : FMLCodevsRevCatMap.keySet()) {                                                   
                Decimal fmlCodeRevAmt = fmlAccCodeRevMap.get(fmlCode); 
                String revCat = FMLCodevsRevCatMap.get(fmlCode);
                    
                if(String.isNotBlank(revCat)) {
                    if(revCat == HW_MAINT ) {       
                        revWrp.HWM_Value += fmlCodeRevAmt;
                        
                    } else if(revCat == SW_MAINT) {
                        revWrp.SWM_Value += fmlCodeRevAmt;
                        
                    } else if(revCat == MGD_SRVS) {
                        revWrp.ManagedServices_Value += fmlCodeRevAmt;
                                 
                    } else if(revCat == TIME_AND_MTRLS) {
                        revWrp.TM_Value += fmlCodeRevAmt;     
                    }                                                        
                } 
            }
        }
        return revWrp;
    }
    
    public class RevenueWrapper {
        @AuraEnabled
        public Decimal HWM_Value; 
        @AuraEnabled
        public Decimal SWM_Value;
        @AuraEnabled
        public Decimal ManagedServices_Value;
        @AuraEnabled
        public Decimal TM_Value;

        public RevenueWrapper() {
            this.HWM_Value = 0;
            this.SWM_Value = 0;
            this.ManagedServices_Value = 0;
            this.TM_Value = 0;
        }
    }
}