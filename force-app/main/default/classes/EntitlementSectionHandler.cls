public with sharing class EntitlementSectionHandler {
    
    @AuraEnabled(cacheable =true)
    public static list<Account_Entitlements__c> getAccountEntitlementList(String accountRecordID){
       List<Account_Entitlements__c> acctEntlsLst = new List<Account_Entitlements__c>(); 
      if(accountRecordID != null){
           acctEntlsLst = [SELECT Id, Hold_Count__c, Expired_Warranty_Count__c, Expired_Count__c, Active_Count__c, Primary_Product_Desc__c, Product_Id__c, Unique_Key__c FROM Account_Entitlements__c where Account__c = :accountRecordID];
       }
       return acctEntlsLst;
    }
}