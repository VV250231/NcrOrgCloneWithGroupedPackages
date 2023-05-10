@isTest
public with sharing class CPQ_ProcessContractEndBatchTest {
       
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
            insert act;

            //create partner account
            partAct = CPQ_TestDataFactory.createPartnerAccount('1', null);
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
        insert opp1;

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
            quoteLineItems.add(qli);
        }   
        insert quoteLineItems;
        Test.startTest();
            Customer_Document__c legalDoc = new Customer_Document__c(Account__c = act.Id,
                    Quote__c = quote.Id,
                    Document_Type__c = 'AE Order Form',
                    Document_Status__c = 'Sent for Signature');
            insert legalDoc;
            // create Order
            quote.SBQQ__Ordered__c = true;
            update quote;

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
    }

    @isTest
    public static void testProcessContractEndBatch() {
        Test.startTest();
            Contract con = [SELECT Id, EndDate, qtc_Termination_Date__c FROM Contract LIMIT 1];
            con.Enddate = System.today();
            update con;

            CPQ_ProcessContractEndBatch batch = new CPQ_ProcessContractEndBatch();
            Id batchId = Database.executeBatch(batch);
        Test.stopTest();     

        Contract updatedContract = [SELECT Id, Is_Processed_By_Contract_End_Batch__c FROM Contract LIMIT 1];
        System.assert(updatedContract.Is_Processed_By_Contract_End_Batch__c == true, 'Batch class didn\'t processed the expired contract');
    }
}