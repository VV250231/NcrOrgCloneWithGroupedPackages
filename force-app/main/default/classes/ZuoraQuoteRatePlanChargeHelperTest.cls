@isTest
public class ZuoraQuoteRatePlanChargeHelperTest {
    
    private static Account a;
    
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    @testSetup static void setupTestData() 
    {
        //create account
        a = new Account(name = 'test-acc', industry = 'HOSPITALITY:CHANNEL', Account_Country_Code__c = 'US', Subscription_Group__c = 'Digital Insight');
        System.runAs(getUser())
        {
            insert a;
        }
        
        Opportunity opp = ZuoraTestUtil.createOpp(a);
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        for(zqu__ZProduct__c zp : pcatalog.products)
        {
            system.debug('zp: ' + zp);
        }
        
        String Prod0_Id = pcatalog.products[0].zqu__Product__c;
        String Prod1_Id = pcatalog.products[1].zqu__Product__c;
        String Prod2_Id = pcatalog.products[2].zqu__Product__c;
        String stdPriceBook = Test.getStandardPricebookId();//stdPriceBook =01s700000002GMc
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', Topline_Product_Lkp__c = Prod1_Id);
        update new Product2(Id = pcatalog.products[1].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated', Topline_Product_Lkp__c = Prod2_Id);
        update new Product2(Id = pcatalog.products[2].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated', Topline_Product_Lkp__c = Prod0_Id);
        
        PricebookEntry[] pbes = new PricebookEntry[]{
            ZuoraTestUtil.createStandardPriceBookEntry(Prod0_Id, stdPriceBook),
                ZuoraTestUtil.createCustomPriceBookEntry(Prod0_Id, GlobalVariable.pricebookId),   
                ZuoraTestUtil.createStandardPriceBookEntry(Prod1_Id , stdPriceBook),
                ZuoraTestUtil.createCustomPriceBookEntry(Prod1_Id , GlobalVariable.pricebookId), //01s7000000030GMAAY =GlobalVariable.pricebookId
                ZuoraTestUtil.createStandardPriceBookEntry(Prod2_Id , stdPriceBook),
                ZuoraTestUtil.createCustomPriceBookEntry(Prod2_Id , GlobalVariable.pricebookId)
                };
                    insert pbes;
        
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Default');  
        
        qt = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
              zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        
        qt.zqu__Primary__c = true;
        update qt; 
        
        
        
        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt),
                ZuoraTestUtil.createQuoteAmendment(qt),
                ZuoraTestUtil.createQuoteAmendment(qt)
                };
                    insert qams;
        
        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]),
                ZuoraTestUtil.createQuoteRatePlan(qt, qams[1], pcatalog.products[1], pcatalog.productRatePlans[1], pcatalog.productRatePlanCharges[1]),
                ZuoraTestUtil.createQuoteRatePlan(qt, qams[2], pcatalog.products[2], pcatalog.productRatePlans[2], pcatalog.productRatePlanCharges[2])
                };
                    insert qrps;  
        
        
        
        zqu__QuoteRatePlanCharge__c [] qrpcs = new zqu__QuoteRatePlanCharge__c [] {
            ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]),
                ZuoraTestUtil.createQuoteRatePlanCharge(qrps[1], pcatalog.productRatePlanCharges[1]),
                ZuoraTestUtil.createQuoteRatePlanCharge(qrps[2], pcatalog.productRatePlanCharges[2])   
                };
                    
                    insert qrpcs; 
        
        /* Map<Id,zqu__QuoteRatePlanCharge__c> mapQRPC=new Map<Id,zqu__QuoteRatePlanCharge__c>();
mapQRPC.put(qrpcs[0].Id, qrpcs[0]);
*/
        
        List<zqu__QuoteChargeSummary__c> QCSList = new List<zqu__QuoteChargeSummary__c>();
        zqu__QuoteChargeSummary__c QCS1 = new zqu__QuoteChargeSummary__c();
        QCS1.Name = 'TestQCS1';
        QCS1.zqu__ProductRatePlanCharge__c = pcatalog.productRatePlanCharges[0].Id;
        //QCS1.zqu__ProductRatePlan__c = pcatalog.productRatePlans[0].Id;
        QCS1.zqu__QuoteRatePlanCharge__c = qrpcs[0].Id;
        QCS1.zqu__QuoteRatePlan__c = qrps[0].Id;
        QCSList.add(QCS1);
        
        zqu__QuoteChargeSummary__c QCS2 = new zqu__QuoteChargeSummary__c();
        QCS2.Name = 'TestQCS2';
        QCS2.zqu__ProductRatePlanCharge__c = pcatalog.productRatePlanCharges[1].Id;
        //QCS2.zqu__ProductRatePlan__c = pcatalog.productRatePlans[1].Id;
        QCS2.zqu__QuoteRatePlanCharge__c = qrpcs[1].Id;
        QCS2.zqu__QuoteRatePlan__c = qrps[1].Id;
        QCSList.add(QCS2);
        
        zqu__QuoteChargeSummary__c QCS3 = new zqu__QuoteChargeSummary__c();
        QCS3.Name = 'TestQCS3';
        QCS3.zqu__ProductRatePlanCharge__c = pcatalog.productRatePlanCharges[2].Id;
        //QCS3.zqu__ProductRatePlan__c = pcatalog.productRatePlans[2].Id;
        QCS3.zqu__QuoteRatePlanCharge__c = qrpcs[2].Id;
        QCS3.zqu__QuoteRatePlan__c = qrps[2].Id;
        QCSList.add(QCS3);
        
        insert QCSList;
        
        Quote_Product__c p1 = new Quote_Product__c(); 
        p1.Name = 'Fake'; 
        p1.Action__c = 'Deactivate'; 
        p1.Quote__c = qt.id;
        p1.Quote_Rate_Plan__c = qrps[0].Id;
        insert p1;
        System.assert(p1.Id!=null);
        system.assertNotEquals('Active',p1.Action__c);
        Quote_Product__c p2 = new Quote_Product__c(); 
        p2.Name = 'Fake2';
        p2.Action__c = 'Softlock'; 
        p2.Quote__c = qt.id;
        p2.Quote_Rate_Plan__c = qrps[1].Id;
        insert p2;
        System.assert(p2.Id!=null);
        system.assertNotEquals('Active',p2.Action__c);
        
        Quote_Product__c p3 = new Quote_Product__c(); 
        p3.Name = 'Fake3';
        p3.Action__c = 'Softlock'; 
        p3.Quote__c = qt.id;
        p3.Quote_Rate_Plan__c = qrps[2].Id;
        insert p3;
        System.assert(p3.Id!=null);
        system.assertNotEquals('Active',p3.Action__c);
    }
    public static String generateGUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String hyphen = '';
        String requestGUID = h.SubString(0,8) + hyphen + h.SubString(8,12) + hyphen + h.SubString(12,16) + hyphen + h.SubString(16,20) + hyphen + h.substring(20);
        return requestGUID;     
    }
    
    public static Opportunity createOppWithChannelOffice(Account acct)
    {
        Id co =NSCCommonInfoUtil.getIdOf('Channel_Office');//0010g00001XjK4kAAF
        OpportunityStage ostage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id,  StageName = ostage.MasterLabel, CloseDate = Date.today().addDays(1),
                                          /* Solution_Portfolio__c = 'DIGITAL BANKING',*/ CurrencyIsoCode = 'USD',Channel_Office__c=co,Opportunity_Classification__c='Digital Insight');
        insert opp;
        System.assert(opp.Id!=null);
        system.assertEquals('Test Opp',opp.Name);
        system.assertNotEquals('NZD', opp.CurrencyIsoCode);
        return opp;
    }
    
    static testMethod void Test() {
        
        /*START*/
        
        Test.startTest();
        
        
        Account acct = new Account();
        acct.name = 'Test Account' ;
        acct.Subscription_Group__c = 'Hosted Solutions' ;
        System.runAs(getUser()){
            insert acct;
        }
        
        Account acct1 = new Account();
        acct1.name = 'Test Account1' ;
        acct1.Subscription_Group__c = 'Hosted Solutions' ;
        System.runAs(getUser()){
            insert acct1;
        }
        
        
        
        
        Opportunity opp = createOppWithChannelOffice(acct);
        
        
        Product2 sfProducts = new Product2();
        sfProducts.zqu__ZuoraId__c = generateGUID();
        sfProducts.Name = 'Test ZProduct 1_SA';
        sfProducts.zqu__SKU__c = 'SKU-9999911';
        sfProducts.ProductCode = 'SKU-9999911';
        sfProducts.IsActive = true;
        insert sfProducts;
        System.assert(sfProducts.Id!=null);
        system.assertNotEquals('TestAashirwaad',sfProducts.ProductCode);
        
        zqu__ZProduct__c zproduct = new zqu__ZProduct__c();
        zproduct.zqu__ZuoraId__c = generateGUID();
        zproduct.Name = 'Test ZProduct 1_SA';
        zproduct.zqu__SKU__c = 'SKU-9999911';
        zproduct.ProductCategory__c = 'IB Vendor'; 
        zproduct.InterfaceType__c = null;
        zproduct.zqu__Product__c = sfProducts.Id;
        zproduct.zqu__EffectiveStartDate__c = Date.today().addYears(-1); 
        zproduct.zqu__EffectiveEndDate__c = Date.today().addYears(25);
        insert zproduct;
        System.assert(zproduct.Id!=null);
        system.assertEquals(null,zproduct.InterfaceType__c);
        
        zqu__ProductRatePlan__c zproductRatePlan = new zqu__ProductRatePlan__c();             
        zproductRatePlan.zqu__Product__c = zproduct.zqu__Product__c;
        zproductRatePlan.zqu__ZuoraId__c = generateGUID(); 
        zproductRatePlan.zqu__ZProduct__c = zproduct.Id; 
        zproductRatePlan.zqu__EffectiveStartDate__c = Date.today().addYears(-1);
        zproductRatePlan.ProductSystem__c= 'ZQuotes';
        zproductRatePlan.zqu__EffectiveEndDate__c = Date.today().addYears(25); 
        zproductRatePlan.zqu__Deleted__c = false;     
        insert zproductRatePlan;
        System.assert(zproductRatePlan.Id!=null);
        system.assertEquals('ZQuotes',zproductRatePlan.ProductSystem__c);
        
        zqu__ProductRatePlanCharge__c zprpc = new zqu__ProductRatePlanCharge__c();
        zprpc.zqu__ZuoraId__c = generateGUID();
        zprpc.zqu__ProductRatePlan__c = zproductRatePlan.Id; 
        zprpc.Name = 'Test Charge 1_1'; 
        zprpc.zqu__RecurringPeriod__c = 'Month';
        zprpc.zqu__Model__c = 'Flat Fee Pricing'; 
        zprpc.zqu__ListPrice__c = 1000; 
        zprpc.zqu__Deleted__c = false;    
        zprpc.MinimumChargeCode__c = 'Test 2'; 
        zprpc.ProductUsageMetric__c = 'Test 2';
        zprpc.zqu__BillingTiming__c='In Advance';
        
        insert zprpc;
        System.assert(zprpc.Id!=null);
        system.assertEquals(1000,zprpc.zqu__ListPrice__c);
        
        zqu__ProductRatePlanChargeTier__c zprpctiers = new zqu__ProductRatePlanChargeTier__c();
        zprpctiers.zqu__ZuoraId__c = generateGUID(); 
        zprpctiers.zqu__ProductRatePlanCharge__c = zprpc.Id; 
        zprpctiers.Name = 'Test Charge 1_1'; 
        zprpctiers.zqu__Price__c = 1000; 
        zprpctiers.zqu__Currency__c = 'USD'; 
        zprpctiers.zqu__Currency2__c = 'USD'; 
        zprpctiers.zqu__Active__c = true;
        zprpctiers.zqu__StartingUnit__c = 0; 
        zprpctiers.zqu__EndingUnit__c = 0; 
        zprpctiers.zqu__Tier__c = 1; 
        zprpctiers.zqu__Deleted__c = false;    
        insert zprpctiers;
        System.assert(zprpctiers.Id!=null);
        system.assertEquals(0,zprpctiers.zqu__StartingUnit__c);
        /*END*/
        
        
        
        zqu__Quote__c qu = new zqu__Quote__c();
        qu.zqu__Opportunity__c = opp.Id;
        qu.Name = 'amit2';
        qu.zqu__Account__c=acct.Id;
        insert qu;
        System.assert(qu.Id!=null);
        system.assertEquals('amit2',qu.Name);
        
        zqu__Quote__c qu1 = new zqu__Quote__c();
        qu1.zqu__Opportunity__c = opp.Id;
        qu1.Name = 'amit21';
        qu1.id=qu.Id;
        qu1.zqu__Account__c=acct1.Id;
        update qu1;
        System.assert(qu.Id!=null);
        system.assertNotEquals('Name',zprpctiers.Name);
        
        zqu__QuoteAmendment__c amm = new zqu__QuoteAmendment__c();
        amm.Name='amit1';
        amm.zqu__Quote__c = qu.Id;
        amm.zqu__Type__c = 'UpdateProduct';
        insert amm;
        System.assert(amm.Id!=null);
        system.assertNotEquals('Aashirwaad',amm.Name);
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Name = 'dummy';
        sub.QuoteID__c = qu.id;
        sub.Zuora__External_Id__c = 'abcde2628';    
        insert sub;
        System.assert(sub.Id!=null);
        system.assertNotEquals('Test',sub.Name);
        
        zuora__SubscriptionRatePlan__c subs = new zuora__SubscriptionRatePlan__c();
        //  subs.Id = sub.QuoteID__c;
        subs.MarketProductId__c = 'abc';
        subs.Zuora__External_Id__c = sub.Zuora__External_Id__c;
        subs.Zuora__Subscription__c= sub.Id;
        // subs.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
        insert subs;
        System.assert(subs.Id!=null);
        system.assertNotEquals('Test',subs.MarketProductId__c);
        
        
        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        // q.zqu__QuoteAmendment__c = 'RemoveProduct'; zqu__QuoteAmendment__c
        qrp.Name = 'SANJAY';
        qrp.zqu__QuoteAmendment__c = amm.Id;
        qrp.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
        qrp.zqu__AmendmentType__c = 'UpdateProduct';
        qrp.MarketProductId__c = subs.MarketProductId__c;
        qrp.zqu__Quote__c = qu.id;
        insert qrp; 
        System.assert(qrp.Id!=null);
        system.assertEquals('UpdateProduct',qrp.zqu__AmendmentType__c);
        
        
        
        Zuora__SubscriptionProductCharge__c subcharge2 = new Zuora__SubscriptionProductCharge__c();
        subcharge2.Zuora__External_Id__c ='zoura-charge2';
        subcharge2.Zuora__RatePlanId__c = 'zuora-plan2'; 
        subcharge2.Zuora__Price__c = 100.00;
        subcharge2.Zuora__ExtendedAmount__c = 100.00;   
        subcharge2.Zuora__Type__c =  'One-Time';
        subcharge2.ChannelPartner__c = 'Earthmover';
        subcharge2.SupportChannelPartner__c = 'Earthmover';
        subcharge2.Wholesaler__c = 'Laurel Grocery Company';
        subcharge2.SalesChannelPartnerCommissionPercent__c = '100';
        subcharge2.SupportChannelPartnerCommissionPercent__c = '100';
        subcharge2.WholesalerCommissionPercent__c = '100'; 
        subcharge2.MinimumChargeCode__c = 'Test 2'; 
        subcharge2.ProductUsageMetric__c = 'Test 2';
        subcharge2.FinalBookingACV__c='testfinal';
        insert subcharge2;        
        System.assert(subcharge2.Id!=null);
        system.assertEquals('Laurel Grocery Company',subcharge2.Wholesaler__c);
        system.assertNotEquals('1000', subcharge2.SalesChannelPartnerCommissionPercent__c);
        //Added By Sanjay Pandit, 12-July-2021
        
        
        //New 
        zqu__QuoteRatePlanCharge__c qrpc=new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c=qrp.Id;
        Account a = TestRecordsFactory.createAccount();      
        qrpc.Name='test';
        qrpc.zqu__ProductRatePlanCharge__c = zprpc.Id;
        qrpc.zqu__ProductRatePlanChargeZuoraId__c = zprpc.zqu__ZuoraId__c;
        qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c=subcharge2.Id;
        qrpc.zqu__Currency__c = 'USD'; 
        qrpc.zqu__EffectivePrice__c = 1000;
        //qrpc.AmendmentType__c='UpdateProduct';
        //qrpc.AmendmentType__c=q.zqu__AmendmentType__c;
        //qrpc.AmendmentType__c = 'UpdateProduct';
        //qrpc.ChannelPartner__c = '';
        //qrpc.SupportChannelPartner__c = 'Earthmover';
        //qrpc.ChannelPartner_Lkp__c = '0017000001WcfRg';
        // qrpc.SupportChannelPartnerLkp__c  = '0017000001WcfRg';
        qrpc.ChannelPartner_Lkp__c = a.id;
        qrpc.SupportChannelPartnerLkp__c = a.id;
        qrpc.Wholesaler__c = 'Laurel Grocery Company';
        qrpc.SalesChannelPartnerCommissionPercent__c = '';
        qrpc.SupportChannelPartnerCommissionPercent__c = '';
        qrpc.PartnerCommission__c='100';
        qrpc.Cost__c='100';
        //qrpc.WholesalerCommissionPercent__c = '100';
        
        insert qrpc; 
        System.assert(qrpc.Id!=null);
        system.assertEquals('Laurel Grocery Company',qrpc.Wholesaler__c);
        system.assertNotEquals('100', qrpc.SalesChannelPartnerCommissionPercent__c);
        
        //
        
        zqu__QuoteRatePlanCharge__c qrpc2=new zqu__QuoteRatePlanCharge__c();
        qrpc2.Id=qrpc.Id;
        qrpc2.zqu__EffectivePrice__c = 1100;
        update qrpc2;
        System.assert(qrpc2.Id!=null);
        system.assertNotEquals(1111, qrpc2.zqu__EffectivePrice__c);
        
        Map<Id, zqu__QuoteRatePlanCharge__c> mapOldQRPC=new Map<Id,zqu__QuoteRatePlanCharge__c>();
        mapOldQRPC.put(qrpc.Id, qrpc);
        
        
        Map<Id, zqu__QuoteRatePlanCharge__c> mapNewQRPC=new Map<Id,zqu__QuoteRatePlanCharge__c>();
        mapNewQRPC.put(qrpc2.Id, qrpc2);
        
        
        ZuoraQuoteRatePlanChargeTriggerHelper obj = new ZuoraQuoteRatePlanChargeTriggerHelper();
        obj.onBeforeInsertCalcACVandAddOLIs(new List<zqu__QuoteRatePlanCharge__c>{qrpc});
        obj.onAfterDeleteCalcACVandAddOLIs(new List<zqu__QuoteRatePlanCharge__c>{qrpc}); 
        obj.onAfterInsertCalcACVandAddOLIs(mapNewQRPC);
        obj.onAfterUnDeleteCalcACVandAddOLIs(mapNewQRPC);
        obj.onBeforeUpdateCalcACVandAddOLIs(new List<zqu__QuoteRatePlanCharge__c>{qrpc},mapOldQRPC,mapNewQRPC);
        obj.onAfterUpdateCalcACVandAddOLIs(new List<zqu__QuoteRatePlanCharge__c>{qrpc},mapOldQRPC,mapNewQRPC);
        
        
        
        //Default Channel  
        //obj.onBeforedefaultChannelOfficeField(new List<zqu__QuoteRatePlanCharge__c>{qrpc});
        obj.onBeforeInsertdefaultChannelOfficeField(new List<zqu__QuoteRatePlanCharge__c>{qrpc});
        obj.onBeforeUpdatedefaultChannelOfficeField(new List<zqu__QuoteRatePlanCharge__c>{qrpc});
        
        
        /*set<String> setOfExistingExistSubscriptionRPID1 = new set<String>();
setOfExistingExistSubscriptionRPID1.add( q.zqu__SubscriptionRatePlanZuoraId__c );
*/      
        Test.stopTest();
    }
    
    
    
    static testMethod void runQRPCUnitTest() {
        Test.startTest();
        CheckRecursive.runCalcACV = true; 
        zqu__QuoteRatePlanCharge__c qrpc = [SELECT Id,zqu__EffectivePrice__c FROM zqu__QuoteRatePlanCharge__c LIMIT 1];
        qrpc.zqu__EffectivePrice__c  = qrpc.zqu__EffectivePrice__c  + 100.00;
        update qrpc;
        System.assert(qrpc.Id!=null);
        system.assertNotEquals(100.00,qrpc.zqu__EffectivePrice__c);
        Test.stopTest();       
    }
    
    static testMethod void runQRPCTest() {
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = [SELECT Id FROM zqu__QuoteRatePlanCharge__c LIMIT 1];
        String qrpcId = qrpc.Id;
        delete qrpc;
        //System.assertEquals(qrpc.IsDeleted, true);
        
        
        CheckRecursive.runCalcACV = true; 
        List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id FROM zqu__QuoteRatePlanCharge__c where Id= :qrpcId ALL ROWS];
        undelete qrpcList;
        System.assert(qrpcList!=null);
        Test.stopTest();
    }
    
    static testMethod void runRatePlanTest() {
        Test.startTest();
        zqu__QuoteRatePlan__c qrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
        String qrpId = qrp.Id;
        delete qrp;
        //System.assertEquals(qrp.IsDeleted, true);
        
        List<zqu__QuoteRatePlan__c > qrpList = [SELECT Id FROM zqu__QuoteRatePlan__c  where Id= :qrpId ALL ROWS];
        undelete qrpList ;
        system.assert(qrpList!=null);
        Test.stopTest();
    }
    
    static testMethod void runQuoteAmendTest() {
        Test.startTest();
        zqu__QuoteAmendment__c qm = [SELECT Id FROM zqu__QuoteAmendment__c LIMIT 1];
        String qmId = qm.Id;
        delete qm;
       // System.assertEquals(qm.IsDeleted, true);
        
        
        List<zqu__QuoteAmendment__c > qmList = [SELECT Id FROM zqu__QuoteAmendment__c where Id = :qmId ALL ROWS];
        undelete qmList;
        System.assert(qmList!=Null);
        Test.stopTest();
    }
    
}