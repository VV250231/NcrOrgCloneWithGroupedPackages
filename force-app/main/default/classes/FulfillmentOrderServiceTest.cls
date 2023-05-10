@isTest
public with sharing class FulfillmentOrderServiceTest {
    private static Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();
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
                    EXPECTED_DELIVERY_ID = 'Delivery Id',
                    LEGAL_DOCUMENT_STATUS_COMPLETED = 'Completed';
    static Integer  EXPECTED_SEQUENCE_NUMBER = 1234,
                    EXPECTED_QTY_TO_SHIP = 88;
    static Date     EXPECTED_ERP_ESTIMATED_SHIP_DATE = Date.today().addDays(10),
                    EXPECTED_CUSTOMER_PO_DATE = Date.today().addDays(30),
                    EXPECTED_PROMISE_DATE = Date.today().addDays(20),
                    // EXPECTED_SW_START_DATE = String.valueOf(Date.today()), 
                    // EXPECTED_SW_END_DATE = String.valueOf(Date.today().addDays(60)), 
                    EXPECTED_COMPLETION_DATE_SHIPMENT_DATE = Date.today().addDays(50),
                    EXPECTED_SCHEDULED_SHIP_DATE = Date.today().addDays(55);


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
            Project_Coordinator_Email__c = 'abc@test.com',
            AutoPay_Setup__c = 'True'
        );
        User soupUser = TestRecordsFactory.getUser();
       Account deliverToSite;
       Account billToSite;
        System.runAs( soupUser ){
            insert thisAccount;
            
            deliverToSite = CPQ_TestDataFactory.createSite(thisAccount, '1', null);
            billToSite =  CPQ_TestDataFactory.createSite(thisAccount, '2', null);
            billToSite.AutoPay_Setup__c = 'True';
            insert deliverToSite;
            insert billToSite;
            
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
            qtc_Bill_To_Site__c = billToSite.Id,
            qtc_Ship_To_Account__c = deliverToSite.Id,
            //Deliver_To_Site__c = thisAccount.Id,
            SBQQ__SalesRep__c = soupUser.Id,
            qtc_Quote_Name__c = EXPECTED_QUOTE_NAME,
            qtc_PO_Number__c = EXPECTED_PO_NUMBER,
            qtc_ERP_Quote_Type__c = EXPECTED_ERP_QUOTE_TYPE,
            SBQQ__PaymentTerms__c = EXPECTED_PAYMENT_TERM,
            qtc_New_Aloha_Key_Number__c = EXPECTED_ALOHA_KEY,
            // qtc_Order_Type__c
            qtc_Conversion_Type__c = EXPECTED_CONVERSION_TYPE,
            // gqtc_Shipping_Instructions__c
            qtc_CIS__c = EXPECTED_CIS,
            qtc_CDP__c = EXPECTED_CDP,
            Customer_PO_Date__c = EXPECTED_CUSTOMER_PO_DATE,
            qtc_Packing_Instructions__c = EXPECTED_PACKING_INSTRUCTIONS,
            qtc_Legal_Document_Status__c = LEGAL_DOCUMENT_STATUS_COMPLETED
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
            SBQQ__PricebookEntryId__c = standardPrice.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = lstProducts[0].Id,


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
        SBQQ__QuoteLine__c passThroughQuoteLine = new SBQQ__QuoteLine__c(
            qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
            Is_Subscriptioned__c = true,
            Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            SBQQ__OptionLevel__c = 1,
            //qtc_MRR__c = 0,
            qtc_Pass_Through__c = true,
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
        SBQQ__QuoteLine__c noOptionLevelQuoteLine = new SBQQ__QuoteLine__c(
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

        insert new List<SBQQ__QuoteLine__c>{positiveQuoteLine, passThroughQuoteLine, noOptionLevelQuoteLine};
    }

    @isTest
    static void newFulfillmentOrder_positiveTest(){
  
                        
                
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, Name, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,qtc_Customer_Setup_Complete_Date__c,
                    SBQQ__PaymentTerms__c,qtc_Order_Authorization_Accepted_Date__c,qtc_Legal_Document_Status__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,
                    SBQQ__Account__r.Account_Country_Code__c, SBQQ__Opportunity2__r.Invoice_Trigger__c,
                    SBQQ__Account__r.Master_Customer_Number__c, qtc_Bill_To_Site__r.Site_Number__c,
                    qtc_Ship_To_Account__r.Site_Number__c, Deliver_To_Site__r.Site_Number__c,SBQQ__OriginalQuote__c,
                    SBQQ__SalesRep__r.Name,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = true
        ];

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];
        System.assertEquals(0, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        System.assertEquals(0, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [ 
            SELECT Id, qtc_Quote__c, qtc_Quote_Number__c, qtc_Quote_Name__c, 
                qtc_Country_Code__c, qtc_MCN__c, qtc_Bill_To_Site__c, qtc_Ship_To_Account__c,
                qtc_DeliverToSite__c, qtc_Invoice_Trigger__c, qtc_PO_Number__c,atc_QuickBaseProjectNumber__c,
                qtc_ERP_Quote_Type__c, qtc_Order_Source__c, qtc_Sequence_Number__c, qtc_PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,
                qtc_New_Aloha_Key_Number__c, CurrencyIsoCode, qtc_Conversion_Type__c, qtc_CIS__c,qtc_Order_Authorization_Accepted_Date__c,
                qtc_CDP__c, qtc_Requested_Delivery_Date__c, qtc_Customer_PO_Date__c 
            FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [   
            SELECT  Id, qtc_FulfillmentOrder__c, qtc_Product__c, qtc_Quantity__c, qtc_ProductOption__c,
                    qtc_Hardware_Role__c, qtc_MDM_Product_ID__c, qtc_SW_Key_Start_Date__c,
                    qtc_SW_Key_End_Date__c, qtc_Unit_List_Price__c, qtc_Qty_to_Ship__c,	
                    qtc_Software_NOT_Ship_Qty__c, qtc_Software_Media_Set__c, qtc_Software_Release_Number__c,
                    qtc_Package_ID__c, qtc_Sub_Package_ID__c, qtc_Software_System_Name__c
            FROM qtc_FulfillmentOrderProduct__c];

        /*
        System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        System.assertEquals(listQuoteLine.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Quote Lines');
        System.assertEquals(listQuoteLine[0].SBQQ__Quantity__c, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'Aggregate quantity should be the same as the quote line');

        System.assertEquals( listQuote[0].Name, afterTestListFulfillmentOrder[0].qtc_Quote_Number__c, 'We expect the quote field to set the fulfillment Order Field');
        System.assertEquals( listQuote[0].qtc_Quote_Name__c, afterTestListFulfillmentOrder[0].qtc_Quote_Name__c, 'We expect the quote field to set the fulfillment Order Field');
        System.assertEquals( listQuote[0].SBQQ__Account__r?.Account_Country_Code__c, afterTestListFulfillmentOrder[0].qtc_Country_Code__c, 'We expect the quote field to set the fulfillment Order Field');
        System.assertEquals( listQuote[0].SBQQ__Account__r?.Master_Customer_Number__c, afterTestListFulfillmentOrder[0].qtc_MCN__c, 'We expect the quote field to set the fulfillment Order Field');
        System.assertEquals( listQuote[0].qtc_Bill_To_Site__r?.Site_Number__c, afterTestListFulfillmentOrder[0].qtc_Bill_To_Site__c, 'We expect the quote field to set the fulfillment Order Field');
        System.assertEquals( listQuote[0].qtc_Ship_To_Account__r?.Site_Number__c, afterTestListFulfillmentOrder[0].qtc_Ship_To_Account__c, 'We expect the quote field to set the fulfillment Order Field');
        System.assertEquals( listQuote[0].Deliver_To_Site__r?.Site_Number__c, afterTestListFulfillmentOrder[0].qtc_DeliverToSite__c, 'We expect the quote field to set the fulfillment Order Field');
*/
        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals('TRUE', requeryQuotes[0].qtc_EligibleForERP__c, 'We expect the picklist to be set to TRUE');
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect the qtc_Ordered_Custom__c to be set to false');

    }

    @isTest
    static void existingFulfillmentOrder_UpdateQuantity_positiveTest(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = false
        ];

        qtc_FulfillmentOrder__c testFulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = listQuote[0].Id,
            qtc_Sequence_Number__c = 0
        );
        insert testFulfillmentOrder;
        Decimal previousQuantity = 1;

        List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProducts = new List<qtc_FulfillmentOrderProduct__c>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
            listFulfillmentOrderProducts.add(
                new qtc_FulfillmentOrderProduct__c(
                    qtc_Product__c = thisQuoteLine.SBQQ__Product__c,
                    qtc_ProductOption__c = thisQuoteLine.SBQQ__ProductOption__c,
                    qtc_FulfillmentOrder__c = testFulfillmentOrder.Id,
                    qtc_Quantity__c = previousQuantity
                )
            );

            thisQuoteLine.SBQQ__Quantity__c = 5;

        }
        insert listFulfillmentOrderProducts;
      
        update listQuoteLine;

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];
        //System.assertEquals(1, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        //System.assertEquals(1, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c, qtc_PreviousQuantity__c FROM qtc_FulfillmentOrderProduct__c];

        //System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        //System.assertEquals(listQuoteLine.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Quote Lines');
        //System.assertEquals(previousQuantity, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'Previous Quantity should be updated to the original Quantity');
        //System.assertEquals(listQuoteLine[0].SBQQ__Quantity__c, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'Aggregate quantity should be the same as the quote line');
        
        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
        
    }

    @isTest
    static void existingFulfillmentOrder_DeleteQuoteLine_positiveTest(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = false
        ];

        qtc_FulfillmentOrder__c testFulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = listQuote[0].Id,
            qtc_Sequence_Number__c = 0
        );
        insert testFulfillmentOrder;
        Decimal previousQuantity = 1;

        List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProducts = new List<qtc_FulfillmentOrderProduct__c>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
            listFulfillmentOrderProducts.add(
                new qtc_FulfillmentOrderProduct__c(
                    qtc_Product__c = thisQuoteLine.SBQQ__Product__c,
                    qtc_ProductOption__c = thisQuoteLine.SBQQ__ProductOption__c,
                    qtc_FulfillmentOrder__c = testFulfillmentOrder.Id,
                    qtc_Quantity__c = thisQuoteLine.SBQQ__Quantity__c
                )
            );
        }
        insert listFulfillmentOrderProducts;
      
        delete listQuoteLine;

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        Map<Id, qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = new  Map<Id, qtc_FulfillmentOrderProduct__c>(
            [SELECT Id, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c]
        );
        //System.assertEquals(1, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        //System.assertEquals(1, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c, qtc_PreviousQuantity__c FROM qtc_FulfillmentOrderProduct__c];

        //System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        //System.assertEquals(listQuoteLine.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Quote Lines');
        for(qtc_FulfillmentOrderProduct__c thisAfterFulfillmentProduct : afterTestListFulfillmentProducts){
            qtc_FulfillmentOrderProduct__c beforeFulfillmentProduct = beforeTestListFulfillmentProducts.get( thisAfterFulfillmentProduct.Id );
            //System.assertEquals(beforeFulfillmentProduct.qtc_Quantity__c, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'Previous Quantity should be updated to the original Quantity');
            //System.assertEquals(0, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'Aggregate quantity should be 0');
        }

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
        
    }

    @isTest
    static void existingFulfillmentOrder_AdditionalQuoteLine_positiveTest(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c, qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,
                    SBQQ__Quote__c, SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = false
        ];

        qtc_FulfillmentOrder__c testFulfillmentOrder = new qtc_FulfillmentOrder__c(
            qtc_Quote__c = listQuote[0].Id,
            qtc_Sequence_Number__c = 0
        );
        insert testFulfillmentOrder;


        List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProducts = new List<qtc_FulfillmentOrderProduct__c>();
        List<SBQQ__QuoteLine__c> listNewQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
            listFulfillmentOrderProducts.add(
                new qtc_FulfillmentOrderProduct__c(
                    qtc_Product__c = thisQuoteLine.SBQQ__Product__c,
                    qtc_ProductOption__c = thisQuoteLine.SBQQ__ProductOption__c,
                    qtc_FulfillmentOrder__c = testFulfillmentOrder.Id,
                    qtc_Quantity__c = thisQuoteLine.SBQQ__Quantity__c
                )
            );

            listNewQuoteLines.add(
                new SBQQ__QuoteLine__c(
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
                    SBQQ__Quote__c = thisQuoteLine.SBQQ__Quote__c,
                    SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                    SBQQ__NetPrice__c = 25,
                    SBQQ__ListPrice__c = 30,
                    SBQQ__Quantity__c = 5,
                    SBQQ__Discount__c = 10,
                    SBQQ__DefaultSubscriptionTerm__c = 5,
                    SBQQ__StartDate__c = Date.today(),
                    SBQQ__EndDate__c = Date.today().addMonths(12),
                    SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
                )
            );
        }
        insert listFulfillmentOrderProducts;
        insert listNewQuoteLines;
      
        

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        Map<Id, qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = new  Map<Id, qtc_FulfillmentOrderProduct__c>(
            [SELECT Id, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c]
        );
        //System.assertEquals(1, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        //System.assertEquals(1, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c, qtc_PreviousQuantity__c FROM qtc_FulfillmentOrderProduct__c];

        //System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        //System.assertEquals(beforeTestListFulfillmentProducts.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products');
        for(qtc_FulfillmentOrderProduct__c thisAfterFulfillmentProduct : afterTestListFulfillmentProducts){
            qtc_FulfillmentOrderProduct__c beforeFulfillmentProduct = beforeTestListFulfillmentProducts.get( thisAfterFulfillmentProduct.Id );
            System.assertEquals(beforeFulfillmentProduct.qtc_Quantity__c, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'Previous Quantity should be updated to the original Quantity');
            System.assertEquals(6, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'Aggregate quantity should be the same as the sum of the two quote lines');
        }

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
        
    }

    @isTest
    static void existingFulfillmentOrder_DeleteAndAddQuoteLine_positiveTest(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,
                    SBQQ__Quote__c, SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = false
        ];

        FulfillmentOrderService intialService = new FulfillmentOrderService( listQuote );
        intialService.run();



        List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProducts = new List<qtc_FulfillmentOrderProduct__c>();
        List<SBQQ__QuoteLine__c> listNewQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
         
            listNewQuoteLines.add(
                new SBQQ__QuoteLine__c(
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
                    SBQQ__Quote__c = thisQuoteLine.SBQQ__Quote__c,
                    SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                    SBQQ__NetPrice__c = 25,
                    SBQQ__ListPrice__c = 30,
                    SBQQ__Quantity__c = 5,
                    SBQQ__Discount__c = 10,
                    SBQQ__DefaultSubscriptionTerm__c = 5,
                    SBQQ__StartDate__c = Date.today(),
                    SBQQ__EndDate__c = Date.today().addMonths(12),
                    SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
                )
            );
        }
        delete listQuoteLine;
        insert listFulfillmentOrderProducts;
        insert listNewQuoteLines;
      
        

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        Map<Id, qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = new  Map<Id, qtc_FulfillmentOrderProduct__c>(
            [SELECT Id, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c]
        );
        //System.assertEquals(1, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        //System.assertEquals(1, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote );
            thisService.run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c, qtc_PreviousQuantity__c FROM qtc_FulfillmentOrderProduct__c];

        //System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        //System.assertEquals(beforeTestListFulfillmentProducts.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products');
        for(qtc_FulfillmentOrderProduct__c thisAfterFulfillmentProduct : afterTestListFulfillmentProducts){
            qtc_FulfillmentOrderProduct__c beforeFulfillmentProduct = beforeTestListFulfillmentProducts.get( thisAfterFulfillmentProduct.Id );
            //System.assertEquals(beforeFulfillmentProduct.qtc_Quantity__c, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'Previous Quantity should be updated to the original Quantity');
            //System.assertEquals(5, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'Aggregate quantity should be the same as the sum of the two quote lines');
        }

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
        
    }

    @isTest
    static void existingFulfillmentOrder_multipleQuoteLines_Test(){
        Map<String, Double> mapExpectedQuantityByKey = new Map<String, Double>();
        Map<String, Double> mapExpectedPreviousQuantityByKey = new Map<String, Double>();

        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,
                    SBQQ__Quote__c, SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
        ];

        FulfillmentOrderService initialService = new FulfillmentOrderService( listQuote ).run();

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        Map<Id, qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = new  Map<Id, qtc_FulfillmentOrderProduct__c>(
            [SELECT Id, qtc_Product__c, qtc_ProductOption__c, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c]
        );
        for(qtc_FulfillmentOrderProduct__c thisProduct : beforeTestListFulfillmentProducts.values() ){
            String key = thisProduct.qtc_Product__c +':'+thisProduct.qtc_ProductOption__c;
            mapExpectedQuantityByKey.put(key, thisProduct.qtc_Quantity__c);
            mapExpectedPreviousQuantityByKey.put(key, thisProduct.qtc_Quantity__c);

        }

        List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProducts = new List<qtc_FulfillmentOrderProduct__c>();

        List<SBQQ__QuoteLine__c> listNewQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
            String key = thisQuoteLine.SBQQ__Product__c +':'+thisQuoteLine.SBQQ__ProductOption__c;
            Double currentQuantity = mapExpectedQuantityByKey.get(key);

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
                SBQQ__Quote__c = thisQuoteLine.SBQQ__Quote__c,
                SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 7,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
            );
            currentQuantity += positiveQuoteLine.SBQQ__Quantity__c;
            listNewQuoteLines.add(positiveQuoteLine);

            SBQQ__QuoteLine__c secondPositiveQuoteLine = new SBQQ__QuoteLine__c(
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
                SBQQ__Quote__c =thisQuoteLine.SBQQ__Quote__c,
                SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 12,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
            );
            currentQuantity += secondPositiveQuoteLine.SBQQ__Quantity__c;
            listNewQuoteLines.add(secondPositiveQuoteLine);
            mapExpectedQuantityByKey.put(key, currentQuantity);

            SBQQ__QuoteLine__c passThroughQuoteLine = new SBQQ__QuoteLine__c(
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
                Is_Subscriptioned__c = true,
                Product_Type__c = 'Package',
                qtc_Bundle_Type__c = 'Core',
                qtc_Component_List_Term_Price__c = 295,
                qtc_Component_Net_Term_Price__c = 295,
                qtc_Group_ID__c = 1,
                SBQQ__OptionLevel__c = 1,
                //qtc_MRR__c = 0,
                qtc_Pass_Through__c = true,
                qtc_Product_Type__c = 'SW Only',
                SBQQ__BillingFrequency__c = 'Monthly',
                SBQQ__BillingType__c = 'Advance',
                SBQQ__Quote__c =thisQuoteLine.SBQQ__Quote__c,
                SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 1,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
            );

            SBQQ__QuoteLine__c newOptionLevelQuoteLine = new SBQQ__QuoteLine__c(
                qtc_Usage_Status__c = USAGE_STATUS_EXPECTING_USAGE,
                Is_Subscriptioned__c = true,
                Product_Type__c = 'Package',
                qtc_Bundle_Type__c = 'Core',
                qtc_Component_List_Term_Price__c = 295,
                qtc_Component_Net_Term_Price__c = 295,
                qtc_Group_ID__c = 1,
                SBQQ__OptionLevel__c = 2,
                //qtc_MRR__c = 0,
                qtc_Pass_Through__c = true,
                qtc_Product_Type__c = 'SW Only',
                SBQQ__BillingFrequency__c = 'Monthly',
                SBQQ__BillingType__c = 'Advance',
                SBQQ__Quote__c =thisQuoteLine.SBQQ__Quote__c,
                SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                SBQQ__NetPrice__c = 25,
                SBQQ__ListPrice__c = 30,
                SBQQ__Quantity__c = 1,
                SBQQ__Discount__c = 10,
                SBQQ__DefaultSubscriptionTerm__c = 5,
                SBQQ__StartDate__c = Date.today(),
                SBQQ__EndDate__c = Date.today().addMonths(12),
                SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
            );
            String newKey = newOptionLevelQuoteLine.SBQQ__Product__c +':'+newOptionLevelQuoteLine.SBQQ__ProductOption__c;
            mapExpectedQuantityByKey.put(newKey, newOptionLevelQuoteLine.SBQQ__Quantity__c);

            listNewQuoteLines.add(newOptionLevelQuoteLine);
        }
       
        //System.assertEquals(1, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        //System.assertEquals(1, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote );
            thisService.run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id,qtc_Product__c, qtc_ProductOption__c, qtc_Quantity__c, qtc_PreviousQuantity__c FROM qtc_FulfillmentOrderProduct__c];

        //System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        //System.assertEquals(mapExpectedQuantityByKey.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Product/Option level combinations');
        for(qtc_FulfillmentOrderProduct__c thisAfterFulfillmentProduct : afterTestListFulfillmentProducts){
            String key = thisAfterFulfillmentProduct.qtc_Product__c +':'+thisAfterFulfillmentProduct.qtc_ProductOption__c;
            Double expectedPreviousQuantity = mapExpectedPreviousQuantityByKey.get(key);
            Double expectedQuantity = mapExpectedQuantityByKey.get(key);
            //System.assertEquals(expectedPreviousQuantity, thisAfterFulfillmentProduct.qtc_PreviousQuantity__c, 'Previous Quantity should be updated to the original Quantity');
            //System.assertEquals(expectedQuantity, thisAfterFulfillmentProduct.qtc_Quantity__c, 'Aggregate quantity should be sum of qualified quote lines');
        }

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
    }

    @isTest
    static void newFulfillmentOrder_multipleQuote_positiveTest(){
        Account thisAccount = new Account(name = 'ContractTestAccount2',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = 'MASTER2',
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
        }

        Opportunity thisOpportunity = new Opportunity(
            AccountID = thisAccount.id,
            Name = 'OppQuote Linkage Test Opportunity2',
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

        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,
                    SBQQ__Quote__c, SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
        ];

        SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true
        );
        insert newQuote;

        List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProducts = new List<qtc_FulfillmentOrderProduct__c>();
        List<SBQQ__QuoteLine__c> listNewQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
         
            listNewQuoteLines.add(
                new SBQQ__QuoteLine__c(
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
                    SBQQ__Quote__c = newQuote.Id,
                    SBQQ__PricebookEntryId__c = thisQuoteLine.SBQQ__PricebookEntryId__c,
                    SBQQ__NetPrice__c = 25,
                    SBQQ__ListPrice__c = 30,
                    SBQQ__Quantity__c = 5,
                    SBQQ__Discount__c = 10,
                    SBQQ__DefaultSubscriptionTerm__c = 5,
                    SBQQ__StartDate__c = Date.today(),
                    SBQQ__EndDate__c = Date.today().addMonths(12),
                    SBQQ__Product__c = thisQuoteLine.SBQQ__Product__c
                )
            );
        }
        insert listNewQuoteLines;
      
        List<SBQQ__Quote__c> testListQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
            
        List<AggregateResult> testListQuoteLine = [
            SELECT SBQQ__Product__c,SBQQ__ProductOption__c
            FROM SBQQ__QuoteLine__c 
            WHERE  SBQQ__Quote__c IN : testListQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = false
            GROUP BY SBQQ__Quote__c,SBQQ__Product__c, SBQQ__ProductOption__c
        ];

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( testListQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();
		
        //List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c where qtc_Quote__c=:testListQuote[0].id];
        //List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id,qtc_Product__c, qtc_ProductOption__c, qtc_Quantity__c, qtc_PreviousQuantity__c FROM qtc_FulfillmentOrderProduct__c where qtc_FulfillmentOrder__c=:afterTestListFulfillmentOrder[0].id];
        System.debug( testListQuoteLine);
        //System.debug( afterTestListFulfillmentProducts);
        //System.assertEquals(testListQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect Fulfillment Orders for both quotes');
        //System.assertEquals(testListQuoteLine.size(), afterTestListFulfillmentProducts.size(), 'We expect Fulfillment Orders products for both quotes');
        
       // List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :testListQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
    }

    @isTest
    static void amendment_QuantityIncrease_Test(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = true
        ];

         User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account' , LOB__c = 'FINANCIAL',
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
            insert parentAccount;
            
            testAccount = new Account(
               RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
        }
        SBQQ.TriggerControl.disable();
        order od = new Order( 
            SBQQ__Quote__c = listQuote[0].Id,
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
           // blng__BillingAccount__c = thisAccount.Id,
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
          //  Pricebook2Id = standardPriceBook,
            qtc_Bill_To_Site__c = testAccount.Id,
            Deliver_To_Site__c = testAccount.Id,
           qtc_Ship_To_Account__c = testAccount.Id,
            qtc_PO_Number__c = '123456789'
        );
        insert od;
        SBQQ.TriggerControl.enable();
        Contract testContract = new Contract(
            StartDate = Date.today(),
            SBQQ__Quote__c = listQuote[0].Id,
            SBQQ__Order__c = od.id,
            AccountId=testAccount.Id);
        insert testContract;

        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
         //   SBQQ__StartDate__c = Date.today(),
          //  SBQQ__SubscriptionTerm__c = 36,
          //  SBQQ__EndDate__c = Date.today().addDays(30),
         //   SBQQ__ProrationDayOfMonth__c = '25',
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Type__c='Amendment',
            SBQQ__Account__c = parentAccount.Id
        //    SBQQ__Opportunity2__c = listQuote[0].SBQQ__Opportunity2__c
        );
        SBQQ.TriggerControl.disable();
        insert amendmentQuote;
        SBQQ.TriggerControl.enable();

        List<SBQQ__Quote__c> listAmendmentQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,qtc_Legal_Document_Status__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            WHERE Id = :amendmentQuote.Id
            LIMIT 1];
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
            SBQQ__PricebookEntryId__c = listQuoteLine[0].SBQQ__PricebookEntryId__c,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listQuoteLine[0].SBQQ__Product__c,
            SBQQ__ProductOption__c = listQuoteLine[0].SBQQ__ProductOption__c
        );
        insert amendmentQuoteLine;

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];

        Test.startTest();   
            FulfillmentOrderService thisService = new FulfillmentOrderService( listAmendmentQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_PreviousQuantity__c, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c];
        //System.assertEquals(1, afterTestListFulfillmentOrder.size(), 'We expect only one fulfillment order at this time');
        //System.assertEquals(1, afterTestListFulfillmentProducts.size(), 'We expect only one fulfillment order product at this time');
        //System.assertEquals(null, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'We expect the previous quantity to be null');
        //System.assertEquals(2, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'We expect the quantity to be the quantity - prior quantity');

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listAmendmentQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
    }

    @isTest
    static void afterUpdate_newFulfillmentOrder_positiveTest(){
  
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = true
        ];
       
        
        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];
        //System.assertEquals(0, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        //System.assertEquals(0, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');
        Test.startTest();
	   		NCR_Payments_Site__c testPay3 = new NCR_Payments_Site__c(Quote__c =  listQuote[0].id,Account_Sites__c=listQuote[0].qtc_Bill_To_Site__c,InfiniceptApplicationId__c='ghh');
    	    insert testPay3;
			system.debug('payment site inserted');
            for( SBQQ__Quote__c thisQuote : listQuote){
                thisQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
            }
            update listQuote;
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c];

        //System.assertEquals(listQuote.size(), afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        //System.assertEquals(listQuoteLine.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Quote Lines');
        //System.assertEquals(listQuoteLine[0].SBQQ__Quantity__c, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'Aggregate quantity should be the same as the quote line');

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
    }

    @isTest
    static void afterUpdate_amendment_QuantityIncrease_Test(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = true
        ];
        
         User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account' , LOB__c = 'FINANCIAL',
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
            insert parentAccount;
            
            testAccount = new Account(
               RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
        }
        SBQQ.TriggerControl.disable();
        order od = new Order( 
            SBQQ__Quote__c = listQuote[0].Id,
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
           // blng__BillingAccount__c = thisAccount.Id,
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
          //  Pricebook2Id = standardPriceBook,
            qtc_Bill_To_Site__c = testAccount.Id,
            Deliver_To_Site__c = testAccount.Id,
           qtc_Ship_To_Account__c = testAccount.Id,
            qtc_PO_Number__c = '123456789'
        );
        insert od;
        SBQQ.TriggerControl.enable();
        Contract testContract = new Contract(
            StartDate = Date.today(),
            SBQQ__Quote__c = listQuote[0].Id,
            SBQQ__Order__c = od.id,
            AccountId=testAccount.Id);
        insert testContract;

        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Type__c='Amendment',
            SBQQ__Account__c = parentAccount.Id);
        SBQQ.TriggerControl.disable();
        insert amendmentQuote;
        SBQQ.TriggerControl.enable();

        List<SBQQ__Quote__c> listAmendmentQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            WHERE Id = :amendmentQuote.Id
            LIMIT 1];
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
            SBQQ__PricebookEntryId__c = listQuoteLine[0].SBQQ__PricebookEntryId__c,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listQuoteLine[0].SBQQ__Product__c,
            SBQQ__ProductOption__c = listQuoteLine[0].SBQQ__ProductOption__c
        );
        insert amendmentQuoteLine;

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];

        Test.startTest();   
            amendmentQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
            update amendmentQuote;
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_PreviousQuantity__c, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c];
        //System.assertEquals(1, afterTestListFulfillmentOrder.size(), 'We expect only one fulfillment order at this time');
        //System.assertEquals(1, afterTestListFulfillmentProducts.size(), 'We expect only one fulfillment order product at this time');
        //System.assertEquals(null, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'We expect the previous quantity to be null');
        //System.assertEquals(2, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'We expect the quantity to be the quantity - prior quantity');

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listAmendmentQuote ];
        //System.assertEquals(false, requeryQuotes[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be false');
    }
    
    @isTest
    static void fulfillmentOrderService_NegativeTest(){
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity thisOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        User soupUser = TestRecordsFactory.getUser();
       
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            CurrencyIsoCode = 'USD',
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true,
            SBQQ__SalesRep__c = soupUser.Id,
            qtc_Quote_Name__c = EXPECTED_QUOTE_NAME,
            qtc_PO_Number__c = EXPECTED_PO_NUMBER,
            qtc_ERP_Quote_Type__c = EXPECTED_ERP_QUOTE_TYPE,
            SBQQ__PaymentTerms__c = EXPECTED_PAYMENT_TERM,
            qtc_New_Aloha_Key_Number__c = EXPECTED_ALOHA_KEY,
            qtc_Conversion_Type__c = EXPECTED_CONVERSION_TYPE,
            SBQQ__Type__c = 'Quote',
            qtc_CIS__c = EXPECTED_CIS,
            qtc_CDP__c = EXPECTED_CDP,
            Customer_PO_Date__c = EXPECTED_CUSTOMER_PO_DATE,
            qtc_Packing_Instructions__c = EXPECTED_PACKING_INSTRUCTIONS,
            qtc_Legal_Document_Status__c = LEGAL_DOCUMENT_STATUS_COMPLETED
        );
        insert thisQuote;
        List<SBQQ__Quote__c> listQuote = new List<SBQQ__Quote__c>{ thisQuote };

        Test.startTest();
            FulfillmentOrderService thisService = new FulfillmentOrderService( listQuote ).run();
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [ 
            SELECT Id, qtc_Quote__c, qtc_Quote_Number__c, qtc_Quote_Name__c, 
                qtc_Country_Code__c, qtc_MCN__c, qtc_Bill_To_Site__c, qtc_Ship_To_Account__c,
                qtc_DeliverToSite__c, qtc_Invoice_Trigger__c, qtc_PO_Number__c,atc_QuickBaseProjectNumber__c,
                qtc_ERP_Quote_Type__c, qtc_Order_Source__c, qtc_Sequence_Number__c, qtc_PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,
                qtc_New_Aloha_Key_Number__c, CurrencyIsoCode, qtc_Conversion_Type__c, qtc_CIS__c,qtc_Order_Authorization_Accepted_Date__c,
                qtc_CDP__c, qtc_Requested_Delivery_Date__c, qtc_Customer_PO_Date__c 
            FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [   
            SELECT  Id, qtc_FulfillmentOrder__c, qtc_Product__c, qtc_Quantity__c, qtc_ProductOption__c,
                    qtc_Hardware_Role__c, qtc_MDM_Product_ID__c, qtc_SW_Key_Start_Date__c,
                    qtc_SW_Key_End_Date__c, qtc_Unit_List_Price__c, qtc_Qty_to_Ship__c,	
                    qtc_Software_NOT_Ship_Qty__c, qtc_Software_Media_Set__c, qtc_Software_Release_Number__c,
                    qtc_Package_ID__c, qtc_Sub_Package_ID__c, qtc_Software_System_Name__c
            FROM qtc_FulfillmentOrderProduct__c];
        List<SBQQ__Quote__c> afterListQuote = [SELECT Id,qtc_Ordered_Custom__c, qtc_EligibleForERP__c FROM SBQQ__Quote__c WHERE Id = :thisQuote.Id];

        //System.assertEquals(0, afterTestListFulfillmentOrder.size(), 'We expect zero Fulfillment Orders at this time');
        //System.assertEquals(0, afterTestListFulfillmentProducts.size(), 'We expect zero Fulfillment Order Products at this time');
        //System.assertEquals('FALSE', afterListQuote[0].qtc_EligibleForERP__c, 'We expect EligibleForERP to be false');
        //System.assertEquals(false, afterListQuote[0].qtc_Ordered_Custom__c, 'We expect qtc_Ordered_Custom__c to be true');

    }

    @isTest
    static void fulfillmentOrderService_Amendment_NegativeTest(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = true
        ];

       
         User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account' , LOB__c = 'FINANCIAL',
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
            insert parentAccount;
            
            testAccount = new Account(
               RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
        }
        SBQQ.TriggerControl.disable();
        order od = new Order( 
            SBQQ__Quote__c = listQuote[0].Id,
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
           // blng__BillingAccount__c = thisAccount.Id,
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
          //  Pricebook2Id = standardPriceBook,
            qtc_Bill_To_Site__c = testAccount.Id,
            Deliver_To_Site__c = testAccount.Id,
           qtc_Ship_To_Account__c = testAccount.Id,
            qtc_PO_Number__c = '123456789'
        );
        insert od;
        SBQQ.TriggerControl.enable();
        Contract testContract = new Contract(
            StartDate = Date.today(),
            SBQQ__Quote__c = listQuote[0].Id,
            SBQQ__Order__c = od.id,
            AccountId=testAccount.Id);
        insert testContract;

        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Type__c='Amendment',
            SBQQ__Account__c = parentAccount.Id,
            qtc_Legal_Document_Status__c = LEGAL_DOCUMENT_STATUS_COMPLETED
        );
        SBQQ.TriggerControl.disable();
        insert amendmentQuote;
        SBQQ.TriggerControl.enable();
        List<SBQQ__Quote__c> listAmendmentQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            WHERE Id = :amendmentQuote.Id
            LIMIT 1];

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];

        Test.startTest();   
            amendmentQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
            update amendmentQuote;
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [ 
            SELECT Id, qtc_Quote__c, qtc_Quote_Number__c, qtc_Quote_Name__c, 
                qtc_Country_Code__c, qtc_MCN__c, qtc_Bill_To_Site__c, qtc_Ship_To_Account__c,
                qtc_DeliverToSite__c, qtc_Invoice_Trigger__c, qtc_PO_Number__c,atc_QuickBaseProjectNumber__c,
                qtc_ERP_Quote_Type__c, qtc_Order_Source__c, qtc_Sequence_Number__c, qtc_PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,
                qtc_New_Aloha_Key_Number__c, CurrencyIsoCode, qtc_Conversion_Type__c, qtc_CIS__c,qtc_Order_Authorization_Accepted_Date__c,
                qtc_CDP__c, qtc_Requested_Delivery_Date__c, qtc_Customer_PO_Date__c 
            FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [   
            SELECT  Id, qtc_FulfillmentOrder__c, qtc_Product__c, qtc_Quantity__c, qtc_ProductOption__c,
                    qtc_Hardware_Role__c, qtc_MDM_Product_ID__c, qtc_SW_Key_Start_Date__c,
                    qtc_SW_Key_End_Date__c, qtc_Unit_List_Price__c, qtc_Qty_to_Ship__c,	
                    qtc_Software_NOT_Ship_Qty__c, qtc_Software_Media_Set__c, qtc_Software_Release_Number__c,
                    qtc_Package_ID__c, qtc_Sub_Package_ID__c, qtc_Software_System_Name__c
            FROM qtc_FulfillmentOrderProduct__c];
        List<SBQQ__Quote__c> afterListQuote = [SELECT Id,qtc_Ordered_Custom__c, qtc_EligibleForERP__c FROM SBQQ__Quote__c WHERE Id = :amendmentQuote.Id];

        //System.assertEquals(0, afterTestListFulfillmentOrder.size(), 'We expect zero Fulfillment Orders at this time');
        //System.assertEquals(0, afterTestListFulfillmentProducts.size(), 'We expect zero Fulfillment Order Products at this time');
        //System.assertEquals('FALSE', afterListQuote[0].qtc_EligibleForERP__c, 'We expect EligibleForERP to be false');

    }

    @isTest
    static void afterUpdate_amendment_excludeFromERP_negativeTest(){
        List<SBQQ__Quote__c> listQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c,qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,SubmittedDate__c
            FROM SBQQ__Quote__c 
            LIMIT 1];
        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductOption__c,SBQQ__PricebookEntryId__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c IN :listQuote
            AND SBQQ__OptionLevel__c <> null
            AND qtc_Pass_Through__c = true
        ];

         User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account' , LOB__c = 'FINANCIAL',
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
            insert parentAccount;
            
            testAccount = new Account(
               RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
        }
        SBQQ.TriggerControl.disable();
        order od = new Order( 
            SBQQ__Quote__c = listQuote[0].Id,
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
           // blng__BillingAccount__c = thisAccount.Id,
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
          //  Pricebook2Id = standardPriceBook,
            qtc_Bill_To_Site__c = testAccount.Id,
            Deliver_To_Site__c = testAccount.Id,
           qtc_Ship_To_Account__c = testAccount.Id,
            qtc_PO_Number__c = '123456789'
        );
        insert od;
        SBQQ.TriggerControl.enable();
        Contract testContract = new Contract(
            StartDate = Date.today(),
            SBQQ__Quote__c = listQuote[0].Id,
            SBQQ__Order__c = od.id,
            AccountId=testAccount.Id);
        insert testContract;

        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
         //   SBQQ__StartDate__c = Date.today(),
          //  SBQQ__SubscriptionTerm__c = 36,
          //  SBQQ__EndDate__c = Date.today().addDays(30),
         //   SBQQ__ProrationDayOfMonth__c = '25',
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Type__c='Amendment',
            SBQQ__Account__c = parentAccount.Id
        //    SBQQ__Opportunity2__c = listQuote[0].SBQQ__Opportunity2__c
        );
        SBQQ.TriggerControl.disable();
        insert amendmentQuote;
        SBQQ.TriggerControl.enable();

        List<Product2> listProducts = new List<Product2>();
        for(SBQQ__QuoteLine__c thisQuoteLine : listQuoteLine){
            listProducts.add( new Product2(
                id = thisQuoteLine.SBQQ__Product__c,
                qtc_Exclude_from_ERP__c = true
            ));
        }
        update listProducts;

        List<SBQQ__Quote__c> listAmendmentQuote = [
            SELECT  Id, qtc_Quote_Name__c, SBQQ__Account__c, qtc_Bill_To_Site__c, SBQQ__Type__c,
                    qtc_Ship_To_Account__c, Deliver_To_Site__c, SBQQ__SalesRep__c, SBQQ__Opportunity2__c,
                    qtc_PO_Number__c,Quickbase_Project_Number__c, qtc_ERP_Quote_Type__c,
                    SBQQ__PaymentTerms__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c,
                    qtc_New_Aloha_Key_Number__c, CurrencyIsoCode,
                    qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c,
                    Customer_PO_Date__c, qtc_Packing_Instructions__c
            FROM SBQQ__Quote__c 
            WHERE Id = :amendmentQuote.Id
            LIMIT 1];
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
            SBQQ__PricebookEntryId__c = listQuoteLine[0].SBQQ__PricebookEntryId__c,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = listQuoteLine[0].SBQQ__Product__c,
            SBQQ__ProductOption__c = listQuoteLine[0].SBQQ__ProductOption__c
        );
        insert amendmentQuoteLine;

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];

        Test.startTest();   
            amendmentQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
            update amendmentQuote;
            Test.getEventBus().deliver();
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_PreviousQuantity__c, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c];
        //System.assertEquals(1, afterTestListFulfillmentOrder.size(), 'We expect only one fulfillment order at this time');
        //System.assertEquals(1, afterTestListFulfillmentProducts.size(), 'We expect only one fulfillment order product at this time');
        //System.assertEquals(null, afterTestListFulfillmentProducts[0].qtc_PreviousQuantity__c, 'We expect the previous quantity to be null');
        //System.assertEquals(2, afterTestListFulfillmentProducts[0].qtc_Quantity__c, 'We expect the quantity to be the quantity - prior quantity');

        List<SBQQ__Quote__c> requeryQuotes = [SELECT Id, qtc_EligibleForERP__c, qtc_Ordered_Custom__c FROM SBQQ__Quote__c WHERE Id IN :listAmendmentQuote ];
        //System.assertEquals('FALSE', requeryQuotes[0].qtc_EligibleForERP__c, 'We expect qtc_EligibleForERP__c to be FALSE');
    }
}