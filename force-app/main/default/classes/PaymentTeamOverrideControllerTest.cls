@isTest
public with sharing class PaymentTeamOverrideControllerTest {
    static String PRODUCT_CODE_REVENUE_PER_TRANSACTION = 'RevenuePerTransaction';

    @TestSetup
    static void setupData(){
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);

        Account thisAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = 'SETUPMASTERCONTRACT',
            Account_Country_Code__c = 'US', 
            CurrencyIsoCode = 'USD',
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

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            qtc_Payment_Team_Override__c = false
        );
        SBQQ.TriggerControl.disable();
        insert testQuote;
        SBQQ.TriggerControl.enable();

        Product2 testProduct = new Product2( 
            Name ='Test Product',
            CurrencyIsoCode='USD',
            isactive=true, 
            ProductCode = PRODUCT_CODE_REVENUE_PER_TRANSACTION,
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
            SBQQ__Quote__c = testQuote.Id,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            qtc_Product_Type__c = 'SW Only',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
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
        insert testQuoteLine;
    }
    @isTest
    static void getQuoteLineTest(){
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c expectedQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :testQuote.id LIMIT 1];

        Test.startTest();
            SBQQ__QuoteLine__c result = PaymentTeamOverrideController.getQuoteLine(testQuote.Id);
        Test.stopTest();
        System.assertEquals(expectedQuoteLine.id, result.Id, 'We expect the quote line related to the quote to be returned');
    }

    @isTest
    static void commitQuoteLineTest(){
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c expectedQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :testQuote.id LIMIT 1];

        Double expectedValue = 8888;
        Test.startTest();
            String result = PaymentTeamOverrideController.commitQuoteLine(testQuote.Id, expectedQuoteLine.Id, expectedValue);
        Test.stopTest();
        System.assertEquals('SUCCESS', result, 'We expect the return of the method to be SUCCESS');
        SBQQ__QuoteLine__c resultQuoteLine = [SELECT Id, SBQQ__ListPrice__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :testQuote.id LIMIT 1];
        System.assertEquals(expectedValue, resultQuoteLine.SBQQ__ListPrice__c, 'We expect the quote line List price field to update');

        SBQQ__Quote__c resultQuote = [SELECT Id, qtc_Payment_Team_Override__c FROM SBQQ__Quote__c LIMIT 1];
        System.assertEquals( true, resultQuote.qtc_Payment_Team_Override__c, 'We expect the Payment Team Override field to be set to true');
    }
}