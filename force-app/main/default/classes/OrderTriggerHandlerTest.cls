@isTest
public with sharing class OrderTriggerHandlerTest {
    static String   CHARGE_TYPE_ONE_TIME = 'One-Time';
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;

    @TestSetup
    static void setupData(){
        User Usr = [Select Id from User Where Name = 'Soup User'];
            
            Account testAccount = new Account(
                    Name='Test Account',
                    Type = 'Suspect');
            System.runAs(Usr){   
                insert testAccount;
            }    
      
            Id pricebookId = Test.getStandardPricebookId();
            blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(
                Name = 'test legal entity',
                CurrencyIsoCode = 'USD',
                blng__Active__c = True );
            insert testLegalEntity;
            
            
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
        
    }

    @isTest
    static void triggerHandler_HoldBillingSetToTrueTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();   

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
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = thisProduct.Id,
            PricebookEntryId = thisPriceBookEntry.Id,
            Quantity = 1
        ));
       
        insert listOrderItem;

        List<Order> listNewOrders = listOrder.deepClone(true, false, true);
        for(Order newOrder : listNewOrders ){
            newOrder.qtc_Hold_Billing__c = true;
        }

        Map<Id, Order> mapOldOrders = new Map<Id, Order>( listOrder );
        
        Test.startTest();
            OrderTriggerHandler triggerHandler = new OrderTriggerHandler(listNewOrders, mapOldOrders);
            triggerHandler.handleAfterUpdate();
        Test.stopTest();

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');
        System.assertEquals( 'Yes', listOrderItemsResult[0].blng__HoldBilling__c, 'We expect the Order Items Hold Billing field to be updated');

    }

    @isTest
    static void triggerHandler_HoldBillingSetToFalseTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();

        List<Order> listOrder = new List<Order>();
        listOrder.add( new Order( 
            qtc_Hold_Billing__c = true,
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
            blng__HoldBilling__c = 'Yes',
            OrderId = listOrder[0].Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = thisProduct.Id,
            PricebookEntryId = thisPriceBookEntry.Id,
            Quantity = 1
        ));
       
        insert listOrderItem;

        List<Order> listNewOrders = listOrder.deepClone(true, false, true);
        for(Order newOrder : listNewOrders ){
            newOrder.qtc_Hold_Billing__c = false;
        }

        Map<Id, Order> mapOldOrders = new Map<Id, Order>( listOrder );
        
        Test.startTest();
            OrderTriggerHandler triggerHandler = new OrderTriggerHandler(listNewOrders, mapOldOrders);
            triggerHandler.handleAfterUpdate();
        Test.stopTest();

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');
        System.assertEquals( 'No', listOrderItemsResult[0].blng__HoldBilling__c, 'We expect the Order Items Hold Billing field to be updated');

    }

    @isTest
    static void triggerHandler_NegativeTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();

        List<Order> listOrder = new List<Order>();
        listOrder.add( new Order( 
            qtc_Hold_Billing__c = false,
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
            blng__HoldBilling__c = 'No',
            OrderId = listOrder[0].Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = thisProduct.Id,
            PricebookEntryId = thisPriceBookEntry.Id,
            Quantity = 1
        ));
       
        insert listOrderItem;

        List<Order> listNewOrders = listOrder.deepClone(true, false, true);
        Map<Id, Order> mapOldOrders = new Map<Id, Order>( listOrder );
        
        Test.startTest();
            OrderTriggerHandler triggerHandler = new OrderTriggerHandler(listNewOrders, mapOldOrders);
            triggerHandler.handleAfterUpdate();
        Test.stopTest();

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');
        System.assertEquals( 'No', listOrderItemsResult[0].blng__HoldBilling__c, 'We expect the Order Items Hold Billing field remains the same');

    }

    @isTest
    static void afterUpdate_HoldBillingSetToTrueTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();   

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
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = thisProduct.Id,
            PricebookEntryId = thisPriceBookEntry.Id,
            Quantity = 1
        ));
       
        insert listOrderItem;
        
        Test.startTest();
            for(Order thisOrder : listOrder ){
                thisOrder.qtc_Hold_Billing__c = true;
            }
            update listOrder;
        Test.stopTest();

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');
        System.assertEquals( 'Yes', listOrderItemsResult[0].blng__HoldBilling__c, 'We expect the Order Items Hold Billing field to be updated');

    }

    @isTest
    static void afterUpdate_HoldBillingSetToFalseTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();

        List<Order> listOrder = new List<Order>();
        listOrder.add( new Order( 
            qtc_Hold_Billing__c = true,
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
            blng__HoldBilling__c = 'Yes',
            OrderId = listOrder[0].Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = thisProduct.Id,
            PricebookEntryId = thisPriceBookEntry.Id,
            Quantity = 1
        ));
       
        insert listOrderItem;
        List<Order> preOrder = [SELECT Id,qtc_Hold_Billing__c FROM Order ];
        Test.startTest();
            for(Order thisOrder : listOrder ){
                thisOrder.qtc_Hold_Billing__c = false;
            }
            update listOrder;
        Test.stopTest();
        List<Order> postOrder = [SELECT Id,qtc_Hold_Billing__c FROM Order ];

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');
        System.assertEquals( 'No', listOrderItemsResult[0].blng__HoldBilling__c, 'We expect the Order Items Hold Billing field to be updated');

    }

    @isTest
    static void afterUpdate_NegativeTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();

        List<Order> listOrder = new List<Order>();
        listOrder.add( new Order( 
            qtc_Hold_Billing__c = false,
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
            blng__HoldBilling__c = 'No',
            OrderId = listOrder[0].Id,
            SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
            UnitPrice = 100.00,
            blng__BillingRule__c = thisBillingRule.Id,
            blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
            blng__TaxRule__c = thisTaxRule.Id,
            EndDate = listOrder[0].EndDate,
            Product2Id = thisProduct.Id,
            PricebookEntryId = thisPriceBookEntry.Id,
            Quantity = 1
        ));
       
        insert listOrderItem;
        
        Test.startTest();
           for(Order thisOrder : listOrder ){
               thisOrder.EndDate = Date.today().addDays(100);
           }
           update listOrder;
        Test.stopTest();

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');
        System.assertEquals( 'No', listOrderItemsResult[0].blng__HoldBilling__c, 'We expect the Order Items Hold Billing field remains the same');

    }

    @isTest
    static void afterUpdate_BulkTest(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        blng__BillingRule__c thisBillingRule = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
        blng__RevenueRecognitionRule__c thisRevenueRec = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1];
        blng__TaxRule__c thisTaxRule = [SELECT Id FROM blng__TaxRule__c LIMIT 1];
        Product2 thisProduct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry thisPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Id pricebookId = Test.getStandardPricebookId();

        List<Order> listOrder = new List<Order>();
        for(Integer i= 0; i < BULK_COUNT; i++){
            listOrder.add( new Order( 
                qtc_Hold_Billing__c = true,
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
        }
        insert listOrder;
        
        List<OrderItem> listOrderItem = new List<OrderItem>();
        for(Order thisOrder : listOrder){
            listOrderItem.add( new OrderItem(
                blng__HoldBilling__c = 'Yes',
                OrderId = thisOrder.Id,
                SBQQ__ChargeType__c = CHARGE_TYPE_ONE_TIME,
                UnitPrice = 100.00,
                blng__BillingRule__c = thisBillingRule.Id,
                blng__RevenueRecognitionRule__c = thisRevenueRec.Id,
                blng__TaxRule__c = thisTaxRule.Id,
                EndDate = thisOrder.EndDate,
                Product2Id = thisProduct.Id,
                PricebookEntryId = thisPriceBookEntry.Id,
                Quantity = 1
            ));

        }
       
        insert listOrderItem;
        List<Order> preOrder = [SELECT Id,qtc_Hold_Billing__c FROM Order ];
        Test.startTest();
            for(Order thisOrder : listOrder ){
                thisOrder.qtc_Hold_Billing__c = false;
            }
            update listOrder;
        Test.stopTest();
        List<Order> postOrder = [SELECT Id,qtc_Hold_Billing__c FROM Order ];

        List<OrderItem> listOrderItemsResult = [SELECT Id, blng__HoldBilling__c FROM OrderItem];
        System.assertEquals( listOrderItem.size(), listOrderItemsResult.size(), 'We expect the same number of OrderItems');

    }
}