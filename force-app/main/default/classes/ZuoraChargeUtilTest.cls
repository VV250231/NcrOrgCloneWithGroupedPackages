@isTest
private class ZuoraChargeUtilTest {
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    @testSetup static void setupTestData() {
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        a.Subscription_Group__c = 'Digital Insight';
        System.runAs(getUser()){
            insert a;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(a);
        ZuoraTestUtil.coverage();
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        for(zqu__ZProduct__c zp : pcatalog.products) {
            system.debug('zp: ' + zp);
        }
        
        String Prod0_Id = pcatalog.products[0].zqu__Product__c;
        String Prod1_Id = pcatalog.products[1].zqu__Product__c;
        String Prod2_Id = pcatalog.products[2].zqu__Product__c;
        
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', Topline_Product_Lkp__c = Prod1_Id);
        update new Product2(Id = pcatalog.products[1].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated', Topline_Product_Lkp__c = Prod2_Id);
        update new Product2(Id = pcatalog.products[2].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated', Topline_Product_Lkp__c = Prod0_Id);
        
        Product2 marketProd = new Product2( Name='TestMarket Product',Product_Type__c = 'Topline', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                           Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/
                                           isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true,PMDM_Unique_Key__c = 'PMDM1');
        insert marketProd ;
        
        String stdPriceBook = Test.getStandardPricebookId();
        PricebookEntry stdPBE1 = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=marketProd.id, PriceBook2Id=stdPriceBook , UnitPrice=2000, UseStandardPrice=false, isactive = true);
        insert stdPBE1 ;
        System.assert(stdPBE1.Id!=null);
        system.assertEquals('USD',stdPBE1.CurrencyIsoCode);
        
        PricebookEntry[] pbes = new PricebookEntry[]{
            ZuoraTestUtil.createStandardPriceBookEntry(Prod0_Id, stdPriceBook),
                ZuoraTestUtil.createCustomPriceBookEntry(Prod0_Id, GlobalVariable.pricebookId),   
                ZuoraTestUtil.createStandardPriceBookEntry(Prod1_Id , stdPriceBook),
                ZuoraTestUtil.createCustomPriceBookEntry(Prod1_Id , GlobalVariable.pricebookId), 
                ZuoraTestUtil.createStandardPriceBookEntry(Prod2_Id , stdPriceBook),
                ZuoraTestUtil.createCustomPriceBookEntry(Prod2_Id ,  GlobalVariable.pricebookId),
                ZuoraTestUtil.createCustomPriceBookEntry(marketProd.Id ,  GlobalVariable.pricebookId)
                };
                    insert pbes;
        
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Default');  
        
        qt = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
              zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        
        qt.zqu__Primary__c = true;
        update qt; 
        System.assert(qt.Id!=null);
        system.assertEquals(true,qt.zqu__Primary__c);
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
    
    static testMethod void runQuoteTest() {
        ZuoraChargeUtil zUtil = new ZuoraChargeUtil(); 
        Set<ID> zChargeIds = new Set<ID>();
        List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id,zqu__EffectivePrice__c FROM zqu__QuoteRatePlanCharge__c];
        
        for(zqu__QuoteRatePlanCharge__c qrpc : qrpcList) {
            zChargeIds.add(qrpc.Id);
        }
        zUtil.populateChargeACV(zChargeIds);
        
        Test.startTest();
        zqu__Quote__c qt = [SELECT Id From zqu__Quote__c Limit 1];
        System.assert(qt.Id !=NULL);
        
        zUtil.calcACVFromQuote(new Set<ID>{qt.Id});
        Test.stopTest();
    }
    
    static testMethod void runQuoteRatePlanTest() {
        Test.startTest();
        zqu__QuoteRatePlan__c qrp = [SELECT Id FROM zqu__QuoteRatePlan__c Limit 1];
        qrp.MarketProductId__c = 'PMDM1';
        update qrp;
        System.assert(qrp.Id !=NULL);
        system.assertNotEquals('TestAashirwaad',qrp.MarketProductId__c);
        new ZuoraChargeUtil().calcACVFromRatePlan(new Set<ID>{qrp.Id});
        delete qrp;
        Test.stopTest();
    }
    static testMethod void runQuoteTestforRecurring() {
        ZuoraChargeUtil zUtil = new ZuoraChargeUtil(); 
        
        Test.startTest();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo =  rtMapByName.get('Amendment');
        
        zqu__Quote__c qt = [SELECT Id From zqu__Quote__c Limit 1];
        qt.RecordTypeId = rtInfo.getRecordTypeId();
        Date startDate = Date.today();
        qt.zqu__SubscriptionTermEndDate__c = Date.today(); //Date.newInstance(startDate.year(), startDate.month()+1, 1);
        update qt;
        System.assert(qt.ID != Null);
        
        
        List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id,zqu__EffectivePrice__c,zqu__ChargeType__c,zqu__Period__c   FROM zqu__QuoteRatePlanCharge__c limit 1];
        qrpcList[0].zqu__ChargeType__c = 'Recurring';
        update qrpcList ;
        zUtil.populateChargeACV(new Set<ID>{qrpcList[0].id});
        Test.stopTest();
    }
    static testMethod void runQuoteTestforOneTime() {
        ZuoraChargeUtil zUtil = new ZuoraChargeUtil(); 
        
        Test.startTest();
        zqu__Quote__c qt = [SELECT Id From zqu__Quote__c Limit 1];
        Date startDate = Date.today();
        qt.zqu__InitialTerm__c = 2;
        qt.zqu__SubscriptionTermEndDate__c = Date.today(); //Date.newInstance(startDate.year(), startDate.month()+1, 1);
        update qt;
        
        
        List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id,zqu__EffectivePrice__c,zqu__ChargeType__c  FROM zqu__QuoteRatePlanCharge__c limit 1];
        qrpcList[0].zqu__ChargeType__c = 'One-Time';
        update qrpcList ;
        System.assert(qrpcList.size()>0);
        system.assertNotEquals('TestAashirwaad',qrpcList[0].zqu__ChargeType__c);
        zUtil.populateChargeACV(new Set<ID>{qrpcList[0].id});
        Test.stopTest();
    }
    
