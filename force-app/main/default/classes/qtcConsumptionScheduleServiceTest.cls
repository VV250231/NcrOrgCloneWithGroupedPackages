@isTest
public with sharing class qtcConsumptionScheduleServiceTest {
    static  String  SLAB_FLAT_FEE = 'SLAB FLAT FEE',
                    SLAB_PER_UNIT = 'SLAB PER UNIT',
                    RANGE_FLAT_FEE = 'RANGE FLAT FEE',
                    RANGE_PER_UNIT = 'RANGE PER UNIT',
                    SLAB_MIXED = 'SLAB MIXED',
                    RATINGMETHOD_TIER = 'Tier',
                    TYPE_SLAB = 'Slab',
                    TYPE_RANGE = 'Range',
                    CATEGORY_RATES = 'RATES',
                    BILLING_TERM_UNIT_MONTH = 'Month',
                    OCCURRENCE_ALL = 'Occurrence - All',
                    STATUS_DRAFT = 'Draft',
                    SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER',
                    CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT = 'Connected Payments No Payments';
        
    @TestSetup
    static void setupData(){
        Account thisAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Project_Coordinator_Email__c = 'abc@test.com'
            );
        System.runAs(TestRecordsFactory.getUser()){
            insert thisAccount;
        }

        Contact testContact = new Contact(
            firstname = 'test',
            lastName = 'Contact 1',
            AccountId = thisAccount.id,
            MailingStreet = '123 fake st',
            MailingCity = 'atlanta',
            MailingState = 'GA',
            MailingPostalCode = '30303',
            MailingCountry = 'US',
            Email = 'Test@Email.com'
        );
        insert testContact;

        Opportunity thisOpportunity = new Opportunity(
            AccountID = thisAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
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

        blng__LegalEntity__c legalEntity = new blng__LegalEntity__c(

        );
        insert legalEntity;

        List<Product2> lstProducts = new List<Product2> ();
        lstProducts.add(new product2(   name='A', 
                                        family='Hardware',
                                        blng__BillingRule__c = billingRule.Id, 
                                        blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                        blng__TaxRule__c = taxrule.ID,
                                        ProductCode = 'TESTPRODUCT',
                                        product_type__c = 'Topline'
                                        ));
        insert lstProducts;

        Id stdPbId = Test.getStandardPricebookId();        

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = lstProducts[0].id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        ConsumptionSchedule testSchedule = new ConsumptionSchedule(
            Name = SLAB_FLAT_FEE,
            BillingTerm = 6,
            BillingTermUnit = BILLING_TERM_UNIT_MONTH,
            UnitOfMeasure  = OCCURRENCE_ALL,
            MatchingAttribute = 'Prereated',
            Type = TYPE_SLAB,
            RatingMethod = 'Tier'
        );
        List<ConsumptionSchedule> listConsumptionSchdules = new List<ConsumptionSchedule>{
            testSchedule
        };
        insert listConsumptionSchdules;

        List<ConsumptionRate> listConsumptionRates = new List<ConsumptionRate>();
        //oiSchedule Range Flat Fee
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 0,
            upperbound = 11,
            price = 9999,
            PricingMethod = 'FlatFee',
            processingOrder = 10,
            ConsumptionScheduleId = testSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 11,
            upperbound = 21,
            price = 999,
            PricingMethod = 'FlatFee',
            processingOrder = 20,
            ConsumptionScheduleId = testSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 21,
            upperbound = null,
            price = 99,
            PricingMethod = 'FlatFee',
            processingOrder = 30,
            ConsumptionScheduleId = testSchedule.Id
        ));

        insert listConsumptionRates;

        testSchedule.isActive  = true;
        update testSchedule;

        ProductConsumptionSchedule thisProductConsumptionSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = testSchedule.Id,
            ProductId = lstProducts[0].Id
        );
        insert thisProductConsumptionSchedule;
    
    }

    @isTest
    static void getRateByProduct_RangeFlatFeeTest(){
        Integer quantity1 = 5;
        Integer quantity2 = 15;
        Integer quantity3 = 45;

        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        ConsumptionSchedule thisSchedule = new ConsumptionSchedule(
            Name = CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT,
            qtc_F_F_Rating__c = true,
            BillingTerm = 6,
            BillingTermUnit = BILLING_TERM_UNIT_MONTH,
            UnitOfMeasure  = OCCURRENCE_ALL,
            Type = TYPE_RANGE,
            RatingMethod = 'Tier'
        );
        insert thisSchedule;

        List<ConsumptionRate> listConsumptionRates = new List<ConsumptionRate>();
        //oiSchedule Range Flat Fee
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 0,
            upperBound = 11,
            price = 50,
            pricingMethod = 'FlatFee',
            processingOrder = 10,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 11,
            upperBound = 21,
            price = 30,
            pricingMethod = 'FlatFee',
            processingOrder = 20,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 21,
            upperBound = null,
            price = 20,
            pricingMethod = 'FlatFee',
            processingOrder = 30,
            consumptionScheduleId = thisSchedule.Id
        ));
        insert listConsumptionRates;

        thisSchedule.isActive  = true;
        update thisSchedule;

        ProductConsumptionSchedule thisProductConsumptionSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = thisSchedule.Id,
            ProductId = thisProduct.Id
        );
        insert thisProductConsumptionSchedule;
       
        

        Set<Id> setProductIds = new Set<Id>{ thisProduct.Id};
        
        Test.startTest();
        qtcConsumptionScheduleService service = new qtcConsumptionScheduleService(setProductIds);
        Decimal rate1 = service.getRateByProduct(quantity1, thisProduct.Id);
        Decimal rate2 = service.getRateByProduct(quantity2, thisProduct.Id);
        Decimal rate3 = service.getRateByProduct(quantity3, thisProduct.Id);
        Test.stopTest();
        
        System.assertEquals( 50, rate1);
        System.assertEquals( 30, rate2);
        System.assertEquals( 20, rate3);
    }

    @isTest
    static void getRateByProduct_RangePerUnitTest(){
        Integer quantity1 = 5;
        Integer quantity2 = 15;
        Integer quantity3 = 45;

        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        ConsumptionSchedule thisSchedule = new ConsumptionSchedule(
            Name = CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT,
            qtc_F_F_Rating__c = true,
            BillingTerm = 6,
            BillingTermUnit = BILLING_TERM_UNIT_MONTH,
            UnitOfMeasure  = OCCURRENCE_ALL,
            Type = TYPE_RANGE,
            RatingMethod = 'Tier'
        );
        insert thisSchedule;

        List<ConsumptionRate> listConsumptionRates = new List<ConsumptionRate>();
        //oiSchedule Range Flat Fee
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 0,
            upperBound = 11,
            price = 50,
            pricingMethod = 'PerUnit',
            processingOrder = 10,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 11,
            upperBound = 21,
            price = 30,
            pricingMethod = 'PerUnit',
            processingOrder = 20,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 21,
            upperBound = null,
            price = 20,
            pricingMethod = 'PerUnit',
            processingOrder = 30,
            consumptionScheduleId = thisSchedule.Id
        ));
        insert listConsumptionRates;

        thisSchedule.isActive  = true;
        update thisSchedule;

        ProductConsumptionSchedule thisProductConsumptionSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = thisSchedule.Id,
            ProductId = thisProduct.Id
        );
        insert thisProductConsumptionSchedule;

        Set<Id> setProductIds = new Set<Id>{ thisProduct.Id};
        
        Test.startTest();
        qtcConsumptionScheduleService service = new qtcConsumptionScheduleService(setProductIds);
        Decimal rate1 = service.getRateByProduct(quantity1, thisProduct.Id);
        Decimal rate2 = service.getRateByProduct(quantity2, thisProduct.Id);
        Decimal rate3 = service.getRateByProduct(quantity3, thisProduct.Id);
        Test.stopTest();
        
        //quantity1 * 50
        System.assertEquals( 250, rate1);

        //quantity1 * 30
        System.assertEquals( 450, rate2);

        //quantity1 * 20
        System.assertEquals( 900, rate3);
    }

    @isTest
    static void getRateByProduct_SlabFlatFeeTest(){
        Integer quantity1 = 5;
        Integer quantity2 = 15;
        Integer quantity3 = 45;

        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        ConsumptionSchedule thisSchedule = new ConsumptionSchedule(
            Name = CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT,
            qtc_F_F_Rating__c = true,
            BillingTerm = 6,
            BillingTermUnit = BILLING_TERM_UNIT_MONTH,
            UnitOfMeasure  = OCCURRENCE_ALL,
            Type = TYPE_SLAB,
            RatingMethod = 'Tier'
        );
        insert thisSchedule;

        List<ConsumptionRate> listConsumptionRates = new List<ConsumptionRate>();
        //oiSchedule Range Flat Fee
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 0,
            upperBound = 11,
            price = 40,
            pricingMethod = 'FlatFee',
            processingOrder = 10,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 11,
            upperBound = 21,
            price = 30,
            pricingMethod = 'FlatFee',
            processingOrder = 20,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 21,
            upperBound = null,
            price = 20,
            pricingMethod = 'FlatFee',
            processingOrder = 30,
            consumptionScheduleId = thisSchedule.Id
        ));
        insert listConsumptionRates;

        thisSchedule.isActive  = true;
        update thisSchedule;

        ProductConsumptionSchedule thisProductConsumptionSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = thisSchedule.Id,
            ProductId = thisProduct.Id
        );
        insert thisProductConsumptionSchedule;

        Set<Id> setProductIds = new Set<Id>{ thisProduct.Id};
        
        Test.startTest();
        qtcConsumptionScheduleService service = new qtcConsumptionScheduleService(setProductIds);
        Decimal rate1 = service.getRateByProduct(quantity1, thisProduct.Id);
        Decimal rate2 = service.getRateByProduct(quantity2, thisProduct.Id);
        Decimal rate3 = service.getRateByProduct(quantity3, thisProduct.Id);
        Test.stopTest();
        
        // quatity 5: (qty 5 = rate 40 )
        System.assertEquals( 40, rate1);

        // quatity 15: (qty 10 = rate 40 )+ (qty 5 = rate 30)
        System.assertEquals( 70, rate2);

        // quatity 45: (qty 10 = rate 40) + (qty 10 = rate 30) + (qty 25 = rate 20)
        System.assertEquals( 90, rate3);
    }

    @isTest
    static void getRateByProduct_SlabPerUnitTest(){
        Integer quantity1 = 5;
        Integer quantity2 = 15;
        Integer quantity3 = 45;

        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        ConsumptionSchedule thisSchedule = new ConsumptionSchedule(
            Name = CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT,
            qtc_F_F_Rating__c = true,
            BillingTerm = 6,
            BillingTermUnit = BILLING_TERM_UNIT_MONTH,
            UnitOfMeasure  = OCCURRENCE_ALL,
            Type = TYPE_SLAB,
            RatingMethod = 'Tier'
        );
        insert thisSchedule;

        List<ConsumptionRate> listConsumptionRates = new List<ConsumptionRate>();
        //oiSchedule Range Flat Fee
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 0,
            upperBound = 11,
            price = 40,
            pricingMethod = 'PerUnit',
            processingOrder = 10,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 11,
            upperBound = 21,
            price = 30,
            pricingMethod = 'PerUnit',
            processingOrder = 20,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 21,
            upperBound = null,
            price = 20,
            pricingMethod = 'PerUnit',
            processingOrder = 30,
            consumptionScheduleId = thisSchedule.Id
        ));
        insert listConsumptionRates;

        thisSchedule.isActive  = true;
        update thisSchedule;

        ProductConsumptionSchedule thisProductConsumptionSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = thisSchedule.Id,
            ProductId = thisProduct.Id
        );
        insert thisProductConsumptionSchedule;

        Set<Id> setProductIds = new Set<Id>{ thisProduct.Id};
        
        Test.startTest();
        qtcConsumptionScheduleService service = new qtcConsumptionScheduleService(setProductIds);
        Decimal rate1 = service.getRateByProduct(quantity1, thisProduct.Id);
        Decimal rate2 = service.getRateByProduct(quantity2, thisProduct.Id);
        Decimal rate3 = service.getRateByProduct(quantity3, thisProduct.Id);
        Test.stopTest();
        
        // quatity 5: (qty 5 * rate 40 )
        System.assertEquals( 200, rate1);

        // quatity 15: (qty 10 * rate 40 )+ (qty 5 * rate 30)
        System.assertEquals( 550, rate2);

        // quatity 45: (qty 10 * rate 40) + (qty 10 * rate 30) + (qty 25 * rate 20)
        System.assertEquals( 1200, rate3);
    }

    @isTest
    static void getRateByProduct_SlabMixedTest(){
        Integer quantity1 = 5;
        Integer quantity2 = 15;
        Integer quantity3 = 45;

        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];

        ConsumptionSchedule thisSchedule = new ConsumptionSchedule(
            Name = CONSUMPTION_SCHEDULE_CONNECTED_PAYMENTS_NO_PAYMENT,
            qtc_F_F_Rating__c = true,
            BillingTerm = 6,
            BillingTermUnit = BILLING_TERM_UNIT_MONTH,
            UnitOfMeasure  = OCCURRENCE_ALL,
            Type = TYPE_SLAB,
            RatingMethod = 'Tier'
        );
        insert thisSchedule;

        List<ConsumptionRate> listConsumptionRates = new List<ConsumptionRate>();
        //oiSchedule Range Flat Fee
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 0,
            upperBound = 11,
            price = 50,
            pricingMethod = 'FlatFee',
            processingOrder = 10,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 11,
            upperBound = 21,
            price = 30,
            pricingMethod = 'FlatFee',
            processingOrder = 20,
            consumptionScheduleId = thisSchedule.Id
        ));
        listConsumptionRates.add( new ConsumptionRate(
            lowerbound = 21,
            upperBound = null,
            price = 20,
            pricingMethod = 'PerUnit',
            processingOrder = 30,
            consumptionScheduleId = thisSchedule.Id
        ));
        insert listConsumptionRates;

        thisSchedule.isActive  = true;
        update thisSchedule;

        ProductConsumptionSchedule thisProductConsumptionSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = thisSchedule.Id,
            ProductId = thisProduct.Id
        );
        insert thisProductConsumptionSchedule;

        Set<Id> setProductIds = new Set<Id>{ thisProduct.Id};
        
        Test.startTest();
        qtcConsumptionScheduleService service = new qtcConsumptionScheduleService(setProductIds);
        Decimal rate1 = service.getRateByProduct(quantity1, thisProduct.Id);
        Decimal rate2 = service.getRateByProduct(quantity2, thisProduct.Id);
        Decimal rate3 = service.getRateByProduct(quantity3, thisProduct.Id);
        Test.stopTest();
        
        // quatity 5: (qty 5 = rate 50 )
        System.assertEquals( 50, rate1);

        // quatity 15: (qty 10 = rate 50 )+ (qty 5 = rate 30)
        System.assertEquals( 80, rate2);

        // quatity 45: (qty 10 = rate 50) + (qty 10 = rate 30) + (qty 25 * rate 20)
        System.assertEquals( 580, rate3);
    }
}