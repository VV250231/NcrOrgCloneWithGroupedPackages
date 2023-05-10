@isTest(SeeAllData=True)
public class DefaultChannelOfficeFieldTest{

    static ProductCatalogTest pcatalog;
    static String zuoraSubscriptionId;

@isTest
    public static void test_QRPC_updateProduct() {
        setUpDefaultValues();
        Account acct = [select id from Account where Subscription_Group__c = 'Digital Insight' limit 1];
        // Account acct = new Account(Name ='Test Account', Account_Country_Code__c= 'US', Industry = 'HOSPITALITY:CHANNEL', Primary_Buying_Cooperative__c = 'Super Store Industries');
       // insert acct;
                
        Opportunity opp = createOppWithChannelOffice(acct);
        
        
        zqu__Quote__c qt = createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, zqu__RenewalTermPeriodType__c, zqu__InitialTermPeriodType__c, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = createQuoteAmendment(qt);
        qam.zqu__Type__c = 'UpdateProduct';
		system.debug('check 1');
        insert qam;

        zqu__QuoteRatePlan__c qrp = createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'UpdateProduct';
		system.debug('check 2');
        insert qrp;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        
        system.debug(JSON.serializePretty(qps));
        
        system.assertEquals(1, qps.size());
       // system.assertEquals('Update', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
        
        Zuora__SubscriptionProductCharge__c subcharge1 = new Zuora__SubscriptionProductCharge__c();
        subcharge1.Zuora__External_Id__c ='zoura-charge1';
        subcharge1.Zuora__RatePlanId__c = 'zuora-plan1'; 
        subcharge1.Zuora__Price__c = 100.00;
        subcharge1.Zuora__ExtendedAmount__c = 100.00;   
        subcharge1.Zuora__Type__c =  'One-Time';
        //subcharge1.Zuora__Subscription__c = zuoraSubscriptionId;
        subcharge1.ChannelPartner__c = 'Earthmover';
        subcharge1.SupportChannelPartner__c = 'Earthmover';
        subcharge1.Wholesaler__c = 'Laurel Grocery Company';
        subcharge1.SalesChannelPartnerCommissionPercent__c = '100';
        subcharge1.SupportChannelPartnerCommissionPercent__c = '100';
        subcharge1.WholesalerCommissionPercent__c = '100';   
        subcharge1.MinimumChargeCode__c = 'Test';   
        subcharge1.ProductUsageMetric__c = 'Test 2';
		system.debug('check 3');
        insert subcharge1;        
        

        zqu__QuoteRatePlanCharge__c qrpc = createQuoteRatePlanChargeWithDefault(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        qrpc.PartnerCommission__c = '10.0';
        qrpc.Cost__c = '10.0';
        qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c = subcharge1.id;
		system.debug('check 4');
        insert qrpc; 
		system.debug('check 5');
        update qrpc;
        
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc1 = createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc1.zqu__EffectivePrice__c = 1500; //update the price
        qrpc1.PartnerCommission__c = '10.0';
        qrpc1.Cost__c = '10.0';
        //qrpc1.zqu__SubscriptionRatePlanChargeZuoraId__c = subcharge1.id;
		system.debug('check 6');
        insert qrpc1;
		system.debug('check 7');
        update qrpc1;
        test.stoptest();
        // check all without default values on account and opportunity reference fields
        //Account acct1 = new Account(Name ='Test Account', Account_Country_Code__c= 'US', Industry = 'HOSPITALITY:CHANNEL');
        //insert acct1;
        Account acct1 = [select id from Account where Subscription_Group__c != 'Digital Insight' limit 1];
        Opportunity opp1 = createOpp(acct1);    
        
        zqu__Quote__c qt1 = createQuote(opp1, 'Amendment');
        qt1 = [select Id,zqu__InitialTermPeriodType__c,zqu__RenewalTermPeriodType__c, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt1.Id];


        zqu__QuoteAmendment__c qam1 = createQuoteAmendment(qt1);
        qam1.zqu__Type__c = 'UpdateProduct';
		system.debug('check 8');
        insert qam1;

        zqu__QuoteRatePlan__c qrp1 = createQuoteRatePlan(qt1, qam1, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp1.zqu__AmendmentType__c = 'UpdateProduct';
		system.debug('check 9');
        insert qrp1;

        ZuoraSubscriptionState zss1 = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss1.addQuote(qt1);
        system.debug(zss1.var_dump());

        ZuoraSubscriptionState.QuoteProduct[] qps1 = zss1.getQuoteProducts();
        system.debug(JSON.serializePretty(qps1));
        
        system.assertEquals(1, qps1.size());
        //system.assertEquals('Update', qps1[0].action);
        system.assertNotEquals(null, qps1[0].sfProductId);
        system.assertEquals(null, qps1[0].sfProductRatePlanId);
        
        Zuora__SubscriptionProductCharge__c subcharge2 = new Zuora__SubscriptionProductCharge__c();
        subcharge2.Zuora__External_Id__c ='zoura-charge2';
        subcharge2.Zuora__RatePlanId__c = 'zuora-plan2'; 
        subcharge2.Zuora__Price__c = 100.00;
        subcharge2.Zuora__ExtendedAmount__c = 100.00;   
        subcharge2.Zuora__Type__c =  'One-Time';
        //subcharge2.Zuora__Subscription__c = zuoraSubscriptionId;
        subcharge2.ChannelPartner__c = 'Earthmover';
        subcharge2.SupportChannelPartner__c = 'Earthmover';
        subcharge2.Wholesaler__c = 'Laurel Grocery Company';
        subcharge2.SalesChannelPartnerCommissionPercent__c = '100';
        subcharge2.SupportChannelPartnerCommissionPercent__c = '100';
        subcharge2.WholesalerCommissionPercent__c = '100'; 
        subcharge2.MinimumChargeCode__c = 'Test 2'; 
        subcharge2.ProductUsageMetric__c = 'Test 2';
		system.debug('check 9');
        insert subcharge2;        
        

        zqu__QuoteRatePlanCharge__c qrpc2 = createQuoteRatePlanChargeWithDefault(qrp1, pcatalog.productRatePlanCharges[0]);
        qrpc2.zqu__EffectivePrice__c = 1500; //update the price
        qrpc2.PartnerCommission__c = '10.0';
        qrpc2.Cost__c = '10.0';
        qrpc2.zqu__SubscriptionRatePlanChargeZuoraId__c = subcharge2.id;
		system.debug('check 10');
        insert qrpc2;
		system.debug('check 11');
        update qrpc2;
        
        
        zqu__QuoteRatePlanCharge__c qrpc3 = createQuoteRatePlanCharge(qrp1, pcatalog.productRatePlanCharges[0]);
        qrpc3.zqu__EffectivePrice__c = 1500; //update the price
        qrpc3.PartnerCommission__c = '10.0';
        qrpc3.Cost__c = '10.0';
        //qrpc3.zqu__SubscriptionRatePlanChargeZuoraId__c = subcharge2.id;
		system.debug('check 12');
        insert qrpc3; 
		system.debug('check 13');
        //update qrpc3;            
        
        //
        zqu__QuoteRatePlanCharge__c qrpc4 = createQuoteRatePlanCharge(qrp1, pcatalog.productRatePlanCharges[0]);
        qrpc4.Id = qrpc3.Id;
        qrpc4.zqu__EffectivePrice__c = 1500; //update the price
        qrpc4.PartnerCommission__c = '10.0';
        qrpc4.Cost__c = '10.0';
        //qrpc3.zqu__SubscriptionRatePlanChargeZuoraId__c = subcharge2.id;
		system.debug('check 12');
        update qrpc4;  
    }

  public static void setUpDefaultValues() 
    {
        pcatalog = createProductCatalogWithDefValues();
        
    ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
    mock.addData('Product', createZuoraObject('Product', new Map<String,Object>{
            'Id'=>pcatalog.products[0].zqu__ZuoraId__c,
      'Name' => 'Test Product'
    }));
    mock.addData('ProductRatePlan', createZuoraObject('ProductRatePlan', new Map<String,Object>{
      'Id' => pcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
      'ProductId' => mock.getFirst('Product').getValue('Id')
    }));
    mock.addData('ProductRatePlanCharge', createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
      'Id' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
      'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
    }));


        mock.addData('Account', createZuoraObject('Account', new Map<String,Object>{
      'Name' => 'Test Account'
    }));
    mock.addData('Subscription', createZuoraObject('Subscription', new Map<String,Object>{
        'AccountId' => mock.getFirst('Account').getValue('Id'),
        'TermType' => 'TERMED',
        'InitialTerm' => 84,
        'RenewalTerm' => 24,
        'SubscriptionStartDate' => Date.today(),
        'SubscriptionEndDate' => Date.today().addMonths(84)
    }));

    zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
    mock.addData('RatePlan', createZuoraObject('RatePlan', new Map<String,Object>{
      'SubscriptionId' => zuoraSubscriptionId,
      'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
    }));
    String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
    mock.addData('RatePlanCharge', createZuoraObject('RatePlanCharge', new Map<String,Object>{
      'RatePlanId' => ratePlanId,
      'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
      'Quantity' => 1,
      'Price' => 1000
    }));
    }



