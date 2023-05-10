public without sharing class APL_HierarchyRevenueDisplayController {
    final static String HARDWARE_MAINTENANCE = 'HARDWARE MAINTENANCE';
    final static String SW_MAINTENANCE  = 'SW MAINTENANCE';
    final static String MANAGED_SERVICES = 'MANAGED SERVICES';
    final static String TIME_AND_MATERIALS = 'TIME AND MATERIALS';
        
    @AuraEnabled(cacheable =true)
    public static RevenueWrapper getRevenueByCategory(String accountID) {
        System.debug('accountID>>' + accountID);
        Set<Id> allAccountIds = findChildAccountIds(new Set<Id>{accountID});
        Map<String, Decimal> fmlAccCodeRevMap = new Map<String, Decimal>();
        RevenueWrapper revWrapper = new RevenueWrapper();
        
        List<APL_Account_Revenue__c> revenueList = [Select fml_account_code__c, Account__c, customer_nbr__c, USD_Amount__c 
                                                    from APL_Account_Revenue__c where Account__c IN :allAccountIds];
        
        for(APL_Account_Revenue__c rev : revenueList) {
        	if(String.isNotBlank(rev.fml_account_code__c))
            
            if(fmlAccCodeRevMap.containsKey(rev.fml_account_code__c)) {
            	 fmlAccCodeRevMap.put(rev.fml_account_code__c, rev.USD_Amount__c + fmlAccCodeRevMap.get(rev.fml_account_code__c));     
            } else {
            	 fmlAccCodeRevMap.put(rev.fml_account_code__c, rev.USD_Amount__c);     
            }
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
            
            for(String fmlAccCode : FMLCodevsRevCatMap.keySet()) {                                                   
                Decimal fmlCodeRevAmount = fmlAccCodeRevMap.get(fmlAccCode); 
                String ActualRevCat = FMLCodevsRevCatMap.get(fmlAccCode);
                    
                if(String.isNotBlank(ActualRevCat)) {
               		if(ActualRevCat == HARDWARE_MAINTENANCE ) {		
                    	revWrapper.HWM_Value += fmlCodeRevAmount;
                        
                    } else if(ActualRevCat == SW_MAINTENANCE) {
                     	revWrapper.SWM_Value += fmlCodeRevAmount;
                        
                    } else if(ActualRevCat == MANAGED_SERVICES) {
                        revWrapper.ManagedServices_Value += fmlCodeRevAmount;
                                 
                    } else if(ActualRevCat == TIME_AND_MATERIALS) {
                        revWrapper.TM_Value += fmlCodeRevAmount;     
                    }                                                        
                } 
            }
        }
        System.debug(revWrapper);
        return revWrapper;
    }


    public static Set<Id> findChildAccountIds(Set<Id> parentAccIds) {
        Set<Id> outputAccIds = new Set<Id>();
        outputAccIds.addAll(parentAccIds);

        Map<Id, Account> accountMap = new  Map<Id, Account>([SELECT Id, Name, ParentId FROM Account where ParentId IN :parentAccIds]);

        if(!accountMap.isEmpty()) {
            Set<Id> childAcctIds = findChildAccountIds(accountMap.keySet());

            if (childAcctIds != null && !childAcctIds.isEmpty()) {
                outputAccIds.addAll(childAcctIds);
            }
        }
        return outputAccIds;
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