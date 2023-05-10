@isTest
public with sharing class qtcQuoteTriggerHandlerTest {
    private static Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();
  private static String   BILLING_FREQUENCY_MONTHLY       = 'Monthly',
                            MULTI_SITE_TYPE_AE_PP           = 'AE+PP',
                            MULTI_SITE_RELATIONSHIP_PARENT  = 'Parent',
                            MULTI_SITE_RELATIONSHIP_CHILD   = 'Child',
                            TYPE_AMENDMENT                  = 'Amendment',
                            PAYMENT_TYPE_FULL_PAYMENT       = 'Full NCR Payments',
                            PAYMENT_TYPE_NO_PAYMENT         = 'No Payments',
                            PAYMENTS_APPROVAL_ACTION_SUBMIT = 'Submit',
                            USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage';

    @isTest
    static void QuoteUpdate_StatusRejectedTest () {
        
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__Status__c= qtcQuoteTriggerHandler.STATUS_DRAFT,
            ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_PENDING,
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;
        
        Test.startTest();
        
        testQuote.ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_REJECTED;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_DRAFT ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];

        System.assertEquals( qtcQuoteTriggerHandler.STATUS_DRAFT, updatedRecord.SBQQ__Status__c, 'We expect the status to be in the draft status' );
        System.assertEquals( null, updatedRecord.qtcApprovalStatusManual__c, 'We expect the field to be a blank' );
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the Draft Record Type' );
    }

    @isTest
    static void QuoteUpdate_StatusRejected_PaymentApprovalApprovedTest () {
        
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__Status__c= qtcQuoteTriggerHandler.STATUS_DRAFT,
            ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_PENDING,
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;

        qtc_PaymentsApproval__c testPaymentsApproval = new qtc_PaymentsApproval__c(
            qtc_ApprovalAction__c = PAYMENTS_APPROVAL_ACTION_SUBMIT,
            ApprovalStatus__c = qtcQuoteTriggerHandler.PAYMENT_APPROVAL_STATUS_APPROVED
        );
        insert testPaymentsApproval;
        
        Test.startTest();
        testQuote.Payments_Approval__c = testPaymentsApproval.Id;
        testQuote.ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_REJECTED;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_DRAFT ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];

        System.assertEquals( qtcQuoteTriggerHandler.STATUS_APPROVED_PAYMENTS_TEAM, updatedRecord.SBQQ__Status__c, 'We expect the CPQ status to be Approved Payments Team' );
        System.assertEquals( null, updatedRecord.qtcApprovalStatusManual__c, 'We expect the field to be a blank' );
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the Draft Record Type' );
    }

    @isTest
    static void QuoteUpdate_StatusRecalledTest () {
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            SBQQ__Status__c='Draft');
        insert testQuote;
        
        Test.startTest();
        
        testQuote.ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_RECALLED;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_DRAFT ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];

        System.assertEquals( qtcQuoteTriggerHandler.STATUS_DRAFT, updatedRecord.SBQQ__Status__c, 'We expect the status to be in the draft status' );
        System.assertEquals( null, updatedRecord.qtcApprovalStatusManual__c, 'We expect the field to be a blank' );
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the Draft Record Type' );
    }
    
    @isTest
    static void QuoteUpdate_StatusRecalled_PaymentsApprovalApprovedTest () {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_PENDING,
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id,
            SBQQ__Status__c='Draft');
        insert testQuote;

        qtc_PaymentsApproval__c testPaymentsApproval = new qtc_PaymentsApproval__c(
            qtc_ApprovalAction__c = PAYMENTS_APPROVAL_ACTION_SUBMIT,
            ApprovalStatus__c = qtcQuoteTriggerHandler.PAYMENT_APPROVAL_STATUS_APPROVED
        );
        insert testPaymentsApproval;
        
        Test.startTest();
        testQuote.Payments_Approval__c = testPaymentsApproval.Id;
        testQuote.ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_RECALLED;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_DRAFT ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];

        System.assertEquals( qtcQuoteTriggerHandler.STATUS_APPROVED_PAYMENTS_TEAM, updatedRecord.SBQQ__Status__c, 'We expect the CPQ status to be Approved Payments Team' );
        System.assertEquals( null, updatedRecord.qtcApprovalStatusManual__c, 'We expect the field to be a blank' );
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the Draft Record Type' );
    }

    @isTest
    static void QuoteUpdate_StatusDraftTest () {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;

        testQuote.SBQQ__Status__c= qtcQuoteTriggerHandler.STATUS_IN_REVIEW;
        update testQuote;
        
        Test.startTest();
        
        testQuote.SBQQ__Status__c = qtcQuoteTriggerHandler.STATUS_DRAFT;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_DRAFT ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the Draft Record Type' );
        System.assertEquals( qtcQuoteTriggerHandler.STATUS_DRAFT, updatedRecord.SBQQ__Status__c, 'We expect the status to be in the draft status' );
    }

    @isTest
    static void QuoteUpdate_ApprovalStatusPendingTest () {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;
        
        Test.startTest();
        
        testQuote.ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_PENDING;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_IN_PROGRESS ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the IN PROGRESS Record Type' );
        System.assertEquals( qtcQuoteTriggerHandler.STATUS_IN_REVIEW, updatedRecord.SBQQ__Status__c, 'We expect the status to be in the Review status' );
    }

    @isTest
    static void QuoteUpdate_ApprovalStatusManualPending_AfterUpdateApprovalSubmissionTest () {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;
       /* User sysAdmin = [ Select Id, Name 
                          From User
                        where Name = 'Austin McCollum'];*/
         
        User sysAdmin = [Select Id, profileId from User where name = 'Admin NSC' and isactive = true  limit 1];
        Test.startTest();
        System.runAs(sysAdmin){
        testQuote.qtcApprovalStatusManual__c = qtcQuoteTriggerHandler.STATUS_PENDING;
        update testQuote;      
        }
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_APPROVED ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];

        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the Apporved Record Type, from the after Update' );
        System.assertEquals( qtcQuoteTriggerHandler.STATUS_APPROVED, updatedRecord.SBQQ__Status__c, 'We expect the quote submit approval process to be invoked from the after update' );
    }

    @isTest
    static void QuoteUpdate_ApprovalStatusApprovedTest () {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
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
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            SBQQ__BillingFrequency__c = BILLING_FREQUENCY_MONTHLY,
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;
        
        Test.startTest();
        
        testQuote.ApprovalStatus__c = qtcQuoteTriggerHandler.STATUS_APPROVED;
        update testQuote;      
        
        Test.stopTest();
        Id expectedRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( qtcQuoteTriggerHandler.RECORD_TYPE_APPROVED ).getRecordTypeId();
        SBQQ__Quote__c updatedRecord = [SELECT RecordTypeId, SBQQ__Status__c, qtcApprovalStatusManual__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id ];
        System.assertEquals( expectedRecordTypeId, updatedRecord.RecordTypeId, 'We expect the record type to be the APPROVED Record Type' );
        System.assertEquals( qtcQuoteTriggerHandler.STATUS_APPROVED, updatedRecord.SBQQ__Status__c, 'We expect the status to be in the draft status' );
    }

    @isTest 
    static void QuoteUpdate_AEPP_ParentValidation_AmendmentCancelledTest(){
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
           /* SBQQ__Ordered__c                        = true,
            qtc_Cancelled__c                        = false,
            SBQQ__OriginalQuote__c                  = parentQuote.Id,
            SBQQ__MasterContract__c                 = testContract.id,
            qtc_Multi_Site__c                       = true,
            qtc_Multi_Site_Type__c                  = MULTI_SITE_TYPE_AE_PP,
            qtc_Multi_Site_Relationship__c          = MULTI_SITE_RELATIONSHIP_PARENT,
            qtc_Number_of_Sites_with_Payments__c    = 2,
            qtc_Payments_Type__c                    = PAYMENT_TYPE_NO_PAYMENT,
            SBQQ__StartDate__c                      = startDate,
            SBQQ__SubscriptionTerm__c               = 36,
            SBQQ__BillingFrequency__c               = BILLING_FREQUENCY_MONTHLY,
            SBQQ__EndDate__c                        = startDate.addDays(10),
            SBQQ__ProrationDayOfMonth__c            = String.valueOf( prorationDayOfMonth )*/
        );
        
        SBQQ__Quote__c amendmentCancelledQuote = new SBQQ__Quote__c(
            SBQQ__Type__c                           = TYPE_AMENDMENT,
            SBQQ__MasterContract__c                 = testContract.id,
            SBQQ__Account__c                        = thisAccount.id
           /* SBQQ__Ordered__c                        = true,
            qtc_Cancelled__c                        = true,
            SBQQ__OriginalQuote__c                  = parentQuote.Id,
            SBQQ__MasterContract__c                 = testContract.id,
            qtc_Multi_Site__c                       = true,
            qtc_Multi_Site_Type__c                  = MULTI_SITE_TYPE_AE_PP,
            qtc_Multi_Site_Relationship__c          = MULTI_SITE_RELATIONSHIP_PARENT,
            qtc_Number_of_Sites_with_Payments__c    = 2,
            qtc_Payments_Type__c                    = PAYMENT_TYPE_NO_PAYMENT,
            SBQQ__StartDate__c                      = startDate,
            SBQQ__SubscriptionTerm__c               = 36,
            SBQQ__BillingFrequency__c               = BILLING_FREQUENCY_MONTHLY,
            SBQQ__EndDate__c                        = startDate.addDays(10),
            SBQQ__ProrationDayOfMonth__c            = String.valueOf( prorationDayOfMonth )*/
        );

        List<SBQQ__Quote__c> listAmendmentQuotes = new List<SBQQ__Quote__c>{ amendmentQuote, amendmentCancelledQuote};
        insert listAmendmentQuotes;
       
        SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
            qtc_Multi_Site__c               = true,
            qtc_Multi_Site_Parent_Quote__c  = parentQuote.Id,
            qtc_Multi_Site_Type__c          = MULTI_SITE_TYPE_AE_PP,
            qtc_Multi_Site_Relationship__c  = MULTI_SITE_RELATIONSHIP_CHILD,
            qtc_Payments_Type__c            = PAYMENT_TYPE_FULL_PAYMENT,
            qtc_Cancelled__c                = false,
            SBQQ__StartDate__c              = startDate,
            SBQQ__SubscriptionTerm__c       = 36,
            SBQQ__BillingFrequency__c       = BILLING_FREQUENCY_MONTHLY,
            SBQQ__EndDate__c                = startDate.addDays(10),
            SBQQ__ProrationDayOfMonth__c    = String.valueOf( prorationDayOfMonth )
        );
        insert childQuote;

        SBQQ__QuoteLine__c childQuoteLines = new SBQQ__QuoteLine__c(
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
            SBQQ__Quote__c = childQuote.Id,
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
        insert childQuoteLines;

      
        SBQQ.TriggerControl.enable();

        Test.startTest();
            try{
                SBQQ.TriggerControl.disable();
                childQuote.SBQQ__Ordered__c = true;
                update childQuote;
                SBQQ.TriggerControl.enable();
                //System.assert(false, 'An exception should of been thrown for failing the validation');
            } catch(Exception ex){
                Boolean containsErrorMessage = ex.getMessage().contains(qtcQuoteTriggerHandler.ERROR_MESSAGE_AE_PP_INVALID);
                System.debug( 'error message ' + ex.getMessage());
                System.Assert(containsErrorMessage, 'We expect an error to be thrown with the error message');
            }
        Test.stopTest();
    }

    @isTest
    static void afterUpdate_SyncFulfillmentOrderTest(){
        Opportunity thisOpportunity;
        Account thisAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = 'MCN1',
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
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
                closeDate = System.TODAY(),
                stagename = 'Prospecting',
                Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
                EndCustomerUnknown__c = true,
                Skip_Validation_Rule_for_Lead_Conversion__c = true,
                ForecastCategoryName ='Omitted'
            );
            insert thisOpportunity;
        }
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
                CDM_Account_Type__c = 'Site',
        		AutoPay_Setup__c = 'True');
        System.runAs( Usr ){
            insert testAccount;
        }
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true,
            qtc_Bill_To_Site__c = testAccount.id
          //  qtc_Multi_Site__c = true
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
                SBQQ__Product__c = thisProduct.Id
            );
            listQuoteLineToInsert.add( positiveQuoteLine );
        }
        insert listQuoteLineToInsert;

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];
        System.assertEquals(0, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        System.assertEquals(0, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            thisQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
            update thisQuote;
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c];

        System.assertEquals(1, afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        System.assertEquals(listQuoteLineToInsert.size(), afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Quote Lines');
    }

    @isTest
    static void afterUpdate_AmendmentSyncFulfillmentOrderTest(){
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
                CDM_Account_Type__c = 'Site',
        		AutoPay_Setup__c = 'True');
        System.runAs( Usr ){
            insert testAccount;
        }

        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true,
            qtc_Bill_To_Site__c = testAccount.id
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
                SBQQ__Product__c = thisProduct.Id
            );
            listQuoteLineToInsert.add( positiveQuoteLine );
        }
        insert listQuoteLineToInsert;

                SBQQ.TriggerControl.disable();
        order od = new Order( 
            SBQQ__Quote__c = thisQuote.id,
            Status = 'Draft',
            Type='New',
            ShippingCountry = 'United States',
            blng__BillingAccount__c = thisAccount.Id,
            AccountId = thisAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
            Pricebook2Id = stdPbId,
            qtc_Bill_To_Site__c = testAccount.id,
            Deliver_To_Site__c = testAccount.id,
            qtc_Ship_To_Account__c = testAccount.id,
            qtc_PO_Number__c = '123456789'
        );
        insert od;
        SBQQ.TriggerControl.enable();
        
        Contract testContract = new Contract(
            StartDate = Date.today(),
            SBQQ__Quote__c = thisQuote.Id,
            SBQQ__Order__c = od.id,
            AccountId=thisAccount.Id);
        insert testContract;

        SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Amendment',
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Account__c = thisAccount.id
            /*qtc_Bill_To_Site__c = testAccount.id
            SBQQ__StartDate__c = Date.today(),
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = Date.today().addDays(30),
            SBQQ__ProrationDayOfMonth__c = '25',
            SBQQ__MasterContract__c = testContract.Id,
            SBQQ__Type__c='Amendment',
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id*/
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

        List<qtc_FulfillmentOrder__c> beforeTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> beforeTestListFulfillmentProducts = [SELECT Id FROM qtc_FulfillmentOrderProduct__c];
        System.assertEquals(0, beforeTestListFulfillmentOrder.size(), 'We expect no Fulfillment Orders at this time');
        System.assertEquals(0, beforeTestListFulfillmentProducts.size(), 'We expect no Fulfillment Order Products at this time');

        Test.startTest();
            amendmentQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now();
            update amendmentQuote;

            amendmentQuote.qtc_SyncFulfillmentOrderDateTime__c = DateTime.now().addDays(1);
            update amendmentQuote;
        Test.stopTest();

        List<qtc_FulfillmentOrder__c> afterTestListFulfillmentOrder = [SELECT Id, qtc_Quote__c FROM qtc_FulfillmentOrder__c];
        List<qtc_FulfillmentOrderProduct__c> afterTestListFulfillmentProducts = [SELECT Id, qtc_Quantity__c FROM qtc_FulfillmentOrderProduct__c];

        System.assertEquals(1, afterTestListFulfillmentOrder.size(), 'We expect one Fulfillment Orders at this time');
        System.assertEquals(1, afterTestListFulfillmentProducts.size(), 'We expect the same number of Fulfillment Order Products as Quote Lines');
    }


}