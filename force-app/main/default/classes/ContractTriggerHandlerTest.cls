@isTest
public with sharing class ContractTriggerHandlerTest {
    static String   STATUS_DRAFT = 'Draft',
                    SETUP_MASTER_CUSTOMER_NUMBER = 'SETUPMASTERCONTRACT',
                    EXPECTED_MASTER_CUSTOMER_NUMBER='EXPECTEDMASTERNUMBER';
    static Date     START_DATE = Date.today(),
                    END_DATE = START_DATE.addDays(25);
    static Integer BULK_COUNT = LIMITS.getLimitQueries()+1;

    
    @TestSetup
    static void setupData(){
       
        
        Account thisAccount = new Account(name = 'ContractTestAccount',
                        LOB__c = 'FINANCIAL',
                        //  MDM_Data_Source_Code__c='CDM',
                        Master_Customer_Number__c = SETUP_MASTER_CUSTOMER_NUMBER,
                        Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
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
        //thisOpportunity.SALES_ORG__C = s.id;
        thisOpportunity.INVOICE_TRIGGER__C = 'Shipment';
        //thisOpportunity.PRIMARY_COMPETITOR__C = c.id;
        thisOpportunity.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        thisOpportunity.closeDate = System.TODAY();
        thisOpportunity.stagename = 'Prospecting';
       // thisOpportunity.recordTypeId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get();
        thisOpportunity.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        thisOpportunity.EndCustomerUnknown__c = true; 
        thisOpportunity.Skip_Validation_Rule_for_Lead_Conversion__c = true;
        thisOpportunity.ForecastCategoryName ='Omitted';
        insert thisOpportunity;
        
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true);
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
            blng__Active__c = TRUE);
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
        
        Order thisOrder = new order(    Pricebook2Id = stdPbId, 
                                        AccountId = thisAccount.id, 
                                        Status = STATUS_DRAFT, 
                                        EffectiveDate = Date.Today(), 
                                        blng__BillingDayOfMonth__c = '28',
                                        qtc_Bill_To_Site__c = thisAccount.Id,
                                        Deliver_To_Site__c = thisAccount.Id,
                                        SBQQ__Quote__c=thisQuote.Id);
        insert thisOrder;
        
        OrderItem thisOrderProduct = new OrderItem(     PriceBookEntryId = standardPrice.Id, 
                                                        OrderId = thisOrder.Id, 
                                                        Quantity = 1, 
                                                        SBQQ__OrderedQuantity__c = 1, 
                                                        UnitPrice = standardPrice.UnitPrice, 
                                                        SBQQ__ChargeType__c = 'One-Time',
                                                        ServiceDate = Date.Today());
        insert thisOrderProduct;

        Contract testContract = new Contract(
            StartDate = START_DATE,
            SBQQ__Order__c = thisOrder.Id,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = lstProducts[0].Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__OrderProduct__c = thisOrderProduct.Id,
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
        insert subs;
     
        
    }
    @isTest
    static void handleAfterUpdate_billToAccountMultipleTest(){
        Integer orderCount = 3;
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
       
        List<Order> listOrders = new List<Order>();
        for(Integer i=0; i<orderCount; i++){
            Order thisOrder = new order(    Pricebook2Id = stdPbId, 
                AccountId = thisAccount.id, 
                Status = STATUS_DRAFT, 
                EffectiveDate = Date.Today(), 
                blng__BillingDayOfMonth__c = '28',
                qtc_Bill_To_Site__c = thisAccount.Id,
                SBQQ__Quote__c=thisQuote.Id);
            listOrders.add(thisOrder);
        }
       
        insert listOrders;

        list<OrderItem> listOrderItems = new List<OrderItem>();
        for(Order thisOrder : listOrders){
            OrderItem thisOrderProduct = new OrderItem(     PriceBookEntryId = standardPrice.Id, 
                                                            OrderId = thisOrder.Id, 
                                                            Quantity = 1, 
                                                            SBQQ__OrderedQuantity__c = 1, 
                                                            UnitPrice = standardPrice.UnitPrice, 
                                                            SBQQ__ChargeType__c = 'One-Time',
                                                            ServiceDate = Date.Today());
            listOrderItems.add(thisOrderProduct);
        }
        insert listOrderItems;

        Contract testContract = [SELECT Id FROM Contract LIMIT 1];
        
        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
        for(Integer i =0; i< orderCount -1; i++){
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = testContract.Id, 
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__OrderProduct__c = listOrderItems[i].Id,
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
            listSubscriptions.add(subs);
        }
        insert listSubscriptions;

        Account expectedAccount = new Account(name = EXPECTED_MASTER_CUSTOMER_NUMBER,
                LOB__c = 'FINANCIAL',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                Master_Customer_Number__c = EXPECTED_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abcd@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert expectedAccount;
        }

        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Bill_To_Site__c FROM Order];
        System.assertEquals(4, listOrderBeforeUpdate.size(), 'We expect four one Order at this time');

      
        Test.startTest();
            testContract.qtc_Bill_To_Account__c = expectedAccount.Id;
            testContract.qtc_Deliver_To_Site__c = expectedAccount.Id;
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Bill_To_Site__c FROM Order WHERE qtc_Bill_To_Site__c= :expectedAccount.Id];
        System.assertEquals(3, listOrderResults.size(), 'We expect 2 Orders to be updated because there are only two subscriptions');

    }


    @isTest
    static void handleAfterUpdate_billToAccountPositiveTest(){
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
       
        Account expectedAccount = new Account(name = EXPECTED_MASTER_CUSTOMER_NUMBER,
                LOB__c = 'FINANCIAL',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                Master_Customer_Number__c = EXPECTED_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abcd@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert expectedAccount;
        }

        Contract testContract = [SELECT Id FROM Contract LIMIT 1];
        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c FROM Order];
        System.assertEquals(1, listOrderBeforeUpdate.size(), 'We expect only one Order at this time');
        System.assertEquals( thisAccount.Id,  listOrderBeforeUpdate[0].qtc_Bill_To_Site__c, 'We expect the Bill To Site to be the setup account Id');

        Test.startTest();
       
            testContract.qtc_Bill_To_Account__c = expectedAccount.Id;
            testContract.qtc_Deliver_To_Site__c = expectedAccount.Id;
            System.debug('## testContract '+testContract);
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c FROM Order];
        System.assertEquals(1, listOrderResults.size(), 'We expect only one Order at this time');
        System.assertEquals( expectedAccount.Id, listOrderResults[0].qtc_Bill_To_Site__c, 'We expect the Bill To Site to be updated with the expected Account Id');
        System.assertEquals( listOrderBeforeUpdate[0].qtc_Hold_Billing__c, listOrderResults[0].qtc_Hold_Billing__c, 'We expect the holdbilling field to not be updated');

    }

    @isTest
    static void handleAfterUpdate_setHoldBillingTrueTest(){
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        Contract testContract = [SELECT Id FROM Contract LIMIT 1];

        thisAccount.Bill_To__c = true;
        thisAccount.Primary_Bill_To__c = true;
        thisAccount.Bill_To__c = true;
        thisAccount.Ship_To__c = true; 
        thisAccount.Primary_Ship_To__c = true;
        thisAccount.Deliver_To__c = true; 
        thisAccount.Primary_Deliver_To__c = true;
        update thisAccount;
        
        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Hold_Billing__c, qtc_Bill_To_Site__c FROM Order];
        listOrderBeforeUpdate[0].ContractId = testContract.Id;
        update listOrderBeforeUpdate;

        System.assertEquals(1, listOrderBeforeUpdate.size(), 'We expect only one Order at this time');
        System.assertEquals( false,  listOrderBeforeUpdate[0].qtc_Hold_Billing__c, 'We expect the hold billing field to be false');

        Test.startTest();
            testContract.qtc_Hold_Billing__c = true;
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Hold_Billing__c, qtc_Bill_To_Site__c FROM Order];
        System.assertEquals(1, listOrderResults.size(), 'We expect only one Order at this time');
        System.assertEquals( true, listOrderResults[0].qtc_Hold_Billing__c, 'We expect the hold billing field to be updated');
        System.assertEquals( listOrderBeforeUpdate[0].qtc_Bill_To_Site__c, listOrderResults[0].qtc_Bill_To_Site__c, 'We expect the bill to site to remain the same');

    }

    @isTest
    static void handleAfterUpdate_setHoldBillingFalseTest(){
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        Contract testContract = [SELECT Id FROM Contract LIMIT 1];

        thisAccount.Bill_To__c = true;
        thisAccount.Primary_Bill_To__c = true;
        thisAccount.Bill_To__c = true;
        thisAccount.Ship_To__c = true; 
        thisAccount.Primary_Ship_To__c = true;
        thisAccount.Deliver_To__c = true; 
        thisAccount.Primary_Deliver_To__c = true;
        update thisAccount;
        
        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Hold_Billing__c, qtc_Bill_To_Site__c FROM Order];
        listOrderBeforeUpdate[0].ContractId = testContract.Id;
        update listOrderBeforeUpdate;

        testContract.qtc_Hold_Billing__c = true;
        update testContract;

        Test.startTest();
            testContract.qtc_Hold_Billing__c = false;
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Hold_Billing__c, qtc_Bill_To_Site__c FROM Order];
        System.assertEquals(1, listOrderResults.size(), 'We expect only one Order at this time');
        System.assertEquals( false, listOrderResults[0].qtc_Hold_Billing__c, 'We expect the hold billing field to be updated');
        System.assertEquals( listOrderBeforeUpdate[0].qtc_Bill_To_Site__c, listOrderResults[0].qtc_Bill_To_Site__c, 'We expect the bill to site to remain the same');

    }

    @isTest
    static void handleAfterUpdate_billToAccount_HoldBillingPositiveTest(){
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
       
        Account expectedAccount = new Account(name = EXPECTED_MASTER_CUSTOMER_NUMBER,
                LOB__c = 'FINANCIAL',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                Master_Customer_Number__c = EXPECTED_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abcd@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert expectedAccount;
        }

        Contract testContract = [SELECT Id FROM Contract LIMIT 1];
        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c FROM Order];
        listOrderBeforeUpdate[0].ContractId = testContract.Id;
        update listOrderBeforeUpdate;

        System.assertEquals(1, listOrderBeforeUpdate.size(), 'We expect only one Order at this time');
        System.assertEquals( thisAccount.Id,  listOrderBeforeUpdate[0].qtc_Bill_To_Site__c, 'We expect the Bill To Site to be the setup account Id');

        Test.startTest();
       
            testContract.qtc_Bill_To_Account__c = expectedAccount.Id;
            testContract.qtc_Deliver_To_Site__c = expectedAccount.Id;
            testContract.qtc_Hold_Billing__c = true;
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c FROM Order];
        System.assertEquals(1, listOrderResults.size(), 'We expect only one Order at this time');
        System.assertEquals( expectedAccount.Id, listOrderResults[0].qtc_Bill_To_Site__c, 'We expect the Bill To Site to be updated with the expected Account Id');
        System.assertEquals( true, listOrderResults[0].qtc_Hold_Billing__c, 'We expect the holdbilling field to be updated');

    }

    @isTest
    static void handleAfterUpdate_bulkTest(){
        CPQMyNcrRequestAsync.bypassQuoteTrigger = true;
        Integer orderCount = BULK_COUNT;
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
       
        List<Order> listOrders = new List<Order>();
        for(Integer i=0; i<orderCount; i++){
            Order thisOrder = new order(    Pricebook2Id = stdPbId, 
                AccountId = thisAccount.id, 
                Status = STATUS_DRAFT, 
                EffectiveDate = Date.Today(), 
                blng__BillingDayOfMonth__c = '28',
                qtc_Bill_To_Site__c = thisAccount.Id,
                SBQQ__Quote__c=thisQuote.Id);
            listOrders.add(thisOrder);
        }
       
        insert listOrders;

        list<OrderItem> listOrderItems = new List<OrderItem>();
        for(Order thisOrder : listOrders){
            OrderItem thisOrderProduct = new OrderItem(     PriceBookEntryId = standardPrice.Id, 
                                                            OrderId = thisOrder.Id, 
                                                            Quantity = 1, 
                                                            SBQQ__OrderedQuantity__c = 1, 
                                                            UnitPrice = standardPrice.UnitPrice, 
                                                            SBQQ__ChargeType__c = 'One-Time',
                                                            ServiceDate = Date.Today());
            listOrderItems.add(thisOrderProduct);
        }
        insert listOrderItems;

        List<Contract> listContracts = new List<Contract>();
        for(Order thisOrder: listOrders){
            listContracts.add( new Contract(
                StartDate = START_DATE,
                SBQQ__Order__c = thisOrder.Id,
                AccountId=thisAccount.Id
            ));
        }
        insert listContracts;

        List<Order> listOrdersToUpdateWithContracts = new List<Order>();
        for(Contract thisContract : listContracts){
            listOrdersToUpdateWithContracts.add( new Order(
                Id = thisContract.SBQQ__Order__c,
                ContractId = thisContract.Id
            ));
        }
        update listOrdersToUpdateWithContracts;
        
        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
        for(Integer i =0; i< orderCount -1; i++){
             SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = listContracts[i].Id, 
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Quantity__c = 5, 
            SBQQ__OrderProduct__c = listOrderItems[i].Id,
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__SubscriptionEndDate__c = END_DATE);
            listSubscriptions.add(subs);
        }
        insert listSubscriptions;

        Account expectedAccount = new Account(name = EXPECTED_MASTER_CUSTOMER_NUMBER,
                LOB__c = 'FINANCIAL',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                Master_Customer_Number__c = EXPECTED_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abcd@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert expectedAccount;
        }

        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Bill_To_Site__c FROM Order];
      
        Test.startTest();
            for(Contract thisContract : listContracts){
                thisContract.qtc_Bill_To_Account__c = expectedAccount.Id;
                thisContract.qtc_Deliver_To_Site__c = expectedAccount.Id;
                thisContract.qtc_Hold_Billing__c = true;

            }
            Update listContracts;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Bill_To_Site__c FROM Order];
        System.assertEquals(orderCount+1, listOrderResults.size(), 'We expect the bulk count + 1 orders to be returned');

    }

    @isTest
    static void handleAfterUpdate_deliverToSitePositiveTest(){
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];

       
       
        Account expectedAccount = new Account(name = EXPECTED_MASTER_CUSTOMER_NUMBER,
                LOB__c = 'FINANCIAL',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                Master_Customer_Number__c = EXPECTED_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abcd@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert expectedAccount;
        }

        thisAccount.Bill_To__c = true;
        thisAccount.Primary_Bill_To__c = true;
        thisAccount.Bill_To__c = true;
        thisAccount.Ship_To__c = true; 
        thisAccount.Primary_Ship_To__c = true;
        thisAccount.Deliver_To__c = true; 
        thisAccount.Primary_Deliver_To__c = true;
        update thisAccount;

        Contract testContract = [SELECT Id FROM Contract LIMIT 1];
        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c, Deliver_To_Site__c FROM Order];
        System.assertEquals(1, listOrderBeforeUpdate.size(), 'We expect only one Order at this time');
        System.assertEquals( thisAccount.Id,  listOrderBeforeUpdate[0].Deliver_To_Site__c, 'We expect the Bill To Site to be the setup account Id');

        Test.startTest();
       
            testContract.qtc_Bill_To_Account__c = thisAccount.Id;
            testContract.qtc_Deliver_To_Site__c = expectedAccount.Id;
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c, Deliver_To_Site__c FROM Order];
        System.assertEquals(1, listOrderResults.size(), 'We expect only one Order at this time');
        System.assertEquals( expectedAccount.Id, listOrderResults[0].Deliver_To_Site__c, 'We expect the Deliver To Site to be updated with the expected Account Id');
        System.assertEquals( thisAccount.Id, listOrderResults[0].qtc_Bill_To_Site__c, 'We expect the Bill To Site to remain the same');
        System.assertEquals( listOrderBeforeUpdate[0].qtc_Hold_Billing__c, listOrderResults[0].qtc_Hold_Billing__c, 'We expect the holdbilling field to not be updated');

    }

    @isTest
    static void handleAfterUpdate_billToAndDeliverToSitePositiveTest(){
        Id stdPbId = Test.getStandardPricebookId();       
        Account thisAccount = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c thisQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PricebookEntry  standardPrice = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
       
        Account expectedAccount = new Account(name = EXPECTED_MASTER_CUSTOMER_NUMBER,
                LOB__c = 'FINANCIAL',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                Master_Customer_Number__c = EXPECTED_MASTER_CUSTOMER_NUMBER,
                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                Active_Account__c = true,
                Project_Coordinator_Email__c = 'abcd@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert expectedAccount;
        }

        Contract testContract = [SELECT Id FROM Contract LIMIT 1];
        list<Order> listOrderBeforeUpdate = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c, Deliver_To_Site__c FROM Order];
        System.assertEquals(1, listOrderBeforeUpdate.size(), 'We expect only one Order at this time');
        System.assertEquals( thisAccount.Id,  listOrderBeforeUpdate[0].Deliver_To_Site__c, 'We expect the Bill To Site to be the setup account Id');

        Test.startTest();
       
            testContract.qtc_Bill_To_Account__c = expectedAccount.Id;
            testContract.qtc_Deliver_To_Site__c = expectedAccount.Id;
            Update testContract;
        Test.stopTest();

        list<Order> listOrderResults = [SELECT Id, qtc_Bill_To_Site__c, qtc_Hold_Billing__c, Deliver_To_Site__c FROM Order];
        System.assertEquals(1, listOrderResults.size(), 'We expect only one Order at this time');
        System.assertEquals( expectedAccount.Id, listOrderResults[0].Deliver_To_Site__c, 'We expect the Deliver To Site to be updated with the expected Account Id');
        System.assertEquals( expectedAccount.Id, listOrderResults[0].qtc_Bill_To_Site__c, 'We expect the Bill To Site to be updated with the expected account id');
        System.assertEquals( listOrderBeforeUpdate[0].qtc_Hold_Billing__c, listOrderResults[0].qtc_Hold_Billing__c, 'We expect the holdbilling field to not be updated');

    }
}