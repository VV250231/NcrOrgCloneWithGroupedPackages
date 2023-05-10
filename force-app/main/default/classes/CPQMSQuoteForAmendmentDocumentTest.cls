@isTest
public class CPQMSQuoteForAmendmentDocumentTest {
/*   @isTest 
    private static void getQulifiedQuotesForAmendmentTest(){
        Integer prorationDayOfMonth = 25;
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Account testAccount;
        Account deliverToSite;
        Account billToSite;
        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        
        
        System.runAs(CPQ_TestDataFactory.getSoupUser()){ 
            
            testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            billToSite =  CPQ_TestDataFactory.createSite(testAccount, '2', null);
            
            insert deliverToSite;
            insert billToSite;
        }
         Contact c= TestRecordsFactory.createContact(testAccount);
         Opportunity opp1 = CPQMSQuoteForAmendmentDocumentTest.getOpportunity(testAccount, c);
         Opportunity opp2 = CPQMSQuoteForAmendmentDocumentTest.getOpportunity(testAccount, c);
         Opportunity opp3 = CPQMSQuoteForAmendmentDocumentTest.getOpportunity(testAccount, c);
         SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c=opp1.Id,
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true
        );
        insert masterQuote;
        System.assert(masterQuote.Id!=null);
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

        List<SBQQ__QuoteLine__c> listQuoteLineToInsert = new List<SBQQ__QuoteLine__c>();
        for(Product2 thisProduct : lstProducts){
            SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
                qtc_Usage_Status__c = 'Expecting Usage',
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
                SBQQ__Quote__c = masterQuote.Id,
                SBQQ__PricebookEntryId__c = standardPrice.Id,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 1,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisProduct.Id
            );
            listQuoteLineToInsert.add( positiveQuoteLine );
        }
        insert listQuoteLineToInsert;
        SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c=opp2.Id,
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Child',
            qtc_Multi_Site_Parent_Quote__c = masterQuote.id
        );
        insert childQuote;
        System.assert(childQuote.Id!=null);
        system.debug('@@@childQuote'+childQuote);
        Contract testContract = new Contract(
            StartDate = startDate,
            AccountId=testAccount.Id,
            SBQQ__Quote__c=masterQuote.Id
        );
        insert testContract;
        system.debug('@@testContract'+testContract);
        System.assert(testContract.Id!=null);
        List<SBQQ__Quote__c> quoteLst = [ 	SELECT Id, Name
                                         FROM SBQQ__Quote__c
                                         WHERE Id =: masterQuote.Id
                                         LIMIT 1 ];
        //SBQQ.TriggerControl.disable();
        SBQQ__Quote__c amendQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c=opp3.Id,
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            SBQQ__MasterContract__c = testContract.Id,
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Amendment',
            Deliver_To_Site__c = deliverToSite.id,
              qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Original_Quote_Number__c=quoteLst[0].Name,
            SBQQ__OriginalQuote__c=quoteLst[0].Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            qtc_Payments_First_Partner__c =true
            
        );
        //SBQQ.TriggerControl.disable();
        insert amendQuote;
       // SBQQ.TriggerControl.enable();
        system.debug('@@@@amendQuote'+amendQuote);
        System.assert(amendQuote.Id!=null);
        List<ID> quoteIds = new List<ID>();
        quoteIds.add(amendQuote.Id);
        List<ID> quoteIdsChild = new List<ID>();
        quoteIdsChild.add(childQuote.Id);
        
        Test.startTest();
        CPQMSQuoteForAmendmentDocument.getQulifiedQuotesForAmendment(quoteIds);
        CPQMSQuoteForAmendmentDocument.getQulifiedQuotesForAmendment(quoteIdsChild);
        Test.stopTest();
	
    }
*/
	@isTest
    static void getQulifiedQuotesForAmendmentTest(){
         Opportunity thisOpportunity;
        Account thisAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = 'MCN1',
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            CDM_Account_Type__c='LOCAL OFFICE',
            CDM_Account_Status__c = 'Active',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert thisAccount;
        
            thisOpportunity = new Opportunity(
                AccountID = thisAccount.id,
                Name = 'OppQuote Linkage Test Opportunity',
                type = 'Indirect Channel',
                CURRENCYISOCODE = 'USD',
                INVOICE_TRIGGER__C = 'Shipment',
                Expected_Delivery_Date__c = System.TODAY().addDays(30),
                Channel_Office__c= thisAccount.id,
                closeDate = System.TODAY(),
                stagename = 'Prospecting',
                Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
                EndCustomerUnknown__c = true,
                Skip_Validation_Rule_for_Lead_Conversion__c = true,
                ForecastCategoryName ='Omitted'
            );
        
            insert thisOpportunity;
        }

        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true
        );
        insert thisQuote;
		SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Child',
            SBQQ__Primary__c=true,
             qtc_Multi_Site_Parent_Quote__c = thisQuote.id
        );
        insert childQuote;
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

        List<SBQQ__QuoteLine__c> listQuoteLineToInsert = new List<SBQQ__QuoteLine__c>();
        for(Product2 thisProduct : lstProducts){
            SBQQ__QuoteLine__c positiveQuoteLine = new SBQQ__QuoteLine__c(
                qtc_Usage_Status__c = 'Expecting Usage',
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
                SBQQ__PricebookEntryId__c = standardPrice.Id,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 1,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisProduct.Id
            );
            listQuoteLineToInsert.add( positiveQuoteLine );
        }
        insert listQuoteLineToInsert;

        Contract testContract = new Contract(
            StartDate = Date.today(),
            SBQQ__Quote__c = thisQuote.Id,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = Date.today(),
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = Date.today().addDays(30),
            SBQQ__ProrationDayOfMonth__c = '25',
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Type__c='Amendment',
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id
        );
        SBQQ.TriggerControl.disable();
        insert amendmentQuote;
        SBQQ.TriggerControl.enable();

        SBQQ__QuoteLine__c amendmentQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = amendmentQuote.Id,
            SBQQ__PriorQuantity__c = 3,
            SBQQ__Quantity__c = 5,
            Is_Subscriptioned__c = true,
            SBQQ__OptionLevel__c = 1,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Group_ID__c = 1,
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__PricebookEntryId__c = standardPrice.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = lstProducts[0].Id
        );
        insert amendmentQuoteLine;
        List<ID> quoteIds = new List<ID>();
        quoteIds.add(amendmentQuote.Id);
        List<ID> quoteIdsChild = new List<ID>();
        quoteIdsChild.add(childQuote.Id);
        
        Test.startTest();
        CPQMSQuoteForAmendmentDocument.getQulifiedQuotesForAmendment(quoteIds);
        CPQMSQuoteForAmendmentDocument.getQulifiedQuotesForAmendment(quoteIdsChild);
        Test.stopTest();
    }
    
    private static Opportunity getOpportunity( Account a, Contact c ){
        Opportunity opp1 = new Opportunity();
		opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        opp1.name = 'OpportunityForMultiSiteQuote';
        opp1.AccountID = a.id;
        opp1.stagename = 'Analyzing';
        opp1.Contacts__c = c.Id; // Primary Contact
       // opp1.Channel_Office__c = partAct.Id;
        opp1.closeDate = System.TODAY();
        opp1.type = 'New Customer';
        opp1.INVOICE_TRIGGER__C = 'Shipment';
        opp1.Forecast_Category__c = 'Pipeline';
        opp1.ForecastCategoryName = 'Pipeline';
        opp1.LeadSource = 'Email';
        opp1.CPQ__c = true;
        opp1.CURRENCYISOCODE = 'USD';      
        opp1.Skip_Validation_Rule_for_Lead_Conversion__c = true;
        insert opp1;
        
        return opp1;
    }
 
}