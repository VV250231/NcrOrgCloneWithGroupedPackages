@isTest
public class BatchCancelInvoicesTest {
	static String   CHARGE_TYPE_ONE_TIME = 'One-Time';
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;
    
    @TestSetup
    static void setupData(){
        User Usr = [Select Id from User Where Name = 'Soup User'];
                    
       system.runAs(Usr){
            blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(
                Name = 'test legal entity',
                CurrencyIsoCode = 'USD',
                blng__Active__c = True );
            insert testLegalEntity;
            

            Account testAccount = new Account(
                Name='Test Account',
                Type = 'Suspect');
            insert testAccount;

            Contact testContact = new Contact(
                firstname = 'test',
                lastName = 'Contact 1',
                AccountId = testAccount.id,
                MailingStreet = '123 fake st',
                MailingCity = 'atlanta',
                MailingState = 'GA',
                MailingPostalCode = '30303',
                MailingCountry = 'US',
                Email = 'Test@Email.com'
            );
            insert testContact;
       }
    }
    
    @isTest
    static void testBatchCancelInvoices() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();

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

        List<Product2> listProducts = new List<Product2>();
        listProducts.add( new Product2(
            Name = 'testProduct',
            ProductCode = 'testProduct',
            isActive = true,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            blng__BillingRule__c = objBillingRule.Id,
            blng__RevenueRecognitionRule__c = objRevenueRec.Id,
            blng__TaxRule__c = objTaxRule.Id
        ));
        insert listProducts;

        List<PricebookEntry> listPbEntry = new List<PricebookEntry>();
        PricebookEntry objPbEntry = new PricebookEntry();
            objPbEntry.Pricebook2Id = pricebookId;
            objPbEntry.Product2Id = listProducts[0].Id;
            objPbEntry.UnitPrice = 1000.00;
            objPbEntry.IsActive = true;
            listPbEntry.add(objPbEntry);
        insert listPbEntry;

        List<Order> listOrder = new List<Order>();
        listOrder.add( new Order( 
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
            blng__BillingAccount__c = testAccount.Id,
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
            Pricebook2Id = pricebookId,
            BillingCity = 'Test',
            BillingCountry = 'Test',
            BillingPostalCode = '3006',
            BillingState = 'Test',
            BillingStreet = 'Test',
            ShippingCity = 'Test',
            ShippingPostalCode = '3006',
            ShippingState = 'Test',
            ShippingStreet = 'Test',
            BillToContactId = testContact.id,
            ShipToContactId = testContact.Id
        ));
        insert listOrder;
        
        List<OrderItem> listOrderItem = new List<OrderItem>();
        listOrderItem.add( new OrderItem(
            OrderId = listOrder[0].Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = objBillingRule.Id,
            blng__RevenueRecognitionRule__c = objRevenueRec.Id,
            blng__TaxRule__c = objTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = listProducts[0].Id,
            PricebookEntryId = listPbEntry[0].Id,
            Quantity = 1
        ));
       
        insert listOrderItem;
        
        blng__Invoice__c testInvoice = new blng__Invoice__c(
            blng__Account__c =  testAccount.Id,
            blng__InvoiceStatus__c = 'Posted');
        insert testInvoice;
        
        Test.StartTest();
        set<Id> setOfInvoiceId = new set<id>();
        setOfInvoiceId.add(testInvoice.Id);
        BatchCancelInvoices  batchObj = new BatchCancelInvoices(setOfInvoiceId);
        ID batchprocessid = Database.executeBatch(batchObj);
        Test.stopTest();
    }
}