@isTest(SeeAllData = true)
private class FindZuoraProductMatchingToplineTest {
    static testmethod  void runUnitTest() {
        Product2 topline = [SELECT Id, Name /*,Offer_Portfolio_Id__c*/ 
                            FROM Product2
                            WHERE Product_Type__c = 'Topline'
                            AND IsActive = true 
                            AND DataHubReferenceKey__c != null 
                            //AND Offer_Portfolio_Id__c != null 
                            LIMIT 1];
                            
        Product2 zProduct = new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', 
                                            ProductCode = 'SKU-999991', IsActive = true, ToplineProduct__c = topline.Name 
                                            /*,OPID__c = topline.Offer_Portfolio_Id__c*/);
                                            
        insert zProduct;
        System.assert(zProduct.Id!=null);
        zProduct.zqu__ZuoraId__c = generateGUID();
        update zProduct;
                
    }
    
    public static String generateGUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String hyphen = '';
        String requestGUID = h.SubString(0,8) + hyphen + h.SubString(8,12) + hyphen + h.SubString(12,16) + hyphen + h.SubString(16,20) + hyphen + h.substring(20);
        return requestGUID;     
    }
}