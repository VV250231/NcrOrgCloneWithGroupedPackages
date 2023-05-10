@isTest
private class CalcACVandAddOLITest {
     @testSetup static void setupTestData() {
        Account a = new Account();
        a.name = 'test-acc'; 
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        a.Subscription_Group__c = 'Digital Insight';
         System.runas(TestRecordsFactory.getUser()){
        insert a;
         }
        
        Opportunity opp = ZuoraTestUtil.createOpp(a);
        
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
        
        //Pricebook2 pb =[ Select id,name from Pricebook2 where name ='Standard Price Book']
        String stdPriceBook = Test.getStandardPricebookId();
        PricebookEntry[] pbes = new PricebookEntry[]{
            ZuoraTestUtil.createStandardPriceBookEntry(Prod0_Id, stdPriceBook),
            ZuoraTestUtil.createCustomPriceBookEntry(Prod0_Id, GlobalVariable.pricebookId),   
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
    
    static testMethod void runQRPCUnitTest() {
        Test.startTest();
        CheckRecursive.runCalcACV = true; 
        zqu__QuoteRatePlanCharge__c qrpc = [SELECT Id,zqu__EffectivePrice__c FROM zqu__QuoteRatePlanCharge__c LIMIT 1];
        qrpc.zqu__EffectivePrice__c  = qrpc.zqu__EffectivePrice__c  + 100.00;
        update qrpc;
        zqu__QuoteRatePlanCharge__c qObj = [select zqu__EffectivePrice__c from zqu__QuoteRatePlanCharge__c where id=:qrpc.id];
        System.assert(qObj.zqu__EffectivePrice__c!=null); 
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
         zqu__QuoteRatePlanCharge__c qrpObj = [select id from zqu__QuoteRatePlanCharge__c where id=:qrpcId];
        System.assert(qrpObj.id!=null);        
        Test.stopTest();
    }
    
     static testMethod void runRatePlanTest() {
        Test.startTest();
            zqu__QuoteRatePlan__c qrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
            String qrpId = qrp.Id;
            delete qrp;
        
        
        List<zqu__QuoteRatePlan__c > qrpList = [SELECT Id FROM zqu__QuoteRatePlan__c  where Id= :qrpId ALL ROWS];
        undelete qrpList ;
         zqu__QuoteRatePlan__c qrpObj = [select id from zqu__QuoteRatePlan__c where id=:qrpId];
        System.assert(qrpObj.id!=null);
        Test.stopTest();
    }
    
    static testMethod void runQuoteAmendTest() {
        Test.startTest();
            zqu__QuoteAmendment__c qm = [SELECT Id FROM zqu__QuoteAmendment__c LIMIT 1];
            String qmId = qm.Id;
            delete qm;
           
        
        List<zqu__QuoteAmendment__c > qmList = [SELECT Id FROM zqu__QuoteAmendment__c where Id = :qmId ALL ROWS];
        undelete qmList;
        zqu__QuoteAmendment__c qrpObj = [select id from zqu__QuoteAmendment__c where id=:qmId];
        System.assert(qrpObj.id!=null);
         Test.stopTest();
    }
}