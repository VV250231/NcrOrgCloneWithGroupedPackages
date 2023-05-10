/**************************************
Author ...............: Suraj Parihar
Date Created .........: 26-JAN-2021
Last Modified By .....:
Last Modified Date ...: 
Description ..........: Test Class QB Sheet sent to POSAAS Admin i.e. EmailQBSalesOrder AND QBSalesOrderMultiSheetController
***************************************/
@isTest
public class CPQSalesOrderMultiSheetController_Test {
    static Account a;
    static Opportunity opp;
    static SBQQ__Quote__c quote;
    static Order ord;
    static Order ord1;
    static String   CHARGE_TYPE_ONE_TIME = 'One-Time';
    
    
    Public Static User getUser()
    {
        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    @isTest
    public static void testQBSheet() {
        
        a = new Account(name = 'Test Acc',
                        LOB__c = 'FINANCIAL',
                        //  MDM_Data_Source_Code__c='CDM',
                        Master_Customer_Number__c = 'TESTMCN00001X',
                        Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                        Active_Account__c = true,
                         CDM_Account_Status__c = 'Active',
                        Project_Coordinator_Email__c = 'abc@test.com');
        System.runAs(getUser()){
            insert a;
        }
     //   opp  = TestRecordsFactory.createSimpleOpportunity(a);
     	opp = CPQSalesOrderMultiSheetController_Test.getOpportunity(a);
        opp.closeDate = System.TODAY()- 200;
        opp.CPQ__c = TRUE;
        update opp;
        
         blng__BillingRule__c objBillingRule = new blng__BillingRule__c();
            objBillingRule.Name = 'Test Billing Rule';
            objBillingRule.blng__Active__c = true;
            objBillingRule.blng__GenerateInvoices__c = 'Yes';
            objBillingRule.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
            objBillingRule.blng__PartialPeriodTreatment__c = 'Separate';
            insert objBillingRule;

            blng__RevenueRecognitionRule__c objRevenueRec = new blng__RevenueRecognitionRule__c();
            objRevenueRec.Name = 'Test Schedule';
            objRevenueRec.blng__CreateRevenueSchedule__c = 'Yes';
            objRevenueRec.blng__Active__c = true;
            insert objRevenueRec;

            blng__TaxRule__c objTaxRule = new blng__TaxRule__c();
            objTaxRule.Name = 'Test Tax Rule';
            objTaxRule.blng__Active__c = true;
            objTaxRule.blng__TaxableYesNo__c = 'Yes';
            insert objTaxRule;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = a.Id,
            SBQQ__Opportunity2__c = opp.Id,
            SBQQ__Primary__c=true);
        insert quote;
        System.assert(quote.Id!=null);
        system.assertEquals(quote.SBQQ__Primary__c, true);
        List<Product2> lstProducts = new List<Product2> ();
        lstProducts.add(new product2(name='A', family='Hardware', ProductCode = 'H400-0001-0000', product_type__c = 'PID', SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
                blng__BillingRule__c = objBillingRule.Id,
                blng__RevenueRecognitionRule__c = objRevenueRec.Id,
                blng__TaxRule__c = objTaxRule.Id));
        lstProducts.add(new product2(name='B', family='Hardware', ProductCode = 'H400-0001-0000',product_type__c = 'PID', SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
                blng__BillingRule__c = objBillingRule.Id,
                blng__RevenueRecognitionRule__c = objRevenueRec.Id,
                blng__TaxRule__c = objTaxRule.Id ));
        lstProducts.add(new product2(name='C', family='Hardware', ProductCode = 'H400-0001-0000', product_type__c = 'PID', SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
                blng__BillingRule__c = objBillingRule.Id,
                blng__RevenueRecognitionRule__c = objRevenueRec.Id,
                blng__TaxRule__c = objTaxRule.Id));
        lstProducts.add(new product2(name='D', family='Hardware', ProductCode = 'H400-0001-0000', SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
                blng__BillingRule__c = objBillingRule.Id,
                blng__RevenueRecognitionRule__c = objRevenueRec.Id,
                blng__TaxRule__c = objTaxRule.Id));
        insert lstProducts;
        
        Id stdPbId = Test.getStandardPricebookId();        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = lstProducts[0].id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Order od = new order(Pricebook2Id = stdPbId, AccountId = a.id, Status = 'Draft', EffectiveDate = Date.Today(), SBQQ__Quote__c=quote.Id,blng__BillingDayOfMonth__c = '1',blng__BillingAccount__c = testAccount.Id);
        insert od;
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        
        OrderItem ordPd = new OrderItem(PriceBookEntryId=standardPrice.Id, OrderId=od.Id, Quantity=1, SBQQ__OrderedQuantity__c = 1, UnitPrice=standardPrice.UnitPrice, ServiceDate=Date.Today(), SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id);
        insert ordPd;
        
        
        List<OrderItem> add_order = new List<OrderItem> ();
        add_order.add(new OrderItem(PriceBookEntryId=standardPrice.Id, OrderId=od.Id, Quantity=1, SBQQ__OrderedQuantity__c = 1, UnitPrice=standardPrice.UnitPrice, ServiceDate=Date.Today(), SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id));
        insert add_order;
        
        List<Order> lstOrder= new List<Order>();
        ord = new Order(AccountId=a.Id, Status='Draft' , EffectiveDate = Date.today(),SBQQ__Quote__c=quote.Id,blng__BillingDayOfMonth__c = '1',blng__BillingAccount__c = testAccount.Id);
        insert ord;
        System.assert(ord.Id!=null);
         List<CPQSalesOrderMultiSheetController.InvestmentDetailsClass> pd = new List<CPQSalesOrderMultiSheetController.InvestmentDetailsClass>(); 
   CPQSalesOrderMultiSheetController.InvestmentDetailsClass p1 = new CPQSalesOrderMultiSheetController.InvestmentDetailsClass();
        p1.QUOTE_HEADER_ID = quote.id;
        p1.SOLD_TO_CUST_ID = a.Id;
        p1.FREIGHT_METHOD = 'ground';
p1.CONTRACTED_FREIGHT_AMOUNT = '100';
p1.ORDER_TYPE = 'shipment';
p1.MASTER_CUSTOMER_NUMBER = '101101010';
p1.SUBSCRIPTION_TYPE = 'monthly';
p1.PO_DATE = '1/2/21';
p1.PAYMENT_TERM = 'monthly';
p1.BILL_TO_CUST_ID = a.id;
p1.SHIP_TO_CUST_ID = a.id;
p1.DELIVER_TO_CUST_ID = a.id;
p1.REQUESTED_ARRIVAL_DATE = '1/2/21';
p1.SHIPPING_METHOD = 'ground';
p1.SHIP_INSTRUCTIONS = 'two days shipping essential';
p1.INVOICE_TRIGGER = 'shipment';
p1.OPPORTUNITY_NUMBER = opp.id;
p1.APPROVED_EXPLANATION = 'yes';
p1.AUTO_SUBMIT = 'yes';
p1.MASTER_QUOTE_NUMBER = quote.id;
p1.IDENTIFIER = 'abcaa_test';
p1.BUNDLE_NAME = 'xyz_test';
p1.DESCR = 'aloha';
p1.QTY = '10';
p1.UNIT_AMT = '10';
p1.ANNUAL_NET_PRICE = '100';
p1.HARDWARE_ROLE = 'tester';
p1.SW_KEY = '1234';
p1.SW_START_DATE = '1/2/21';
p1.SW_END_DATE = '1/2/21';
p1.ENTITLE_START_DATE = '1/2/21';
p1.ENTITLE_END_DATE = '1/2/21';
p1.TEXT254 = 'test254';      
p1.PO_REF = 'po_ref';
p1.INTFC_ID = 'INTFC_ID';
p1.INTFC_LINE_NUM = '49';
p1.TRANS_TYPE_BI = 'TRANS_TYPE_BI';
p1.TRANS_TYPE_BI_SEQ = 'TRANS_TYPE_BI_SEQ';     
p1.BUSINESS_UNIT = 'EDA sales';
p1.SOLD_TO_ADDR_NUM = 'SOLD_TO_ADDR_NUM-97';
p1.ADDRESS_SEQ_NUM = 'SOLD_TO_ADDR_NUM-97';
p1.SHIP_TO_ADDR_NUM = 'SOLD_TO_ADDR_NUM-97';     
p1.BILL_TYPE_ID = '111000';     
p1.REFERENCE_ORDER_NUMBER = od.id;
p1.LINE_SEQ_NUM = '10';
p1.BI_CURRENCY_CD = 'USD';
p1.FROM_DT = '1/2/21';
p1.TO_DT = '1/2/21';
p1.NOTES_SEQ_NUM = '49';
p1.NOTE_TYPE = 'test';
p1.INTERNAL_FLAG = 'test';
p1.BILL_SOURCE_ID = 'test';
p1.BILLING_FREQUENCY = '24';
p1.BILL_CYCLE_ID = '1234';
p1.PYMNT_TERMS_CD = '24';
p1.ORDER_GRP = 'test';
p1.BILL_BY_ID = '1234';
p1.VANTATIVE_CASE_ID = '1234';
p1.RMA_ID = '1234';
p1.INTMED_SHIP_ID = '1234';
p1.PG_GROUP_LINE_NO = '42';
pd.add(p1);    
        
        
        Test.startTest();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setHtmlBody('strEmail');
        insert new NCR_CPQBLG_Email__c(Name='Order Management',Email__c='sp185453@ncr.com');
        insert new NCR_CPQBLG_Email__c(Name='Default Workflow Email',Email__c='sp185453@ncr.com');
        PageReference pageRef = Page.CPQEmailSalesOrderPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',ord.Id);
        //pageRef.getParameters().put('QteId', String.valueOf(Qte2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        CPQEmailSalesOrder Obj = new CPQEmailSalesOrder(sc); 
        Obj.sendQBOrder();  
        
        
        CPQSalesOrderMultiSheetController Obj1 = new CPQSalesOrderMultiSheetController();
        obj1.AddDynamicRows(add_order);
        obj1.getInvestmentDetails();
        obj1.setInvestmentDetails(pd);
        
        Test.stopTest();
        
    }
     private static Opportunity getOpportunity( Account a){
        Opportunity opp1 = new Opportunity();
		opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        opp1.name = 'OpportunityForMultiSiteQuote';
        opp1.AccountID = a.id;
        opp1.stagename = 'Analyzing';
     //   opp1.Contacts__c = c.Id; // Primary Contact
    //    opp1.Channel_Office__c = partAct.Id;
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