// ===========================================================================
// Object: QuoteSummaryControllerTests
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for QuoteSummaryController for DI story 1478
// ===========================================================================
// Changes: 2016-12-05 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class QuoteSummaryControllerTests {
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    } 
    
    
    /******************************************* */
    
    
    
    @isTest
    public static void testRenew1() {
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('Recurring', 'Per Unit Pricing');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account'
        }));
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'AccountId' => mock.getFirst('Account').getValue('Id'),
            'TermType' => 'TERMED',
            'InitialTerm' => 84,
            'RenewalTerm' => 24,
            'SubscriptionStartDate' => Date.today(),
            'SubscriptionEndDate' => Date.today().addMonths(84)
        }));
        String zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => zuoraSubscriptionId,
            'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Volume Pricing'
        }));
        String ratePlanChargeId = (String)mock.getFirst('RatePlanCharge').getValue('Id');
        mock.addData('RatePlanChargeTier', ZuoraTestUtil.createZuoraObject('RatePlanChargeTier', new Map<String,Object>{
            'RatePlanChargeId' => ratePlanChargeId, 'StartingUnit' => 0, 'EndingUnit' => 1,
            'Tier' => 1, 'Price' => 1000
        }));
        mock.addData('RatePlanChargeTier', ZuoraTestUtil.createZuoraObject('RatePlanChargeTier', new Map<String,Object>{
            'RatePlanChargeId' => ratePlanChargeId,
            'Tier' => 2, 'Price' => 900, 'StartingUnit' => 2
        }));
        
        Account acct = new Account(Name ='Test Account');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        qt.Renewal_Subscription_ID__c = zuoraSubscriptionId;
        update qt;
        
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];

        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        //qam.zqu__Type__c = 'UpdateProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        //qrp.zqu__AmendmentType__c = 'UpdateProduct';
        qrp.Renewal_Rate_Plan_Id__c = ratePlanId;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1000; //update the price
        qrpc.zqu__Quantity__c = 2;
        qrpc.zqu__Model__c = 'Volume Pricing';
        insert qrpc;
                
        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        //zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id);        
        qcs.zqu__EffectivePrice__c = 1500;
        qcs.zqu__Quantity__c = 3; //update the quantity
        qcs.zqu__TotalPrice__c = 1500;
        qcs.zqu__Model__c = 'Volume Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;
                
        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        qam2.zqu__Type__c = 'UpdateProduct';
        insert qam2;

        
        ZuoraTestUtil.ProductCatalog pcatalog2 = ZuoraTestUtil.createOneProductCatalog('SKU-999992','Recurring', 'Volume Pricing');
        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam2, pcatalog2.products[0], pcatalog2.productRatePlans[0], pcatalog2.productRatePlanCharges[0]);
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog2.productRatePlanCharges[0]);
        qrpc2.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc2;
        
        //Sanjay
        zqu__QuoteRatePlanCharge__c qrpc3 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog2.productRatePlanCharges[0]);
        qrpc3.zqu__EffectivePrice__c = 1300; //update the price
        qrpc3.Id=qrpc2.Id;
        update qrpc3;
        
        DIQuoteUtil.createQuoteProducts(new Set<Id>{ qt.Id });

        QuoteSummaryController qsc = new QuoteSummaryController(new ApexPages.StandardController(qt));
        qsc.initAction();
        system.debug(qsc.isNew);
        system.debug(qsc.pageBlockTitle);
        system.debug(qsc.subscriptionType);
        
        QuoteSummaryController.coverage();
    }

    
    
    
    
    
    
    
    
    
    
    
    /******************************************* */
    
    @isTest
    public static void testRenew() {
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('Recurring', 'Per Unit Pricing');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account'
        }));
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'AccountId' => mock.getFirst('Account').getValue('Id'),
            'TermType' => 'TERMED',
            'InitialTerm' => 84,
            'RenewalTerm' => 24,
            'SubscriptionStartDate' => Date.today(),
            'SubscriptionEndDate' => Date.today().addMonths(84)
        }));
        String zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => zuoraSubscriptionId,
            'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Volume Pricing'
        }));
        String ratePlanChargeId = (String)mock.getFirst('RatePlanCharge').getValue('Id');
        mock.addData('RatePlanChargeTier', ZuoraTestUtil.createZuoraObject('RatePlanChargeTier', new Map<String,Object>{
            'RatePlanChargeId' => ratePlanChargeId, 'StartingUnit' => 0, 'EndingUnit' => 1,
            'Tier' => 1, 'Price' => 1000
        }));
        mock.addData('RatePlanChargeTier', ZuoraTestUtil.createZuoraObject('RatePlanChargeTier', new Map<String,Object>{
            'RatePlanChargeId' => ratePlanChargeId,
            'Tier' => 2, 'Price' => 900, 'StartingUnit' => 2
        }));
        
        Account acct = new Account(Name ='Test Account');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        qt.Renewal_Subscription_ID__c = zuoraSubscriptionId;
        update qt;
        
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];

        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        //qam.zqu__Type__c = 'UpdateProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        //qrp.zqu__AmendmentType__c = 'UpdateProduct';
        qrp.Renewal_Rate_Plan_Id__c = ratePlanId;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        qrpc.zqu__Quantity__c = 1;
        insert qrpc;
        
        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__EffectivePrice__c = 1500;
        qcs.zqu__Quantity__c = 1; //update the quantity
        qcs.zqu__TotalPrice__c = 1500;
        qcs.zqu__Model__c = 'Per Unit Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        //qam.zqu__Type__c = 'UpdateProduct';
        insert qam2;

        ZuoraTestUtil.ProductCatalog pcatalog2 = ZuoraTestUtil.createOneProductCatalog('SKU-999992','Recurring', 'Per Unit Pricing');
        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam2, pcatalog2.products[0], pcatalog2.productRatePlans[0], pcatalog2.productRatePlanCharges[0]);
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog2.productRatePlanCharges[0]);
        qrpc2.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc2;

        DIQuoteUtil.createQuoteProducts(new Set<Id>{ qt.Id });

        QuoteSummaryController qsc = new QuoteSummaryController(new ApexPages.StandardController(qt));
        qsc.initAction();
        system.debug(qsc.isNew);
        system.debug(qsc.pageBlockTitle);
        system.debug(qsc.subscriptionType);
    }

    @isTest
    public static void testAmend() {
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account'
        }));
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'AccountId' => mock.getFirst('Account').getValue('Id'),
            'TermType' => 'TERMED',
            'InitialTerm' => 84,
            'RenewalTerm' => 24,
            'SubscriptionStartDate' => Date.today(),
            'SubscriptionEndDate' => Date.today().addMonths(84)
        }));
        String zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        
        Account acct = new Account(Name ='Test Account');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt.zqu__ExistSubscriptionID__c = zuoraSubscriptionId;
        update qt;
        
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];

        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'UpdateProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'UpdateProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc;
        
        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        //qam.zqu__Type__c = 'UpdateProduct';
        insert qam2;

        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam2, pcatalog.products[1], pcatalog.productRatePlans[1], pcatalog.productRatePlanCharges[1]);
        //qrp.zqu__AmendmentType__c = 'UpdateProduct';
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog.productRatePlanCharges[1]);
        qrpc2.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc2;

        DIQuoteUtil.createQuoteProducts(new Set<Id>{ qt.Id });
        Test.startTest();
        QuoteSummaryController qsc = new QuoteSummaryController(new ApexPages.StandardController(qt));
        qsc.initAction();
        system.debug(qsc.isNew);
        system.debug(qsc.pageBlockTitle);
        system.debug(qsc.subscriptionType);
        Test.stopTest();
    }

    @isTest
    public static void testNew() {
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        
        Account acct = new Account(Name ='Test Account');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Default');
        
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];

        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc;
        
        zqu__QuoteChargeSummary__c qchargeSummary = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__Quantity__c = 1, zqu__EffectivePrice__c = 1500, zqu__MRR__c = 1500);
        insert qchargeSummary;

        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        insert qam2;

        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam2, pcatalog.products[1], pcatalog.productRatePlans[1], pcatalog.productRatePlanCharges[1]);
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog.productRatePlanCharges[1]);
        qrpc2.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc2;
        
        zqu__QuoteChargeSummary__c qchargeSummary2 = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp2.Id, zqu__Quantity__c = 1, zqu__EffectivePrice__c = 1500, zqu__MRR__c = 1500);
        insert qchargeSummary2;

        DIQuoteUtil.createQuoteProducts(new Set<Id>{ qt.Id });

        QuoteSummaryController qsc = new QuoteSummaryController(new ApexPages.StandardController(qt));
        qsc.initAction();
        system.debug(qsc.isNew);
        system.debug(qsc.pageBlockTitle);
        system.debug(qsc.subscriptionType);
    }
    
    
    @isTest
    public static void testCoverage() {
        zqu__QuoteCharge_Tier__c qct = new zqu__QuoteCharge_Tier__c (
            zqu__Tier__c = 1, zqu__StartingUnit__c = 1,
            zqu__EndingUnit__c = 100, zqu__Effective_Price__c = 100.0  
        );
        
        QuoteSummaryController.ChargeTier chargeTier = new QuoteSummaryController.ChargeTier();
        chargeTier = new QuoteSummaryController.ChargeTier(qct); 
    }
}