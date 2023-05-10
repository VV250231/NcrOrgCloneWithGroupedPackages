@isTest
public with sharing class OrderProductTriggerHandlerTest {
    static String   STATUS_DRAFT = 'Draft',
                    SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER',
                    USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage',
                    USAGE_STATUS_NOT_EXPECTING_USAGE = 'Not Expecting Usage	';

    static Integer  setupYear = 2020,
                    setupMonth = 1,
                    setupDay = 1;
            
    static Date     START_DATE = Date.today(),
                    END_DATE = START_DATE.addDays(25),
                    CONTRACT_START_DATE = Date.newInstance( setupYear, setupMonth, setupDay);
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;




    @TestSetup
    static void setupData(){
        Account thisAccount = new Account(name = 'ContractTestAccount',
                LOB__c = 'FINANCIAL',
                //  MDM_Data_Source_Code__c='CDM',
                Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abc@test.com');
        System.runAs(TestRecordsFactory.getUser()){
        insert thisAccount;
        }

        Opportunity thisOpportunity = new Opportunity();
        thisOpportunity.name = 'abc';
        thisOpportunity.AccountID = thisAccount.id;
        thisOpportunity.Name = 'OppQuote Linkage Test Opportunity';
        thisOpportunity.type = 'Indirect Channel';
        thisOpportunity.CURRENCYISOCODE = 'USD';
        //thisOpportunity.SALES_ORG__C = s.id;
        thisOpportunity.INVOICE_TRIGGER__C = 'Shipment';
        //thisOpportunity.PRIMARY_COMPETITOR__C = c.id;
        thisOpportunity.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        thisOpportunity.closeDate = System.TODAY();
        thisOpportunity.stagename = 'Prospecting';
        // thisOpportunity.recordTypeId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get();
        thisOpportunity.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        thisOpportunity.EndCustomerUnknown__c = true; 
        thisOpportunity.Skip_Validation_Rule_for_Lead_Conversion__c = true;
        thisOpportunity.ForecastCategoryName ='Omitted';
        insert thisOpportunity;

        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
        SBQQ__Account__c = thisAccount.Id,
        SBQQ__Opportunity2__c = thisOpportunity.Id,
        SBQQ__Primary__c=true);
        insert thisQuote;

        blng__BillingRule__c billingRule = new blng__BillingRule__c(
        Name = 'Test Billing Rule',
        blng__Active__c = true,
        blng__GenerateInvoices__c = 'No',
        blng__InitialBillingTrigger__c = 'Order Product Activation Date',
        blng__PartialPeriodTreatment__c = 'Separate'
        );
        insert billingRule;

        blng__TaxRule__c taxrule = new blng__TaxRule__c(
        Name = 'Test Rule',
        blng__TaxableYesNo__c = 'Yes',
        blng__Active__c = TRUE);
        insert taxrule;

        blng__RevenueRecognitionRule__c revenueRecognizationRule = new blng__RevenueRecognitionRule__c(
        Name = 'Test Schedule',
        blng__CreateRevenueSchedule__c = 'Yes',
        blng__Active__c = true
        );
        insert revenueRecognizationRule;

        List<Product2> lstProducts = new List<Product2> ();
        lstProducts.add(new product2(   name='A', 
                                family='Hardware',
                                blng__BillingRule__c = billingRule.Id, 
                                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                blng__TaxRule__c = taxrule.ID,
                                ProductCode = 'H400-0001-0000', 
                                product_type__c = 'Topline'));
        lstProducts.add(new product2(   name='B', 
                                family='Hardware',
                                blng__BillingRule__c = billingRule.Id, 
                                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                blng__TaxRule__c = taxrule.ID,
                                ProductCode = 'H400-0001-0000',
                                product_type__c = 'Topline' ));
        lstProducts.add(new product2(   name='C', 
                                family='Hardware',
                                blng__BillingRule__c = billingRule.Id, 
                                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                blng__TaxRule__c = taxrule.ID,
                                ProductCode = 'H400-0001-0000', 
                                product_type__c = 'Topline'));
        lstProducts.add(new product2(   name='D', 
                                family='Hardware',
                                blng__BillingRule__c = billingRule.Id, 
                                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                blng__TaxRule__c = taxrule.ID,
                                ProductCode = 'H400-0001-0000'));
        insert lstProducts;

        Id stdPbId = Test.getStandardPricebookId();        

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = lstProducts[0].id, UnitPrice = 100, IsActive = true);
        insert standardPrice;

        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            //qtc_MRR__c = 0,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__PricebookEntryId__c = standardPrice.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = lstProducts[0].Id

        );
        insert testQuoteLine;
    }

    @IsTest
    static void afterInsert_MissingUsage_NegativeFalseTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = false,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        Test.startTest();
            OrderItem thisOrderProduct = new OrderItem(     
                qtc_Missing_Usage__c = false,
                SBQQ__Subscription__c = thisSubscription.Id,
                PriceBookEntryId = standardPrice.Id, 
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                OrderId = thisOrder.Id, 
                SBQQ__QuoteLine__c = testQuoteLine.Id,
                Quantity = 1, 
                SBQQ__OrderedQuantity__c = 1, 
                UnitPrice = standardPrice.UnitPrice, 
                SBQQ__ChargeType__c = 'One-Time',
                ServiceDate = Date.Today()
            );
            SBQQ.TriggerControl.disable();
            insert thisOrderProduct;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

    }

    @IsTest
    static void afterInsert_MissingUsage_NegativeTrueTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = true,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = true,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        Test.startTest();
            OrderItem thisOrderProduct = new OrderItem(     
                qtc_Missing_Usage__c = true,
                SBQQ__Subscription__c = thisSubscription.Id,
                PriceBookEntryId = standardPrice.Id, 
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                OrderId = thisOrder.Id, 
                SBQQ__QuoteLine__c = testQuoteLine.Id,
                Quantity = 1, 
                SBQQ__OrderedQuantity__c = 1, 
                UnitPrice = standardPrice.UnitPrice, 
                SBQQ__ChargeType__c = 'One-Time',
                ServiceDate = Date.Today()
            );
            SBQQ.TriggerControl.disable();
            insert thisOrderProduct;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

    }

    @IsTest
    static void afterInsert_MissingUsage_PositiveSetToTrueTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = false,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = false,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        Test.startTest();
            OrderItem thisOrderProduct = new OrderItem(     
                qtc_Missing_Usage__c = true,
                SBQQ__Subscription__c = thisSubscription.Id,
                PriceBookEntryId = standardPrice.Id, 
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                OrderId = thisOrder.Id, 
                SBQQ__QuoteLine__c = testQuoteLine.Id,
                Quantity = 1, 
                SBQQ__OrderedQuantity__c = 1, 
                UnitPrice = standardPrice.UnitPrice, 
                SBQQ__ChargeType__c = 'One-Time',
                ServiceDate = Date.Today()
            );
            SBQQ.TriggerControl.disable();
            insert thisOrderProduct;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

    }


    @IsTest
    static void afterInsert_MissingUsage_PositiveSetToFalseTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = true,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = true,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        Test.startTest();
            OrderItem thisOrderProduct = new OrderItem(     
                qtc_Missing_Usage__c = false,
                SBQQ__Subscription__c = thisSubscription.Id,
                PriceBookEntryId = standardPrice.Id, 
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                OrderId = thisOrder.Id, 
                SBQQ__QuoteLine__c = testQuoteLine.Id,
                Quantity = 1, 
                SBQQ__OrderedQuantity__c = 1, 
                UnitPrice = standardPrice.UnitPrice, 
                SBQQ__ChargeType__c = 'One-Time',
                ServiceDate = Date.Today()
            );
            SBQQ.TriggerControl.disable();
            insert thisOrderProduct;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

    }

    @IsTest
    static void afterUpdate_MissingUsage_NegativeFalseTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = false,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = false,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        OrderItem thisOrderProduct = new OrderItem(     
            qtc_Missing_Usage__c = false,
            SBQQ__Subscription__c = thisSubscription.Id,
            PriceBookEntryId = standardPrice.Id, 
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            OrderId = thisOrder.Id, 
            SBQQ__QuoteLine__c = testQuoteLine.Id,
            Quantity = 1, 
            SBQQ__OrderedQuantity__c = 1, 
            UnitPrice = standardPrice.UnitPrice, 
            SBQQ__ChargeType__c = 'One-Time',
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');
        
        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        Test.startTest();
        thisOrderProduct.qtc_Missing_Usage__c= false;
        thisOrderProduct.Quantity = 2;
        SBQQ.TriggerControl.disable();
        update thisOrderProduct;
        SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

    }

    @IsTest
    static void afterUpdate_MissingUsage_NegativeTrueTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = true,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = true,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

      
        OrderItem thisOrderProduct = new OrderItem(     
            qtc_Missing_Usage__c = true,
            SBQQ__Subscription__c = thisSubscription.Id,
            PriceBookEntryId = standardPrice.Id, 
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            OrderId = thisOrder.Id, 
            SBQQ__QuoteLine__c = testQuoteLine.Id,
            Quantity = 1, 
            SBQQ__OrderedQuantity__c = 1, 
            UnitPrice = standardPrice.UnitPrice, 
            SBQQ__ChargeType__c = 'One-Time',
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        Test.startTest();
        thisOrderProduct.qtc_Missing_Usage__c= true;
        thisOrderProduct.Quantity = 2;
        SBQQ.TriggerControl.disable();
        update thisOrderProduct;
        SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

    }

    @IsTest
    static void afterUpdate_MissingUsage_PositiveSetToTrueTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = false,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = false,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        OrderItem thisOrderProduct = new OrderItem(     
            qtc_Missing_Usage__c = false,
            SBQQ__Subscription__c = thisSubscription.Id,
            PriceBookEntryId = standardPrice.Id, 
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            OrderId = thisOrder.Id, 
            SBQQ__QuoteLine__c = testQuoteLine.Id,
            Quantity = 1, 
            SBQQ__OrderedQuantity__c = 1, 
            UnitPrice = standardPrice.UnitPrice, 
            SBQQ__ChargeType__c = 'One-Time',
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();
        
        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');
        
        Test.startTest();
            thisOrderProduct.qtc_Missing_Usage__c= true;
            thisOrderProduct.Quantity = 2;
            SBQQ.TriggerControl.disable();
            update thisOrderProduct;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

    }

    @IsTest
    static void afterUpdate_MissingUsage_PositiveSetToFalseest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = true,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = true,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        OrderItem thisOrderProduct = new OrderItem(     
            qtc_Missing_Usage__c = true,
            SBQQ__Subscription__c = thisSubscription.Id,
            PriceBookEntryId = standardPrice.Id, 
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            OrderId = thisOrder.Id, 
            SBQQ__QuoteLine__c = testQuoteLine.Id,
            Quantity = 1, 
            SBQQ__OrderedQuantity__c = 1, 
            UnitPrice = standardPrice.UnitPrice, 
            SBQQ__ChargeType__c = 'One-Time',
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();
        
        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        
        Test.startTest();
            thisOrderProduct.qtc_Missing_Usage__c= false;
            thisOrderProduct.Quantity = 2;
            SBQQ.TriggerControl.disable();
            update thisOrderProduct;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

    }

    @IsTest
    static void afterUpdate_Bulk_MissingUsage_PositiveSetToFalseest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        List<Contract> listContract = new List<Contract>();
        for(Integer i=0; i<BULK_COUNT; i++){
            Contract testContract = new Contract(
                StartDate = CONTRACT_START_DATE,
                qtc_Missing_Usage__c = true,
                AccountId=thisAccount.Id);
            listContract.add(testContract);
        }
        insert listContract;

        List<SBQQ__Subscription__c> listSubscription = new List<SBQQ__Subscription__c>();
        for(Contract thisContract : listContract ){
            SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
                SBQQ__Contract__c = thisContract.Id, 
                SBQQ__Product__c = thisProduct.Id, 
                SBQQ__Quantity__c = 5, 
                SBQQ__Account__c = thisAccount.Id,
                SBQQ__NetPrice__c = 25,
                SBQQ__SubscriptionEndDate__c = END_DATE);
            listSubscription.add( thisSubscription );
        }
        insert listSubscription;

        List<Order> listOrder = new List<Order>();
        for(Integer i=0; i<BULK_COUNT; i++){
            Order thisOrder = new order(    
                qtc_Missing_Usage__c = true,
                Pricebook2Id = standardPrice.Pricebook2Id, 
                AccountId = thisAccount.id, 
                Status = STATUS_DRAFT, 
                EffectiveDate = Date.Today(), 
                blng__BillingDayOfMonth__c = '28',
                qtc_Bill_To_Site__c = thisAccount.Id,
                Deliver_To_Site__c = thisAccount.Id,
                SBQQ__Quote__c=thisQuote.Id);
            listOrder.add( thisOrder );
        }
        insert listOrder;

        List<OrderItem> listOrderItems = new List<OrderItem>();
        for(Integer i=0; i<BULK_COUNT; i++){
            OrderItem thisOrderProduct = new OrderItem(     
                qtc_Missing_Usage__c = true,
                SBQQ__Subscription__c = listSubscription[i].Id,
                PriceBookEntryId = standardPrice.Id, 
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                OrderId = listOrder[i].Id, 
                SBQQ__QuoteLine__c = testQuoteLine.Id,
                Quantity = 1, 
                SBQQ__OrderedQuantity__c = 1, 
                UnitPrice = standardPrice.UnitPrice, 
                SBQQ__ChargeType__c = 'One-Time',
                ServiceDate = Date.Today()
            );
            listOrderItems.add( thisOrderProduct);
        }
        SBQQ.TriggerControl.disable();
        insert listOrderItems;
        SBQQ.TriggerControl.enable();
        
        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(BULK_COUNT, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(BULK_COUNT, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        
        Test.startTest();
            for(OrderItem thisOrderProduct : listOrderItems ){
                thisOrderProduct.qtc_Missing_Usage__c= false;
                thisOrderProduct.Quantity = 2;
            }
            SBQQ.TriggerControl.disable();
            update listOrderItems;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(BULK_COUNT, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(false, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(BULK_COUNT, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

    }

    @IsTest
    static void afterInsert_MissingUsage_PositiveSetToTrue_EvaluateSubscriptionUpdateTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        Contract testContract = new Contract(
            StartDate = CONTRACT_START_DATE,
            qtc_Missing_Usage__c = false,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = thisProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert thisSubscription;

        Order thisOrder = new order(    
            qtc_Missing_Usage__c = false,
            Pricebook2Id = standardPrice.Pricebook2Id, 
            AccountId = thisAccount.id, 
            Status = STATUS_DRAFT, 
            EffectiveDate = Date.Today(), 
            blng__BillingDayOfMonth__c = '28',
            qtc_Bill_To_Site__c = thisAccount.Id,
            Deliver_To_Site__c = thisAccount.Id,
            SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;

        OrderItem thisOrderProduct = new OrderItem(     
                qtc_Missing_Usage__c = true,
                PriceBookEntryId = standardPrice.Id, 
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                OrderId = thisOrder.Id, 
                SBQQ__QuoteLine__c = testQuoteLine.Id,
                Quantity = 1, 
                SBQQ__OrderedQuantity__c = 1, 
                UnitPrice = standardPrice.UnitPrice, 
                SBQQ__ChargeType__c = 'One-Time',
                ServiceDate = Date.Today()
            );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        List<Order> listBeforeTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listBeforeTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listBeforeTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listBeforeTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listBeforeTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(false, listBeforeTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be false');

        Test.startTest();
        thisOrderProduct.SBQQ__Subscription__c = thisSubscription.Id;
        SBQQ.TriggerControl.disable();
        update thisOrderProduct;
        SBQQ.TriggerControl.enable();
            
        Test.stopTest();

        List<Order> listAfterTestOrders = [SELECT Id, qtc_Missing_Usage__c FROM Order];
        System.assertEquals(1, listAfterTestOrders.size(), 'We expect only 1 Order at this time');
        System.assertEquals(true, listAfterTestOrders[0].qtc_Missing_Usage__c, 'We expect the field to be true');

        List<Contract> listAfterTestContract = [SELECT Id, qtc_Missing_Usage__c FROM Contract];
        System.assertEquals(1, listAfterTestContract.size(), 'We expect only 1 Contract at this time');
        System.assertEquals(true, listAfterTestContract[0].qtc_Missing_Usage__c, 'We expect the field to be true');

    }
}