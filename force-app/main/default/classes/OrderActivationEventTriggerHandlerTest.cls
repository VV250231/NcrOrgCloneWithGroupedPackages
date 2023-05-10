@isTest
public with sharing class OrderActivationEventTriggerHandlerTest {
    static String   STATUS_DRAFT = 'Draft',
                    SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER';
    static Date     START_DATE = Date.today(),
                    END_DATE = START_DATE.addDays(25);
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;

    
    @TestSetup
    static void setupData(){
       
        
        Account thisAccount = new Account(name = 'ContractTestAccount',
                        LOB__c = 'FINANCIAL',
                        // MDM_Data_Source_Code__c='SF',
                        Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
                        Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                        Active_Account__c = true,
                        Project_Coordinator_Email__c = 'abc@test.com',
                         CDM_Account_Status__c = 'Active'
                                         );
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
            SBQQ__Primary__c = true
        );
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
        
        List<Product2> lstProducts = new List<Product2>();
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
        
        Order thisOrder = new order(    Pricebook2Id = stdPbId, 
                                        AccountId = thisAccount.id, 
                                        Status = STATUS_DRAFT, 
                                        EffectiveDate = Date.Today(), 
                                        blng__BillingDayOfMonth__c = '28',
                                        qtc_Bill_To_Site__c = thisAccount.Id,
                                        Deliver_To_Site__c = thisAccount.Id,
                                        SBQQ__Quote__c = thisQuote.Id);
        insert thisOrder;
        
        OrderItem thisOrderProduct = new OrderItem(     PriceBookEntryId = standardPrice.Id, 
                                                        OrderId = thisOrder.Id, 
                                                        Quantity = 1, 
                                                        SBQQ__OrderedQuantity__c = 1, 
                                                        UnitPrice = standardPrice.UnitPrice, 
                                                        SBQQ__ChargeType__c = 'One-Time',
                                                        ServiceDate = Date.Today());
        insert thisOrderProduct;
    }

    @isTest
    static void triggerHandler_PriceCalcCompleted_PositiveTest(){
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        testOrder.SBQQ__PriceCalcStatus__c = 'Completed';
        SBQQ.TriggerControl.disable();
        update testOrder;
        SBQQ.TriggerControl.enable();
        List<qtcOrderActivation__e> listEvents = new List<qtcOrderActivation__e>();
        qtcOrderActivation__e event = new qtcOrderActivation__e(
            qtcOrderId__c = testOrder.Id
        );
        listEvents.add( event );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            OrderActivationEventTriggerHandler triggerHandler = new OrderActivationEventTriggerHandler( listEvents, null);
            triggerHandler.handleAfterInsert();
            SBQQ.TriggerControl.enable();
        Test.stopTest();
        Order resultOrder = [SELECT Id, status FROM Order LIMIT 1];
        System.assertEquals('Activated', resultOrder.status, 'We expect the order status to be updated to Activated');
        System.assertEquals(1, triggerHandler.listContractOrderEvents.size(), 'We expect a contract order event to be added to this list');

    }

    @isTest
    static void triggerHandler_PriceCalcNotNeeded_PositiveTest(){
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        testOrder.SBQQ__PriceCalcStatus__c = 'Not Needed';
        SBQQ.TriggerControl.disable();
        update testOrder;
        SBQQ.TriggerControl.enable();
        List<qtcOrderActivation__e> listEvents = new List<qtcOrderActivation__e>();
        qtcOrderActivation__e event = new qtcOrderActivation__e(
            qtcOrderId__c = testOrder.Id
        );
        listEvents.add( event );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            OrderActivationEventTriggerHandler triggerHandler = new OrderActivationEventTriggerHandler( listEvents, null);
            triggerHandler.handleAfterInsert();
            SBQQ.TriggerControl.enable();
        Test.stopTest();
        Order resultOrder = [SELECT Id, status FROM Order LIMIT 1];
        System.assertEquals('Activated', resultOrder.status, 'We expect the order status to be updated to Activated');
        System.assertEquals(1, triggerHandler.listContractOrderEvents.size(), 'We expect a contract order event to be added to this list');

    }

    @isTest
    static void triggerHandler_PriceCalcQueued_NegativeTest(){
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        testOrder.SBQQ__PriceCalcStatus__c = 'Queued';
        SBQQ.TriggerControl.disable();
        update testOrder;
        SBQQ.TriggerControl.enable();
        List<qtcOrderActivation__e> listEvents = new List<qtcOrderActivation__e>();
        qtcOrderActivation__e event = new qtcOrderActivation__e(
            qtcOrderId__c = testOrder.Id,
            qtcRetryAttempt__c = 0 
        );
        listEvents.add( event );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            OrderActivationEventTriggerHandler triggerHandler = new OrderActivationEventTriggerHandler( listEvents, null);
            triggerHandler.handleAfterInsert();
            SBQQ.TriggerControl.enable();
        Test.stopTest();
        Order resultOrder = [SELECT Id, status FROM Order LIMIT 1];
        System.assertEquals(STATUS_DRAFT, resultOrder.status, 'We expect the order status to remain the same');

        System.assertEquals(1, triggerHandler.listOrderActivationEventsToRepublish.size(), 'We expect an event to be added to this list to republish the event');
        System.assertEquals(1, triggerHandler.listOrderActivationEventsToRepublish[0].qtcRetryAttempt__c, 'We expect the retry attempt to increment by 1');

        System.assertEquals(0, triggerHandler.listContractOrderEvents.size(), 'We expect no event to be added to this list for contracting');

    }

    @isTest
    static void triggerHandler_exceedFiveAttempts_NegativeTest(){
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        testOrder.SBQQ__PriceCalcStatus__c = 'Queued';
        SBQQ.TriggerControl.disable();
        update testOrder;
        SBQQ.TriggerControl.enable();
        List<qtcOrderActivation__e> listEvents = new List<qtcOrderActivation__e>();
        qtcOrderActivation__e event = new qtcOrderActivation__e(
            qtcOrderId__c = testOrder.Id,
            qtcRetryAttempt__c = 5 
        );
        listEvents.add( event );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            OrderActivationEventTriggerHandler triggerHandler = new OrderActivationEventTriggerHandler( listEvents, null);
            triggerHandler.handleAfterInsert();
            SBQQ.TriggerControl.enable();
        Test.stopTest();
        Order resultOrder = [SELECT Id, status FROM Order LIMIT 1];
        System.assertEquals(STATUS_DRAFT, resultOrder.status, 'We expect the order status to remain the same');

        System.assertEquals(0, triggerHandler.listOrderActivationEventsToRepublish.size(), 'We expect No event to be added to this list to republish the event');

        System.assertEquals(0, triggerHandler.listContractOrderEvents.size(), 'We expect no event to be added to this list for contracting');

    }



    @isTest
    static void afterInsert_PriceCalcCompleted_PositiveTest(){
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        testOrder.SBQQ__PriceCalcStatus__c = 'Completed';
        SBQQ.TriggerControl.disable();
        update testOrder;
        SBQQ.TriggerControl.enable();
        List<qtcOrderActivation__e> listEvents = new List<qtcOrderActivation__e>();
        qtcOrderActivation__e event = new qtcOrderActivation__e(
            qtcOrderId__c = testOrder.Id
        );
        listEvents.add( event );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            List<Database.SaveResult> results = EventBus.publish(listEvents);
            Test.getEventBus().deliver();
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        Order resultOrder = [SELECT Id, status FROM Order LIMIT 1];
        System.assertEquals('Activated', resultOrder.status, 'We expect the order status to be updated to Activated');

    }
}