@isTest
public with sharing class BillingCPQFormulaTriggerHandlerTest {
    @isTest
    static void beforeInsert_calculateQuoteLineTest(){
        Integer prorationDayOfMonth = 25;

        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            BillingMultiplier__c = 1,
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth )
        );
        insert testQuote;

        Product2 testProduct = new Product2( 
            Name ='Test Product',
            CurrencyIsoCode='USD',
            isactive=true, 
            Annuity_product__c = false, 
            CanUseQuantitySchedule = true
        );
        insert testProduct;
        
        String standardPriceBook = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry = new PricebookEntry(
            CurrencyIsoCode='USD', 
            Product2Id=testProduct.id,
            PriceBook2Id=standardPriceBook, 
            UnitPrice=15.00, 
            UseStandardPrice=false, 
            isactive = true
        );
        insert testPriceBookEntry;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
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
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__PricebookEntryId__c = testPriceBookEntry.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = testProduct.Id

        );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            insert testQuoteLine;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<SBQQ__QuoteLine__c> listQuoteLine = [SELECT SBQQ__NetPrice__c, SBQQ__ProrateMultiplier__c, BillingMultiplier__c FROM SBQQ__QuoteLine__c];
        System.assertEquals(1, listQuoteLine.size(), 'We expect only one quote line to be created');
        System.assertNotEquals(null, listQuoteLine[0].SBQQ__NetPrice__c, 'We expect this field to be populated from the trigger');
        System.assertNotEquals(null, listQuoteLine[0].SBQQ__ProrateMultiplier__c, 'We expect this field to be populated from the trigger');
        System.assertNotEquals(null, listQuoteLine[0].BillingMultiplier__c, 'We expect this field to be populated from the trigger');



    }

    

    @isTest
    static void beforeInsert_calculateQuoteLine_withDiscountScheduleTest(){
        Integer prorationDayOfMonth = 25;

        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            BillingMultiplier__c = 1,
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth )
        );
        insert testQuote;

        Product2 testProduct = new Product2( 
            Name ='Test Product',
            CurrencyIsoCode='USD',
            isactive=true, 
            Annuity_product__c = false, 
            CanUseQuantitySchedule = true
        );
        insert testProduct;
        
        String standardPriceBook = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry = new PricebookEntry(
            CurrencyIsoCode='USD', 
            Product2Id=testProduct.id,
            PriceBook2Id=standardPriceBook, 
            UnitPrice=15.00, 
            UseStandardPrice=false, 
            isactive = true
        );
        insert testPriceBookEntry;
        
        SBQQ__DiscountSchedule__c testDiscountSchedulable = new SBQQ__DiscountSchedule__c(
            Name = 'test Sechedulable',
            SBQQ__Type__c = 'Slab',
            SBQQ__DiscountUnit__c = 'Amount'
        );
        insert testDiscountSchedulable;
        
        List<SBQQ__DiscountTier__c> listDiscountTiers = new List<SBQQ__DiscountTier__c>();
        listDiscountTiers.add( new SBQQ__DiscountTier__c(
            Name = 'first discount',
            SBQQ__Schedule__c = testDiscountSchedulable.Id,
            SBQQ__LowerBound__c = 0,
            SBQQ__UpperBound__c = 2,
            SBQQ__DiscountAmount__c = 10
        ));
        listDiscountTiers.add( new SBQQ__DiscountTier__c(
            Name = 'second discount',
            SBQQ__Schedule__c = testDiscountSchedulable.Id,
            SBQQ__LowerBound__c = 2,
            SBQQ__DiscountAmount__c = 0
        ));
        insert listDiscountTiers;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
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
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__PricebookEntryId__c = testPriceBookEntry.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = testProduct.Id,
            SBQQ__DiscountSchedule__c = testDiscountSchedulable.Id

        );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            insert testQuoteLine;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<SBQQ__QuoteLine__c> listQuoteLine = [SELECT SBQQ__NetPrice__c, SBQQ__ProrateMultiplier__c, BillingMultiplier__c FROM SBQQ__QuoteLine__c];
        System.assertEquals(1, listQuoteLine.size(), 'We expect only one quote line to be created');
        System.assertNotEquals(null, listQuoteLine[0].SBQQ__NetPrice__c, 'We expect this field to be populated from the trigger');
        System.assertNotEquals(null, listQuoteLine[0].SBQQ__ProrateMultiplier__c, 'We expect this field to be populated from the trigger');
        System.assertNotEquals(null, listQuoteLine[0].BillingMultiplier__c, 'We expect this field to be populated from the trigger');



    }

    @isTest
    static void beforeInsert_setNetUnitAmend(){
        Integer prorationDayOfMonth = 25;

        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = TestRecordsFactory.createAccount('Test Account',Null);
        
        SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth )
        );
        insert masterQuote;

        Contract testContract = new Contract(
            StartDate = startDate,
            SBQQ__Quote__c = masterQuote.Id,
            AccountId=testAccount.Id);
        insert testContract;

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            SBQQ__MasterContract__c = testContract.Id,
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Amendment'
        );
        insert testQuote;

        Product2 testProduct = new Product2( 
            Name ='Test Product',
            CurrencyIsoCode='USD',
            isactive=true, 
            Annuity_product__c = false, 
            CanUseQuantitySchedule = true
        );
        insert testProduct;
        
        String standardPriceBook = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry = new PricebookEntry(
            CurrencyIsoCode='USD', 
            Product2Id=testProduct.id,
            PriceBook2Id=standardPriceBook, 
            UnitPrice=15.00, 
            UseStandardPrice=false, 
            isactive = true
        );
        insert testPriceBookEntry;
        
        SBQQ__DiscountSchedule__c testDiscountSchedulable = new SBQQ__DiscountSchedule__c(
            Name = 'test Sechedulable',
            SBQQ__Type__c = 'Slab',
            SBQQ__DiscountUnit__c = 'Amount'
        );
        insert testDiscountSchedulable;
        
        List<SBQQ__DiscountTier__c> listDiscountTiers = new List<SBQQ__DiscountTier__c>();
        listDiscountTiers.add( new SBQQ__DiscountTier__c(
            Name = 'first discount',
            SBQQ__Schedule__c = testDiscountSchedulable.Id,
            SBQQ__LowerBound__c = 0,
            SBQQ__UpperBound__c = 2,
            SBQQ__DiscountAmount__c = 10
        ));
        listDiscountTiers.add( new SBQQ__DiscountTier__c(
            Name = 'second discount',
            SBQQ__Schedule__c = testDiscountSchedulable.Id,
            SBQQ__LowerBound__c = 2,
            SBQQ__DiscountAmount__c = 0
        ));
        insert listDiscountTiers;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
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
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__PricebookEntryId__c = testPriceBookEntry.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = testProduct.Id,
            SBQQ__DiscountSchedule__c = testDiscountSchedulable.Id

        );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            insert testQuoteLine;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<SBQQ__QuoteLine__c> listQuoteLine = [SELECT qtc_NetUnitAmend__c, SBQQ__NetPrice__c, SBQQ__ProrateMultiplier__c, BillingMultiplier__c FROM SBQQ__QuoteLine__c];
        System.assertEquals(1, listQuoteLine.size(), 'We expect only one quote line to be created');
        System.assertNotEquals(null, listQuoteLine[0].qtc_NetUnitAmend__c, 'We expect this field to be populated from the trigger');

    }

    @isTest
    static void beforeInsert_setNetUnitAmend_PassThrough(){
        Integer prorationDayOfMonth = 25;

        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = TestRecordsFactory.createAccount('Test Account',Null);
        
        SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth )
        );
        insert masterQuote;

        Contract testContract = new Contract(
            StartDate = startDate,
            SBQQ__Quote__c = masterQuote.Id,
            AccountId=testAccount.Id);
        insert testContract;

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            SBQQ__MasterContract__c = testContract.Id,
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Amendment'
        );
        insert testQuote;

        Product2 testProduct = new Product2( 
            Name ='Test Product',
            CurrencyIsoCode='USD',
            isactive=true, 
            Annuity_product__c = false, 
            CanUseQuantitySchedule = true
        );
        insert testProduct;
        
        String standardPriceBook = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry = new PricebookEntry(
            CurrencyIsoCode='USD', 
            Product2Id=testProduct.id,
            PriceBook2Id=standardPriceBook, 
            UnitPrice=15.00, 
            UseStandardPrice=false, 
            isactive = true
        );
        insert testPriceBookEntry;
        
        SBQQ__DiscountSchedule__c testDiscountSchedulable = new SBQQ__DiscountSchedule__c(
            Name = 'test Sechedulable',
            SBQQ__Type__c = 'Slab',
            SBQQ__DiscountUnit__c = 'Amount'
        );
        insert testDiscountSchedulable;
        
        List<SBQQ__DiscountTier__c> listDiscountTiers = new List<SBQQ__DiscountTier__c>();
        listDiscountTiers.add( new SBQQ__DiscountTier__c(
            Name = 'first discount',
            SBQQ__Schedule__c = testDiscountSchedulable.Id,
            SBQQ__LowerBound__c = 0,
            SBQQ__UpperBound__c = 2,
            SBQQ__DiscountAmount__c = 10
        ));
        listDiscountTiers.add( new SBQQ__DiscountTier__c(
            Name = 'second discount',
            SBQQ__Schedule__c = testDiscountSchedulable.Id,
            SBQQ__LowerBound__c = 2,
            SBQQ__DiscountAmount__c = 0
        ));
        insert listDiscountTiers;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
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
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__PricebookEntryId__c = testPriceBookEntry.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = testProduct.Id,
            SBQQ__DiscountSchedule__c = testDiscountSchedulable.Id,
            qtc_Pass_Through__c = true

        );

        Test.startTest();
            SBQQ.TriggerControl.disable();
            insert testQuoteLine;
            SBQQ.TriggerControl.enable();
        Test.stopTest();

        List<SBQQ__QuoteLine__c> listQuoteLine = [SELECT qtc_NetUnitAmend__c, SBQQ__NetPrice__c, SBQQ__ProrateMultiplier__c, BillingMultiplier__c FROM SBQQ__QuoteLine__c];
        System.assertEquals(1, listQuoteLine.size(), 'We expect only one quote line to be created');
        System.assertEquals(0, listQuoteLine[0].qtc_NetUnitAmend__c, 'We expect this field to be set to 0');

    }
}