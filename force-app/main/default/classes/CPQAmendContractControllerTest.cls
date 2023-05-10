/**
* This class reposible for test CPQAmendContractController.apxc class
* 
* */
@isTest
public class CPQAmendContractControllerTest {
    
    private static Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();
    private static String   BILLING_FREQUENCY_MONTHLY       = 'Monthly',
        TYPE_AMENDMENT                  = 'Amendment',MULTI_SITE_TYPE_AE_PP           = 'AE+PP',
        MULTI_SITE_RELATIONSHIP_PARENT  = 'Parent',PAYMENT_TYPE_NO_PAYMENT         = 'No Payments';
    
    
    @isTest 
    static void amendContractTest(){
        Account thisAccount = TestRecordsFactory.createAccount();
        Account channelAccount = new Account(
            Name='Test Company Name123',
            Account_Country_Code__c = 'US',
            LOB__c='HOSPITALITY',
            Active_Account__c = true,
            CDM_Account_Type__c='LOCAL OFFICE',
            CDM_Account_Status__c = 'Active',
            //CDM_Sub_Account_Type__c = 'LOCAL OFFICE',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com');
        insert channelAccount;
        
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account testAccount = new Account(
            RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
            Name='Test Company Name123',
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            ParentId = thisAccount.Id,
            CDM_Account_Type__c = 'Site');
        System.runAs( Usr ){
            insert testAccount;
        }
        
        Integer prorationDayOfMonth = 25;
        
        Integer setupYear = 2020;
        Integer setupMonth = 2;
        Integer setupDay = 1;
        Integer expectedYear =  setupYear;
        Integer expectedMonth = setupMonth;
        Integer expectedDay = Date.daysInMonth(expectedYear, expectedMonth);
        
        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        
        Opportunity thisOpportunity = new Opportunity(
            AccountID = thisAccount.id,
            Channel_Office__c = channelAccount.Id,
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
        System.runAs(TestRecordsFactory.getUser()){
            insert thisOpportunity;
        }
        
        
        SBQQ__Quote__c parentQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c                   = thisOpportunity.Id,
            qtc_Multi_Site__c                       = true,
            SBQQ__Primary__c                        = true,
            qtc_Multi_Site_Type__c                  = MULTI_SITE_TYPE_AE_PP,
            qtc_Multi_Site_Relationship__c          = MULTI_SITE_RELATIONSHIP_PARENT,
            qtc_Number_of_Sites_with_Payments__c    = 2,
            qtc_Payments_Type__c                    = PAYMENT_TYPE_NO_PAYMENT,
            qtc_Cancelled__c                        = false,
            SBQQ__StartDate__c                      = startDate,
            SBQQ__SubscriptionTerm__c               = 36,
            SBQQ__BillingFrequency__c               = BILLING_FREQUENCY_MONTHLY,
            SBQQ__EndDate__c                        = startDate.addDays(10),
            SBQQ__ProrationDayOfMonth__c            = String.valueOf( prorationDayOfMonth ),
            qtc_Bill_To_Site__c                     = testAccount.Id,
            Deliver_To_Site__c                      = testAccount.Id,
            qtc_Ship_To_Account__c                  = testAccount.Id
        );
        insert parentQuote;
        
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
            SBQQ__Quote__c = parentQuote.Id,
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
        SBQQ.TriggerControl.disable();
        order od = new Order( 
            SBQQ__Quote__c = parentQuote.id,
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
            blng__BillingAccount__c = thisAccount.Id,
            AccountId = thisAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
            Pricebook2Id = standardPriceBook,
            qtc_Bill_To_Site__c = testAccount.id,
            Deliver_To_Site__c = testAccount.id,
            qtc_Ship_To_Account__c = testAccount.id,
            qtc_PO_Number__c = '123456789'
        );
        insert od;
        SBQQ.TriggerControl.enable();
        Contract testContract = new Contract(
            StartDate = startDate,
            SBQQ__Quote__c = parentQuote.Id,
            SBQQ__Order__c = od.id,
            AccountId=thisAccount.Id);
        insert testContract;
        SBQQ.TriggerControl.disable();
        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
            SBQQ__Type__c                           = TYPE_AMENDMENT,
            SBQQ__MasterContract__c                 = testContract.id,
            SBQQ__Account__c                        = thisAccount.id
        );
        
        List<SBQQ__Quote__c> listAmendmentQuotes = new List<SBQQ__Quote__c>{ amendmentQuote};
            insert listAmendmentQuotes;
        
        SBQQ.TriggerControl.enable();
        
        Test.startTest();
        try{
            
            PageReference myVfPage = Page.CPQ_Amend;
            Test.setCurrentPage(myVfPage);
            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('id',testContract.id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testContract);
            CPQAmendContractController cpqAmend = new CPQAmendContractController(sc);
            
            cpqAmend.viewContract();
            cpqAmend.amendContract();
            
            
            //System.assert(false, 'An exception should of been thrown for failing the validation');
        } catch(Exception ex){ 
            
            System.debug( 'error message ' + ex.getMessage());
            
        }
        Test.stopTest();
    }
    
}