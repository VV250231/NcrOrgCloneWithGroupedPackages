public class CPQTriggerFOOnAutoPaySetup {
    
    @InvocableMethod(label= 'Update Quote To Sync FulfillmentOrder DateTime')
    public static List<Integer> updateQuoteToSyncFulfillmentOrder(List<String> aId) {
        String accID = aId.get(0);
        List<Integer> returnObj = new List<Integer>();
		//Code changed by PP185093 - SFCPQBLG-1399 - Q-22951 did not create the Fulfillment Order
        /*List<SBQQ__Quote__c> QuoteRec = [select id,qtc_Bill_To_Site__c,SBQQ__Opportunity2__r.ownerId,qtc_Legal_Document_Status__c,qtc_SyncFulfillmentOrderDateTime__c from SBQQ__Quote__c where  qtc_Bill_To_Site__c=:accID AND SBQQ__Opportunity2__r.CPQ__c = true AND SBQQ__Opportunity2__r.IsClosed = false AND (qtc_Bill_To_Site__r.AutoPay_Setup__c = 'True' OR qtc_Bill_To_Site__r.AutoPay_Setup__c = 'Manual')];*/
		
		List<SBQQ__Quote__c> QuoteRec = [select id,qtc_Bill_To_Site__c,SBQQ__Opportunity2__r.ownerId,qtc_Legal_Document_Status__c,
                   qtc_SyncFulfillmentOrderDateTime__c,qtc_EligibleForERP__c from SBQQ__Quote__c where  
                   qtc_Bill_To_Site__c=:accID AND SBQQ__Opportunity2__r.CPQ__c = true 
                   AND SBQQ__Opportunity2__r.IsClosed = false AND 
                   (qtc_Bill_To_Site__r.AutoPay_Setup__c = 'True' OR qtc_Bill_To_Site__r.AutoPay_Setup__c = 'Manual') 
                                         AND SBQQ__Ordered__c = false];
        List<SBQQ__Quote__c> quotes =	new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : QuoteRec){
            if(quote.qtc_Legal_Document_Status__c == 'Completed'){
                Integer count = [select count() from qtc_FulfillmentOrder__c where qtc_Quote__c =:quote.Id];
                if (count == 0 || String.isBlank(quote.qtc_EligibleForERP__c)){
                    quote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
                    quotes.add(quote);
                }
				/*qtc_FulfillmentOrder__c fo = [select id,Order_Interface_Status__c from qtc_FulfillmentOrder__c where qtc_Quote__c =:quote.Id];
				if(fo == null || String.isBlank(quote.qtc_EligibleForERP__c)){
					quote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
                    quotes.add(quote);
				}*/
            }
            
        }
        if(quotes.size() > 0){
            update quotes;
        }
        
        returnObj.add(quotes.size()); 
        return returnObj;
        
    }
    
}