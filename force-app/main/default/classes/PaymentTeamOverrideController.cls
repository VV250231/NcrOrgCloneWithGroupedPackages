public with sharing class PaymentTeamOverrideController {
    static string PRODUCT_CODE_REVENUE_PER_TRANSACTION = 'RevenuePerTransaction';

    @AuraEnabled(cacheable=false)
    public static SBQQ__QuoteLine__c getQuoteLine(Id quoteId){
        return [SELECT Id, SBQQ__ListPrice__c 
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c = :quoteId
                AND SBQQ__ProductCode__c = :PRODUCT_CODE_REVENUE_PER_TRANSACTION
                AND SBQQ__UpgradedSubscription__c = null
                LIMIT 1];
    }

    @AuraEnabled
    public static String commitQuoteLine(Id quoteId, Id quoteLineId, Double listPriceValue){
        try {
            SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
                Id = quoteId,
                qtc_Payment_Team_Override__c = true
            );
            SBQQ__QuoteLine__c thisQuoteLine = new SBQQ__QuoteLine__c(
                Id = quoteLineId,
                SBQQ__ListPrice__c = listPriceValue
            );
            
            update thisQuoteLine;
            update thisQuote;

           
            return 'SUCCESS';

        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}