    public class ProductCatalogTest {
        public zqu__ZProduct__c[] products {get;set;}
        public zqu__ProductRatePlan__c[] productRatePlans {get;set;}
        public zqu__ProductRatePlanCharge__c[] productRatePlanCharges {get;set;}
    }

    public static Opportunity createOppWithChannelOffice(Account acct)
    {
        OpportunityStage ostage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id, Channel_Office__c = acct.Id, StageName = ostage.MasterLabel, CloseDate = Date.today().addDays(1),
       /* Solution_Portfolio__c = 'DIGITAL BANKING',*/ CurrencyIsoCode = 'USD');
        insert opp;
        return opp;
    }

    public static Opportunity createOpp(Account acct)
    {
        OpportunityStage ostage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id, StageName = ostage.MasterLabel, CloseDate = Date.today().addDays(1),
        /*Solution_Portfolio__c = 'DIGITAL BANKING',*/ CurrencyIsoCode = 'USD');
        insert opp;
        return opp;
    }

    public static zqu__Quote__c createQuote(Opportunity opp, String recordTypeName)
    {
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo =  rtMapByName.get(recordTypeName);
        Date startDate = Date.today();
        Date strtDate = Date.newInstance(startDate.year(), startDate.month()+1, 1);
        zqu__Quote__c qt = new zqu__Quote__c(zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c = 'Month',zqu__Opportunity__c = opp.Id, zqu__Account__c = opp.AccountId, Name = 'Test Quote', zqu__StartDate__c = strtDate,
            zqu__Currency__c = opp.CurrencyIsoCode, RecordTypeId = rtInfo.getRecordTypeId());
            insert qt;
            return qt;
    }


    public static ProductCatalogTest createProductCatalogWithDefValues()
    {
        String zuoraId1 = generateGUID();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = zuoraId1, Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', ProductCode = 'SKU-999991', IsActive = true),
            new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992', ProductCode = 'SKU-999992', IsActive = true),
            new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 3', zqu__SKU__c = 'SKU-999993', ProductCode = 'SKU-999993', IsActive = true)
        };
        insert sfProducts;

        ProductCatalogTest pcatalog = new ProductCatalogTest();
        pcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            ),
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = sfProducts[1].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            ),
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 3', zqu__SKU__c = 'SKU-999993',
                ProductCategory__c = null, InterfaceType__c = null, zqu__Product__c = sfProducts[2].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            )
        };
        insert pcatalog.products;


        pcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            createProductRatePlan(pcatalog.products[0]),
            createProductRatePlan(pcatalog.products[1]),
            createProductRatePlan(pcatalog.products[2])
        };
        insert pcatalog.productRatePlans;

        pcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            createProductRatePlanChargeWithDefVal(pcatalog.productRatePlans[0], 'Test Charge 1'),
            createProductRatePlanChargeWithDefVal(pcatalog.productRatePlans[1], 'Test Charge 2'),
            createProductRatePlanChargeWithDefVal(pcatalog.productRatePlans[2], 'Test Charge 3')
        };
        insert pcatalog.productRatePlanCharges;

        zqu__ProductRatePlanChargeTier__c[] tiers = new zqu__ProductRatePlanChargeTier__c[]{
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[0], 'Test Charge 1'),
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[1], 'Test Charge 2'),
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[2], 'Test Charge 3')
        };
        insert tiers;
        return pcatalog;
    }

    public static ProductCatalogTest createProductCatalog()
    {
        String zuoraId1 = generateGUID();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = zuoraId1, Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', ProductCode = 'SKU-999991', IsActive = true),
            new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992', ProductCode = 'SKU-999992', IsActive = true),
            new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 3', zqu__SKU__c = 'SKU-999993', ProductCode = 'SKU-999993', IsActive = true)
        };
        insert sfProducts;

        ProductCatalogTest pcatalog = new ProductCatalogTest();
        pcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            ),
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = sfProducts[1].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            ),
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 3', zqu__SKU__c = 'SKU-999993',
                ProductCategory__c = null, InterfaceType__c = null, zqu__Product__c = sfProducts[2].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            )
        };
        insert pcatalog.products;


        pcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            createProductRatePlan(pcatalog.products[0]),
            createProductRatePlan(pcatalog.products[1]),
            createProductRatePlan(pcatalog.products[2])
        };
        insert pcatalog.productRatePlans;

        pcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            createProductRatePlanCharge(pcatalog.productRatePlans[0], 'Test Charge 1'),
            createProductRatePlanCharge(pcatalog.productRatePlans[1], 'Test Charge 2'),
            createProductRatePlanCharge(pcatalog.productRatePlans[2], 'Test Charge 3')
        };
        insert pcatalog.productRatePlanCharges;

        zqu__ProductRatePlanChargeTier__c[] tiers = new zqu__ProductRatePlanChargeTier__c[]{
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[0], 'Test Charge 1'),
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[1], 'Test Charge 2'),
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[2], 'Test Charge 3')
        };
        insert tiers;
        return pcatalog;
    }

    public static zqu__ProductRatePlan__c createProductRatePlan(zqu__ZProduct__c zprod)
    {
        String zid = generateGUID();
        return new zqu__ProductRatePlan__c(
            zqu__Product__c = zprod.zqu__Product__c,
            zqu__ZuoraId__c = zid, zqu__ZProduct__c = zprod.Id, zqu__EffectiveStartDate__c = Date.today().addYears(-1),
            zqu__EffectiveEndDate__c = Date.today().addYears(25), zqu__Deleted__c = false, ProductSystem__c= 'ZQuotes'
        );
    }

    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(zqu__ProductRatePlan__c prp, String chargeName)
    {
        return new zqu__ProductRatePlanCharge__c(
            zqu__ZuoraId__c = generateGUID(), zqu__ProductRatePlan__c = prp.Id, 
            Name = chargeName, zqu__RecurringPeriod__c = 'Month',
            zqu__Model__c = 'Flat Fee Pricing', zqu__ListPrice__c = 1000, zqu__Deleted__c = false
        );
    }

    public static zqu__ProductRatePlanCharge__c createProductRatePlanChargeWithDefVal(zqu__ProductRatePlan__c prp, String chargeName)
    {
        return new zqu__ProductRatePlanCharge__c(
            zqu__ZuoraId__c = generateGUID(), zqu__ProductRatePlan__c = prp.Id, 
            Name = chargeName, zqu__RecurringPeriod__c = 'Month',
            zqu__Model__c = 'Flat Fee Pricing', zqu__ListPrice__c = 1000, zqu__Deleted__c = false,
            SalesChannelPartnerCommissionPercent__c = '10',
            SupportChannelPartnerCommissionPercent__c = '10',
            MinimumChargeCode__c = 'PRPC Minimum Charge Code',
            ProductUsageMetric__c = 'prpc product usage metric'
        );
    }

    private static zqu__ProductRatePlanChargeTier__c createProductRatePlanChargeTier(zqu__ProductRatePlanCharge__c prpc, String chargeTierName)
    {
        return new zqu__ProductRatePlanChargeTier__c(
            zqu__ZuoraId__c = generateGUID(), zqu__ProductRatePlanCharge__c = prpc.Id, 
            Name = chargeTierName, zqu__Price__c = 1000, zqu__Currency__c = 'USD', zqu__Currency2__c = 'USD', zqu__Active__c = true,
            zqu__StartingUnit__c = 0, zqu__EndingUnit__c = 0, zqu__Tier__c = 1, zqu__Deleted__c = false      
        );
    }

    public static zqu__QuoteCharge__c createQuoteCharge(zqu__Quote__c theQuote, zqu__ZProduct__c zprod, zqu__ProductRatePlan__c prp, zqu__ProductRatePlanCharge__c prpc)
    {
        return new zqu__QuoteCharge__c(
            zqu__Quote__c = theQuote.Id, zqu__Quantity__c = 1, zqu__ProductRatePlanCharge__c = prpc.Id,
            zqu__Model__c = prpc.zqu__Model__c, zqu__Currency__c = theQuote.zqu__Currency__c,
            zqu__RatePlanCharge_ZuoraID__c = prpc.zqu__ZuoraId__c, zqu__ProductRatePlanName__c = prp.Name, zqu__ProductName__c = zprod.Name
        );
    }

    public static zqu__QuoteRatePlan__c createQuoteRatePlan(zqu__Quote__c theQuote, zqu__QuoteAmendment__c qam, zqu__ZProduct__c zprod, zqu__ProductRatePlan__c prp, zqu__ProductRatePlanCharge__c prpc)
    {
        return new zqu__QuoteRatePlan__c(
            zqu__Quote__c = theQuote.Id, zqu__QuoteAmendment__c = qam.Id, zqu__ProductRatePlanZuoraId__c = prp.zqu__ZuoraId__c,
            zqu__ProductRatePlan__c = prp.Id, zqu__AmendmentType__c = qam.zqu__Type__c
        );
    }

    public static zqu__QuoteRatePlanCharge__c createQuoteRatePlanCharge(zqu__QuoteRatePlan__c quoteRatePlan, zqu__ProductRatePlanCharge__c prpc)
    {
        return new zqu__QuoteRatePlanCharge__c(
            zqu__QuoteRatePlan__c = quoteRatePlan.Id, zqu__ProductRatePlanCharge__c = prpc.Id,
            zqu__ProductRatePlanChargeZuoraId__c = prpc.zqu__ZuoraId__c, zqu__Currency__c = 'USD', 
            zqu__EffectivePrice__c = 1000
        );
    }

    public static zqu__QuoteRatePlanCharge__c createQuoteRatePlanChargeWithDefault(zqu__QuoteRatePlan__c quoteRatePlan, zqu__ProductRatePlanCharge__c prpc)
    {	    
        	Account a = TestRecordsFactory.createAccount();
        return new zqu__QuoteRatePlanCharge__c(
            zqu__QuoteRatePlan__c = quoteRatePlan.Id, zqu__ProductRatePlanCharge__c = prpc.Id,
            zqu__ProductRatePlanChargeZuoraId__c = prpc.zqu__ZuoraId__c, zqu__Currency__c = 'USD', 
            zqu__EffectivePrice__c = 1000,
            ChannelPartner__c = 'Earthmover',
            SupportChannelPartner__c = 'Earthmover',
            //ChannelPartner_Lkp__c = '0017000001WcfRg',
            //SupportChannelPartnerLkp__c  = '0017000001WcfRg',
            ChannelPartner_Lkp__c = a.id,
            SupportChannelPartnerLkp__c = a.id,	
            Wholesaler__c = 'Laurel Grocery Company',
            SalesChannelPartnerCommissionPercent__c = '100',
            SupportChannelPartnerCommissionPercent__c = '100',
            WholesalerCommissionPercent__c = '100'
        );
    }

    public static zqu__QuoteAmendment__c createQuoteAmendment(zqu__Quote__c theQuote)
    {
        return new zqu__QuoteAmendment__c(
            zqu__Quote__c = theQuote.Id, zqu__QuoteAmendmentZuoraId__c = generateGUID(), zqu__Type__c = 'NewProduct',
            zqu__TermStartDate__c = Date.today(), zqu__TermType__c = 'Evergreen'
        );
    }

    public static String generateGUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String hyphen = '';
        String requestGUID = h.SubString(0,8) + hyphen + h.SubString(8,12) + hyphen + h.SubString(12,16) + hyphen + h.SubString(16,20) + hyphen + h.substring(20);
        return requestGUID;     
    }

    public static Zuora.zObject createZuoraObject(String ztype, Map<String,Object> vals) {
        Zuora.zObject zobj = new Zuora.zObject(ztype);
        if(!vals.containsKey('Id')) zobj.setValue('Id', generateGUID());
        for(String fieldName : vals.keySet()) {
            zobj.setValue(fieldName, vals.get(fieldName));
        }
        return zobj;
    }
	//new method
	@isTest
    public static void test_QRPC_updateProduct1() {
        setUpDefaultValues();
        Account acct = [select id from Account where Subscription_Group__c = 'Digital Insight' limit 1];
        // Account acct = new Account(Name ='Test Account', Account_Country_Code__c= 'US', Industry = 'HOSPITALITY:CHANNEL', Primary_Buying_Cooperative__c = 'Super Store Industries');
       // insert acct;
                
        Opportunity opp = createOppWithChannelOffice(acct);
        
        
        zqu__Quote__c qt = createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, zqu__RenewalTermPeriodType__c, zqu__InitialTermPeriodType__c, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = createQuoteAmendment(qt);
        qam.zqu__Type__c = 'UpdateProduct';
		system.debug('check 1');
        insert qam;

        zqu__QuoteRatePlan__c qrp = createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'UpdateProduct';
		system.debug('check 2');
        insert qrp;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        
        system.debug(JSON.serializePretty(qps));
        
        system.assertEquals(1, qps.size());
       // system.assertEquals('Update', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
        
        Zuora__SubscriptionProductCharge__c subcharge1 = new Zuora__SubscriptionProductCharge__c();
        subcharge1.Zuora__External_Id__c ='zoura-charge1';
        subcharge1.Zuora__RatePlanId__c = 'zuora-plan1'; 
        subcharge1.Zuora__Price__c = 100.00;
        subcharge1.Zuora__ExtendedAmount__c = 100.00;   
        subcharge1.Zuora__Type__c =  'One-Time';
        //subcharge1.Zuora__Subscription__c = zuoraSubscriptionId;
        subcharge1.ChannelPartner__c = 'Earthmover';
        subcharge1.SupportChannelPartner__c = 'Earthmover';
        subcharge1.Wholesaler__c = 'Laurel Grocery Company';
        subcharge1.SalesChannelPartnerCommissionPercent__c = '100';
        subcharge1.SupportChannelPartnerCommissionPercent__c = '100';
        subcharge1.WholesalerCommissionPercent__c = '100';   
        subcharge1.MinimumChargeCode__c = 'Test';   
        subcharge1.ProductUsageMetric__c = 'Test 2';
		system.debug('check 3');
        insert subcharge1;        
        

        zqu__QuoteRatePlanCharge__c qrpc = createQuoteRatePlanChargeWithDefault(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        qrpc.PartnerCommission__c = '10.0';
        qrpc.Cost__c = '10.0';
        qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c = subcharge1.id;
		system.debug('check 4');
        insert qrpc; 
		system.debug('check 5');
        //update qrpc;
        
        /*Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc1 = createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc1.zqu__EffectivePrice__c = 1500; //update the price
        qrpc1.PartnerCommission__c = '10.0';
        qrpc1.Cost__c = '10.0';
        update qrpc1;
        test.stoptest();*/
        
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc1 = new zqu__QuoteRatePlanCharge__c();
        qrpc1.Id = qrpc.Id;
        qrpc1.zqu__EffectivePrice__c = 1500; //update the price
        qrpc1.PartnerCommission__c = '10.0';
        qrpc1.Cost__c = '10.0';
        update qrpc1;
        test.stoptest();
        
        
        
        // check all without default values on account and opportunity reference fields
        //Account acct1 = new Account(Name ='Test Account', Account_Country_Code__c= 'US', Industry = 'HOSPITALITY:CHANNEL');
        //insert acct1;
        Account acct1 = [select id from Account where Subscription_Group__c != 'Digital Insight' limit 1];
        Opportunity opp1 = createOpp(acct1);    
        
        zqu__Quote__c qt1 = createQuote(opp1, 'Amendment');
        qt1 = [select Id,zqu__InitialTermPeriodType__c,zqu__RenewalTermPeriodType__c, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt1.Id];


        zqu__QuoteAmendment__c qam1 = createQuoteAmendment(qt1);
        qam1.zqu__Type__c = 'UpdateProduct';
		system.debug('check 8');
        insert qam1;

        zqu__QuoteRatePlan__c qrp1 = createQuoteRatePlan(qt1, qam1, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp1.zqu__AmendmentType__c = 'UpdateProduct';
		system.debug('check 9');
        insert qrp1;

        ZuoraSubscriptionState zss1 = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss1.addQuote(qt1);
        system.debug(zss1.var_dump());

        ZuoraSubscriptionState.QuoteProduct[] qps1 = zss1.getQuoteProducts();
        system.debug(JSON.serializePretty(qps1));
        
        system.assertEquals(1, qps1.size());
        //system.assertEquals('Update', qps1[0].action);
        system.assertNotEquals(null, qps1[0].sfProductId);
        system.assertEquals(null, qps1[0].sfProductRatePlanId);
    }

	//
}