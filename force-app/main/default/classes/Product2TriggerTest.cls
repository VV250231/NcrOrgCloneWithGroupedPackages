@isTest
public class Product2TriggerTest {
    public static testMethod void TestAutoPopulateHierarchyFields(){
        
        Product2 Pro = new Product2();
        Pro.Name = 'ATM Machine';
        Pro.L0_Category_text__c = 'NCR';
        Pro.L1_Category_text__c = 'ABC';
        Pro.L2_Category_text__c = 'DEF';
        Pro.L3_Category_text__c = 'GHI';
        Pro.L4_Category_text__c = 'JKL';
        Pro.L0_Category__c = '';
        Pro.L1_Category__c = '';
        Pro.L2_Category__c  = '';
        Pro.L3_Category__c = '';
        Pro.L4_Category__c = 'Test Topline 123';
        Pro.Service_Offer_Category__c = 'SW';
        Pro.Product_Category__c = 'Software';
        
        insert Pro;
        
        Pro.Service_Offer_Category__c = 'HW';
        Pro.Product_Category__c = 'Hardware';
        update Pro;
        product2 prodObj =[select L3_Category_text__c from product2 where id=:Pro.id];
        System.assert(prodObj.L3_Category_text__c==null);
    }
    static testMethod void runAutoPopulateTriggerOnProduct(){
        Product2 zProductWithMarketId = new Product2( Name='Test Zuora Product',Product_Type__c = 'Zuora Product', zqu__ZuoraId__c
                                                     = '1233456', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                                     Solution_Portfolio__c='Entertainment Self Service', isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,MarketProductIds__c = 'PMDM1;PMDM2');
        insert zProductWithMarketId;
        
        String standardPriceBook = Test.getStandardPricebookId();
        PricebookEntry stdPriceBookEntry = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=zProductWithMarketId.id, PriceBook2Id=standardPriceBook, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        insert stdPriceBookEntry;
        
        zqu__ZProduct__c zProduct = new zqu__ZProduct__c( Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = zProductWithMarketId.Id,zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25));
        insert  zProduct;
        
        zqu__ProductRatePlan__c ProRatePlan = new zqu__ProductRatePlan__c(zqu__Product__c = zProductWithMarketId.id ,zqu__ZuoraId__c = 'zuraExtId', zqu__ZProduct__c = zProduct.Id, zqu__EffectiveStartDate__c = Date.today().addYears(-1),zqu__EffectiveEndDate__c = Date.today().addYears(25), zqu__Deleted__c = false, ProductSystem__c= 'ZQuotes'); 
        insert ProRatePlan ;
        
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.name = 'test-quote';
        quote.zqu__Status__c = 'QA Processing Complete';
        quote.Rebill__c = false; 
        quote.Provisioning_Not_Required__c = false;
        quote.Provisioning_Status__c = 'Complete';
        quote.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
        insert quote;
        
        zqu__QuoteAmendment__c qAmendment = new zqu__QuoteAmendment__c();
        qAmendment.name = 'abc' ;
        qAmendment.zqu__Quote__c = quote.id;
        insert qAmendment;
        
        zqu__QuoteRatePlan__c QuoteRP = new zqu__QuoteRatePlan__c();
        QuoteRP.name = 'abc';
        QuoteRP.zqu__Quote__c = quote.id ;
        QuoteRP.zqu__QuoteAmendment__c = qAmendment.id;
        QuoteRP.zqu__ProductRatePlan__c = ProRatePlan.id;
        QuoteRP.MarketProductId__c = 'PMDM1;PMDM2';
        QuoteRP.zqu__AmendmentType__c ='NewProduct'; 
        insert QuoteRP;
        
