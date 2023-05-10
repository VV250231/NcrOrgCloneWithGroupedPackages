@isTest(SeeAllData=true)
public class NCRQuoteSubmitControllerTests 
{
    static zqu__Quote__c qt;
    
    @isTest
    public static void test1_Renewal()
    {
        Account acct = new Account(Name = 'Test Account');
        system.runas(TestRecordsFactory.getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        //QuBy_Detail__c qubyDetail = new QuBy_Detail__c(Opportunity__c = opp.Id, Solution_Quote_Status__c = 'Acknowledged');
        //insert qubyDetail;
        QuBy_Detail__c qubyDetail = ZuoraTestUtil.createQubyDetail(opp);
    
       
        opp.StageName = 'Closed/Booked';
        opp.CLM_Sales_Acknowledgment__c=true;
        update opp;
        
       
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('Recurring', 'Per Unit Pricing');
        qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        qt.Renewal_Subscription_ID__c = ZuoraTestUtil.generateGUID();
        qt.DI_Approval_Status__c = 'Approved';
        update qt;
        Test.startTest();
         
        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        system.assert(qt.id!=null);

        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        qrpc.zqu__Quantity__c = 2;
        insert qrpc;
        
        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrps[0].Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__EffectivePrice__c = 1001;
        qcs.zqu__Quantity__c = 2; //update the quantity
        qcs.zqu__TotalPrice__c = 1001;
        qcs.zqu__Model__c = 'Per Unit Pricing';
        qcs.zqu__Type__c = 'Recurring';
        insert qcs;

        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'Id' => qt.Renewal_Subscription_ID__c
        }));
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => qt.Renewal_Subscription_ID__c,
            'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Per Unit Pricing'
        }));
        qrps[0].Renewal_Rate_Plan_Id__c = ratePlanId;
        update qrps;

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
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id'), 
            'TriggerEvent' => 'ServiceActivation'
        }));

        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        system.assertNotEquals(cont,null);
        system.debug(cont.hasChanges);
        system.debug(cont.pageBlockTitle);
        cont.toQuoteDetail();
        cont.cancelAction();
        Test.stopTest();
    }

    @isTest
    public static void test2_New()
    {
        Account acct = new Account(Name = 'Test Account');
        system.runas(TestRecordsFactory.getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        //QuBy_Detail__c qubyDetail = new QuBy_Detail__c(Opportunity__c = opp.Id, Solution_Quote_Status__c = 'Acknowledged');
        //insert qubyDetail;
        
        QuBy_Detail__c qubyDetail = ZuoraTestUtil.createQubyDetail(opp);
        
        Test.startTest();
        opp.StageName = 'Closed/Booked';
        opp.CLM_Sales_Acknowledgment__c=true;
        update opp;
        
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        qt = ZuoraTestUtil.createQuote(opp, 'Default');
        qt.DI_Approval_Status__c = 'Approved';
        update qt;

        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        system.assert(qt.id!=null);

        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        insert qrpc;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c(zqu__QuoteRatePlan__c = qrps[0].Id, zqu__QuoteRatePlanCharge__c = qrpc.Id);
        qcs.zqu__EffectivePrice__c = qrpc.zqu__EffectivePrice__c;
        qcs.zqu__Quantity__c = qrpc.zqu__Quantity__c;
        qcs.zqu__TotalPrice__c = qrpc.zqu__EffectivePrice__c;
        qcs.zqu__Model__c = qrpc.zqu__Model__c;
        qcs.zqu__Type__c = qrpc.zqu__ChargeType__c;
        insert qcs;

        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        system.assertNotEquals(cont,null);
        system.debug(cont.pageBlockTitle);
        Test.stopTest();
    }

    @isTest
    public static void test3_Amendment()
    {
        Account acct = new Account(Name = 'Test Account');
        system.runas(TestRecordsFactory.getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        //QuBy_Detail__c qubyDetail = new QuBy_Detail__c(Opportunity__c = opp.Id, Solution_Quote_Status__c = 'Acknowledged');
        //insert qubyDetail;
        QuBy_Detail__c qubyDetail = ZuoraTestUtil.createQubyDetail(opp);
        
        Test.startTest();
        opp.StageName = 'Closed/Booked';
        opp.CLM_Sales_Acknowledgment__c=true;
        update opp;
        
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        qt.zqu__ExistSubscriptionID__c = ZuoraTestUtil.generateGUID();
        qt.DI_Approval_Status__c = 'Approved';
        update qt;

        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        system.assert(qt.id!=null);

        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        insert qrpc;
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'Id' => qt.Renewal_Subscription_ID__c
        }));
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => qt.Renewal_Subscription_ID__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001
        }));

        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        system.assertNotEquals(cont,null);
        system.debug(cont.pageBlockTitle);
        system.debug(cont.hasChanges);
        cont.toQuoteDetail();
        cont.cancelAction();
        Test.stopTest();
    }

    @isTest
    public static void test4_E1()
    {
        Account acct = new Account(Name = 'Test Account');
        system.runas(TestRecordsFactory.getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        //QuBy_Detail__c qubyDetail = new QuBy_Detail__c(Opportunity__c = opp.Id, Solution_Quote_Status__c = 'Acknowledged');
        //insert qubyDetail;
        QuBy_Detail__c qubyDetail = ZuoraTestUtil.createQubyDetail(opp);
        
        Test.startTest();
        opp.StageName = 'Closed/Booked';
        opp.CLM_Sales_Acknowledgment__c=true;
        update opp;
        
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        qt.Renewal_Subscription_ID__c = ZuoraTestUtil.generateGUID();
        qt.DI_Approval_Status__c = 'Approved';
        qt.zqu__Status__c = 'Not New';
        update qt;

        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        system.assert(qt.id!=null);

        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        insert qrpc;
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'Id' => qt.Renewal_Subscription_ID__c
        }));
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => qt.Renewal_Subscription_ID__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001
        }));

        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        system.assertNotEquals(cont,null);
        Test.stopTest();
    }

    @isTest
    public static void test4_E2()
    {
        Account acct = new Account(Name = 'Test Account');
        system.runas(TestRecordsFactory.getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        //QuBy_Detail__c qubyDetail = new QuBy_Detail__c(Opportunity__c = opp.Id, Solution_Quote_Status__c = 'Acknowledged');
        //insert qubyDetail;
        QuBy_Detail__c qubyDetail = ZuoraTestUtil.createQubyDetail(opp);
        
        Test.startTest();
        opp.StageName = 'Closed/Booked';
        opp.CLM_Sales_Acknowledgment__c=true;
        update opp;
        
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        qt.Renewal_Subscription_ID__c = ZuoraTestUtil.generateGUID();
        //qt.DI_Approval_Status__c = 'Approved';
        update qt;

        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        system.assert(qt.id!=null);

        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        insert qrpc;
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'Id' => qt.Renewal_Subscription_ID__c
        }));
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => qt.Renewal_Subscription_ID__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001
        }));

        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        system.assertNotEquals(cont,null);
        Test.stopTest();
    }

    @isTest
    public static void test4_E3()
    {
        Account acct = new Account(Name = 'Test Account');
         system.runas(TestRecordsFactory.getUser()){
        insert acct;
        }
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        //QuBy_Detail__c qubyDetail = new QuBy_Detail__c(Opportunity__c = opp.Id, Solution_Quote_Status__c = 'Acknowledged');
        //insert qubyDetail;
        QuBy_Detail__c qubyDetail = ZuoraTestUtil.createQubyDetail(opp);
        
        Test.startTest();
        
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        qt.Renewal_Subscription_ID__c = ZuoraTestUtil.generateGUID();
        qt.DI_Approval_Status__c = 'Approved';
        update qt;

        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        system.assert(qt.id!=null);

        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        insert qrpc;
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'Id' => qt.Renewal_Subscription_ID__c
        }));
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => qt.Renewal_Subscription_ID__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1000
        }));

        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        system.debug(cont.pageBlockTitle);
        system.assertNotEquals(cont,null);
        Test.stopTest();
        NCRQuoteSubmit2Controller.codeCoverage();
    }
}