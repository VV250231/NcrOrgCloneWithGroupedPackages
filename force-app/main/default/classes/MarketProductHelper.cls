public class MarketProductHelper {
    
    final Set<String> productRecTypes = new Set<String>{'PID', 'SID'};
        final String SPRTR = '-', TOPLINE = 'Topline';
    static boolean runOnce = true;
    
    public void ppltMrktPrdBfrInsrt(List<OpportunityLineItem> oliLst) {
        ppltMrktPrd(oliLst);    
    }
    public void ppltMrktPrd(List<OpportunityLineItem> newOLILst) {      
        List<OpportunityLineItem> CPQOLILst = new List<OpportunityLineItem>();
        List<OpportunityLineItem> nonCPQOLILst = new List<OpportunityLineItem>();           
        Set<String> mrktPrdIds = new Set<String>();
        Set<String> prcbkIds = new Set<String>();
        Set<String> currCodes = new Set<String>();
        // didnt changed set as per old implementation and minimum change
        prcbkIds.add(GlobalVariable.CPQPricebookId);
        for(OpportunityLineItem oli : newOLILst) {               
            if(oli.SBQQ__QuoteLine__c!=null) {
                if (String.isNotBlank(oli.Product_Type__c) && productRecTypes.contains(oli.Product_Type__c) && oli.Topline_Product_Lkp__c != NULL && oli.Market_Product_PriceBookEntryId__c == NULL) {
                    CPQOLILst.add(oli); 
                    mrktPrdIds.add(oli.Topline_Product_Lkp__c);
                    currCodes.add(oli.CurrencyIsoCode);
                }
            } else if(String.isBlank(oli.Product_Type__c) || oli.Product_Type__c.equalsIgnoreCase(TOPLINE)) {
                oli.Topline_Product_Lkp__c = oli.Product2Id;
                oli.Market_Product_PriceBookEntryId__c = oli.PricebookEntryId;
            }    
        }
        
        if(!CPQOLILst.isEmpty()) {
            fetchAndPpltPBEId(mrktPrdIds, prcbkIds, currCodes, CPQOLILst);
        }
    }
    
    public void ppltMrktPrdBfrUpdt(List<OpportunityLineItem> newOLILst, Map<Id, OpportunityLineItem> oldOLIMap) {
        List<OpportunityLineItem> updateOLILst = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : newOLILst) {
            if (( (String.isBlank(oli.Product_Type__c) || oli.Product_Type__c.equalsIgnoreCase(TOPLINE)) && (oli.Product2Id != oli.Topline_Product_Lkp__c || oli.PricebookEntryId != oli.Market_Product_PriceBookEntryId__c)) 
                || (String.isNotBlank(oli.Product_Type__c)  && oli.Topline_Product_Lkp__c != NULL && oli.Market_Product_PriceBookEntryId__c == NULL)
                || (oli.Topline_Product_Lkp__c != oldOLIMap.get(oli.Id).Topline_Product_Lkp__c) 
                || (oli.Market_Product_PriceBookEntryId__c != oldOLIMap.get(oli.Id).Market_Product_PriceBookEntryId__c)) {
                    
                    updateOLILst.add(oli);   
                }              
        }
        
        if (!updateOLILst.isEmpty()) {
            ppltMrktPrd(updateOLILst);
        }
    }
    
    
    public void fetchAndPpltPBEId(Set<String> mrktPrdIdsSet, Set<String> prcbkIds, Set<String> currCodes, List<OpportunityLineItem> CPQOLILst) {
        List<PricebookEntry> pbeLst = [SELECT Id,Product2Id,Pricebook2Id,CurrencyIsoCode FROM PricebookEntry 
                                       WHERE Product2Id IN :mrktPrdIdsSet AND Pricebook2Id IN :prcbkIds 
                                       AND CurrencyIsoCode IN :currCodes AND Product2.Product_Type__c = :TOPLINE];
        Map<String, String> pbeMap = new Map<String, String>();
        
        for(PricebookEntry pbe : pbeLst) {
            String unqKey = pbe.Product2Id + SPRTR + pbe.Pricebook2Id + SPRTR + pbe.CurrencyIsoCode;
            pbeMap.put(unqKey, pbe.Id);
        }
        
        for(OpportunityLineItem oli : CPQOLILst) {
            String olikey = oli.Topline_Product_Lkp__c + SPRTR + GlobalVariable.CPQPricebookId + SPRTR + oli.CurrencyIsoCode;
            String mrktPrdPBEId = pbeMap.get(olikey);
            if(String.isNotBlank(mrktPrdPBEId)) oli.Market_Product_PriceBookEntryId__c = mrktPrdPBEId;
        } 
    }
    
    public boolean runOnce() {
        if(runOnce) {
            runOnce = false;
            return true;
        } else {
            return runOnce;
        }
    }
}