public with sharing class EntitlementSectionHierarchy {

    @AuraEnabled(cacheable =true)
    public static WrapEntitlementWithTotal2 getAccountEntitlementList( String accountRecordID  ){
        Set<Id> allAccountIds = findChildAccountIds(new Set<Id>{accountRecordID});
        System.debug('accountRecordID>>' + accountRecordID);
        List<Account_Entitlements__c> accountEntitlementsList = new List<Account_Entitlements__c>(); 
        Set <String> prodDesc=new Set<String>();
        if(accountRecordID != null){
            accountEntitlementsList = [SELECT Id, Account__r.RecordType.Name, Hold_Count__c, Expired_Warranty_Count__c, Expired_Count__c, Active_Count__c, Account__c, Primary_Product_Desc__c, Master_Customer_Number__c, Product_Id__c, Unique_Key__c, Name FROM Account_Entitlements__c where Account__c IN :allAccountIds];
        }
        List<Account_Entitlements__c> oh=new List<Account_Entitlements__c>();

        Decimal totalHoldCount = 0;
        Decimal totalActiveCount = 0;
        Decimal totalExpCount = 0;
        Decimal totalExpWarCount = 0;
        System.debug('accountEntitlementsList : '+accountEntitlementsList);

        for(Account_Entitlements__c gh: accountEntitlementsList){
            System.debug('@@@' + gh);
            WrapEntitlementWithTotal wrapObj = new WrapEntitlementWithTotal();
            if(prodDesc.contains(gh.Primary_Product_Desc__c))  {
                for(Account_Entitlements__c ohh:oh){
                    if(ohh.Primary_Product_Desc__c==gh.Primary_Product_Desc__c){
                    if(gh.Hold_Count__c!=null)
                        ohh.Hold_Count__c= (ohh.Hold_Count__c != null ? ohh.Hold_Count__c : 0) +gh.Hold_Count__c; 
                    if(gh.Expired_Warranty_Count__c!=null)
                        ohh.Expired_Warranty_Count__c= (ohh.Expired_Warranty_Count__c != null ? ohh.Expired_Warranty_Count__c : 0) + gh.Expired_Warranty_Count__c;
                    if(gh.Active_Count__c!=null)
                        ohh.Active_Count__c= (ohh.Active_Count__c != null ? ohh.Active_Count__c : 0) + gh.Active_Count__c;
                    if(gh.Expired_Count__c!=null)
                        ohh.Expired_Count__c= (ohh.Expired_Count__c != null ? ohh.Expired_Count__c : 0) + gh.Expired_Count__c;
                    }
                }
                totalActiveCount += (gh.Active_Count__c != null ? gh.Active_Count__c : 0);
                totalHoldCount += (gh.Hold_Count__c != null ?  gh.Hold_Count__c : 0);
                totalExpCount += (gh.Expired_Count__c != null ? gh.Expired_Count__c : 0);
                totalExpWarCount += (gh.Expired_Warranty_Count__c != null ? gh.Expired_Warranty_Count__c : 0);

            }else{
                wrapObj.prodDes = gh.Primary_Product_Desc__c;
                wrapObj.activeCount = gh.Active_Count__c;                
                totalActiveCount += (gh.Active_Count__c != null ? gh.Active_Count__c : 0);
                wrapObj.holdCount = gh.Hold_Count__c;
                totalHoldCount += (gh.Hold_Count__c != null ?  gh.Hold_Count__c : 0);
                wrapObj.expCount = gh.Expired_Count__c;
                totalExpCount += (gh.Expired_Count__c != null ? gh.Expired_Count__c : 0);
                wrapObj.ExpWarCount = gh.Expired_Warranty_Count__c;
                totalExpWarCount += (gh.Expired_Warranty_Count__c != null ? gh.Expired_Warranty_Count__c : 0);
                System.debug('gh : '+gh);
                oh.add(gh);
                prodDesc.add(gh.Primary_Product_Desc__c);
            }        
        }
        WrapEntitlementWithTotal2 wrapClassObj = new WrapEntitlementWithTotal2();
        WrapEntitlementWithTotal wrapObjLast = new WrapEntitlementWithTotal();
        wrapObjLast.prodDes = 'Total';
        wrapObjLast.activeCount = totalActiveCount;
        wrapObjLast.holdCount = totalHoldCount;
        wrapObjLast.expCount = totalExpCount;
        wrapObjLast.ExpWarCount = totalExpWarCount;
        wrapClassObj.wrap = wrapObjLast;
        wrapClassObj.entitlementList = oh;
    
        return wrapClassObj;
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


    public class WrapEntitlementWithTotal{
        @AuraEnabled
        public String prodDes;
        @AuraEnabled
        public Decimal activeCount;
        @AuraEnabled
        public Decimal holdCount;
        @AuraEnabled
        public Decimal expCount;
        @AuraEnabled
        public Decimal ExpWarCount;
    }
    public class WrapEntitlementWithTotal2{
        @AuraEnabled
        public WrapEntitlementWithTotal wrap;
        @AuraEnabled
        public List<Account_Entitlements__c> entitlementList;
    }
}