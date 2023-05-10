@isTest(seeAllData = false)
public class Test_AutoUpdateMarketProductIdOnQRP{

static testMethod void runAutoPopulateTriggerOnProduct(){
    Product2 zProductWithMarketId = new Product2( Name='Test Zuora Product',Product_Type__c = 'Zuora Product', zqu__ZuoraId__c
= '1233456', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                            Solution_Portfolio__c='Entertainment Self Service', isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,MarketProductIds__c = 'PMDM1;PMDM2');
    insert zProductWithMarketId;
    System.assert(zProductWithMarketId.Id!=null);
    system.assertEquals('Test Zuora Product',zProductWithMarketId.Name);
    system.assertNotEquals('ALoha Essential',zProductWithMarketId.Product_Type__c);
    
    String standardPriceBook = Test.getStandardPricebookId();
    PricebookEntry stdPriceBookEntry = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=zProductWithMarketId.id, PriceBook2Id=standardPriceBook, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
    insert stdPriceBookEntry;
    system.assertEquals('USD',stdPriceBookEntry.CurrencyIsoCode);
    zqu__ZProduct__c zProduct = new zqu__ZProduct__c( Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = zProductWithMarketId.Id,zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25));
    insert  zProduct;
    system.assertEquals('SKU-999992',zProduct.zqu__SKU__c);
    
    zqu__ProductRatePlan__c ProRatePlan = new zqu__ProductRatePlan__c(zqu__Product__c = zProductWithMarketId.id,ProductSystem__c='ZQuotes',zqu__ZuoraId__c = 'zuraExtId', zqu__ZProduct__c = zProduct.Id, zqu__EffectiveStartDate__c = Date.today().addYears(-1),zqu__EffectiveEndDate__c = Date.today().addYears(25), zqu__Deleted__c = false); 
        insert ProRatePlan ;
        system.assertNotEquals('ALohaID',ProRatePlan.zqu__ZuoraId__c);
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.name = 'test-quote';
        quote.zqu__Status__c = 'QA Processing Complete';
        quote.Rebill__c = false; 
        quote.Provisioning_Not_Required__c = false; 
        quote.Provisioning_Status__c = 'Complete';
        quote.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
        insert quote;
        system.assertNotEquals('quote',quote.name);
        
        zqu__QuoteAmendment__c qAmendment = new zqu__QuoteAmendment__c();
        qAmendment.name = 'abc' ;
        qAmendment.zqu__Quote__c = quote.id;
        insert qAmendment;
     	system.assertNotEquals('test-quote',qAmendment.name);    
    
        zqu__QuoteRatePlan__c QuoteRP = new zqu__QuoteRatePlan__c();
        QuoteRP.name = 'abc';
        QuoteRP.zqu__Quote__c = quote.id ;
        QuoteRP.zqu__QuoteAmendment__c = qAmendment.id;
        QuoteRP.zqu__ProductRatePlan__c = ProRatePlan.id;
        QuoteRP.MarketProductId__c = 'PMDM1;PMDM2';
        QuoteRP.zqu__AmendmentType__c ='NewProduct'; 
        insert QuoteRP;
    	system.assertNotEquals('xyz',QuoteRP.name);    
    
        Product2 updateVar = [Select Id, Name, MarketProductIds__c from Product2 where Id = :zProductWithMarketId.Id];
        system.debug('The Value of upadteVar' + updateVar);
        updateVar.MarketProductIds__c = 'XYZ;ABC';
        update updateVar;
        Product2 updateVar2 = [Select Id, Name, MarketProductIds__c from Product2 where Id = :zProductWithMarketId.Id];
        system.debug('The Value of upadteVar' + updateVar2);
}


}