        Product2 updateVar = [Select Id, Name, MarketProductIds__c from Product2 where Id = :zProductWithMarketId.Id];
        system.debug('The Value of upadteVar' + updateVar);
        updateVar.MarketProductIds__c = 'XYZ;ABC';
        update updateVar;
        zqu__QuoteRatePlan__c quotePlanObj = [select MarketProductId__c from zqu__QuoteRatePlan__c where id =:QuoteRP.id];
        System.assert(quotePlanObj.MarketProductId__c!=null);
    }
    public static testmethod void TestSyncOliKeyFields(){
        List<Opportunity> Opportunities ;
        
        Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity opp = Opportunities[0];
        insert opp;
        
        Product2 prod = new Product2();
        prod.Name = 'Orderman';
        prod.Family = 'Hardware';
        prod.CanUseQuantitySchedule = true;
        prod.Service_Offer_Category__c='HW';
        prod.Available_for_Subscription__c  = true;
        insert prod;
        
        Product2 newProd = TestRecordsFactory.createProduct();
        
        PriceBookEntry customPriceBook = TestRecordsFactory.createStandardPriceBookEntry(prod);
        
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(newProd));
        
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='HW';
        OLI1.Sites__c = 10;
        OLI1.Is_Subscriptioned__c = true;
        OlI1.Topline_Product_Lkp__c =newProd.id;
        update OLI1;
        prod= [Select id, name,Service_Offer_Category__c,Product_Category__c from Product2 where id=:newProd.id limit 1];
        prod.Service_Offer_Category__c = 'SW';
        prod.Product_Category__c = 'Software';
        update prod;
        System.debug('@@@@'+[Select id,Topline_Product_Lkp__c from OpportunityLineItem where id =:OLI1.Id]);
        System.debug('@@@@'+newProd.id);
        map<Id, Product2> mp=new map<Id, Product2>();
        mp.put(newProd.id, newProd);
        Set<Id> subtoNonSubProdList = new Set<Id>{newProd.Id}; 
            Set<Id> nonSubtoSubProdList = new Set<Id>{newProd.Id}; 
                SyncOLIKeyFields so=new SyncOLIKeyFields(mp,  subtoNonSubProdList, nonSubtoSubProdList );
        so.sendEmail(new List<String>{'test'}, 'test');
        Test.startTest();
        SyncOLIKeyFields bSync = new SyncOLIKeyFields(mp,  subtoNonSubProdList, nonSubtoSubProdList);
        Database.executeBatch(bSync);
        System.assertEquals(1, [select count() from OpportunityLineItem where Revenue_Type__c = 'HW']);
        Test.stopTest();
        
        
        
    }
    
    public static testmethod void altifyTest(){
        
        ALTF__Solution__c SWSol = new ALTF__Solution__c(Name='Software', ALTF__Tooltip__c='Software', ALTF__Solution_Family__c='Revenue Types', ALTF__Active__c=true);
        ALTF__Solution__c HWSol = new ALTF__Solution__c(Name='Hardware', ALTF__Tooltip__c='Hardware', ALTF__Solution_Family__c='Revenue Types', ALTF__Active__c=true);
        List<ALTF__Solution__c> altSolLst = new List<ALTF__Solution__c>{HWSol, SWSol};
            insert altSolLst;
        
        Product2 p1 = new Product2();
        //p2 = TestRecordsFactory.createProduct(adv);
        p1.Product_Type__c  = 'Topline';
        p1.Name = 'Test Product';
        p1.Product_Category__c ='Software';
        p1.Family ='Solution';
        p1.service_offer_category__c='HW';
        p1.CanUseQuantitySchedule=true;
        p1.ALTF__Solution__c = HWSol.Id;
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Product_Type__c  = 'PID';
        p2.Name = 'Test Product';
        p2.Product_Category__c ='Software';
        p2.Family ='Solution';
        p2.CanUseQuantitySchedule=true;
        p2.Topline_Product_Lkp__c = p1.Id;
        insert p2;    
        
        p2 = [SELECT Id,service_offer_category__c,ALTF__Solution__r.Name FROM Product2 WHERE Id = :p2.Id];
        System.assertEquals(p2.service_offer_category__c, 'HW');
        System.assertEquals(p2.ALTF__Solution__r.Name, 'Hardware');
        
        p2.Service_Offer_Category__c = 'SW';
        update p2;
        
        p2 = [SELECT Id,service_offer_category__c,ALTF__Solution__r.Name FROM Product2 WHERE Id = :p2.Id];
        System.assertEquals(p2.ALTF__Solution__r.Name, 'Software');
    }

	// 7-JUL-2022: Added by Dharmendra to test class CPQSyncQLIFields    
     public static testmethod void TestCPQQLIFields(){
        Test.startTest();
      	// create quote and lines
        List<Product2> productData = Test.loadData(Product2.sObjectType,'CPQProductData');
         system.debug('productData  :'+productData.size() );
        Id pbid = Test.getStandardPricebookId();
        List<SBQQ__Quote__c> q= Test.loadData(SBQQ__Quote__c.sObjectType,'CPQQuoteTestData');
        List<SBQQ__QuoteLineGroup__c> quoteLinesGroup = Test.loadData(SBQQ__QuoteLineGroup__c.sObjectType,'CPQLineGroup');
        List<SBQQ__QuoteLine__c> quoteLinespackg = Test.loadData(SBQQ__QuoteLine__c.sObjectType,'CPQPackageData');
        List<SBQQ__QuoteLine__c> quoteLines = Test.loadData(SBQQ__QuoteLine__c.sObjectType,'CPQQuoteLineTestData');
		
         //update products, qtc_Interchange_Cost_Percentage__c and qtc_Blended_Rate_Percentage__c
        for(Product2 pro : productData) {
            pro.qtc_Interchange_Cost_Percentage__c=1;
            pro.qtc_Blended_Rate_Percentage__c = 1;
        }
        update productData ;
        
        Test.stopTest();
        
        List<SBQQ__QuoteLine__c> lines=[select qtc_Interchange_Cost_Percentage__c,qtc_Blended_Rate_Percentage__c,Name,SBQQ__RequiredBy__r.Name,qtc_Pass_Through__c,Product_Type__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: q[0].Id];
        
        System.assertEquals(1,lines[0].qtc_Interchange_Cost_Percentage__c, 'Expected Price 1');
        
        CPQSyncQLIFields customE = new CPQSyncQLIFields();
        List <String> CustomException = new List<string>();
        CustomException.add('LimitException');
        CustomException.add('ListException');
        customE.sendEmail(CustomException, 'Custom Exception Occured');
        
        
    }

}