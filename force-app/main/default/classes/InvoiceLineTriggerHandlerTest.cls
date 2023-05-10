@isTest
public with sharing class InvoiceLineTriggerHandlerTest {
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
    static void triggerHandler_PositiveTest(){
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
        
        Test.startTest();
            List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__OrderProduct__c = listOrderItem[0].Id,
                blng__StartDate__c = Date.today(),
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            TriggerHandlerBase.bypass('InvoiceLineTriggerHandler');
            insert listInvoiceLines;

            InvoiceLineTriggerHandler triggerHandler = new InvoiceLineTriggerHandler( listInvoiceLines, null);
            triggerHandler.handleAfterInsert();
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice to be updated with the order id');
    }

    @isTest
    static void afterInsert_setInvoiceOrder_NewOrderTest(){
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
            Type = 'New',
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
        
        Test.startTest();
            List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__OrderProduct__c = listOrderItem[0].Id,
                blng__StartDate__c = Date.today(),
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            insert listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice to be updated with the order id');
    }

    @isTest
    static void afterInsert_setInvoiceOrder_OrderAmendmentTest(){
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
            Type = 'Amendment',
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
        
        Test.startTest();
            List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__OrderProduct__c = listOrderItem[0].Id,
                blng__StartDate__c = Date.today(),
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            insert listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice is populated with the amendment order');
    }

    @isTest
    static void afterInsert_setInvoiceOrder_NewOrderNegativeTest(){
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
        for(Integer i = 0; i<2; i++){
            listOrder.add( new Order( 
                Status = 'Draft',
                Type = 'New',
                ShippingCountry = 'United States',
                blng__BillingAccount__c = testAccount.Id,
                AccountId = testAccount.Id,
                EffectiveDate = Date.today(),
                EndDate = Date.today() + 60,
                blng__BillingDayOfMonth__c = '1',
                Pricebook2Id = pricebookId,
                BillingCity = 'Test'+i,
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

        }
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
            blng__Order__c = listOrder[1].Id,
            blng__InvoiceStatus__c = 'Posted');
        insert testInvoice;
        
        Test.startTest();
            List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__OrderProduct__c = listOrderItem[0].Id,
                blng__StartDate__c = Date.today(),
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            insert listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[1].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field to not be updated');
    }

    @isTest
    static void afterInsert_setInvoiceOrder_BulkTest(){

        Integer numberOfOrders = 4,
                numberOrderItemsPerOrder = BULK_COUNT / numberOfOrders;
        
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
        for(Integer i=0; i < numberOfOrders; i++){
            listOrder.add( new Order( 
                Status = 'Draft',
                Type = 'New',
                ShippingCountry = 'United States',
                blng__BillingAccount__c = testAccount.Id,
                AccountId = testAccount.Id,
                EffectiveDate = Date.today(),
                EndDate = Date.today() + 60,
                blng__BillingDayOfMonth__c = '1',
                Pricebook2Id = pricebookId,
                BillingCity = 'Test'+i,
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
        }
        insert listOrder;
        
        List<OrderItem> listOrderItem = new List<OrderItem>();
        for(Order thisOrder : listOrder){
            for(Integer i = 0; i < numberOrderItemsPerOrder; i++){
                listOrderItem.add( new OrderItem(
                    OrderId = thisOrder.Id,
                    SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
                    UnitPrice = 100.00 +i,
                    blng__BillingRule__c = objBillingRule.Id,
                    blng__RevenueRecognitionRule__c = objRevenueRec.Id,
                    blng__TaxRule__c = objTaxRule.Id,
                    EndDate = thisOrder.EndDate,
                    Product2Id = listProducts[0].Id,
                    PricebookEntryId = listPbEntry[0].Id,
                    Quantity = 1
                ));
            }
        }
       
        insert listOrderItem;
        Map<Id, blng__Invoice__c> mapInvoiceByOrderId = new Map<Id, blng__Invoice__c>();
        for(Order thisOrder : listOrder){
            blng__Invoice__c thisInvoice = new blng__Invoice__c(
                blng__Account__c =  testAccount.Id,
                blng__InvoiceStatus__c = 'Posted');
                
            mapInvoiceByOrderId.put(thisOrder.Id, thisInvoice);
        }
        insert mapInvoiceByOrderId.values();
        
        Test.startTest();
            List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            for( OrderItem thisOrderItem : listOrderItem){
                blng__Invoice__c thisInvoice = mapInvoiceByOrderId.get( thisOrderItem.OrderId );
                listInvoiceLines.add( new blng__InvoiceLine__c(
                        blng__Invoice__c = thisInvoice.Id,
                        blng__OrderProduct__c = thisOrderItem.Id,
                        blng__StartDate__c = Date.today(),
                        blng__EndDate__c = thisOrderItem.EndDate,
                        blng__Product__c = listProducts[0].Id,
                        blng__Quantity__c = 1));
            }
           
            insert listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(numberOfOrders, listInvoiceResult.size(), 'We expect only 4 invoices at this time');
      
    }

    @isTest
    static void afterUpdate_setOrderProduct_positiveTest(){
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
            Type = 'New',
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

        List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__StartDate__c = Date.today(),
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            insert listInvoiceLines;

        List<blng__Invoice__c> listBeforeInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listBeforeInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( null, listBeforeInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice to be null');
        
        Test.startTest();
            for( blng__InvoiceLine__c thisInvoiceLine : listInvoiceLines){
                thisInvoiceLine.blng__OrderProduct__c= listOrderItem[0].Id;
            }
            update listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice to be updated with the order id');
    }

    @isTest
    static void afterUpdate_setOrderProductNull_negativeTest(){
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
            Type = 'New',
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

        listOrder.add( new Order( 
            Status = 'Draft',
            Type = 'New',
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

        listOrderItem.add( new OrderItem(
            OrderId = listOrder[1].Id,
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

        List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__StartDate__c = Date.today(),
                blng__OrderProduct__c= listOrderItem[0].Id,
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            insert listInvoiceLines;

        List<blng__Invoice__c> listBeforeInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listBeforeInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listBeforeInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice to be updated with the order id');
        
        Test.startTest();
            for( blng__InvoiceLine__c thisInvoiceLine : listInvoiceLines){
                thisInvoiceLine.blng__OrderProduct__c = null;
            }
            update listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field to remain the same');
    }

    @isTest
    static void afterUpdate_setOrderProduct_negativeTest(){
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
            Type = 'New',
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

        listOrder.add( new Order( 
            Status = 'Draft',
            Type = 'New',
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

        listOrderItem.add( new OrderItem(
            OrderId = listOrder[1].Id,
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

        List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__StartDate__c = Date.today(),
                blng__OrderProduct__c= listOrderItem[0].Id,
                blng__EndDate__c = listOrderItem[0].EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
            insert listInvoiceLines;

        List<blng__Invoice__c> listBeforeInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listBeforeInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listBeforeInvoiceResult[0].blng__Order__c, 'We expect the order field on the invoice to be updated with the order id');
        
        Test.startTest();
            for( blng__InvoiceLine__c thisInvoiceLine : listInvoiceLines){
                thisInvoiceLine.blng__OrderProduct__c = listOrderItem[1].Id;
            }
            update listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( listOrder[0].Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field to remain the same');
    }

    @isTest
    static void afterInsert_setOrderProductAmendment_positiveTest(){
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
        Order newOrder = new Order( 
            Status = 'Draft',
            Type = 'New',
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
        );
        listOrder.add( newOrder );

        Order amendmentOrder = new Order( 
            Status = 'Draft',
            Type = 'Amendment',
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
        );
        listOrder.add( amendMentOrder );
        insert listOrder;
        
        List<OrderItem> listOrderItem = new List<OrderItem>();
        OrderItem newOrderItem =  new OrderItem(
            OrderId = newOrder.Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = objBillingRule.Id,
            blng__RevenueRecognitionRule__c = objRevenueRec.Id,
            blng__TaxRule__c = objTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = listProducts[0].Id,
            PricebookEntryId = listPbEntry[0].Id,
            Quantity = 1
        );
        listOrderItem.add( newOrderItem );

        OrderItem amendmentOrderItem = new OrderItem(
            OrderId = amendmentOrder.Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = objBillingRule.Id,
            blng__RevenueRecognitionRule__c = objRevenueRec.Id,
            blng__TaxRule__c = objTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = listProducts[0].Id,
            PricebookEntryId = listPbEntry[0].Id,
            Quantity = 1
        );
        listOrderItem.add( amendmentOrderItem );
        insert listOrderItem;
        
        blng__Invoice__c testInvoice = new blng__Invoice__c(
            blng__Account__c =  testAccount.Id,
            blng__InvoiceStatus__c = 'Posted');
        insert testInvoice;

        List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__StartDate__c = Date.today(),
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));

            listInvoiceLines.add( new blng__InvoiceLine__c(
                blng__Invoice__c = testInvoice.Id,
                blng__StartDate__c = Date.today(),
                blng__OrderProduct__c = amendmentOrderItem.Id,
                blng__EndDate__c = amendmentOrderItem.EndDate,
                blng__Product__c = listProducts[0].Id,
                blng__Quantity__c = 1));
           
        
        Test.startTest();
            insert listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( amendmentOrder.Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field to populate with amendment order since no New order is available');
    }


    @isTest
    static void afterInsert_setOrderProduct_NewAndAmendment_positiveTest(){
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
        Order newOrder = new Order( 
            Status = 'Draft',
            Type = 'New',
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
        );
        listOrder.add( newOrder );

        Order amendmentOrder = new Order( 
            Status = 'Draft',
            Type = 'Amendment',
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
        );
        listOrder.add( amendMentOrder );
        insert listOrder;
        
        List<OrderItem> listOrderItem = new List<OrderItem>();
        OrderItem newOrderItem =  new OrderItem(
            OrderId = newOrder.Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = objBillingRule.Id,
            blng__RevenueRecognitionRule__c = objRevenueRec.Id,
            blng__TaxRule__c = objTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = listProducts[0].Id,
            PricebookEntryId = listPbEntry[0].Id,
            Quantity = 1
        );
        listOrderItem.add( newOrderItem );

        OrderItem amendmentOrderItem = new OrderItem(
            OrderId = amendmentOrder.Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = objBillingRule.Id,
            blng__RevenueRecognitionRule__c = objRevenueRec.Id,
            blng__TaxRule__c = objTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = listProducts[0].Id,
            PricebookEntryId = listPbEntry[0].Id,
            Quantity = 1
        );
        listOrderItem.add( amendmentOrderItem );
        insert listOrderItem;
        
        blng__Invoice__c testInvoice = new blng__Invoice__c(
            blng__Account__c =  testAccount.Id,
            blng__InvoiceStatus__c = 'Posted');
        insert testInvoice;

        List<blng__InvoiceLine__c> listInvoiceLines = new List<blng__InvoiceLine__c>();
        listInvoiceLines.add( new blng__InvoiceLine__c(
            blng__Invoice__c = testInvoice.Id,
            blng__StartDate__c = Date.today(),
            blng__OrderProduct__c = amendmentOrderItem.Id,
            blng__EndDate__c = amendmentOrderItem.EndDate,
            blng__Product__c = listProducts[0].Id,
            blng__Quantity__c = 1));
        listInvoiceLines.add( new blng__InvoiceLine__c(
            blng__Invoice__c = testInvoice.Id,
            blng__StartDate__c = Date.today(),
            blng__OrderProduct__c = newOrderItem.Id,
            blng__EndDate__c = newOrderItem.EndDate,
            blng__Product__c = listProducts[0].Id,
            blng__Quantity__c = 1));
       
        
        Test.startTest();
            insert listInvoiceLines;
        Test.stopTest();
        List<blng__Invoice__c> listInvoiceResult = [SELECT Id, blng__Order__c FROM blng__Invoice__c];
        System.assertEquals(1, listInvoiceResult.size(), 'We expect a single invoice at this time');
        System.assertEquals( newOrder.Id, listInvoiceResult[0].blng__Order__c, 'We expect the order field to populate with New order since no New order is available');
    }
}