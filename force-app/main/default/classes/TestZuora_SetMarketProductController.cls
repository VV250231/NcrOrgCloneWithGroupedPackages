@isTest(seeAllData = false)
public class TestZuora_SetMarketProductController { 
    public static zqu__Quote__c q;
    public static zqu__QuoteAmendment__c qa;
    public static zqu__ProductRatePlan__c objPRP;
    public static Product2 marketProd;
    static {
        marketProd = new Product2( Name='TestMarket Product',Product_Type__c = 'Topline', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                  Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/
                                  isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,PMDM_Unique_Key__c = 'PMDM1');
        
        insert marketProd ;
        System.assert(marketProd.Id!=null);
        system.assertEquals( 'TestMarket Product', marketProd.Name);
        
        Product2 zuoraProduct = new Product2( Name='Test Zuora Product',Product_Type__c = 'Zuora Product', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                             Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/
                                             isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,MarketProductIds__c = 'PMDM1');
        insert  zuoraProduct;                               
        System.assert(zuoraProduct.Id!=null);
        system.assertNotEquals( 'Test1 Zuora', zuoraProduct.Name);
        
        String stdPriceBook = Test.getStandardPricebookId();
        
        PricebookEntry stdPBE1 = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=marketProd.id, PriceBook2Id=stdPriceBook , UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        insert stdPBE1 ;
        System.assert(stdPBE1.Id!=null);
        system.assertNotEquals( 'Test1', stdPBE1.CurrencyIsoCode);
        
        PricebookEntry stdPBE2 = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=zuoraProduct.id, PriceBook2Id=stdPriceBook , UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        insert stdPBE2;
        System.assert(stdPBE2.Id!=null);
        system.assertNotEquals( 'Test2', stdPBE2.CurrencyIsoCode); 
        
        zqu__ZProduct__c objZP = new zqu__ZProduct__c( Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = zuoraProduct.Id,zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25));
        insert  objZP;
        System.assert(objZP.Id!=null);
        system.assertNotEquals( 'Test ZProduct', objZP.Name); 
        
        objPRP = new zqu__ProductRatePlan__c(zqu__Product__c = zuoraProduct.id ,zqu__ZuoraId__c = 'zuraExtId', zqu__ZProduct__c = objZP.Id, zqu__EffectiveStartDate__c = Date.today().addYears(-1),zqu__EffectiveEndDate__c = Date.today().addYears(25),ProductSystem__c='ZQuotes', zqu__Deleted__c = false); 
        insert objPRP ;
        System.assert(objPRP.Id!=null);
        system.assertNotEquals( 'abc', objPRP.zqu__ZuoraId__c);
        
        q = new zqu__Quote__c();
        q.name = 'test-quote';
        q.zqu__Status__c = 'QA Processing Complete';
        q.Rebill__c = false; 
        q.Provisioning_Not_Required__c = false;
        q.Provisioning_Status__c = 'Complete';
        q.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
        insert q;
        System.assert(q.Id!=null);
        system.assertNotEquals( 'abc', q.Name);
        
        qa = new zqu__QuoteAmendment__c();
        qa.name = 'abc' ;
        qa.zqu__Quote__c = q.id;
        insert qa;
        System.assert(qa.Id!=null);
        system.assertEquals( 'abc', qa.Name);
        
        zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
        qp.name = 'abc';
        qp.zqu__Quote__c = q.id ;
        qp.zqu__QuoteAmendment__c = qa.id;
        qp.zqu__ProductRatePlan__c = objPRP.id;
        qp.MarketProductId__c = 'PMDM1';
        qp.zqu__AmendmentType__c ='NewProduct'; 
        insert qp ;
        System.assert(qp.Id!=null);
        system.assertEquals( 'abc', qp.Name);
        
    }
    
    static testMethod void runUnitTest(){
        /* Product2 marketProd = new Product2( Name='TestMarket Product',Product_Type__c = 'Topline', CurrencyIsoCode='USD', Product_Category__c ='HW', 
Solution_Portfolio__c='Entertainment Self Service', isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,PMDM_Unique_Key__c = 'PMDM1');

insert marketProd ;

Product2 zuoraProduct = new Product2( Name='Test Zuora Product',Product_Type__c = 'Zuora Product', CurrencyIsoCode='USD', Product_Category__c ='HW', 
Solution_Portfolio__c='Entertainment Self Service', isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,MarketProductIds__c = 'PMDM1');
insert  zuoraProduct;                               

String stdPriceBook = Test.getStandardPricebookId();

PricebookEntry stdPBE1 = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=marketProd.id, PriceBook2Id=stdPriceBook , UnitPrice=0.00, UseStandardPrice=false, isactive = true);
insert stdPBE1 ;

PricebookEntry stdPBE2 = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=zuoraProduct.id, PriceBook2Id=stdPriceBook , UnitPrice=0.00, UseStandardPrice=false, isactive = true);
insert stdPBE2;


zqu__ZProduct__c objZP = new zqu__ZProduct__c( Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = zuoraProduct.Id,zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25));
insert  objZP;

zqu__ProductRatePlan__c objPRP = new zqu__ProductRatePlan__c(zqu__Product__c = zuoraProduct.id ,zqu__ZuoraId__c = 'zuraExtId', zqu__ZProduct__c = objZP.Id, zqu__EffectiveStartDate__c = Date.today().addYears(-1),zqu__EffectiveEndDate__c = Date.today().addYears(25), zqu__Deleted__c = false); 
insert objPRP ;

zqu__Quote__c q = new zqu__Quote__c();
q.name = 'test-quote';
q.zqu__Status__c = 'QA Processing Complete';
q.Rebill__c = false; 
q.Provisioning_Not_Required__c = false;
q.Provisioning_Status__c = 'Complete';
q.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
insert q;

zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
qa.name = 'abc' ;
qa.zqu__Quote__c = q.id;
insert qa;

zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
qp.name = 'abc';
qp.zqu__Quote__c = q.id ;
qp.zqu__QuoteAmendment__c = qa.id;
qp.zqu__ProductRatePlan__c = objPRP.id;
qp.MarketProductId__c = 'PMDM1';
qp.zqu__AmendmentType__c ='NewProduct'; 
insert qp ;*/
        
        Test.StartTest();
        
        
        PageReference pageRef = Page.Zuora_SetMarketProductPage; // Add your VF page Name here
        
        pageRef.getParameters().put('inpval', 'PMDM1');
        pageRef.getParameters().put('id', String.valueOf(q.id));
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController scObj = new ApexPages.StandardController(q);
        Zuora_SetMarketProductController testSMP = new Zuora_SetMarketProductController(scObj );
        Map<String,List<SelectOption>> obj = new Map<String,List<selectOption>>();
        String testS = 'test';
        obj = testSMP.createPicklist();
        System.assert(obj!=null);
        
        testSMP.Contorlsave();   
        testSMP.edit();
        testS = testSMP.getcollectPicklistValue();
        testSMP.setcollectPicklistValue(testS );
        
        Test.StopTest();
        
        
        
        
    }
    
    static testMethod void runUnitTest2(){
        Zuora__Subscription__c sub = new Zuora__Subscription__c ();
        sub.Name = 'test Sub';
        insert sub;
        System.assert(sub.Id!=null);
        system.assertEquals( 'test Sub', sub.Name);
        
        Zuora__SubscriptionRatePlan__c srp = new Zuora__SubscriptionRatePlan__c();
        srp.name = 'test SRP';
        srp.MarketProductId__c = 'abcd';
        srp.Zuora__External_Id__c = 'abcxyz';
        srp.Zuora__Subscription__c = sub.Id;
        insert srp; 
        System.assert(srp.Id!=null);
        system.assertEquals( 'abcxyz', srp.Zuora__External_Id__c);
        
        Zuora__SubscriptionRatePlan__c srp2 = new Zuora__SubscriptionRatePlan__c();
        srp2.name = 'test SRP2';
        srp2.Zuora__External_Id__c = 'cassasds';
        srp2.Zuora__Subscription__c = sub.Id;
        insert srp2;
        System.assert(srp2.Id!=null);
        system.assertNotEquals( 'UpdateProduct', srp2.Zuora__External_Id__c);
        
        zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
        qp.name = 'abc';
        qp.zqu__Quote__c = q.id ;
        qp.zqu__QuoteAmendment__c = qa.id;
        qp.zqu__ProductRatePlan__c = objPRP.id;
        qp.MarketProductId__c = 'PMDM1';
        qp.zqu__AmendmentType__c ='UpdateProduct';
        qp.zqu__SubscriptionRatePlanZuoraId__c = 'abcxyz';
        insert qp ;
        System.assert(qp.Id!=null);
        system.assertEquals( 'UpdateProduct', qp.zqu__AmendmentType__c);
        
        zqu__QuoteRatePlan__c qp2 = new zqu__QuoteRatePlan__c();
        qp2.name = 'abc';
        qp2.zqu__Quote__c = q.id ;
        qp2.zqu__QuoteAmendment__c = qa.id;
        qp2.zqu__ProductRatePlan__c = objPRP.id;
        qp2.MarketProductId__c = 'PMDM1';
        qp2.zqu__AmendmentType__c ='UpdateProduct'; 
        qp2.zqu__SubscriptionRatePlanZuoraId__c = 'cassasds';
        insert qp2;
        
        System.assert(qp2.Id!=null);
        system.assertEquals( 'UpdateProduct', qp2.zqu__AmendmentType__c);
        
    }
    static testMethod void runUnitTest3(){
        
        Product2 marketProd2 = new Product2( Name='TestMarket Product1',Product_Type__c = 'Topline', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                            Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/
                                            isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,PMDM_Unique_Key__c = 'PMDM12',MarketProductIds__c = 'xyz');
        
        insert marketProd2 ;
        System.assert(marketProd2.Id!=null);
        system.assertNotEquals( 'AD Entertainment',marketProd2.Solution_Portfolio__c);
        
        
        Product2 prod = new Product2();
        prod = [Select Id,name, MarketProductIds__c from Product2 where Id = :marketProd2.Id];
        system.debug('the value of Product 2'+prod);
        prod.MarketProductIds__c = 'gdgd';
        //Test.StartTest();
        update prod;
        //Test.StopTest();
        //prod = [Select Id,name, MarketProductIds__c from Product2 where Id = :prod.Id];
        system.debug('the value of update'+prod.MarketProductIds__c +'----'+ prod.id);
        
        Product2 prod1 = [Select Id, MarketProductIds__c from Product2 where Id = :prod.Id];
        system.debug('the value of update'+prod1.MarketProductIds__c );  
    } 
    
}