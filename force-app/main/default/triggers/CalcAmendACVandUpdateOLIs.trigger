trigger CalcAmendACVandUpdateOLIs on zqu__QuoteAmendment__c (after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
             Set<ID> zQuoteIds = new Set<ID>();
             
             for (zqu__QuoteAmendment__c quoteAmd : Trigger.old) {
                 if (quoteAmd.zqu__Quote__c != null) {
                     zQuoteIds.add(quoteAmd.zqu__Quote__c);
                 }    
             } 
             if(!zQuoteIds.isEmpty()) new ZuoraChargeUtil().calcACVFromQuote(zQuoteIds);    
        } else if (Trigger.isUndelete){
            Set<ID> zQuoteIds = new Set<ID>();
            
            for (zqu__QuoteAmendment__c quoteAmd : Trigger.new) {
                 if (quoteAmd.zqu__Quote__c != null) {
                     zQuoteIds.add(quoteAmd.zqu__Quote__c);
                 }    
            }
            if(!zQuoteIds.isEmpty()) new ZuoraChargeUtil().calcACVFromQuote(zQuoteIds);            
        }
    }
}