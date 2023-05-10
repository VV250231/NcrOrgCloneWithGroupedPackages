@isTest
public with sharing class qtcOrderActivationBatchTest {
    static String   STATUS_DRAFT = 'Draft',
                    CHANNEL_PARTNER = 'PARTNER',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER';
    static Date     START_DATE = Date.today(),
                    END_DATE = START_DATE.addDays(25);
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;

    static String   SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
        USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage',
        EXPECTED_QUOTE_NAME = 'test quote name',
        EXPECTED_SALES_ORG_CODE= 'salesOrgCode',
        EXPECTED_PO_NUMBER = 'poNumber',
        EXPECTED_ERP_QUOTE_TYPE = 'erpQuoteType',
        EXPECTED_ORDER_SOURCE = 'orderSource',
        EXPECTED_PAYMENT_TERM = 'Net 30',
        EXPECTED_ALOHA_KEY = 'newAlohaKey',
        EXPECTED_CONVERSION_TYPE = 'conversionType',
        EXPECTED_CIS = 'CISValue',
        EXPECTED_CDP = 'CDPValue',
        EXPECTED_PACKING_INSTRUCTIONS = 'Packing Instructions',
        EXPECTED_HARDWARE_ROLE = 'Hardware Role',
        EXPECTED_PRODUCTID = 'MDM product Id',
        EXPECTED_SOFTWARE_MEDIA_SET = 'Software Media Set',
        EXPECTED_SOFTWARE_RELEASE_NUMBER = 'Software Release Number',
        EXPECTED_SOFTWARE_SYSTEM = 'Software System Name',
        EXPECTED_DELIVERY_ID = 'Delivery Id';
    static Integer  EXPECTED_SEQUENCE_NUMBER = 1234,
        EXPECTED_QTY_TO_SHIP = 88;
    static Date     EXPECTED_ERP_ESTIMATED_SHIP_DATE = Date.today().addDays(10),
        EXPECTED_CUSTOMER_PO_DATE = Date.today().addDays(30),
        EXPECTED_PROMISE_DATE = Date.today().addDays(20),
        // EXPECTED_SW_START_DATE = String.valueOf(Date.today()), 
        // EXPECTED_SW_END_DATE = String.valueOf(Date.today().addDays(60)), 
        EXPECTED_COMPLETION_DATE_SHIPMENT_DATE = Date.today().addDays(50),
        EXPECTED_SCHEDULED_SHIP_DATE = Date.today().addDays(55);

    @isTest 
    static void batch_orderStartLastMonth_positiveTest(){
        Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Id stdPbId = Test.getStandardPricebookId();        

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            CDM_Account_Type__c=CHANNEL_PARTNER,
            CDM_Account_Status__c = 'Active',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        Account deliverToSite;

        System.runAs(TestRecordsFactory.getUser()){
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            
            insert deliverToSite;
        }

        Opportunity thisOpportunity = new Opportunity(
            AccountID = testAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= testAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Pricebook2Id = stdPbId,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            qtc_Ordered_Custom__c = false, 
            qtc_Channel_Local_Office_Record_Type__c = CHANNEL_PARTNER,
            SBQQ__Opportunity2__c = thisOpportunity.Id, 
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Payments_Type__c = 'No Payments',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false,
            qtc_Legal_Document_Status__c='Sent for Signature');
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
            blng__Active__c = TRUE
        );
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
        insert lstProducts;

       
        List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
        for( Product2 thisProduct: lstProducts ){
            listPricebookEntries.add( 
                new PricebookEntry(
                    Pricebook2Id = stdPbId, 
                    Product2Id = thisProduct.id, 
                    UnitPrice = 100, 
                    UseStandardPrice = false,
                    IsActive = true)
            );
        }
   
        insert listPricebookEntries;

        SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            SBQQ__OptionLevel__c = 1,
            //qtc_MRR__c = 0,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__PricebookEntryId__c = listPricebookEntries[0].Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listPricebookEntries[0].Product2Id,
            SBQQ__ChargeType__c = 'Recurring',

            qtc_Hardware_Role__c = EXPECTED_HARDWARE_ROLE,
            // atc_SW_Key_Start_Date__c = EXPECTED_SW_START_DATE, 
            // qtc_SW_Key_End_Date__c = EXPECTED_SW_END_DATE, 
            // qtc_QTY__c
            // qtc_Software Not Ship_Qty
            qtc_Software_Media_Set__c = EXPECTED_SOFTWARE_MEDIA_SET,
            qtc_Software_Release_Number__c = EXPECTED_SOFTWARE_RELEASE_NUMBER,
            // qtc_Product_Code__c = EXPECTED_PRODUCT_CODE,
            // qtc_Sub_Package_ID__c = EXPECTED_SUB_PACKAGE_ID,
            qtc_Software_System_Name__c = EXPECTED_SOFTWARE_SYSTEM
            
        );
        insert positiveQuoteLine;

        thisOpportunity.SBQQ__PrimaryQuote__c = thisQuote.Id;
        update thisOpportunity;

        qtc_FulfillmentOrder__c fulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = thisQuote.Id,
            qtc_OrderStartDate__c = Date.today().addMonths( -1 )
        );
        insert fulfillmentOrder;

        Test.startTest();
            CPQMyNcrRequestAsync.bypassQuoteTrigger = true;
       
            qtcOrderActivationBatch testBatch = new qtcOrderActivationBatch();
            Id batchId = Database.executeBatch( testBatch );
         
        Test.stopTest();

        SBQQ__Quote__c resultQuote = [SELECT Id, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id = :thisQuote.Id];
        SYstem.assertEquals( true, resultQuote.qtc_Ordered_Custom__c, 'We expect the ordered field to be set to true');
    }

    @isTest 
    static void batch_orderStartThisMonth_negativeTest(){
        Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Id stdPbId = Test.getStandardPricebookId();        

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            CDM_Account_Type__c=CHANNEL_PARTNER,
            CDM_Account_Status__c = 'Active',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        Account deliverToSite;

        System.runAs(TestRecordsFactory.getUser()){
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            
            insert deliverToSite;
        }

        Opportunity thisOpportunity = new Opportunity(
            AccountID = testAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= testAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Pricebook2Id = stdPbId,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            qtc_Ordered_Custom__c = false, 
            qtc_Channel_Local_Office_Record_Type__c = CHANNEL_PARTNER,
            SBQQ__Opportunity2__c = thisOpportunity.Id, 
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Payments_Type__c = 'No Payments',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false,
            qtc_Legal_Document_Status__c='Sent for Signature');
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
            blng__Active__c = TRUE
        );
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
        insert lstProducts;

       
        List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
        for( Product2 thisProduct: lstProducts ){
            listPricebookEntries.add( 
                new PricebookEntry(
                    Pricebook2Id = stdPbId, 
                    Product2Id = thisProduct.id, 
                    UnitPrice = 100, 
                    UseStandardPrice = false,
                    IsActive = true)
            );
        }
   
        insert listPricebookEntries;

        SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            SBQQ__OptionLevel__c = 1,
            //qtc_MRR__c = 0,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__PricebookEntryId__c = listPricebookEntries[0].Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listPricebookEntries[0].Product2Id,
            SBQQ__ChargeType__c = 'Recurring',

            qtc_Hardware_Role__c = EXPECTED_HARDWARE_ROLE,
            // atc_SW_Key_Start_Date__c = EXPECTED_SW_START_DATE, 
            // qtc_SW_Key_End_Date__c = EXPECTED_SW_END_DATE, 
            // qtc_QTY__c
            // qtc_Software Not Ship_Qty
            qtc_Software_Media_Set__c = EXPECTED_SOFTWARE_MEDIA_SET,
            qtc_Software_Release_Number__c = EXPECTED_SOFTWARE_RELEASE_NUMBER,
            // qtc_Product_Code__c = EXPECTED_PRODUCT_CODE,
            // qtc_Sub_Package_ID__c = EXPECTED_SUB_PACKAGE_ID,
            qtc_Software_System_Name__c = EXPECTED_SOFTWARE_SYSTEM
            
        );
        insert positiveQuoteLine;

        thisOpportunity.SBQQ__PrimaryQuote__c = thisQuote.Id;
        update thisOpportunity;

        qtc_FulfillmentOrder__c fulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = thisQuote.Id,
            qtc_OrderStartDate__c = Date.today().toStartOfMonth().addDays(5)
        );
        insert fulfillmentOrder;

        Test.startTest();
            CPQMyNcrRequestAsync.bypassQuoteTrigger = true;
       
            qtcOrderActivationBatch testBatch = new qtcOrderActivationBatch();
            Id batchId = Database.executeBatch( testBatch );
         
        Test.stopTest();

        SBQQ__Quote__c resultQuote = [SELECT Id, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id = :thisQuote.Id];
        System.assertEquals( false, resultQuote.qtc_Ordered_Custom__c, 'We expect the quote to not be ordered');
    }

    @isTest 
    static void invocableAction_orderStartLastMonth_positiveTest(){
        Integer prorationDayOfMonth = 25;
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Id stdPbId = Test.getStandardPricebookId();        

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            CDM_Account_Type__c=CHANNEL_PARTNER,
            CDM_Account_Status__c = 'Active',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        Account deliverToSite;

        System.runAs(TestRecordsFactory.getUser()){
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            
            insert deliverToSite;
        }

        Opportunity thisOpportunity = new Opportunity(
            AccountID = testAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= testAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Pricebook2Id = stdPbId,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            qtc_Ordered_Custom__c = false, 
            qtc_Channel_Local_Office_Record_Type__c = CHANNEL_PARTNER,
            SBQQ__Opportunity2__c = thisOpportunity.Id, 
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Payments_Type__c = 'No Payments',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false,
            qtc_Legal_Document_Status__c='Sent for Signature');
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
            blng__Active__c = TRUE
        );
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
        insert lstProducts;

        
        List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
        for( Product2 thisProduct: lstProducts ){
            listPricebookEntries.add( 
                new PricebookEntry(
                    Pricebook2Id = stdPbId, 
                    Product2Id = thisProduct.id, 
                    UnitPrice = 100, 
                    UseStandardPrice = false,
                    IsActive = true)
            );
        }
    
        insert listPricebookEntries;

        SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            SBQQ__OptionLevel__c = 1,
            //qtc_MRR__c = 0,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__PricebookEntryId__c = listPricebookEntries[0].Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listPricebookEntries[0].Product2Id,
            SBQQ__ChargeType__c = 'Recurring',

            qtc_Hardware_Role__c = EXPECTED_HARDWARE_ROLE,
            // atc_SW_Key_Start_Date__c = EXPECTED_SW_START_DATE, 
            // qtc_SW_Key_End_Date__c = EXPECTED_SW_END_DATE, 
            // qtc_QTY__c
            // qtc_Software Not Ship_Qty
            qtc_Software_Media_Set__c = EXPECTED_SOFTWARE_MEDIA_SET,
            qtc_Software_Release_Number__c = EXPECTED_SOFTWARE_RELEASE_NUMBER,
            // qtc_Product_Code__c = EXPECTED_PRODUCT_CODE,
            // qtc_Sub_Package_ID__c = EXPECTED_SUB_PACKAGE_ID,
            qtc_Software_System_Name__c = EXPECTED_SOFTWARE_SYSTEM
            
        );
        insert positiveQuoteLine;

        thisOpportunity.SBQQ__PrimaryQuote__c = thisQuote.Id;
        update thisOpportunity;

        qtc_FulfillmentOrder__c fulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = thisQuote.Id,
            qtc_OrderStartDate__c = Date.today().addMonths( -1 )
        );
        insert fulfillmentOrder;

        Test.startTest();
            CPQMyNcrRequestAsync.bypassQuoteTrigger = true;
            List<qtcOrderActivationBatchAction.ExecutebatchRequest> listRequest = new List<qtcOrderActivationBatchAction.ExecutebatchRequest>();
            qtcOrderActivationBatchAction.ExecutebatchRequest request = new qtcOrderActivationBatchAction.ExecutebatchRequest();
            request.batchSize = 200;
            listRequest.add( request );
        
            List<qtcOrderActivationBatchAction.ExecuteBatchResponse> batchResponses = qtcOrderActivationBatchAction.executeBatchAction(listRequest);
            
        Test.stopTest();

        SBQQ__Quote__c resultQuote = [SELECT Id, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id = :thisQuote.Id];
        SYstem.assertEquals( true, resultQuote.qtc_Ordered_Custom__c, 'We expect the ordered field to be set to true');
    }


    @isTest 
    static void batch_orderStartBeginingOfMonth_positiveTest(){
        Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Id stdPbId = Test.getStandardPricebookId();        

        Date startDate = Date.today().toStartOfMonth();
        Account testAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            CDM_Account_Type__c=CHANNEL_PARTNER,
            CDM_Account_Status__c = 'Active',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        Account deliverToSite;

        System.runAs(TestRecordsFactory.getUser()){
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            
            insert deliverToSite;
        }

        Opportunity thisOpportunity = new Opportunity(
            AccountID = testAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= testAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Pricebook2Id = stdPbId,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            qtc_Ordered_Custom__c = false, 
            qtc_Channel_Local_Office_Record_Type__c = CHANNEL_PARTNER,
            SBQQ__Opportunity2__c = thisOpportunity.Id, 
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Payments_Type__c = 'No Payments',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false,
            qtc_Legal_Document_Status__c='Sent for Signature');
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
            blng__Active__c = TRUE
        );
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
        insert lstProducts;

       
        List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
        for( Product2 thisProduct: lstProducts ){
            listPricebookEntries.add( 
                new PricebookEntry(
                    Pricebook2Id = stdPbId, 
                    Product2Id = thisProduct.id, 
                    UnitPrice = 100, 
                    UseStandardPrice = false,
                    IsActive = true)
            );
        }
   
        insert listPricebookEntries;

        SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            SBQQ__OptionLevel__c = 1,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__PricebookEntryId__c = listPricebookEntries[0].Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listPricebookEntries[0].Product2Id,
            SBQQ__ChargeType__c = 'Recurring',
            qtc_Hardware_Role__c = EXPECTED_HARDWARE_ROLE,
            qtc_Software_Media_Set__c = EXPECTED_SOFTWARE_MEDIA_SET,
            qtc_Software_Release_Number__c = EXPECTED_SOFTWARE_RELEASE_NUMBER,
            qtc_Software_System_Name__c = EXPECTED_SOFTWARE_SYSTEM
            
        );
        insert positiveQuoteLine;

        thisOpportunity.SBQQ__PrimaryQuote__c = thisQuote.Id;
        update thisOpportunity;

        qtc_FulfillmentOrder__c fulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = thisQuote.Id,
            qtc_OrderStartDate__c = startDate
        );
        insert fulfillmentOrder;

        Test.startTest();
            CPQMyNcrRequestAsync.bypassQuoteTrigger = true;
       
            qtcOrderActivationBatch testBatch = new qtcOrderActivationBatch();
            Id batchId = Database.executeBatch( testBatch );
         
        Test.stopTest();

        SBQQ__Quote__c resultQuote = [SELECT Id, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id = :thisQuote.Id];
        SYstem.assertEquals( true, resultQuote.qtc_Ordered_Custom__c, 'We expect the ordered field to be set to true');
    }

    @isTest 
    static void batch_orderStartBeginingOfMonth_negativeTest(){
        Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Id stdPbId = Test.getStandardPricebookId();        

        Date startDate = Date.today().toStartOfMonth().addDays(1);
        Account testAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            CDM_Account_Type__c=CHANNEL_PARTNER,
            CDM_Account_Status__c = 'Active',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        Account deliverToSite;

        System.runAs(TestRecordsFactory.getUser()){
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            
            insert deliverToSite;
        }

        Opportunity thisOpportunity = new Opportunity(
            AccountID = testAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= testAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Pricebook2Id = stdPbId,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            qtc_Ordered_Custom__c = false, 
            qtc_Channel_Local_Office_Record_Type__c = CHANNEL_PARTNER,
            SBQQ__Opportunity2__c = thisOpportunity.Id, 
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Payments_Type__c = 'No Payments',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false,
            qtc_Legal_Document_Status__c='Sent for Signature');
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
            blng__Active__c = TRUE
        );
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
        insert lstProducts;

       
        List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
        for( Product2 thisProduct: lstProducts ){
            listPricebookEntries.add( 
                new PricebookEntry(
                    Pricebook2Id = stdPbId, 
                    Product2Id = thisProduct.id, 
                    UnitPrice = 100, 
                    UseStandardPrice = false,
                    IsActive = true)
            );
        }
   
        insert listPricebookEntries;

        SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            SBQQ__OptionLevel__c = 1,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__PricebookEntryId__c = listPricebookEntries[0].Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listPricebookEntries[0].Product2Id,
            SBQQ__ChargeType__c = 'Recurring',
            qtc_Hardware_Role__c = EXPECTED_HARDWARE_ROLE,
            qtc_Software_Media_Set__c = EXPECTED_SOFTWARE_MEDIA_SET,
            qtc_Software_Release_Number__c = EXPECTED_SOFTWARE_RELEASE_NUMBER,
            qtc_Software_System_Name__c = EXPECTED_SOFTWARE_SYSTEM
            
        );
        insert positiveQuoteLine;

        thisOpportunity.SBQQ__PrimaryQuote__c = thisQuote.Id;
        update thisOpportunity;

        qtc_FulfillmentOrder__c fulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = thisQuote.Id,
            qtc_OrderStartDate__c = startDate
        );
        insert fulfillmentOrder;

        Test.startTest();
            CPQMyNcrRequestAsync.bypassQuoteTrigger = true;
       
            qtcOrderActivationBatch testBatch = new qtcOrderActivationBatch();
            Id batchId = Database.executeBatch( testBatch );
         
        Test.stopTest();

        SBQQ__Quote__c resultQuote = [SELECT Id, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id = :thisQuote.Id];
        SYstem.assertEquals( false, resultQuote.qtc_Ordered_Custom__c, 'We expect the ordered field remain the same');
    }
}