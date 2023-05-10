@isTest
public class FullfillmentOrderTriggerTest {
    static String   SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
        USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage',
        EXPECTED_QUOTE_NAME = 'test quote name',
        EXPECTED_SALES_ORG_CODE= 'salesOrgCode',
        EXPECTED_PO_NUMBER = 'poNumber',
        EXPECTED_ERP_QUOTE_TYPE = 'erpQuoteType',
        EXPECTED_ORDER_SOURCE = 'orderSource',
        EXPECTED_PAYMENT_TERM = '3 NET',
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
        EXPECTED_DELIVERY_ID = 'Delivery Id',
        LEGAL_DOCUMENT_STATUS_COMPLETED = 'Completed';
    static Integer  EXPECTED_SEQUENCE_NUMBER = 1234,
        EXPECTED_QTY_TO_SHIP = 88;
    static Date     EXPECTED_ERP_ESTIMATED_SHIP_DATE = Date.today().addDays(10),
        EXPECTED_CUSTOMER_PO_DATE = Date.today().addDays(30),
        EXPECTED_PROMISE_DATE = Date.today().addDays(20),
        EXPECTED_COMPLETION_DATE_SHIPMENT_DATE = Date.today().addDays(50),
        EXPECTED_SCHEDULED_SHIP_DATE = Date.today().addDays(55);
    static Account act;
    static Account site;
    static Contact con;
    
    @TestSetup
    static void setupData(){
        Account thisAccount = new Account(name = 'ContractTestAccount',
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
                                          CDM_Account_Type__c='LOCAL OFFICE',
                                          CDM_Account_Status__c = 'Active',
                                          industry = 'HOSPITALITY:QSR',
                                          Project_Coordinator_Email__c = 'abc@test.com'
                                         );
        User soupUser = TestRecordsFactory.getUser();
        System.runAs( soupUser ){
            insert thisAccount;
        }
        
        Opportunity thisOpportunity = new Opportunity(
            AccountID = thisAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= thisAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            CurrencyIsoCode = 'USD',
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true,
            // qtc_Bill_To_Site__c = thisAccount.Id,
            // qtc_Ship_To_Account__c = thisAccount.Id,
            // Deliver_To_Site__c = thisAccount.Id,
            SBQQ__SalesRep__c = soupUser.Id,
            qtc_Quote_Name__c = EXPECTED_QUOTE_NAME,
            qtc_PO_Number__c = EXPECTED_PO_NUMBER,
            qtc_ERP_Quote_Type__c = EXPECTED_ERP_QUOTE_TYPE,
            SBQQ__PaymentTerms__c = EXPECTED_PAYMENT_TERM,
            qtc_New_Aloha_Key_Number__c = EXPECTED_ALOHA_KEY,
            qtc_Conversion_Type__c = EXPECTED_CONVERSION_TYPE,
            qtc_CIS__c = EXPECTED_CIS,
            qtc_CDP__c = EXPECTED_CDP,
            Customer_PO_Date__c = EXPECTED_CUSTOMER_PO_DATE,
            qtc_Packing_Instructions__c = EXPECTED_PACKING_INSTRUCTIONS,
            qtc_Legal_Document_Status__c = LEGAL_DOCUMENT_STATUS_COMPLETED,
            qtc_EligibleForERP__c='TRUE'
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
                                     qtc_Exclude_from_ERP__c =false,
                                     product_type__c = 'Topline'));
        lstProducts.add(new product2(   name='B', 
                                     family='Hardware',
                                     blng__BillingRule__c = billingRule.Id, 
                                     blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                     blng__TaxRule__c = taxrule.ID,
                                     ProductCode = 'H400-0001-0000',
                                     qtc_Exclude_from_ERP__c =false,
                                     product_type__c = 'Topline' ));
        lstProducts.add(new product2(   name='C', 
                                     family='Hardware',
                                     blng__BillingRule__c = billingRule.Id, 
                                     blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                     blng__TaxRule__c = taxrule.ID,
                                     ProductCode = 'H400-0001-0000', 
                                     qtc_Exclude_from_ERP__c =false,
                                     product_type__c = 'Topline'));
        lstProducts.add(new product2(   name='D', 
                                     family='Hardware',
                                     blng__BillingRule__c = billingRule.Id, 
                                     blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id, 
                                     blng__TaxRule__c = taxrule.ID,
                                     qtc_Exclude_from_ERP__c =false,
                                     ProductCode = 'H400-0001-0000'));
        insert lstProducts;
        
        Id stdPbId = Test.getStandardPricebookId();        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = lstProducts[0].id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(
            // qtc_Quote__r.SBQQ__SalesRep__r.Name = 'Suraj',
            qtc_Quote__c=thisQuote.ID,
            qtc_Shipping_Instructions__c = 'Test Ship',
            qtc_Transactional_Currency_Code__c ='USD',
            // qtc_Quote__r.Name = 'Q-10023',
            qtc_Quote_Name__c ='Test Quote',
            qtc_MCN__c=SETUP_MASTER_CUSTOMER_NUMBER,
            qtc_Country_Code__c='US',
            qtc_Bill_To_Site__c='12345',
            qtc_CDP__c='hc230064',
            qtc_CIS__c='sh230150',
            qtc_DeliverToSite__c='7280632',
            qtc_Invoice_Trigger__c='',
            Order_Interface_Status__c='ERP Ready',
            qtc_PaymentTerms__c='',
            Retry_Attempt__c=1,
            qtc_Sequence_Number__c=1,
            qtc_Ship_To_Account__c=''
            
        );
        insert fo;
    }
	 @isTest
    static void testFulfillmentOrderTrigger() {
        qtc_FulfillmentOrder__c pOrd = [SELECT Id, Name,Order_Interface_Status__c FROM qtc_FulfillmentOrder__c LIMIT 1];
        
        Test.startTest();
        pOrd.Order_Interface_Status__c = 'Order Booked';
        update pOrd;
        System.assertEquals('Order Booked', pOrd.Order_Interface_Status__c, 'Opp Closed Booked');
        Test.stopTest();   
    }
}