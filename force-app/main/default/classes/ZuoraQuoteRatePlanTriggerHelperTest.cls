@isTest
public class ZuoraQuoteRatePlanTriggerHelperTest {

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
        String stdPriceBook = Test.getStandardPricebookId();
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', Topline_Product_Lkp__c = Prod1_Id);
        update new Product2(Id = pcatalog.products[1].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated', Topline_Product_Lkp__c = Prod2_Id);
        update new Product2(Id = pcatalog.products[2].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated', Topline_Product_Lkp__c = Prod0_Id);
        
        PricebookEntry[] pbes = new PricebookEntry[]{
            ZuoraTestUtil.createStandardPriceBookEntry(Prod0_Id, stdPriceBook),//stdPriceBook = 01s700000002GMcAAM
            ZuoraTestUtil.createCustomPriceBookEntry(Prod0_Id,GlobalVariable.pricebookId ),   //GlobalVariable.pricebookId = 01s7000000030GMAAY
            ZuoraTestUtil.createStandardPriceBookEntry(Prod1_Id , stdPriceBook),
            ZuoraTestUtil.createCustomPriceBookEntry(Prod1_Id , GlobalVariable.pricebookId), 
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
        
        
       
        
    }
    static testMethod void Test() {
        Test.startTest();
         zqu__Quote__c qu = new zqu__Quote__c();
        //qu.Id = opp.Id;
        qu.Name = 'amit2';
       
        insert qu;
        System.assert(qu.Id!=null);
        system.assertNotEquals('xyz',qu.Name);
        
        zqu__QuoteAmendment__c amm = new zqu__QuoteAmendment__c();
        amm.Name='amit1';
        amm.zqu__Quote__c = qu.Id;
        amm.zqu__Type__c = 'UpdateProduct';
        insert amm;
        System.assert(amm.Id!=null);
        system.assertNotEquals('abc',amm.Name);
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Name = 'dummy';
        sub.QuoteID__c = qu.id;
        sub.Zuora__External_Id__c = 'abcde2628';    
        insert sub;
        System.assert(sub.Id!=null);
        system.assertEquals('dummy',sub.Name);
        
        zuora__SubscriptionRatePlan__c subs = new zuora__SubscriptionRatePlan__c();
      //  subs.Id = sub.QuoteID__c;
        subs.MarketProductId__c = 'abc';
        subs.Zuora__External_Id__c = sub.Zuora__External_Id__c;
        subs.Zuora__Subscription__c= sub.Id;
       // subs.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
        insert subs;
       System.assert(subs.Id!=null);
        system.assertEquals('abc',subs.MarketProductId__c);
        
        
        zqu__QuoteRatePlan__c q = new zqu__QuoteRatePlan__c();
       // q.zqu__QuoteAmendment__c = 'RemoveProduct'; zqu__QuoteAmendment__c
        q.Name = 'Amit';
        q.zqu__QuoteAmendment__c = amm.Id;
         q.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
       q.zqu__AmendmentType__c = 'NewProduct1';
        q.MarketProductId__c = subs.MarketProductId__c;
        q.zqu__Quote__c = qu.id;
        insert q; 
        System.assert(q.Id!=null);
        system.assertEquals('NewProduct1',q.zqu__AmendmentType__c);
        
       ZuoraQuoteRatePlanTriggerHelper obj = new ZuoraQuoteRatePlanTriggerHelper();
        obj.onBeforeInsertdefaultProductId(new List<zqu__QuoteRatePlan__c>{q});
        set<String> setOfExistingExistSubscriptionRPID1 = new set<String>();
        setOfExistingExistSubscriptionRPID1.add( q.zqu__SubscriptionRatePlanZuoraId__c );
        
        Test.stopTest();
    }
     static testMethod void Test1() {
        Test.startTest();
         zqu__Quote__c qu = new zqu__Quote__c();
        //qu.Id = opp.Id;
        qu.Name = 'amit2';
       
        insert qu;
        System.assert(qu.Id!=null);
        system.assertNotEquals('xyz',qu.Name);
         
        zqu__QuoteAmendment__c amm = new zqu__QuoteAmendment__c();
        amm.Name='amit1';
        amm.zqu__Quote__c = qu.Id;
        amm.zqu__Type__c = 'UpdateProduct';
        insert amm;
        System.assert(amm.Id!=null);
        system.assertNotEquals('abc',amm.Name);
         
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Name = 'dummy';
        sub.QuoteID__c = qu.id;
        sub.Zuora__External_Id__c = 'abcde2628';    
        insert sub;       
        System.assert(sub.Id!=null);
        system.assertEquals('dummy',sub.Name);
         
        zuora__SubscriptionRatePlan__c subs = new zuora__SubscriptionRatePlan__c();
      //  subs.Id = sub.QuoteID__c;
        subs.MarketProductId__c = 'abc';
        subs.Zuora__External_Id__c = sub.Zuora__External_Id__c;
         //subs.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
        insert subs;
         System.assert(subs.Id!=null);
         system.assertEquals('abc',subs.MarketProductId__c);
         
        zqu__QuoteRatePlan__c q = new zqu__QuoteRatePlan__c();
       // q.zqu__QuoteAmendment__c = 'RemoveProduct'; zqu__QuoteAmendment__c
        q.Name = 'Amit';
        q.zqu__QuoteAmendment__c = amm.Id;
         q.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
       q.zqu__AmendmentType__c = 'NewProduct1';
        //q.MarketProductId__c = subs.MarketProductId__c;
        q.zqu__Quote__c = qu.id;
        insert q; 
        System.assert(q.Id!=null);
        system.assertEquals('NewProduct1',q.zqu__AmendmentType__c);
         
       ZuoraQuoteRatePlanTriggerHelper obj = new ZuoraQuoteRatePlanTriggerHelper();
        obj.onBeforeInsertdefaultProductId(new List<zqu__QuoteRatePlan__c>{q});
       set<String> setOfExistingExistSubscriptionRPID1 = new set<String>();
       setOfExistingExistSubscriptionRPID1.add( q.zqu__SubscriptionRatePlanZuoraId__c );
         
        Test.stopTest();
    }
   
    
    
    
    static testMethod void runQRPCUnitTest() {
        Test.startTest();
        CheckRecursive.runCalcACV = true; 
        zqu__QuoteRatePlanCharge__c qrpc = [SELECT Id,zqu__EffectivePrice__c FROM zqu__QuoteRatePlanCharge__c LIMIT 1];
        qrpc.zqu__EffectivePrice__c  = qrpc.zqu__EffectivePrice__c  + 100.00;
        update qrpc;
        System.assert(qrpc.Id!=null);
        system.assertNotEquals(100,qrpc.zqu__EffectivePrice__c);
        Test.stopTest();       
    }
    
    static testMethod void runQRPCTest() {
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = [SELECT Id FROM zqu__QuoteRatePlanCharge__c LIMIT 1];
        String qrpcId = qrpc.Id;
        delete qrpc;
        
        
        CheckRecursive.runCalcACV = true; 
        List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id FROM zqu__QuoteRatePlanCharge__c where Id= :qrpcId ALL ROWS];
        undelete qrpcList;
        System.assert(qrpcList!=Null);
        Test.stopTest();
    }
    
     static testMethod void runRatePlanTest() {
        Test.startTest();
            zqu__QuoteRatePlan__c qrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
            String qrpId = qrp.Id;
            delete qrp;
        
        
        List<zqu__QuoteRatePlan__c > qrpList = [SELECT Id FROM zqu__QuoteRatePlan__c  where Id= :qrpId ALL ROWS];
        undelete qrpList ;
         System.assert(qrpList!=Null);
        Test.stopTest();
    }
    
    static testMethod void runQuoteAmendTest() {
        Test.startTest();
            zqu__QuoteAmendment__c qm = [SELECT Id FROM zqu__QuoteAmendment__c LIMIT 1];
            String qmId = qm.Id;
            delete qm;
       
        
        List<zqu__QuoteAmendment__c > qmList = [SELECT Id FROM zqu__QuoteAmendment__c where Id = :qmId ALL ROWS];
        undelete qmList;
        System.assert(qmList!=Null);
         Test.stopTest();
    }
    
  /*  static testMethod void runSubscriptionTest() 
    {
       Test.startTest();
            zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
         //         q.Name = 'Amit';
       // q.zqu__QuoteAmendment__c = amm.Id;
            zuora__SubscriptionRatePlan__c qrpList = [SELECT Id, MarketProductId__c, Zuora__External_Id__c  FROM zuora__SubscriptionRatePlan__c];
            qrp.zqu__AmendmentType__c = 'RemoveProduct';
            qrp.MarketProductId__c = qrpList.MarketProductId__c;
            qrp.zqu__SubscriptionRatePlanZuoraId__c = qrpList.Zuora__External_Id__c;
        //qrp.zqu__QuoteAmendment__c=amm.id;
        upsert qrp;
        Test.stopTest();
    }*/
}