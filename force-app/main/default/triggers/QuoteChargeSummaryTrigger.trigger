trigger QuoteChargeSummaryTrigger on zqu__QuoteChargeSummary__c (before insert, before update) {
    Set<Id> quoteRatePlanIds = new Set<Id>();
    for(zqu__QuoteChargeSummary__c qcs : Trigger.new) {
        if(qcs.zqu__QuoteRatePlan__c != null) {
            quoteRatePlanIds.add(qcs.zqu__QuoteRatePlan__c);
        }
    }
    
    Map<Id, Id> quoteIdsByQuoteRatePlanId = new Map<Id, Id>();
    for(zqu__QuoteRatePlan__c qrp : [select Id, zqu__Quote__c from zqu__QuoteRatePlan__c where Id in :quoteRatePlanIds]) {
        quoteIdsByQuoteRatePlanId.put(qrp.Id, qrp.zqu__Quote__c);
    }

    for(zqu__QuoteChargeSummary__c qcs : Trigger.new) {
        if(qcs.zqu__QuoteRatePlan__c != null && quoteIdsByQuoteRatePlanId.containsKey(qcs.zqu__QuoteRatePlan__c)) {
            qcs.Quote__c = quoteIdsByQuoteRatePlanId.get(qcs.zqu__QuoteRatePlan__c);
        }
    }
}