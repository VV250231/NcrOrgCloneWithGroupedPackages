// ===========================================================================
// Object: TestZuoraSubscriptionState
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for ZuoraSubscriptionState
// ===========================================================================
// Changes: 2016-10-10 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class TestZuoraSubscriptionState 
{
    static ZuoraTestUtil.ProductCatalog pcatalog;
    static String zuoraSubscriptionId;
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }
    
    @isTest
    public static void test1_updatePriceAmendment() {
        setUp1();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '5555');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
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

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(1, qps.size());
        system.assertEquals('No Action', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
    }
    
    @isTest
    public static void test2_addQuantityAmendment() {
        Test.startTest();
        setUp2();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '6666');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        qt.zqu__ExistSubscriptionID__c = (String)mock.getFirst('Subscription').getValue('Id');
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
        qrpc.zqu__EffectivePrice__c = 1000;
        qrpc.zqu__Quantity__c = 3; //update the quantity
        qrpc.zqu__FeeType__c = 'Per Unit';
        qrpc.zqu__ChargeType__c = 'Recurring';
        insert qrpc;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__EffectivePrice__c = 1000;
        qcs.zqu__Quantity__c = 2; //update the quantity
        qcs.zqu__TotalPrice__c = 1000;
        qcs.zqu__Model__c = 'Per Unit Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(2, qps.size());
        system.assertEquals('Activate', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertNotEquals(null, qps[0].sfProductRatePlanId);
        system.assertEquals('Activate', qps[1].action);
        system.assertNotEquals(null, qps[1].sfProductId);
        system.assertNotEquals(null, qps[1].sfProductRatePlanId);
        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
        Test.stopTest();   
    }

    @isTest
    public static void test2B_addQuantityWithDuplicateAmendment() {
        Test.startTest();
        setUp2();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '7777');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        qt.zqu__ExistSubscriptionID__c = (String)mock.getFirst('Subscription').getValue('Id');
        update qt;
        
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1000;
        qrpc.zqu__Quantity__c = 2; //update the quantity by adding new quantity
        qrpc.zqu__FeeType__c = 'Per Unit';
        qrpc.zqu__ChargeType__c = 'Recurring';
        insert qrpc;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__EffectivePrice__c = 1000;
        qcs.zqu__Quantity__c = 2; //update the quantity
        qcs.zqu__TotalPrice__c = 1000;
        qcs.zqu__Model__c = 'Per Unit Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(2, qps.size());
        system.assertEquals('Activate', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertNotEquals(null, qps[0].sfProductRatePlanId);
        system.assertEquals('Activate', qps[1].action);
        system.assertNotEquals(null, qps[1].sfProductId);
        system.assertNotEquals(null, qps[1].sfProductRatePlanId);
        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
        Test.stopTest();   
    }

    @isTest
    public static void test3_addNewPriceAmendment() {
        setUp1();
        zqu__ProductRatePlan__c prp = ZuoraTestUtil.createProductRatePlan(pcatalog.products[0]);
        insert prp;
        
        zqu__ProductRatePlanCharge__c prpc = ZuoraTestUtil.createProductRatePlanCharge(prp, 'Test Charge 4');
        insert prpc;
        
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '1234');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], prp, prpc);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, prpc);
        insert qrpc;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(1, qps.size());
        system.assertEquals('No Action', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
    }

    @isTest
    public static void test4_addNewPriceAndNewQuantityAmendment() {
        setUp2();
        zqu__ProductRatePlan__c prp = ZuoraTestUtil.createProductRatePlan(pcatalog.products[0]);
        insert prp;
        
        zqu__ProductRatePlanCharge__c prpc = ZuoraTestUtil.createProductRatePlanCharge(prp, 'Test Charge 4');
        insert prpc;
        
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '3456');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], prp, prpc);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, prpc);
        qrpc.zqu__EffectivePrice__c = 1000;
        insert qrpc;

        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        qam2.zqu__Type__c = 'UpdateProduct';
        insert qam2;

        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp2.zqu__AmendmentType__c = 'UpdateProduct';
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog.productRatePlanCharges[0]);
        qrpc2.zqu__Quantity__c = 3; //update the quantity
        qrpc2.zqu__FeeType__c = 'Per Unit';
        qrpc2.zqu__ChargeType__c = 'Recurring';
        insert qrpc2;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp2.Id, zqu__QuoteRatePlanCharge__c = qrpc2.Id);
        qcs.zqu__EffectivePrice__c = 1000;
        qcs.zqu__Quantity__c = 2; //update the quantity
        qcs.zqu__TotalPrice__c = 1000;
        qcs.zqu__Model__c = 'Per Unit Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(3, qps.size());
        system.assertEquals('Activate', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertNotEquals(null, qps[0].sfProductRatePlanId);
        system.assertEquals('Activate', qps[1].action);
        system.assertNotEquals(null, qps[1].sfProductId);
        system.assertNotEquals(null, qps[1].sfProductRatePlanId);
        system.assertEquals('No Action', qps[2].action);
        system.assertNotEquals(null, qps[2].sfProductId);
        system.assertEquals(null, qps[2].sfProductRatePlanId);
    }
    
    @isTest
    public static void test5_renewalNoChange() {
        setUp1();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '7899');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');

        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        qt.Renewal_Subscription_ID__c = (String)mock.getFirst('Subscription').getValue('Id');
        update qt;

        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1000; //update the price
        insert qrpc;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(1, qps.size());
        system.assertEquals('No Action', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
    }

    @isTest
    public static void test5B_renewalUpdate() {
        setUp1();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '1232');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');

        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        qt.Renewal_Subscription_ID__c = (String)mock.getFirst('Subscription').getValue('Id');
        update qt;

        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(1, qps.size());
        system.assertEquals('No Action', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
    }    
    
    @isTest
    public static void test5C_renewalUpdate() {
        setUp1();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '1111');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');

        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        qt.Renewal_Subscription_ID__c = (String)mock.getFirst('Subscription').getValue('Id');
        update qt;

        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1500; //update the price
        insert qrpc;

        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        qam2.zqu__Type__c = 'NewProduct';
        insert qam2;

        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[1], pcatalog.productRatePlans[1], pcatalog.productRatePlanCharges[0]);
        qrp2.zqu__AmendmentType__c = 'NewProduct';
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, pcatalog.productRatePlanCharges[1]);
        qrpc2.zqu__EffectivePrice__c = 1000;
        qrpc2.zqu__ChargeType__c = 'Recurring';
        qrpc2.zqu__Quantity__c = 1; //update the quantity
        qrpc2.zqu__FeeType__c = 'Per Unit';
        insert qrpc2;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp2.Id, zqu__QuoteRatePlanCharge__c = qrpc2.Id);
        qcs.zqu__EffectivePrice__c = 1000;
        qcs.zqu__Quantity__c = 1; //update the quantity
        qcs.zqu__TotalPrice__c = 1000;
        qcs.zqu__Model__c = 'Per Unit Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(2, qps.size());
        system.assertEquals('No Action', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);

        system.assertEquals('Activate', qps[1].action);
        system.assertNotEquals(null, qps[1].sfProductId);
        system.assertNotEquals(null, qps[1].sfProductRatePlanId);

        DIQuoteUtil.createQuoteProducts(new Set<Id>{qt.Id});
    }    

    @isTest
    public static void test6_newQuote() {
        setUp6();
        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '2222');
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
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1000; //update the price
        insert qrpc;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState();
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(1, qps.size());
        system.assertEquals('Activate', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
    }

    @isTest
    public static void test7_newQuote() {
        setUp7();
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        String subId = (String)mock.getFirst('Subscription').getValue('Id');
        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(subId));
        System.assert(subId != null);
        /*
        Account acct = new Account(Name ='Test Account');
        insert acct;
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Default');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'NewProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__AmendmentType__c = 'NewProduct';
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1000; //update the price
        insert qrpc;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState();
        zss.addQuote(qt);
        system.debug(zss.var_dump());
        ZuoraSubscriptionState.QuoteProduct[] qps = zss.getQuoteProducts();
        system.debug(JSON.serializePretty(qps));
        system.assertEquals(1, qps.size());
        system.assertEquals('Add', qps[0].action);
        system.assertNotEquals(null, qps[0].sfProductId);
        system.assertEquals(null, qps[0].sfProductRatePlanId);
        */
    }

    public static void setUp1() 
    {
        pcatalog = ZuoraTestUtil.createProductCatalog();
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id'=>pcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => pcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));


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
        zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => zuoraSubscriptionId,
            'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1000
        }));
    }

    public static void setUp2() 
    {
        pcatalog = ZuoraTestUtil.createProductCatalog();
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id'=>pcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => pcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));


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
        zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => zuoraSubscriptionId,
            'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1000, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Per Unit Pricing'
        }));
    }
    
    public static void setUp6() 
    {
        pcatalog = ZuoraTestUtil.createProductCatalog();
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id'=>pcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => pcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));


        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account'
        }));
    }

    public static void setUp7() 
    {
        pcatalog = ZuoraTestUtil.createProductCatalog();

        String zid = ZuoraTestUtil.generateGUID();
        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 4', zqu__SKU__c = 'SKU-999994', ProductCode = 'SKU-999994', IsActive = true)
        };
        insert sfProducts;
        
        zqu__ZProduct__c zp = new zqu__ZProduct__c(
            zqu__ZuoraId__c = zid, Name = 'Test ZProduct 4', zqu__SKU__c = 'SKU-999994',
            ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id
        );
        insert zp;

        pcatalog.products.add(zp);

        zqu__ProductRatePlan__c prp = ZuoraTestUtil.createProductRatePlan(zp);
        insert prp;
        pcatalog.productRatePlans.add(prp);
        
        zqu__ProductRatePlanCharge__c prpc = ZuoraTestUtil.createProductRatePlanCharge(prp, 'Test Charge 4');
        insert prpc;
        pcatalog.productRatePlanCharges.add(prpc);

        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id'=>zp.zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => pcatalog.productRatePlans[3].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => pcatalog.productRatePlanCharges[3].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));

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
        zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => zuoraSubscriptionId,
            'ProductRatePlanId' => pcatalog.productRatePlans[3].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[3].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1000, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Volume Pricing'
        }));
    }

    @isTest
    public static void test8A_removeSome() {
        ZuoraTestUtil.ProductCatalog zcatalog = new ZuoraTestUtil.ProductCatalog();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', ProductCode = 'SKU-999991', IsActive = true)
        };
        insert sfProducts;

        zcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id
            )
        };
        insert zcatalog.products;


        zcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            ZuoraTestUtil.createProductRatePlan(zcatalog.products[0])
        };
        insert zcatalog.productRatePlans;

        zqu__ProductRatePlanCharge__c testCharge = ZuoraTestUtil.createProductRatePlanCharge(zcatalog.productRatePlans[0], 'Test Charge 1');
        //testCharge.zqu__Model__c = 'Per Unit Pricing';
        
        zcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            testCharge
        };
        insert zcatalog.productRatePlanCharges;      
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id' => zcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => zcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => zcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));

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
        zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        //add 3 of the same rate plan
        for(integer i=0; i<3; i++) {
            mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
                'SubscriptionId' => zuoraSubscriptionId,
                'ProductRatePlanId' => zcatalog.productRatePlans[0].zqu__ZuoraId__c
            }));
            
            String ratePlanId = (String)mock.get('RatePlan',i).getValue('Id');
            mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
                'RatePlanId' => ratePlanId,
                'ProductRatePlanChargeId' => zcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
                'Quantity' => 1, 'Price' => 1000, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Flat Fee Pricing'
            }));
        }

        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c='3333');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'RemoveProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, zcatalog.products[0], zcatalog.productRatePlans[0], zcatalog.productRatePlanCharges[0]);
        qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.get('RatePlan',1).getValue('Id');
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, zcatalog.productRatePlanCharges[0]);
        insert qrpc;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__Model__c = 'Flat Fee Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        
        system.assertEquals(1, zss.productsByZID.size());
        system.assertEquals(3, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[0].zqu__ZuoraId__c).ratePlansById.size());
        system.assertEquals(1, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[0].zqu__ZuoraId__c).quoteRatePlansById.size());
        List<ZuoraSubscriptionState.QuoteProduct> qps = zss.getQuoteProducts();
        system.assertEquals(1, qps.size());
        system.assertEquals('No Action', qps[0].action);
    }

    @isTest
    public static void test8B_removeAll() {
        ZuoraTestUtil.ProductCatalog zcatalog = new ZuoraTestUtil.ProductCatalog();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', ProductCode = 'SKU-999991', IsActive = true)
        };
        insert sfProducts;

        zcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id
            )
        };
        insert zcatalog.products;


        zcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            ZuoraTestUtil.createProductRatePlan(zcatalog.products[0])
        };
        insert zcatalog.productRatePlans;

        zqu__ProductRatePlanCharge__c testCharge = ZuoraTestUtil.createProductRatePlanCharge(zcatalog.productRatePlans[0], 'Test Charge 1');
        //testCharge.zqu__Model__c = 'Per Unit Pricing';
        
        zcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            testCharge
        };
        insert zcatalog.productRatePlanCharges;      
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id' => zcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => zcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => zcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));

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
        zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        //add 1 of the same rate plan
        for(integer i=0; i<1; i++) {
            mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
                'SubscriptionId' => zuoraSubscriptionId,
                'ProductRatePlanId' => zcatalog.productRatePlans[0].zqu__ZuoraId__c
            }));
            
            String ratePlanId = (String)mock.get('RatePlan',i).getValue('Id');
            mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
                'RatePlanId' => ratePlanId,
                'ProductRatePlanChargeId' => zcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
                'Quantity' => 1, 'Price' => 1000, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Flat Fee Pricing'
            }));
        }

        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '4444');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'RemoveProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, zcatalog.products[0], zcatalog.productRatePlans[0], zcatalog.productRatePlanCharges[0]);
        qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.get('RatePlan',0).getValue('Id');
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, zcatalog.productRatePlanCharges[0]);
        insert qrpc;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__Model__c = 'Flat Fee Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        
        system.assertEquals(1, zss.productsByZID.size());
        system.assertEquals(1, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[0].zqu__ZuoraId__c).ratePlansById.size());
        system.assertEquals(1, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[0].zqu__ZuoraId__c).quoteRatePlansById.size());
        List<ZuoraSubscriptionState.QuoteProduct> qps = zss.getQuoteProducts();
        system.assertEquals(1, qps.size());
        system.assertEquals('Deactivate', qps[0].action);
    }

    @isTest
    public static void test8C_removeAllOfOneLeaveAnother() {
        ZuoraTestUtil.ProductCatalog zcatalog = new ZuoraTestUtil.ProductCatalog();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', ProductCode = 'SKU-999991', IsActive = true)
        };
        insert sfProducts;

        zcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id
            )
        };
        insert zcatalog.products;


        zcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            ZuoraTestUtil.createProductRatePlan(zcatalog.products[0]),
            ZuoraTestUtil.createProductRatePlan(zcatalog.products[0])
        };
        insert zcatalog.productRatePlans;

        zqu__ProductRatePlanCharge__c testCharge = ZuoraTestUtil.createProductRatePlanCharge(zcatalog.productRatePlans[0], 'Test Charge 1');
        zqu__ProductRatePlanCharge__c testCharge2 = ZuoraTestUtil.createProductRatePlanCharge(zcatalog.productRatePlans[1], 'Test Charge 2');

        //testCharge.zqu__Model__c = 'Per Unit Pricing';
        
        zcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            testCharge, testCharge2
        };
        insert zcatalog.productRatePlanCharges;      
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id' => zcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => zcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => zcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => zcatalog.productRatePlans[1].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan 2', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => zcatalog.productRatePlanCharges[1].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge 2', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));


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
        zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        //add 1 of the same rate plan
        for(integer i=0; i<1; i++) {
            mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
                'SubscriptionId' => zuoraSubscriptionId,
                'ProductRatePlanId' => zcatalog.productRatePlans[0].zqu__ZuoraId__c
            }));
            
            String ratePlanId = (String)mock.get('RatePlan',i).getValue('Id');
            mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
                'RatePlanId' => ratePlanId,
                'ProductRatePlanChargeId' => zcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
                'Quantity' => 1, 'Price' => 1000, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Flat Fee Pricing'
            }));
        }

        //add 1 of another same rate plan
        for(integer i=1; i<2; i++) {
            mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
                'SubscriptionId' => zuoraSubscriptionId,
                'ProductRatePlanId' => zcatalog.productRatePlans[1].zqu__ZuoraId__c
            }));
            
            String ratePlanId = (String)mock.get('RatePlan',i).getValue('Id');
            mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
                'RatePlanId' => ratePlanId,
                'ProductRatePlanChargeId' => zcatalog.productRatePlanCharges[1].zqu__ZuoraId__c,
                'Quantity' => 1, 'Price' => 1000, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Flat Fee Pricing'
            }));
        }

        Account acct = new Account(Name ='Test Account', Master_Customer_Number__c = '4555');
        System.runAs(getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt = [select Id, zqu__SubscriptionType__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
                    (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
                    (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c, Notes__c, Quote_Rate_Plan__c, Index__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
                    from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        qam.zqu__Type__c = 'RemoveProduct';
        insert qam;

        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, zcatalog.products[0], zcatalog.productRatePlans[0], zcatalog.productRatePlanCharges[0]);
        qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.get('RatePlan',0).getValue('Id');
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrp, zcatalog.productRatePlanCharges[0]);
        insert qrpc;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp.Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__Model__c = 'Flat Fee Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        /*
        zqu__QuoteAmendment__c qam2 = ZuoraTestUtil.createQuoteAmendment(qt);
        qam2.zqu__Type__c = 'RemoveProduct';
        insert qam2;

        zqu__QuoteRatePlan__c qrp2 = ZuoraTestUtil.createQuoteRatePlan(qt, qam2, zcatalog.products[0], zcatalog.productRatePlans[1], zcatalog.productRatePlanCharges[1]);
        qrp2.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.get('RatePlan',1).getValue('Id');
        insert qrp2;

        zqu__QuoteRatePlanCharge__c qrpc2 = ZuoraTestUtil.createQuoteRatePlanCharge(qrp2, zcatalog.productRatePlanCharges[1]);
        insert qrpc2;

        zqu__QuoteChargeSummary__c qcs2 = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrp2.Id, zqu__QuoteRatePlanCharge__c = qrpc2.Id);
        qcs2.zqu__Model__c = 'Flat Fee Pricing';
        qcs2.zqu__Type__c = 'Recurring';
        insert qcs2;
        */

        ZuoraSubscriptionState zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(zuoraSubscriptionId));
        zss.addQuote(qt);
        
        system.assertEquals(1, zss.productsByZID.size());
        system.assertEquals(1, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[0].zqu__ZuoraId__c).ratePlansById.size());
        system.assertEquals(1, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[1].zqu__ZuoraId__c).ratePlansById.size());

        system.assertEquals(1, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[0].zqu__ZuoraId__c).quoteRatePlansById.size());
        system.assertEquals(0, zss.productsByZID.get(zcatalog.products[0].zqu__ZuoraId__c).productRatePlansByZID.get(zcatalog.productRatePlans[1].zqu__ZuoraId__c).quoteRatePlansById.size());

        List<ZuoraSubscriptionState.QuoteProduct> qps = zss.getQuoteProducts();
        system.assertEquals(1, qps.size());
        system.assertEquals('No Action', qps[0].action);
        ZuoraSubscriptionState.codecoverage();
    }
    
    

}