@isTest
public with sharing class Cpq_QuoteUtilTest {
    
    @testSetup
    static void setupData() {
        Account act;
        Account partAct;
        Contact con;
        List<Account> sites;
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            List<Account> accounts = new List<Account>();
            //create customer account
            act = CPQ_TestDataFactory.createAccount('1', null);
            //accounts.add(act);
            insert act;

            //create partner account
            partAct = CPQ_TestDataFactory.createPartnerAccount('1', null);
            //accounts.add(partAct);
            insert partAct;

            //create primary site and one extra site/ secondary site.
            sites = new List<Account>();
            Account primerySite = CPQ_TestDataFactory.createSite(act, '1', null);
            primerySite.Primary_Bill_To__c = true;
            primerySite.Primary_Deliver_To__c = true;
            primerySite.Primary_Ship_To__c = true;
            sites.add(primerySite);
            sites.add(CPQ_TestDataFactory.createSite(act, '2', null));
            insert sites;
            //accounts.addAll(sites);
            //insert accounts;

            //creat contact
            con = CPQ_TestDataFactory.createContact(act.Id, '1', null);
            insert con;

            

            // Create Account Relationship
            cdm_Account_Relationship__c relationShip = new cdm_Account_Relationship__c(
                Account__c = act.Id,
                Account_Number__c = act.Master_Customer_Number__c,
                Related_Account__c = partAct.id,
                Related_Account_Number__c = partAct.Master_Customer_Number__c,
                Name = 'Partner',
                Relationship_Code__c = 'End Customer Of',
                Relationship_Type__c = 'End Customer - Partner',
                Start_Date__c = System.Today(),
                End_Date__c = System.Today() + 365,
                ROR_Update_Date_Time__c = System.Now(),
                Active__c = true
            );
            insert relationShip;
        }

        // Creating Include in Funnel opportunity
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId(); 
        opp1.name = 'OpportunityForMultiSiteQuote';
        opp1.AccountID = act.id;
        opp1.stagename = 'Analyzing';
        opp1.Contacts__c = con.Id; // Primary Contact
        opp1.Channel_Office__c = partAct.Id;
        opp1.closeDate = System.TODAY();
        opp1.type = 'New Customer';
        opp1.INVOICE_TRIGGER__C = 'Shipment';
        opp1.Forecast_Category__c = 'Pipeline';
        opp1.ForecastCategoryName = 'Pipeline';
        opp1.LeadSource = 'Email';
        opp1.CPQ__c = true;
        opp1.CURRENCYISOCODE = 'USD';      
        opp1.Skip_Validation_Rule_for_Lead_Conversion__c = true;        
        //insert opp1;
        opportunityList.add(opp1);

        Opportunity opp2 = new Opportunity();
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId(); 
        opp2.name = 'OpportunityForMultiSiteQuote';
        opp2.AccountID = act.id;
        opp2.stagename = 'Analyzing';
        opp2.Contacts__c = con.Id; // Primary Contact
        opp2.Channel_Office__c = partAct.Id;
        opp2.closeDate = System.TODAY();
        opp2.type = 'New Customer';
        opp2.INVOICE_TRIGGER__C = 'Shipment';
        opp2.Forecast_Category__c = 'Pipeline';
        opp2.ForecastCategoryName = 'Pipeline';
        opp2.LeadSource = 'Email';
        opp2.CPQ__c = true;
        opp2.CURRENCYISOCODE = 'USD';      
        opp2.Skip_Validation_Rule_for_Lead_Conversion__c = true;        
        //insert opp2;
        opportunityList.add(opp2);
        insert opportunityList;

        // Creating products. Products are subscriptionable. 
        //Because Contract from order can be created only for subscriptionable products.
        List<Product2> products = CPQ_TestDataFactory.createProducts(10);
        insert products;

        List<PricebookEntry> pbEntries = CPQ_TestDataFactory.createPriceBookEntries(Test.getStandardPricebookId(), products);
        insert pbEntries;

        Map<Id,PricebookEntry> productIdToPBEntery = new Map<Id,PricebookEntry>();
        for (PricebookEntry pbEntry : pbEntries) {
            productIdToPBEntery.put(pbEntry.Product2Id, pbEntry);
        }

        Account billingSite = [SELECT Id, Master_Customer_Number__c, Site_Number__c FROM Account 
                WHERE RecordType.Name = 'Site' AND Name = 'Site1' LIMIT 1];
        
        Test.startTest();
        // Multisite, Ordered Quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createMultiSiteQuote(act,billingSite,con,'AE Only','Parent');
        quote.qtc_Quote_Name__c  = 'multiSiteQuote';
        quote.SBQQ__Opportunity2__c = opp1.Id;
        insert quote;

        quote.SBQQ__Status__c = 'Approved'; // While inserting this status does not get set to approved, so update operation.
        update quote;

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        for (Product2 product : products) {
            SBQQ__QuoteLine__c qli = CPQ_TestDataFactory.createQuoteLineItem(quote, product, productIdToPBEntery.get(product.Id));           
            qli.Service_Offer_Category__c = 'cloud';
            qli.SBQQ__ChargeType__c = 'Recurring';
            qli.SBQQ__BillingType__c = 'Advance';
            qli.SBQQ__BillingFrequency__c = 'Monthly';
            //qli.SBQQ__ListPrice__c = 1;
            quoteLineItems.add(qli);
        }   
        insert quoteLineItems;
        // Single Site Un-Ordered Quote, Legal Document is signed.
        SBQQ__Quote__c singleSiteQuote = CPQ_TestDataFactory.createSingleSiteQuote(act,billingSite,con);
        singleSiteQuote.SBQQ__Opportunity2__c = opp2.Id;
        insert singleSiteQuote;

        singleSiteQuote.SBQQ__Status__c = 'Approved'; // While inserting this status does not get set to approved, so update operation.
        update singleSiteQuote;
        List<SBQQ__QuoteLine__c> quoteLineItems2 = new List<SBQQ__QuoteLine__c>();
        for (Product2 product : products) {
            SBQQ__QuoteLine__c qli = CPQ_TestDataFactory.createQuoteLineItem(singleSiteQuote, product, productIdToPBEntery.get(product.Id));           
            qli.Service_Offer_Category__c = 'cloud';
            qli.SBQQ__ChargeType__c = 'Recurring';
            qli.SBQQ__BillingType__c = 'Advance';
            qli.SBQQ__BillingFrequency__c = 'Monthly';
            quoteLineItems2.add(qli);
        } 

        if (quoteLineItems2.size() > 0) {
            insert quoteLineItems2;
        }
        
        List<Customer_Document__c> leagalDocs = new List<Customer_Document__c>();
        leagalDocs.add(new Customer_Document__c(Account__c = act.Id,
                Quote__c = singleSiteQuote.Id,
                Document_Type__c = 'AE Order Form',
                Document_Status__c = 'Sent for Signature'));
        leagalDocs.add(new Customer_Document__c(Account__c = act.Id,
                Quote__c = quote.Id,
                Document_Type__c = 'AE Order Form',
                Document_Status__c = 'Sent for Signature'));   
        
       if (leagalDocs.size() > 0) {
           insert leagalDocs;
       } 

        // create Order
        SBQQ__Quote__c quote1 = [SELECT Id, SBQQ__Ordered__c FROM SBQQ__Quote__c 
                WHERE qtc_Quote_Name__c  = 'multiSiteQuote' LIMIT 1];
        quote1.SBQQ__Ordered__c = true;
        update quote1;
       Test.stopTest();
    }

    @isTest
    public static void testGetQuotes() {
        Account customerAct = [SELECT Id, Master_Customer_Number__c FROM Account WHERE RecordType.Name = 'Customer'];
        Account billingSite = [SELECT Id, Master_Customer_Number__c, Site_Number__c FROM Account WHERE RecordType.Name = 'Site' AND Name = 'Site1' LIMIT 1];
        List<Cpq_QuoteUtil.QuoteDetail> quoteDetails = new List<Cpq_QuoteUtil.QuoteDetail>();
        Test.startTest();
           
            
            // Activate Order
            Order orderRec = [SELECT Id, Status, SBQQ__Contracted__c, qtc_Bill_To_Site_Number__c, 
                qtc_Master_Customer_Number__c,SBQQ__Quote__r.SBQQ__Status__c,qtc_Multi_Site_Relationship__c,
                qtc_Multi_Site_Type__c,
                (SELECT Id, SBQQ__Status__c from OrderItems) from Order LIMIT 1];
            orderRec.Status = 'Activated';

            List<OrderItem> orderItemsToActivate = new List<OrderItem>();
            for (OrderItem oli : orderRec.OrderItems) {
                oli.SBQQ__Status__c = 'Activated';
                oli.SBQQ__Activated__c = true;
                orderItemsToActivate.add(oli);
            }
            if (orderItemsToActivate.size() > 0) {
                update orderItemsToActivate;
            }
            update orderRec;

            // Create Contract
            orderRec.SBQQ__Contracted__c = true;    
            update orderRec;

        Test.stopTest();
        quoteDetails = Cpq_QuoteUtil.getQuotes(customerAct.Master_Customer_Number__c,billingSite.Site_Number__c);
        System.assertEquals(2, quoteDetails.size(), 'Expected number of quotes not recived.');
        
    }
}