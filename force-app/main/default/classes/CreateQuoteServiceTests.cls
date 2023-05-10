// ===========================================================================
// Object: CreateQuoteServiceTests
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for the CreateQuoteService REST service
// ===========================================================================
// Changes: 2017-04-05 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class CreateQuoteServiceTests 
{
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    } 
    private static void setUp() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.httpMethod = 'POST';
        RestContext.request.headers.put('Logging', 'document');

        Solution_Provider__c sp = new Solution_Provider__c(Name = 'Test SP', Solution_Provider_Number__c = '00001');
        insert sp;

        Solution_Provider_Product__c[] spProducts = new Solution_Provider_Product__c[]{
            new Solution_Provider_Product__c(Solution_Provider_Id__c = sp.Id, Name = 'Test SPP',
                Solution_Provider_Product_Category__c = 'IB Vendor',
                Interface_Type__c = 'Integrated', Internal_Status__c = 'Available')
        };
        insert spProducts;

    }
    
    @isTest static void test10_e1() {
        setUp();
        RestContext.request.headers.put('Logging', 'none');
        CreateQuoteService.createQuote();
        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest static void test10_e2() {
        setUp();
        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();

        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        CreateQuoteService.createQuote();
        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest static void test10_e3() {
        setUp();
        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = 'abc123';
        jsonBody.quoteInformation.masterCustomerNumber = 'DI9999';
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'Default';
        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        CreateQuoteService.createQuote();
        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest static void test10_e4() {
        setUp();
        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);

        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.billingAccountid = ZuoraTestUtil.generateGUID();
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'BadQuoteType';
        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        CreateQuoteService.createQuote();
        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest static void test10_e5() {
        setUp();
        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);

        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.masterCustomerNumber = 'DI9999';
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'Default';
        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        CreateQuoteService.createQuote();
        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest static void test1_newSubscriptionQuote() {
        setUp();

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('SKU-99991','Recurring', 'Per Unit Pricing');
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');
        
        ZuoraTestUtil.ProductCatalog pcatalog2 = ZuoraTestUtil.createOneProductCatalog('SKU-99992', 'Recurring', 'Volume Pricing');

        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        String bilingAccountId = ZuoraTestUtil.generateGUID();
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(
            Zuora__Account__c = acct.Id, BillToFlag__c = 'Yes',
            Zuora__External_Id__c = bilingAccountId, Zuora__Zuora_Id__c = bilingAccountId,
            MasterCustomerNumber__c = 'DI9999'
        );
        insert billingAccount;

        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.masterCustomerNumber = 'DI9999';
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'Default';
        jsonBody.quoteInformation.ownerFirstName = UserInfo.getFirstName();
        jsonBody.quoteInformation.ownerLastName = UserInfo.getLastName();
        
        jsonBody.ratePlans = new CreateQuoteModel.RatePlan[]{};
        CreateQuoteModel.RatePlan rp1 = new CreateQuoteModel.RatePlan();
        rp1.name = pcatalog.productRatePlans[0].Name;
        rp1.productRatePlanId = pcatalog.productRatePlans[0].zqu__ZuoraId__c;
        rp1.tpv = 'Test SPP';
        jsonBody.ratePlans.add(rp1);
        
        CreateQuoteModel.RatePlan rp2 = new CreateQuoteModel.RatePlan();
        rp2.name = pcatalog2.productRatePlans[0].Name;
        rp2.productRatePlanId = pcatalog2.productRatePlans[0].zqu__ZuoraId__c;
        rp2.tiers = new CreateQuoteModel.RatePlanTier[]{};
        CreateQuoteModel.RatePlanTier t1 = new CreateQuoteModel.RatePlanTier();           
        t1.tier = 1;
        t1.startingUnit = 0;
        t1.endingUnit = 99;
        t1.price = 100;
        rp2.tiers.add(t1);
        CreateQuoteModel.RatePlanTier t2 = new CreateQuoteModel.RatePlanTier();           
        t2.tier = 2;
        t2.startingUnit = 100;
        t2.endingUnit = null;
        t2.price = 90;
        rp2.tiers.add(t2);
        jsonBody.ratePlans.add(rp2);

        String jsonString = JSON.serializePretty(jsonBody);
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        //system.assertEquals(200, RestContext.response.statusCode, RestContext.response.responseBody.toString());
        
        CreateQuoteModel.OutgoingJSONBodyWrapper responseJSON = (CreateQuoteModel.OutgoingJSONBodyWrapper)JSON.deserialize(RestContext.response.responseBody.toString(), CreateQuoteModel.OutgoingJSONBodyWrapper.class);
        system.assertNotEquals(null, responseJSON.quoteId);
        
        Test.startTest();
        update new zqu__Quote__c(Id = responseJSON.quoteId, RecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('ReadOnly').getRecordTypeId());
        CreateQuoteServiceUtil.exportQuote(responseJSON.quoteId);
        Test.stopTest();
    }   

    @isTest static void test2_amendmentQuote_withUpdate() {
        setUp();

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('SKU-999991', 'Recurring', 'Per Unit Pricing');
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');
        ZuoraTestUtil.ProductCatalog pcatalogNew = ZuoraTestUtil.createOneProductCatalog('SKU-999992', 'One-Time', 'Flat Fee Pricing');
        
        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account', 'CrmId' => acct.Id
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
            'Quantity' => 1, 'Price' => 1000
        }));


        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.billingAccountId = ZuoraTestUtil.generateGUID();
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'Amendment';
        jsonBody.quoteInformation.subscriptionId = zuoraSubscriptionId;
        
        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));
        
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(200, RestContext.response.statusCode);
        
        CreateQuoteModel.OutgoingJSONBodyWrapper out = (CreateQuoteModel.OutgoingJSONBodyWrapper)JSON.deserialize(RestContext.response.responseBody.toString(), CreateQuoteModel.OutgoingJSONBodyWrapper.class);
        system.assertNotEquals(null, out.quoteId);
        jsonBody.quoteInformation.id = out.quoteId;

        jsonBody.ratePlans = new CreateQuoteModel.RatePlan[]{};

        //UPDATED rate plan
        CreateQuoteModel.RatePlan rp1 = new CreateQuoteModel.RatePlan();
        rp1.name = pcatalog.productRatePlans[0].Name;
        rp1.productRatePlanId = pcatalog.productRatePlans[0].zqu__ZuoraId__c;
        rp1.subscriptionRatePlanId = ratePlanId;
        rp1.tpv = 'Test SPP';
        jsonBody.ratePlans.add(rp1);

        //NEW rate plan
        CreateQuoteModel.RatePlan rp2 = new CreateQuoteModel.RatePlan();
        rp2.name = pcatalogNew.productRatePlans[0].Name;
        rp2.productRatePlanId = pcatalogNew.productRatePlans[0].zqu__ZuoraId__c;
        jsonBody.ratePlans.add(rp2);

        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        Test.startTest();
        CreateQuoteServiceUtil.AllowMultipleQuotes = true;
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(200, RestContext.response.statusCode, RestContext.response.responseBody.toString());
        Test.stopTest();
    }   

    @isTest static void test2_amendmentQuote_withRemove() {
        setUp();

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('SKU-999991', 'Recurring', 'Per Unit Pricing');
        ZuoraTestUtil.ProductCatalog pcatalogNew = ZuoraTestUtil.createOneProductCatalog('SKU-999992', 'One-Time', 'Flat Fee Pricing');
        
        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account', 'CrmId' => acct.Id
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
            'Quantity' => 1, 'Price' => 1000
        }));


        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.billingAccountId = ZuoraTestUtil.generateGUID();
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'Amendment';
        jsonBody.quoteInformation.subscriptionId = zuoraSubscriptionId;
        
        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));
        
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(200, RestContext.response.statusCode);
        
        CreateQuoteModel.OutgoingJSONBodyWrapper out = (CreateQuoteModel.OutgoingJSONBodyWrapper)JSON.deserialize(RestContext.response.responseBody.toString(), CreateQuoteModel.OutgoingJSONBodyWrapper.class);
        system.assertNotEquals(null, out.quoteId);
        jsonBody.quoteInformation.id = out.quoteId;

        jsonBody.ratePlans = new CreateQuoteModel.RatePlan[]{};

        //REMOVED rate plan
        CreateQuoteModel.RatePlan rp1 = new CreateQuoteModel.RatePlan();
        rp1.name = pcatalog.productRatePlans[0].Name;
        rp1.productRatePlanId = pcatalog.productRatePlans[0].zqu__ZuoraId__c;
        rp1.subscriptionRatePlanId = ratePlanId;
        rp1.action = 'remove';
        jsonBody.ratePlans.add(rp1);

        //NEW rate plan
        CreateQuoteModel.RatePlan rp2 = new CreateQuoteModel.RatePlan();
        rp2.name = pcatalogNew.productRatePlans[0].Name;
        rp2.productRatePlanId = pcatalogNew.productRatePlans[0].zqu__ZuoraId__c;
        jsonBody.ratePlans.add(rp2);

        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        Test.startTest();
        CreateQuoteServiceUtil.AllowMultipleQuotes = true;
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(200, RestContext.response.statusCode, RestContext.response.responseBody.toString());
        Test.stopTest();
    }       

    @isTest static void test2_renewalQuote_withUpdate() {
        setUp();

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('SKU-999991', 'Recurring', 'Per Unit Pricing');
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');
        ZuoraTestUtil.ProductCatalog pcatalogNew = ZuoraTestUtil.createOneProductCatalog('SKU-999992', 'One-Time', 'Flat Fee Pricing');
        
        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
            'Name' => 'Test Account', 'CrmId' => acct.Id
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
            'Quantity' => 1, 'Price' => 1000
        }));


        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.billingAccountId = ZuoraTestUtil.generateGUID();
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'New Renewal';
        jsonBody.quoteInformation.subscriptionId = zuoraSubscriptionId;
        
        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));
        
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(200, RestContext.response.statusCode);
        
        CreateQuoteModel.OutgoingJSONBodyWrapper out = (CreateQuoteModel.OutgoingJSONBodyWrapper)JSON.deserialize(RestContext.response.responseBody.toString(), CreateQuoteModel.OutgoingJSONBodyWrapper.class);
        system.assertNotEquals(null, out.quoteId);
        jsonBody.quoteInformation.id = out.quoteId;

        jsonBody.ratePlans = new CreateQuoteModel.RatePlan[]{};

        //UPDATED rate plan
        CreateQuoteModel.RatePlan rp1 = new CreateQuoteModel.RatePlan();
        rp1.name = pcatalog.productRatePlans[0].Name;
        rp1.productRatePlanId = pcatalog.productRatePlans[0].zqu__ZuoraId__c;
        rp1.subscriptionRatePlanId = ratePlanId;
        rp1.tpv = 'Test SPP';
        jsonBody.ratePlans.add(rp1);

        //NEW rate plan
        CreateQuoteModel.RatePlan rp2 = new CreateQuoteModel.RatePlan();
        rp2.name = pcatalogNew.productRatePlans[0].Name;
        rp2.productRatePlanId = pcatalogNew.productRatePlans[0].zqu__ZuoraId__c;
        jsonBody.ratePlans.add(rp2);

        RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(jsonBody));

        Test.startTest();
        CreateQuoteServiceUtil.AllowMultipleQuotes = true;
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
       // system.assertEquals(200, RestContext.response.statusCode, RestContext.response.responseBody.toString());
        Test.stopTest();
    }   
    
    @isTest static void test3_newSubscriptionQuote_multipleError() {
        setUp();

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createOneProductCatalog('SKU-99991','Recurring', 'Per Unit Pricing');
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');
        
        ZuoraTestUtil.ProductCatalog pcatalog2 = ZuoraTestUtil.createOneProductCatalog('SKU-99992', 'Recurring', 'Volume Pricing');

        Account acct = new Account(Name = 'Test Account');
        System.runAs(getUser()){
            insert acct;
        }
        
        String bilingAccountId = ZuoraTestUtil.generateGUID();
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(
            Zuora__Account__c = acct.Id, BillToFlag__c = 'Yes',
            Zuora__External_Id__c = bilingAccountId, Zuora__Zuora_Id__c = bilingAccountId,
            MasterCustomerNumber__c = 'DI9999'
        );
        insert billingAccount;

        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        CreateQuoteModel.IncomingJSONBodyWrapper jsonBody = new CreateQuoteModel.IncomingJSONBodyWrapper();
        jsonBody.quoteInformation = new CreateQuoteModel.QuoteInformation();
        jsonBody.quoteInformation.opportunityId = opp.Id;
        jsonBody.quoteInformation.masterCustomerNumber = 'DI9999';
        jsonBody.quoteInformation.startDate = Date.today().addDays(1);
        jsonBody.quoteInformation.quoteType = 'Default';
        jsonBody.quoteInformation.ownerFirstName = UserInfo.getFirstName();
        jsonBody.quoteInformation.ownerLastName = UserInfo.getLastName();
        
        jsonBody.ratePlans = new CreateQuoteModel.RatePlan[]{};
        CreateQuoteModel.RatePlan rp1 = new CreateQuoteModel.RatePlan();
        rp1.name = pcatalog.productRatePlans[0].Name;
        rp1.productRatePlanId = pcatalog.productRatePlans[0].zqu__ZuoraId__c;
        rp1.tpv = 'Test SPP';
        jsonBody.ratePlans.add(rp1);
        
        CreateQuoteModel.RatePlan rp2 = new CreateQuoteModel.RatePlan();
        rp2.name = pcatalog2.productRatePlans[0].Name;
        rp2.productRatePlanId = pcatalog2.productRatePlans[0].zqu__ZuoraId__c;
        rp2.tiers = new CreateQuoteModel.RatePlanTier[]{};
        CreateQuoteModel.RatePlanTier t1 = new CreateQuoteModel.RatePlanTier();           
        t1.tier = 1;
        t1.startingUnit = 0;
        t1.endingUnit = 99;
        t1.price = 100;
        rp2.tiers.add(t1);
        CreateQuoteModel.RatePlanTier t2 = new CreateQuoteModel.RatePlanTier();           
        t2.tier = 2;
        t2.startingUnit = 100;
        t2.endingUnit = null;
        t2.price = 90;
        rp2.tiers.add(t2);
        jsonBody.ratePlans.add(rp2);

        String jsonString = JSON.serializePretty(jsonBody);
        RestContext.request.requestBody = Blob.valueOf(jsonString);
        
        CreateQuoteService.createQuote();

        system.debug(RestContext.response.statusCode);
        system.debug(RestContext.response.responseBody.toString());
        //system.assertEquals(200, RestContext.response.statusCode, RestContext.response.responseBody.toString());
        Test.startTest();
        CreateQuoteService.createQuote();
        system.assertEquals(500, RestContext.response.statusCode, RestContext.response.responseBody.toString());
        Test.stopTest();
    }   


}