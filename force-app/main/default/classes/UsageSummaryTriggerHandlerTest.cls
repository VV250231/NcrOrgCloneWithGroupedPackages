@isTest
public with sharing class UsageSummaryTriggerHandlerTest {
    static String   STATUS_DRAFT = 'Draft',
                    SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER',
                    USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage',
                    USAGE_STATUS_NOT_EXPECTING_USAGE = 'Not Expecting Usage	';

    static Date     START_DATE = Date.today(),
                     END_DATE = START_DATE.addDays(25);
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

        Order thisOrder = new order(    Pricebook2Id = stdPbId, 
                                AccountId = thisAccount.id, 
                                Status = STATUS_DRAFT, 
                                EffectiveDate = Date.Today(), 
                                blng__BillingDayOfMonth__c = '28',
                                qtc_Bill_To_Site__c = thisAccount.Id,
                                Deliver_To_Site__c = thisAccount.Id,
                                SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;
    }

    @IsTest
    static void afterInsert_MissingUsage_NegativeFalseTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
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

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be false');
        Test.startTest();
            List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>();
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-10),
                blng__SummaryEndDate__c = Date.today().addDays(10),
                blng__TotalQuantity__c = 10,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-20),
                blng__SummaryEndDate__c = Date.today().addDays(-10),
                blng__TotalQuantity__c = 10,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            insert listUsageSummaries;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to true');
    }
    @IsTest
    static void afterInsert_MissingUsage_NegativeTrueTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
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
            qtc_Missing_Usage__c = true,
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        Test.startTest();
            List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>();
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-10),
                blng__SummaryEndDate__c = Date.today().addDays(10),
                blng__TotalQuantity__c = null,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-20),
                blng__SummaryEndDate__c = Date.today().addDays(-10),
                blng__TotalQuantity__c = null,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            insert listUsageSummaries;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to true');
    }

    @IsTest
    static void afterInsert_MissingUsage_Positive_setToTrueTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
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

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be false');
        Test.startTest();
            List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>();
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-10),
                blng__SummaryEndDate__c = Date.today().addDays(10),
                blng__TotalQuantity__c = null,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-20),
                blng__SummaryEndDate__c = Date.today().addDays(-10),
                blng__TotalQuantity__c = null,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            insert listUsageSummaries;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to true');
    }

    @IsTest
    static void afterInsert_MissingUsage_Positive_setToFalseTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
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
            qtc_Missing_Usage__c = true,
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        Test.startTest();
            List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>();
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-10),
                blng__SummaryEndDate__c = Date.today().addDays(10),
                blng__TotalQuantity__c = 10,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            listUsageSummaries.add( new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-20),
                blng__SummaryEndDate__c = Date.today().addDays(-10),
                blng__TotalQuantity__c = 10,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            ));
            insert listUsageSummaries;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to false');
    }

    @IsTest
    static void afterUpdate_MissingUsage_Positive_SetToTrueTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
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

        
        blng__UsageSummary__c usageSummary1 =  new blng__UsageSummary__c(
            blng__OrderProduct__c = thisOrderProduct.Id,
            blng__SummaryStartDate__c = Date.today().addDays(-10),
            blng__SummaryEndDate__c = Date.today().addDays(10),
            blng__TotalQuantity__c = 10,
            blng__PreratedQuantity__c = null,
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
        );
        blng__UsageSummary__c usageSummary2 =  new blng__UsageSummary__c(
            blng__OrderProduct__c = thisOrderProduct.Id,
            blng__SummaryStartDate__c = Date.today().addDays(-20),
            blng__SummaryEndDate__c = Date.today().addDays(-10),
            blng__TotalQuantity__c = 10,
            blng__PreratedQuantity__c = null,
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
        );
        List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>{usageSummary1, usageSummary2};
        insert listUsageSummaries;

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be false');
        Test.startTest();
            usageSummary2.blng__TotalQuantity__c = null;
            update usageSummary2;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to TRUE');
    }

    @IsTest
    static void afterUpdate_MissingUsage_Positive_SetToFalseTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
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

        
        blng__UsageSummary__c usageSummary1 =  new blng__UsageSummary__c(
            blng__OrderProduct__c = thisOrderProduct.Id,
            blng__SummaryStartDate__c = Date.today().addDays(-10),
            blng__SummaryEndDate__c = Date.today().addDays(10),
            blng__TotalQuantity__c = 10,
            blng__Subtotal__c = 50,
            blng__PreratedQuantity__c = null,
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
        );
        blng__UsageSummary__c usageSummary2 =  new blng__UsageSummary__c(
            blng__OrderProduct__c = thisOrderProduct.Id,
            blng__SummaryStartDate__c = Date.today().addDays(-20),
            blng__SummaryEndDate__c = Date.today().addDays(-10),
            blng__TotalQuantity__c = null,
            blng__Subtotal__c = 40,
            blng__PreratedQuantity__c = null,
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
        );
        List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>{usageSummary1, usageSummary2};
        insert listUsageSummaries;

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        Test.startTest();
            usageSummary2.blng__TotalQuantity__c = 10;
            update usageSummary2;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to false');
    }

    @IsTest
    static void afterUpdate_Bulk_MissingUsage_Positive_SetToTrueTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        List<OrderItem> listOrderProducts = new List<OrderItem>();
        for( Integer i=0; i< BULK_COUNT; i++){
            OrderItem thisOrderProduct = new OrderItem(     
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
            listOrderProducts.add( thisOrderProduct );
        }
        SBQQ.TriggerControl.disable();
        insert listOrderProducts;
        SBQQ.TriggerControl.enable();

        List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>();
        for(OrderItem thisOrderProduct : listOrderProducts){
            blng__UsageSummary__c usageSummary1 =  new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-20),
                blng__SummaryEndDate__c = Date.today().addDays(-10),
                blng__TotalQuantity__c = 10,
                blng__Subtotal__c = 20,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            );
            listUsageSummaries.add( usageSummary1);
        }
    
        insert listUsageSummaries;

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(BULK_COUNT, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(false, listBeforeTestOrderItem[0].qtc_Missing_Usage__c, 'We expect the field to be true');
        Test.startTest();
            for(blng__UsageSummary__c thisUsageSummary : listUsageSummaries){
                thisUsageSummary.blng__TotalQuantity__c = null;
            }
            update listUsageSummaries;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Missing_Usage__c FROM OrderItem];
        System.assertEquals(BULK_COUNT, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(true, listResultOrderItem[0].qtc_Missing_Usage__c, 'We expect the trigger to update this field to true');
    }
    
    @IsTest
    static void afterInsert_AggregateSubtotalPositiveTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
            PriceBookEntryId = standardPrice.Id, 
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            OrderId = thisOrder.Id, 
            SBQQ__QuoteLine__c = testQuoteLine.Id,
            Quantity = 1, 
            qtc_Unbilled_Usage_Total__c = 0,
            SBQQ__OrderedQuantity__c = 1, 
            UnitPrice = standardPrice.UnitPrice, 
            SBQQ__ChargeType__c = 'One-Time',
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Unbilled_Usage_Total__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(0, listBeforeTestOrderItem[0].qtc_Unbilled_Usage_Total__c, 'We expect the field to be this value');
        Test.startTest();
            blng__UsageSummary__c usageSummary1 =  new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-10),
                blng__SummaryEndDate__c = Date.today().addDays(10),
                blng__TotalQuantity__c = 10,
                blng__Subtotal__c = 40,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            );
            blng__UsageSummary__c usageSummary2 =  new blng__UsageSummary__c(
                blng__OrderProduct__c = thisOrderProduct.Id,
                blng__SummaryStartDate__c = Date.today().addDays(-20),
                blng__SummaryEndDate__c = Date.today().addDays(-10),
                blng__TotalQuantity__c = null,
                blng__Subtotal__c = 50,
                blng__PreratedQuantity__c = null,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
            );
            Double afterInsertTotal = usageSummary1.blng__Subtotal__c + usageSummary2.blng__Subtotal__c;
            List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>{usageSummary1, usageSummary2};
            insert listUsageSummaries;
           
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Unbilled_Usage_Total__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(afterInsertTotal, listResultOrderItem[0].qtc_Unbilled_Usage_Total__c, 'We expect the field to be this value');
    }

    @IsTest
    static void afterUpdate_AggregateSubtotalPositiveTest(){
        PricebookEntry standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Order thisOrder = [SELECT Id FROM Order LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRecognitionRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];

        OrderItem thisOrderProduct = new OrderItem(     
            PriceBookEntryId = standardPrice.Id, 
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRecognitionRule.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            OrderId = thisOrder.Id, 
            SBQQ__QuoteLine__c = testQuoteLine.Id,
            Quantity = 1, 
            qtc_Unbilled_Usage_Total__c = 0,
            SBQQ__OrderedQuantity__c = 1, 
            UnitPrice = standardPrice.UnitPrice, 
            SBQQ__ChargeType__c = 'One-Time',
            ServiceDate = Date.Today()
        );
        SBQQ.TriggerControl.disable();
        insert thisOrderProduct;
        SBQQ.TriggerControl.enable();

        
        blng__UsageSummary__c usageSummary1 =  new blng__UsageSummary__c(
            blng__OrderProduct__c = thisOrderProduct.Id,
            blng__SummaryStartDate__c = Date.today().addDays(-10),
            blng__SummaryEndDate__c = Date.today().addDays(10),
            blng__TotalQuantity__c = 10,
            blng__Subtotal__c = 40,
            blng__PreratedQuantity__c = null,
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
        );
        blng__UsageSummary__c usageSummary2 =  new blng__UsageSummary__c(
            blng__OrderProduct__c = thisOrderProduct.Id,
            blng__SummaryStartDate__c = Date.today().addDays(-20),
            blng__SummaryEndDate__c = Date.today().addDays(-10),
            blng__TotalQuantity__c = null,
            blng__Subtotal__c = 50,
            blng__PreratedQuantity__c = null,
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE
        );
        Double beforeUpdateTotal = usageSummary1.blng__Subtotal__c + usageSummary2.blng__Subtotal__c;
        List<blng__UsageSummary__c> listUsageSummaries = new List<blng__UsageSummary__c>{usageSummary1, usageSummary2};
        insert listUsageSummaries;

        List<OrderItem> listBeforeTestOrderItem = [SELECT Id, qtc_Unbilled_Usage_Total__c FROM OrderItem];
        System.assertEquals(1, listBeforeTestOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(beforeUpdateTotal, listBeforeTestOrderItem[0].qtc_Unbilled_Usage_Total__c, 'We expect the field to be this value');
        Test.startTest();
            usageSummary2.blng__TotalQuantity__c = 150;
            Double afterUpdateTotal = usageSummary1.blng__Subtotal__c + usageSummary2.blng__Subtotal__c;
            update usageSummary2;
        Test.stopTest();
    
        List<OrderItem> listResultOrderItem = [SELECT Id, qtc_Unbilled_Usage_Total__c FROM OrderItem];
        System.assertEquals(1, listResultOrderItem.size(), 'We expect only one Order Product at this time');
        System.assertEquals(afterUpdateTotal, listResultOrderItem[0].qtc_Unbilled_Usage_Total__c, 'We expect the field to be this value');
       
    }
}