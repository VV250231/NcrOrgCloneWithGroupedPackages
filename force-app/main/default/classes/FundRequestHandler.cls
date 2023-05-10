public class FundRequestHandler {
    public static void beforeInsertHandler(List <SFDC_MDF__c> newList){
        Set<Id> accountIdSet =  new Set<Id>(); 
        for(SFDC_MDF__c fund : newList){
            if(fund.Account__c != null){
                accountIdSet.add(fund.Account__c);
            }
        }
        
        List<Account> accountList;
        Map<Id,Account> actIdToAccountMap = new Map<id,Account>([SELECT Id, LOB__c, Account_Region__c,Partner_Type__c FROM Account WHERE Id IN: accountIdSet]);
               
        for(SFDC_MDF__c fundReq : newList) {
            if (actIdToAccountMap.containsKey(fundReq.Account__C)){
                if (actIdToAccountMap.get(fundReq.Account__C).LOB__c != null) {
                    fundReq.LOB_from_Account__c = actIdToAccountMap.get(fundReq.Account__C).LOB__c;
                    System.debug('========@= LOB ===='+actIdToAccountMap.get(fundReq.Account__C).LOB__c);
                }
                if (actIdToAccountMap.get(fundReq.Account__C).Partner_Type__c != null) {
                    fundReq.Account_Partner_Type__c = actIdToAccountMap.get(fundReq.Account__C).Partner_Type__c;
                }
                if (actIdToAccountMap.get(fundReq.Account__C).Account_Region__c != null) {
                    fundReq.Region__c = actIdToAccountMap.get(fundReq.Account__C).Account_Region__c;
                }
            }
        }
    }
}