    static testMethod void runQuoteTestforAmendment() {
        ZuoraChargeUtil zUtil = new ZuoraChargeUtil(); 
        
        Test.startTest();
        
        zqu__Quote__c qt = [SELECT Id,zqu__Opportunity__c From zqu__Quote__c Limit 1];
        
        Date startDate = Date.today();
        qt.zqu__InitialTerm__c = 0;
        qt.zqu__SubscriptionType__c = 'Amend Subscription';
        qt.zqu__SubscriptionTermEndDate__c = Date.today(); //Date.newInstance(startDate.year(), startDate.month()+1, 1);
        update qt;
        Opportunity opp = new opportunity(id=qt.zqu__Opportunity__c);
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        System.assert(p1.Id!=null);
        system.assertEquals('testpay',p1.Name);
        
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        
        List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id,zqu__EffectivePrice__c,zqu__ChargeType__c  FROM zqu__QuoteRatePlanCharge__c limit 1];
        qrpcList[0].zqu__ChargeType__c = 'One-Time';
        qrpcList[0].zqu__EffectivePrice__c = 1030 ;
        update qrpcList ;
        system.assertEquals('One-Time',qrpcList[0].zqu__ChargeType__c);
        
        Map<Id, Map<Id, Decimal>> mapIdChargeACV = new Map<Id, Map<Id, Decimal>>();
        mapIdChargeACV.put(qt.id,new Map<Id, Decimal>{qt.id => 108});
        Map<Id,Id> mpOpQ = new Map<Id,Id>();
        mpOpQ.put(qt.id,qt.zqu__Opportunity__c);
        
        zUtil.updateExistingOLIofOpp(mapIdChargeACV,mpOpQ);
        zUtil.populateChargeACV(new Set<ID>{qrpcList[0].id});
        ZuoraChargeUtil.runACVCalcOnce();
        Test.stopTest();
    }
    
    static testMethod void runForDeleteQRP() {
        ZuoraChargeUtil zUtil = new ZuoraChargeUtil(); 
        
        Test.startTest();
        
        zqu__Quote__c qt = [SELECT Id,zqu__Opportunity__c From zqu__Quote__c Limit 1];
        
        Date startDate = Date.today();
        qt.zqu__InitialTerm__c = 0;
        qt.zqu__SubscriptionType__c = 'Amend Subscription';
        qt.zqu__SubscriptionTermEndDate__c = Date.today(); //Date.newInstance(startDate.year(), startDate.month()+1, 1);
        update qt;
        System.assert(qt.Id!=null);
        system.assertNotEquals('TestAashirwaad',qt.zqu__SubscriptionType__c);
        
        Opportunity opp = new opportunity(id=qt.zqu__Opportunity__c);
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        
        System.assert(p1.Id!=null);
        system.assertEquals('testpay',p1.Name);
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        
        zqu__QuoteRatePlan__c qrp = [SELECT Id FROM zqu__QuoteRatePlan__c Limit 1];
        
        delete qrp ;
        undelete qrp;
        Test.stopTest();
    }
    
}