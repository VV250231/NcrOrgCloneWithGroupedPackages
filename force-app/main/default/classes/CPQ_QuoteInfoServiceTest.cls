@isTest
public with sharing class CPQ_QuoteInfoServiceTest {
    static Account act;
    static Account site;
    static List<Account> sites;
    static Contact con;

    @testSetup
    static void setup() {
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            //create account
            act = CPQ_TestDataFactory.createAccount('1', null);
            insert act;

            //creat contact
            con = CPQ_TestDataFactory.createContact(act.Id, '1', null);
            insert con;

            //create sites
            sites = new List<Account>();
            sites.add(CPQ_TestDataFactory.createSite(act, '1', null));
            sites.add(CPQ_TestDataFactory.createSite(act, '2', null));
            insert sites;
        }

        List<Product2> products = CPQ_TestDataFactory.createProducts(10);
        insert products;

        List<PricebookEntry> pbEntries = CPQ_TestDataFactory.createPriceBookEntries(Test.getStandardPricebookId(), products);
        insert pbEntries;

        Map<Id,PricebookEntry> productIdToPBEntery = new Map<Id,PricebookEntry>();
        for (PricebookEntry pbEntry : pbEntries) {
            productIdToPBEntery.put(pbEntry.Product2Id, pbEntry);
        }

        // Create Multisite Quote
        SBQQ__Quote__c quote = CPQ_TestDataFactory.createMultiSiteQuote(act,sites[0],con,'AE Only','Parent');
        quote.SBQQ__Status__c = 'Approved';
        insert quote;

        for (Product2 product : products) {
            CPQ_TestDataFactory.createQuoteLineItem(quote, product, productIdToPBEntery.get(product.Id));
        }

        // Create Single site quote
        SBQQ__Quote__c singleSiteQuote = CPQ_TestDataFactory.createSingleSiteQuote(act,sites[0],con);
        singleSiteQuote.SBQQ__Status__c = 'Approved';
        insert singleSiteQuote;
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        for (Product2 product : products) {
            SBQQ__QuoteLine__c qli = CPQ_TestDataFactory.createQuoteLineItem(singleSiteQuote, product, productIdToPBEntery.get(product.Id));
            qli.Service_Offer_Category__c = 'cloud';
            quoteLineItems.add(qli);
        }
        if (quoteLineItems.size() > 0) {
            Test.startTest();
            SBQQ.TriggerControl.disable();
            insert quoteLineItems;
            SBQQ.TriggerControl.enable();
            Test.stopTest();
            
        }
    }

    @isTest
    static void testGetRequest() {
        act = [SELECT Id, Name, Master_Customer_Number__c FROM Account WHERE ParentId = null LIMIT 1];
        site = [SELECT Id, Name, Site_Number__c FROM Account WHERE ParentId != null LIMIT 1];

        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quote : [SELECT id, SBQQ__Status__c, qtc_Multi_Site__c,qtc_Multi_Site_Relationship__c,
                qtc_Multi_Site_Type__c FROM SBQQ__Quote__c ]) {
            quote.SBQQ__Status__c = 'Approved';
            quotesToUpdate.add(quote);
        }

        if (quotesToUpdate.size() > 0) {
            update quotesToUpdate;
        }
        

        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/cpq/v1/site-quotes';
        request.addParameter('mcn', act.Master_Customer_Number__c);
        request.addParameter('billToSiteNumber', site.Site_Number__c);
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = res;

        CPQ_QuoteInfoService.getQuotes();
    }

    @isTest
    static void testGetRequestMissingParameter() {
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();

        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/cpq/v1/site-quotes';
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = res;

        CPQ_QuoteInfoService.getQuotes();
    }
   
}