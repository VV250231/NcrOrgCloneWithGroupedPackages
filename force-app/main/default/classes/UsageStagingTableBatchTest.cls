@isTest
public with sharing class UsageStagingTableBatchTest {
    static String   STATUS_DRAFT = 'Draft',
                    PRODUCT_CODE_PAYMENTS_CONNECTED = 'S200-2001-0000',
                    USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage',
                    SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
                    UNIT_OF_MEASURE_DEVICE = 'Device',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER',
                    CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT = 'Connected Payments No Payments',
                    USAGE_SUMMARY_STATUS_NEW = 'New';
    static List<String> LIST_MASTER_CUSTOMER_NUMBER = new List<String>{
        'SETUPMASTERCONTRACT1',
        'SETUPMASTERCONTRACT2',
        'SETUPMASTERCONTRACT3',
        'SETUPMASTERCONTRACT4'
    };
    static Date     START_DATE = Date.newInstance(2021, 1, 1);
    static List<Date> LIST_START_DATES = new List<Date>{
        START_DATE,
        START_DATE,
        START_DATE,
        START_DATE.addMonths(-1),
        START_DATE.addMonths(-2),
        START_DATE.addMonths(-3)
    };
    static Integer END_DATE_COUNT = 25;
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;

    @TestSetup
    static void setupData(){
       
		// Jesse D - 11/30 - added custom setting to bypass validation rules in test
        Automation_Setting__c autoSetting = new Automation_Setting__c();
        autoSetting.Skip_Flow__c = false;
        autoSetting.Skip_Trigger__c = false;
        autoSetting.Skip_Validation_Rule__c = true;
        autoSetting.Skip_Outbound_Integration__c = true;
        insert autoSetting;
        
        Account thisAccount = new Account(name = 'ContractTestAccount',
        LOB__c = 'FINANCIAL',
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
        thisOpportunity.INVOICE_TRIGGER__C = 'Shipment';
        thisOpportunity.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        thisOpportunity.closeDate = System.TODAY();
        thisOpportunity.stagename = 'Prospecting';
        thisOpportunity.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        thisOpportunity.EndCustomerUnknown__c = true; 
        thisOpportunity.Skip_Validation_Rule_for_Lead_Conversion__c = true;
        thisOpportunity.ForecastCategoryName ='Omitted';
        insert thisOpportunity;

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
                ProductCode = 'H400-0001-0001',
                product_type__c = 'Topline' ));
        lstProducts.add(new product2(   name='C', 
                family='Hardware',
                blng__BillingRule__c = billingRule.Id, 
                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                blng__TaxRule__c = taxrule.ID,
                ProductCode = 'H400-0001-0002', 
                product_type__c = 'Topline'));
        lstProducts.add(new product2(   name='D', 
                family='Hardware',
                blng__BillingRule__c = billingRule.Id, 
                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                blng__TaxRule__c = taxrule.ID,
                ProductCode = 'H400-0001-0003'));
        Product2 connectedPaymentProduct = new product2(   
                                name='D', 
                                family='Hardware',
                                blng__BillingRule__c = billingRule.Id, 
                                blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                blng__TaxRule__c = taxrule.ID,
                                ProductCode = PRODUCT_CODE_PAYMENTS_CONNECTED);
                                // ProductCode = UsageStagingTableBatch.PRODUCT_CODE_CONNECTED_PAYMENTS );
        lstProducts.add( connectedPaymentProduct );
        insert lstProducts;

        List<Contract> listContract = new List<Contract>();
      
        Contract thisContract = new Contract(
            StartDate = START_DATE,
            qtc_Missing_Usage__c = true,
            AccountId=thisAccount.Id);
        listContract.add(thisContract);
        
        insert listContract;

        Map<Id, SBQQ__Subscription__c> mapSubscriptionByProduct2Id = new Map<Id, SBQQ__Subscription__c>();
        for(Product2 thisProduct : lstProducts){
            SBQQ__Subscription__c thisSubscription = new SBQQ__Subscription__c(
                SBQQ__Contract__c = thisContract.Id, 
                SBQQ__Product__c = thisProduct.Id, 
                SBQQ__Quantity__c = 5, 
                SBQQ__Account__c = thisAccount.Id,
                SBQQ__NetPrice__c = 25,
                SBQQ__SubscriptionEndDate__c = START_DATE.addDays(END_DATE_COUNT));
            mapSubscriptionByProduct2Id.put(thisProduct.Id, thisSubscription);
        }

        insert mapSubscriptionByProduct2Id.values();

        Id stdPbId = Test.getStandardPricebookId();        
        Map<Id, PricebookEntry> mapPriceBookeEntryByProductId = new Map<Id, PricebookEntry>();
        for(Product2 thisProduct : lstProducts ){
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = thisProduct.id, UnitPrice = 100, IsActive = true);
            mapPriceBookeEntryByProductId.put(thisProduct.Id, standardPrice);
        }
        insert mapPriceBookeEntryByProductId.values();

        List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testSetupQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = START_DATE,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__ProrationDayOfMonth__c = String.valueOf( 25 ),
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true
        );
        listQuotes.add( testSetupQuote );

        insert listQuotes;
        
        List<SBQQ__QuoteLine__c> listQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(Product2 thisProduct : lstProducts ){
            PricebookEntry thisPricebookEntry = mapPriceBookeEntryByProductId.get(thisProduct.Id);
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
                SBQQ__Quote__c = testSetupQuote.Id,
                SBQQ__PricebookEntryId__c = thisPricebookEntry.Id,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 1,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisProduct.Id
    
            );
            listQuoteLines.add( testQuoteLine );
        }
        insert listQuoteLines;
        Map<String, List<SBQQ__QuoteLine__c>> mapQuoteLinesByQuoteId = ApexUtils.groupBy(listQuoteLines, SBQQ__QuoteLine__c.SBQQ__Quote__c);

        List<Order> listSetupOrders = new List<Order>();
        for( SBQQ__Quote__c thisQuote : listQuotes ){
            for( Date thisStartDate : LIST_START_DATES ){
                Date thisEndDate = thisStartDate.addDays( END_DATE_COUNT );
                Order thisOrder = new order(    
                    Pricebook2Id = stdPbId, 
                    AccountId = thisAccount.id, 
                    Status = STATUS_DRAFT, 
                    EffectiveDate = thisStartDate, 
                    EndDate = thisEndDate,
                    blng__BillingDayOfMonth__c = '28',
                    qtc_Bill_To_Site__c = thisAccount.Id,
                    Deliver_To_Site__c = thisAccount.Id,
                    SBQQ__Quote__c=thisQuote.Id);
                listSetupOrders.add(thisOrder);
            }
        }
        insert listSetupOrders;
        
        Map<Id, Order> mapOrderById = new Map<Id, Order>( listSetupOrders );

        List<OrderItem> listOrderItem = new List<OrderItem>();
        for(Order thisOrder : listSetupOrders){
            List<SBQQ__QuoteLine__c> thisListQuoteLines = mapQuoteLinesByQuoteId.get( thisOrder.SBQQ__Quote__c );
            for(SBQQ__QuoteLine__c thisQuoteLine : thisListQuoteLines){
                SBQQ__Subscription__c thisSubscription= mapSubscriptionByProduct2Id.get(thisQuoteLine.SBQQ__Product__c);
                PricebookEntry thisPricebookEntry = mapPriceBookeEntryByProductId.get(thisQuoteLine.SBQQ__Product__c);
                OrderItem thisOrderProduct = new OrderItem(     
                    PriceBookEntryId = thisPricebookEntry.Id, 
                    OrderId = thisOrder.Id, 
                    product2Id = thisQuoteLine.SBQQ__Product__c,
                    SBQQ__Subscription__c = thisSubscription.Id,
                    SBQQ__QuoteLine__c = thisQuoteLine.Id,
                    Quantity = 1, 
                    blng__BillingRule__c = billingRule.id,
                    blng__TaxRule__c = taxrule.Id,
                    blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                    SBQQ__OrderedQuantity__c = 1, 
                    UnitPrice = thisPricebookEntry.UnitPrice, 
                    blng__BillableUnitPrice__c = 15,
                    SBQQ__ChargeType__c = 'One-Time',
                    ServiceDate = thisOrder.EffectiveDate);
                System.debug('###SETUP OrderItem '+ thisOrderProduct);
                listOrderItem.add(thisOrderProduct);
            }
        }
        SBQQ.TriggerControl.disable();
        insert listOrderItem;
        SBQQ.TriggerControl.enable();

        // Jesse D - 11/30 - update to activate Orders since usage staging table requires them to be activated
        for (Order order : listSetupOrders) {
            order.Status = 'Activated';
        }
        update listSetupOrders;
        
        ConsumptionSchedule preratedSchedule = new ConsumptionSchedule(
            Name = 'TestPreratedSchedule',
            RatingMethod = 'Tier', 
            BillingTerm = 1, 
            BillingTermUnit = 'Month',
            MatchingAttribute = 'Prerated',
            SBQQ__Category__c = 'Rates', 
            Type = 'Range'
        );
    
        ConsumptionSchedule noPaymentSchedule = new ConsumptionSchedule(
            Name = CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT,
            qtc_F_F_Rating__c = true,
            RatingMethod = 'Tier', 
            BillingTerm = 1, 
            BillingTermUnit = 'Month',
            SBQQ__Category__c = 'Rates', 
            Type = 'Range'
        );
        List<ConsumptionSchedule> consolidatedListConsumptionSchedule = new List<ConsumptionSchedule>{
            preratedSchedule,
            noPaymentSchedule
        };
        insert consolidatedListConsumptionSchedule;

        List<ConsumptionRate> listConsumptionRate = new List<ConsumptionRate>();
        listConsumptionRate.add( new ConsumptionRate(
            lowerBound = 0, 
            price = 9999, 
            pricingMethod = 'PerUnit', 
            processingOrder = 0,
            consumptionScheduleId = preratedSchedule.Id
        ));
            
        listConsumptionRate.add( new ConsumptionRate(
            lowerBound = 0, 
            upperBound = 11, 
            price = 10, 
            pricingMethod = 'PerUnit', 
            processingOrder = 0,
            consumptionScheduleId = noPaymentSchedule.Id
        ));
        listConsumptionRate.add( new ConsumptionRate(
            lowerBound = 11, 
            upperBound = 21, 
            pricingMethod = 'PerUnit', 
            processingOrder = 1,
            price = 20, 
            consumptionScheduleId = noPaymentSchedule.Id
        ));
        listConsumptionRate.add( new ConsumptionRate(
            lowerBound = 21, 
            upperBound = null, 
            pricingMethod = 'PerUnit', 
            processingOrder = 2,
            price = 30, 
            consumptionScheduleId = noPaymentSchedule.Id
        ));
        
        insert listConsumptionRate;
        for(ConsumptionSchedule thisConsumptionSchedule : consolidatedListConsumptionSchedule){
            thisConsumptionSchedule.isActive = true;
        }
        update consolidatedListConsumptionSchedule;

        List<ProductConsumptionSchedule> listProductConsumptionSchedule = new List<ProductConsumptionSchedule>();
        for(Product2 thisProduct : lstProducts){
         
            listProductConsumptionSchedule.add(
                new ProductConsumptionSchedule(
                    ConsumptionScheduleId = preratedSchedule.Id,
                    ProductId = thisProduct.Id
            ));
            listProductConsumptionSchedule.add(
                new ProductConsumptionSchedule(
                    ConsumptionScheduleId = noPaymentSchedule.Id,
                    ProductId = thisProduct.Id
            ));
        }
        insert listProductConsumptionSchedule;
        
    }

    @isTest
    static void executeBatch_SingleUsagePositive(){
        Order thisOrder = [SELECT Id,EffectiveDate, EndDate, qtc_Master_Customer_Number__c, AccountId FROM Order LIMIT 1];
        List<OrderItem> listOrderItems = [SELECT Id FROM OrderItem WHERE OrderId = :thisOrder.Id];
     
        List<blng__UsageSummary__c> listUsageSummaryToInsert = new List<blng__UsageSummary__c>();
        for( OrderItem thisOrderItem : listOrderItems){
            listUsageSummaryToInsert.add( new blng__UsageSummary__c(
                blng__Status__c = USAGE_SUMMARY_STATUS_NEW,
                blng__Account__c = thisOrder.accountId,
                blng__Order__c = thisOrder.Id,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
                blng__OrderProduct__c = thisOrderItem.Id,
                blng__UnitOfMeasure__c = UNIT_OF_MEASURE_DEVICE,
                blng__SummaryStartDate__c = thisOrder.EffectiveDate,
                blng__SummaryEndDate__c = thisOrder.EndDate
            ));
        }
        insert listUsageSummaryToInsert;
        System.debug('### test listUsageSummaryToInsert '+listUsageSummaryToInsert);


        List<blng__UsageSummary__c> listRequeryUsageSummaryWithPaymentsConnected = 
            [   SELECT  Id, blng__MatchingId__c, blng__SummaryStartDate__c, blng__SummaryEndDate__c, 
                        blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c,
                        blng__OrderItemConsumptionSchedule__c
                FROM blng__UsageSummary__c
                WHERE Id IN :listUsageSummaryToInsert
                    AND blng__OrderProduct__r.Product2.ProductCode = :PRODUCT_CODE_PAYMENTS_CONNECTED ];

        List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
        for( blng__UsageSummary__c thisSummary : listRequeryUsageSummaryWithPaymentsConnected ){
            System.debug('### thisSummary test '+thisSummary);
            listUsageStagingTable.add( new Usage_Staging_Table__c(
                qtc_MasterCustomerNumber__c = thisOrder.qtc_Master_Customer_Number__c, 
                CurrencyIsoCode = 'USD',
                qtc_MatchingAttribute__c = 'testMatchingAtrribute1',
                qtc_MatchingId__c = thisSummary.blng__MatchingId__c,
                qtc_SummaryStartDate__c = thisSummary.blng__SummaryStartDate__c,
                qtc_SummaryEndDate__c = thisSummary.blng__SummaryEndDate__c,
                qtc_TotalQuantity__c  = 10,
                qtc_UsageSummaryId__c = String.valueOf( thisSummary.Id)
            ));
        }
        insert listUsageStagingTable;

        Test.startTest();
            UsageStagingTableBatch testBatch = new UsageStagingTableBatch();
            Id batchId = Database.executeBatch( testBatch );
        Test.stopTest();

        Integer expectedPooledTotal = 10; 
        Double expectedPooledRate = 10; //Range Rate of 10
        Double expectedTotal = expectedPooledTotal * expectedPooledRate;
        Double expectedPerUnitRate = expectedTotal / expectedPooledTotal;
        
        List<blng__Usage__c> listUsageResult = [SELECT  Id, blng__UsageSummary__c, qtc_Master_Customer_Number__c, CurrencyIsoCode, blng__MatchingAttribute__c, 
                                                        blng__MatchingId__c, blng__PreratedAmount__c, blng__PreratedQuantity__c, blng__EndDateTime__c, 
                                                        blng__StartDateTime__c, blng__UnitOfMeasure__c
                                                FROM blng__Usage__c];
        System.assertEquals(
            listUsageStagingTable.size(), 
            listUsageResult.size(), 
            'We expect the same number of usage records to be created as Usage Staging Table/Usage Summary Records'
        );

        System.assertEquals(
            1, 
            listUsageResult.size(), 
            'We expect only 1 usage record to be created at this time'
        );
   
        for(blng__Usage__c thisUsage : listUsageResult ){
            System.assertEquals( 
                expectedTotal, 
                thisUsage.blng__PreratedAmount__c, 
                'We expect the Prerated amount to be calculated with the Pooled Rate'
            );

            System.assertEquals(UNIT_OF_MEASURE_DEVICE, thisUsage.blng__UnitOfMeasure__c, 'We expect the UOM to be stamped by the Summaries UOM value');
        }
        List<Usage_Staging_Table__c> listUsageStagingTableResult = [SELECT qtc_UsageStagingProcessed__c, qtc_Usage__c FROM Usage_Staging_Table__c];
        System.assertEquals( listUsageResult.size(), listUsageStagingTableResult.size(), 'We expect an equal number of usage records as staging table records');
        for(Usage_Staging_Table__c stagingTableResult :  listUsageStagingTableResult){
            System.assertNotEquals(null, stagingTableResult.qtc_Usage__c, 'We expect the Usage field to be populated');
            System.assertEquals(true, stagingTableResult.qtc_UsageStagingProcessed__c, 'We expect the field to be flagged as true after processing');
        }
    }


    @isTest
    static void executeBatch_MultipleUsagePositive(){
        List<Order> listOrder = [SELECT Id,EffectiveDate, EndDate, qtc_Master_Customer_Number__c, AccountId FROM Order WHERE EffectiveDate = :START_DATE];
        List<OrderItem> listOrderItems = [SELECT Id, OrderId, Order.accountId, Order.EffectiveDate, Order.EndDate FROM OrderItem WHERE OrderId IN :listOrder];
     
        Id doNotRateOrder = listOrder[0].Id;
        List<blng__UsageSummary__c> listUsageSummaryToInsert = new List<blng__UsageSummary__c>();
        for( OrderItem thisOrderItem : listOrderItems){
         
            listUsageSummaryToInsert.add( new blng__UsageSummary__c(
                blng__Status__c = USAGE_SUMMARY_STATUS_NEW,
                blng__Account__c = thisOrderItem.Order.accountId,
                blng__Order__c = thisOrderItem.Order.Id,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
                blng__OrderProduct__c = thisOrderItem.Id,
                blng__SummaryStartDate__c = thisOrderItem.Order.EffectiveDate,
                blng__SummaryEndDate__c = thisOrderItem.Order.EndDate
                
            ));
        }
        insert listUsageSummaryToInsert;
        for(blng__UsageSummary__c thisUsageSummary : listUsageSummaryToInsert ){
            if( thisUsageSummary.blng__Order__c == doNotRateOrder){
                thisUsageSummary.qtc_Do_Not_Rate__c = true;
            }
        }
        update listUsageSummaryToInsert;
     

        List<blng__UsageSummary__c> listRequeryUsageSummaryWithPaymentsConnected = 
            [   SELECT  Id, blng__MatchingId__c, blng__SummaryStartDate__c, blng__SummaryEndDate__c, 
                        blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c,
                        blng__OrderItemConsumptionSchedule__c
                FROM blng__UsageSummary__c
                WHERE Id IN :listUsageSummaryToInsert
                    AND blng__OrderProduct__r.Product2.ProductCode = :PRODUCT_CODE_PAYMENTS_CONNECTED ];

        List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
        for( blng__UsageSummary__c thisSummary : listRequeryUsageSummaryWithPaymentsConnected ){
            listUsageStagingTable.add( new Usage_Staging_Table__c(
                qtc_MasterCustomerNumber__c = thisSummary.blng__Order__r.qtc_Master_Customer_Number__c, 
                CurrencyIsoCode = 'USD',
                qtc_MatchingAttribute__c = 'testMatchingAtrribute1',
                qtc_MatchingId__c = thisSummary.blng__MatchingId__c,
                qtc_SummaryStartDate__c = thisSummary.blng__SummaryStartDate__c,
                qtc_SummaryEndDate__c = thisSummary.blng__SummaryEndDate__c,
                qtc_TotalQuantity__c  = 10,
                qtc_UsageSummaryId__c = String.valueOf( thisSummary.Id)
            ));
        }
        insert listUsageStagingTable;

        Test.startTest();
            UsageStagingTableBatch testBatch = new UsageStagingTableBatch();
            Id batchId = Database.executeBatch( testBatch );
        Test.stopTest();

        Integer expectedQuantityTotal = 10+10+10;
        Integer expectedPooledTotal = 0 + 10 + 10; 
        Double expectedPooledRate = 20; //Range Rate of 20
        Double expectedTotal = expectedPooledTotal * expectedPooledRate;
        Double expectedPerUnitRate = expectedTotal / expectedPooledTotal;
        Double expectedPreratedAmountPerUsage = expectedPerUnitRate * 10;
        
        List<blng__Usage__c> listUsageResult = [SELECT  Id, blng__UsageSummary__c, qtc_Master_Customer_Number__c, CurrencyIsoCode, blng__MatchingAttribute__c, 
                                                        blng__MatchingId__c, blng__PreratedAmount__c, blng__PreratedQuantity__c, blng__EndDateTime__c, 
                                                        blng__StartDateTime__c, blng__UsageSummary__r.qtc_Do_Not_Rate__c, blng__UsageSummary__r.Id
                                                FROM blng__Usage__c];
        System.assertEquals(
            listUsageStagingTable.size(), 
            listUsageResult.size(), 
            'We expect the same number of usage records to be created as Usage Staging Table/Usage Summary Records'
        );

        System.assertEquals(
            3, 
            listUsageResult.size(), 
            'We expect only 3 usage record to be created at this time'
        );
   
        Double resultTotal = 0;
        Double resultQuantity=0;
        for(blng__Usage__c thisUsage : listUsageResult ){
            resultTotal += thisUsage.blng__PreratedAmount__c;
            resultQuantity += thisUsage.blng__PreratedQuantity__c;
        }
        System.assertEquals(expectedTotal, resultTotal, 'We expect the total to equal the expected total');
        System.assertEquals(expectedQuantityTotal, resultQuantity, 'We expect the total prerated quantity to equal this even with Do Not Rate usage summaries');

        List<Usage_Staging_Table__c> listUsageStagingTableResult = [SELECT qtc_UsageStagingProcessed__c, qtc_Usage__c FROM Usage_Staging_Table__c];
        System.assertEquals( listUsageResult.size(), listUsageStagingTableResult.size(), 'We expect an equal number of usage records as staging table records');
        for(Usage_Staging_Table__c stagingTableResult :  listUsageStagingTableResult){
            System.assertNotEquals(null, stagingTableResult.qtc_Usage__c, 'We expect the Usage field to be populated');
            System.assertEquals(true, stagingTableResult.qtc_UsageStagingProcessed__c, 'We expect the field to be flagged as true after processing');
        }
    }

    @isTest
    static void executeBatch_MultipleUsageNegative(){
        List<Order> listOrder = [SELECT Id,EffectiveDate, EndDate, qtc_Master_Customer_Number__c, AccountId FROM Order WHERE EffectiveDate = :START_DATE] ;
        List<OrderItem> listOrderItems = [SELECT Id, OrderId, Order.accountId, Order.EffectiveDate, Order.EndDate FROM OrderItem WHERE OrderId IN :listOrder];
  
        Id doNotRateOrder = listOrder[0].Id;
        List<blng__UsageSummary__c> listUsageSummaryToInsert = new List<blng__UsageSummary__c>();
        for( OrderItem thisOrderItem : listOrderItems){
  
            listUsageSummaryToInsert.add( new blng__UsageSummary__c(
                blng__Status__c = USAGE_SUMMARY_STATUS_NEW,
                blng__Account__c = thisOrderItem.Order.accountId,
                blng__Order__c = thisOrderItem.Order.Id,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
          
                blng__OrderProduct__c = thisOrderItem.Id,
                blng__SummaryStartDate__c = thisOrderItem.Order.EffectiveDate,
                blng__SummaryEndDate__c = thisOrderItem.Order.EndDate,
                qtc_Do_Not_Rate__c = thisOrderItem.OrderId == doNotRateOrder ? true : false
            ));
        }

        insert listUsageSummaryToInsert;

        List<blng__UsageSummary__c> listRequeryUsageSummaryWithPaymentsConnected = 
            [   SELECT  Id, blng__MatchingId__c, blng__SummaryStartDate__c, blng__SummaryEndDate__c, 
                        blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c,
                        blng__OrderItemConsumptionSchedule__c
                FROM blng__UsageSummary__c
                WHERE Id IN :listUsageSummaryToInsert
                    AND blng__OrderProduct__r.Product2.ProductCode = :PRODUCT_CODE_PAYMENTS_CONNECTED ];

        List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
       
        blng__UsageSummary__c thisSummary = listRequeryUsageSummaryWithPaymentsConnected[0];
        listUsageStagingTable.add( new Usage_Staging_Table__c(
            qtc_MasterCustomerNumber__c = thisSummary.blng__Order__r.qtc_Master_Customer_Number__c, 
            CurrencyIsoCode = 'USD',
            qtc_MatchingAttribute__c = 'testMatchingAtrribute1',
            qtc_MatchingId__c = thisSummary.blng__MatchingId__c,
            qtc_SummaryStartDate__c = thisSummary.blng__SummaryStartDate__c,
            qtc_SummaryEndDate__c = thisSummary.blng__SummaryEndDate__c,
            qtc_TotalQuantity__c  = 10,
            qtc_UsageSummaryId__c = String.valueOf( thisSummary.Id)
        ));
    
        insert listUsageStagingTable;

        Test.startTest();
            UsageStagingTableBatch testBatch = new UsageStagingTableBatch();
            Id batchId = Database.executeBatch( testBatch );
        Test.stopTest();

        Integer expectedQuantityTotal = 10+10+10;
        Integer expectedPooledTotal = 0 + 10 + 10; 
        Double expectedPooledRate = 20; //Range Rate of 20
        Double expectedTotal = expectedPooledTotal * expectedPooledRate;
        Double expectedPerUnitRate = expectedTotal / expectedPooledTotal;
        Double expectedPreratedAmountPerUsage = expectedPerUnitRate * 10;
        
        List<blng__Usage__c> listUsageResult = [SELECT  Id, blng__UsageSummary__c, qtc_Master_Customer_Number__c, CurrencyIsoCode, blng__MatchingAttribute__c, 
                                                        blng__MatchingId__c, blng__PreratedAmount__c, blng__PreratedQuantity__c, blng__EndDateTime__c, 
                                                        blng__StartDateTime__c, blng__UsageSummary__r.qtc_Do_Not_Rate__c, blng__UsageSummary__r.Id
                                                FROM blng__Usage__c];
        System.assertEquals(
            0,
            listUsageResult.size(), 
            'We expect 0 usasge records to be created, because there are not enough Usage Staging Table Records'
        );

        List<Usage_Staging_Table__c> listUsageStagingTableResult = [SELECT qtc_UsageStagingProcessed__c FROM Usage_Staging_Table__c];
        for(Usage_Staging_Table__c stagingTableResult :  listUsageStagingTableResult){
            System.assertEquals(false, stagingTableResult.qtc_UsageStagingProcessed__c, 'We expect the field to remain as false');
        }
    }

    @isTest
    static void executeBatch_MultipleDatesPositive(){
        List<Order> listOrder = [SELECT Id,EffectiveDate, EndDate, qtc_Master_Customer_Number__c, AccountId FROM Order ];
        List<OrderItem> listOrderItems = [SELECT Id, OrderId, Order.accountId, Order.EffectiveDate, Order.EndDate FROM OrderItem WHERE OrderId IN :listOrder];
    
        Id doNotRateOrder = listOrder[0].Id;
        List<blng__UsageSummary__c> listUsageSummaryToInsert = new List<blng__UsageSummary__c>();
        for( OrderItem thisOrderItem : listOrderItems){
            listUsageSummaryToInsert.add( new blng__UsageSummary__c(
                blng__Status__c = USAGE_SUMMARY_STATUS_NEW,
                blng__Account__c = thisOrderItem.Order.accountId,
                blng__Order__c = thisOrderItem.Order.Id,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
                blng__OrderProduct__c = thisOrderItem.Id,
                blng__SummaryStartDate__c = thisOrderItem.Order.EffectiveDate,
                blng__SummaryEndDate__c = thisOrderItem.Order.EndDate,
                qtc_Do_Not_Rate__c = thisOrderItem.OrderId == doNotRateOrder ? true : false
            ));
        }

        insert listUsageSummaryToInsert;

        List<blng__UsageSummary__c> listRequeryUsageSummaryWithPaymentsConnected = 
            [   SELECT  Id, blng__MatchingId__c, blng__SummaryStartDate__c, blng__SummaryEndDate__c, 
                        blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c,
                        blng__OrderItemConsumptionSchedule__c
                FROM blng__UsageSummary__c
                WHERE Id IN :listUsageSummaryToInsert
                    AND blng__OrderProduct__r.Product2.ProductCode = :PRODUCT_CODE_PAYMENTS_CONNECTED ];

        List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
        for( blng__UsageSummary__c thisSummary : listRequeryUsageSummaryWithPaymentsConnected ){
            listUsageStagingTable.add( new Usage_Staging_Table__c(
                qtc_MasterCustomerNumber__c = thisSummary.blng__Order__r.qtc_Master_Customer_Number__c, 
                CurrencyIsoCode = 'USD',
                qtc_MatchingAttribute__c = 'testMatchingAtrribute1',
                qtc_MatchingId__c = thisSummary.blng__MatchingId__c,
                qtc_SummaryStartDate__c = thisSummary.blng__SummaryStartDate__c,
                qtc_SummaryEndDate__c = thisSummary.blng__SummaryEndDate__c,
                qtc_TotalQuantity__c  = 10,
                qtc_UsageSummaryId__c = String.valueOf( thisSummary.Id)
            ));
        }
        insert listUsageStagingTable;

        Test.startTest();
            UsageStagingTableBatch testBatch = new UsageStagingTableBatch();
            Id batchId = Database.executeBatch( testBatch );
        Test.stopTest();

        Integer expectedQuantityTotal = 10+10+10;
        Integer expectedPooledTotal = 0 + 10 + 10; 
        Double expectedPooledRate = 20; //Range Rate of 20
        Double expectedTotal = expectedPooledTotal * expectedPooledRate;
        Double expectedPerUnitRate = expectedTotal / expectedPooledTotal;
        Double expectedPreratedAmountPerUsage = expectedPerUnitRate * 10;
        
        List<blng__Usage__c> listUsageResult = [SELECT  Id, blng__UsageSummary__c, qtc_Master_Customer_Number__c, CurrencyIsoCode, blng__MatchingAttribute__c, 
                                                        blng__MatchingId__c, blng__PreratedAmount__c, blng__PreratedQuantity__c, blng__EndDateTime__c, 
                                                        blng__StartDateTime__c, blng__UsageSummary__r.qtc_Do_Not_Rate__c, blng__UsageSummary__r.Id
                                                FROM blng__Usage__c];
        System.assertEquals(
            listUsageStagingTable.size(), 
            listUsageResult.size(), 
            'We expect the same number of usage records to be created as Usage Staging Table/Usage Summary Records'
        );
    }

    // @isTest
    // static void executeBatch_MultipleUsage_NotNewNegative(){
    //     List<Order> listOrder = [SELECT Id,EffectiveDate, EndDate, qtc_Master_Customer_Number__c, AccountId FROM Order WHERE EffectiveDate = :START_DATE];
    //     List<OrderItem> listOrderItems = [SELECT Id, OrderId, Order.accountId, Order.EffectiveDate, Order.EndDate FROM OrderItem WHERE OrderId IN :listOrder];
     
    //     Id NotNewStatus = listOrder[0].Id;
    //     List<blng__UsageSummary__c> listUsageSummaryToInsert = new List<blng__UsageSummary__c>();
    //     for( OrderItem thisOrderItem : listOrderItems){
         
    //         listUsageSummaryToInsert.add( new blng__UsageSummary__c(
    //             blng__Status__c = USAGE_SUMMARY_STATUS_NEW,
    //             blng__Account__c = thisOrderItem.Order.accountId,
    //             blng__Order__c = thisOrderItem.Order.Id,
    //             qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
    //             blng__OrderProduct__c = thisOrderItem.Id,
    //             blng__SummaryStartDate__c = thisOrderItem.Order.EffectiveDate,
    //             blng__SummaryEndDate__c = thisOrderItem.Order.EndDate
                
    //         ));
    //     }
    //     insert listUsageSummaryToInsert;
    //     for(blng__UsageSummary__c thisUsageSummary : listUsageSummaryToInsert ){
    //         if( thisUsageSummary.blng__Order__c == NotNewStatus){
    //             thisUsageSummary.blng__Status__c = 'Processed';
    //         }
    //     }
    //     update listUsageSummaryToInsert;
     

    //     List<blng__UsageSummary__c> listRequeryUsageSummaryWithPaymentsConnected = 
    //         [   SELECT  Id, blng__MatchingId__c, blng__SummaryStartDate__c, blng__SummaryEndDate__c, 
    //                     blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c,
    //                     blng__OrderItemConsumptionSchedule__c
    //             FROM blng__UsageSummary__c
    //             WHERE Id IN :listUsageSummaryToInsert
    //                 AND blng__OrderProduct__r.Product2.ProductCode = :PRODUCT_CODE_PAYMENTS_CONNECTED ];

    //     List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
    //     for( blng__UsageSummary__c thisSummary : listRequeryUsageSummaryWithPaymentsConnected ){
    //         listUsageStagingTable.add( new Usage_Staging_Table__c(
    //             qtc_MasterCustomerNumber__c = thisSummary.blng__Order__r.qtc_Master_Customer_Number__c, 
    //             CurrencyIsoCode = 'USD',
    //             qtc_MatchingAttribute__c = 'testMatchingAtrribute1',
    //             qtc_MatchingId__c = thisSummary.blng__MatchingId__c,
    //             qtc_SummaryStartDate__c = thisSummary.blng__SummaryStartDate__c,
    //             qtc_SummaryEndDate__c = thisSummary.blng__SummaryEndDate__c,
    //             qtc_TotalQuantity__c  = 10,
    //             qtc_UsageSummaryId__c = String.valueOf( thisSummary.Id)
    //         ));
    //     }
    //     insert listUsageStagingTable;

    //     Test.startTest();
    //         UsageStagingTableBatch testBatch = new UsageStagingTableBatch();
    //         Id batchId = Database.executeBatch( testBatch );
    //     Test.stopTest();

    //     Integer expectedQuantityTotal = 10+10+10;
    //     Integer expectedPooledTotal = 0 + 10 + 10; 
    //     Double expectedPooledRate = 20; //Range Rate of 20
    //     Double expectedTotal = expectedPooledTotal * expectedPooledRate;
    //     Double expectedPerUnitRate = expectedTotal / expectedPooledTotal;
    //     Double expectedPreratedAmountPerUsage = expectedPerUnitRate * 10;
        
    //     List<blng__Usage__c> listUsageResult = [SELECT  Id, blng__UsageSummary__c, qtc_Master_Customer_Number__c, CurrencyIsoCode, blng__MatchingAttribute__c, 
    //                                                     blng__MatchingId__c, blng__PreratedAmount__c, blng__PreratedQuantity__c, blng__EndDateTime__c, 
    //                                                     blng__StartDateTime__c, blng__UsageSummary__r.qtc_Do_Not_Rate__c, blng__UsageSummary__r.Id
    //                                             FROM blng__Usage__c];
    //     System.assertEquals(
    //         0, 
    //         listUsageResult.size(), 
    //         'Given 3 usage Summaries (2 new status and 1 not New status) and 3 Usage Staging Tables; When The batch is Ran; '+
    //             'Then No Usages will be created because of a mis match of new Usage Summaries and Usage Staging Tables'
    //     );

    //     List<Usage_Staging_Table__c> listUsageStagingTableResult = [SELECT qtc_BatchLog__c FROM Usage_Staging_Table__c];
    //     for(Usage_Staging_Table__c thisUsageStagingTable : listUsageStagingTableResult){
    //         System.assertEquals(UsageStagingTableBatch.INVALID_MISMATCH_MESSAGE, thisUsageStagingTable.qtc_BatchLog__c, 'We expect the invalid mismatch messge to be populated' );
    //     }
    // }

    @isTest
    static void invocableAction_MultipleUsagePositive(){
        List<Order> listOrder = [SELECT Id,EffectiveDate, EndDate, qtc_Master_Customer_Number__c, AccountId FROM Order WHERE EffectiveDate = :START_DATE];
        List<OrderItem> listOrderItems = [SELECT Id, OrderId, Order.accountId, Order.EffectiveDate, Order.EndDate FROM OrderItem WHERE OrderId IN :listOrder];
     
        Id doNotRateOrder = listOrder[0].Id;
        List<blng__UsageSummary__c> listUsageSummaryToInsert = new List<blng__UsageSummary__c>();
        for( OrderItem thisOrderItem : listOrderItems){
         
            listUsageSummaryToInsert.add( new blng__UsageSummary__c(
                blng__Status__c = USAGE_SUMMARY_STATUS_NEW,
                blng__Account__c = thisOrderItem.Order.accountId,
                blng__Order__c = thisOrderItem.Order.Id,
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
                blng__OrderProduct__c = thisOrderItem.Id,
                blng__SummaryStartDate__c = thisOrderItem.Order.EffectiveDate,
                blng__SummaryEndDate__c = thisOrderItem.Order.EndDate
                
            ));
        }
        insert listUsageSummaryToInsert;
        for(blng__UsageSummary__c thisUsageSummary : listUsageSummaryToInsert ){
            if( thisUsageSummary.blng__Order__c == doNotRateOrder){
                thisUsageSummary.qtc_Do_Not_Rate__c = true;
            }
        }
        update listUsageSummaryToInsert;
     

        List<blng__UsageSummary__c> listRequeryUsageSummaryWithPaymentsConnected = 
            [   SELECT  Id, blng__MatchingId__c, blng__SummaryStartDate__c, blng__SummaryEndDate__c, 
                        blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c,
                        blng__OrderItemConsumptionSchedule__c
                FROM blng__UsageSummary__c
                WHERE Id IN :listUsageSummaryToInsert
                    AND blng__OrderProduct__r.Product2.ProductCode = :PRODUCT_CODE_PAYMENTS_CONNECTED ];

        List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
        for( blng__UsageSummary__c thisSummary : listRequeryUsageSummaryWithPaymentsConnected ){
            listUsageStagingTable.add( new Usage_Staging_Table__c(
                qtc_MasterCustomerNumber__c = thisSummary.blng__Order__r.qtc_Master_Customer_Number__c, 
                CurrencyIsoCode = 'USD',
                qtc_MatchingAttribute__c = 'testMatchingAtrribute1',
                qtc_MatchingId__c = thisSummary.blng__MatchingId__c,
                qtc_SummaryStartDate__c = thisSummary.blng__SummaryStartDate__c,
                qtc_SummaryEndDate__c = thisSummary.blng__SummaryEndDate__c,
                qtc_TotalQuantity__c  = 10,
                qtc_UsageSummaryId__c = String.valueOf( thisSummary.Id)
            ));
        }
        insert listUsageStagingTable;

        Test.startTest();
        List<UsageStagingTableBatchAction.ExecuteBatchResponse> batchResponses = UsageStagingTableBatchAction.executeBatchAction();
        Test.stopTest();
        for(UsageStagingTableBatchAction.ExecuteBatchResponse thisResponse : batchResponses){
            System.assertNotEquals(null, thisResponse.batchId, 'We expect the batch to be successfully invoked');
        }
    }
}