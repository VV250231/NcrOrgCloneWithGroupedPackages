@isTest
public with sharing class CPQ_EmailTemplateBodyTest {
    @TestSetup
    static void makeData() {
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            //create account
            Account act = CPQ_TestDataFactory.createAccount('1', null);
            insert act;

            //creat contact
            Contact con = CPQ_TestDataFactory.createContact(act.Id, '1', null);
            insert con;

            //create sites
            List<Account> sites = new List<Account>();
            sites.add(CPQ_TestDataFactory.createSite(act, '1', null));
            sites.add(CPQ_TestDataFactory.createSite(act, '2', null));
            insert sites;
           
        }
    }
    
    @isTest
    static void testGetEmailBody() {
        List<Product2> products = CPQ_TestDataFactory.createProducts(10);
        insert products;

        List<PricebookEntry> pbEntries = CPQ_TestDataFactory.createPriceBookEntries(Test.getStandardPricebookId(), products);
        insert pbEntries;

        Map<Id,PricebookEntry> productIdToPBEntery = new Map<Id,PricebookEntry>();
        for (PricebookEntry pbEntry : pbEntries) {
            productIdToPBEntery.put(pbEntry.Product2Id, pbEntry);
        }

        // Create Single site quote
        Account act = [SELECT Id, Name from Account WHERE RecordType.Name = 'Customer' LIMIT 1];
        List<Account> sites = [SELECT Id, Name from Account WHERE RecordType.Name = 'Site'];
        Contact con = [SELECT Id from Contact];
        SBQQ__Quote__c singleSiteQuote = CPQ_TestDataFactory.createSingleSiteQuote(act,sites[0],con);
        insert singleSiteQuote;
        for (Product2 product : products) {
            CPQ_TestDataFactory.createQuoteLineItem(singleSiteQuote, product, productIdToPBEntery.get(product.Id));
        }

        List<SBQQ__Quote__c> quotes = [SELECT Id from SBQQ__Quote__c];
        List<CPQ_Sales_Survey__c> cPQSalesSurveys = new List<CPQ_Sales_Survey__c> ();
        CPQ_Sales_Survey__c salesSurvey = new CPQ_Sales_Survey__c();
        salesSurvey.Local_Office_Region__c = 'Northeast – PDC, TRS, NEE';
        salesSurvey.Salesforce_Quote_Id__c = quotes[0].Id;
        insert cPQSalesSurveys;

        List<qtc_FulfillmentOrder__c> qtcFulfillmentOrders = new List<qtc_FulfillmentOrder__c>();
        qtcFulfillmentOrders.add(new qtc_FulfillmentOrder__c(
            qtc_Quote__c = quotes[0].Id
        ));
        insert qtcFulfillmentOrders;

        List<CPQ_EmailTemplateBody.CPQ_InvocableRequest> requestList = new List<CPQ_EmailTemplateBody.CPQ_InvocableRequest>();
        CPQ_EmailTemplateBody.CPQ_InvocableRequest request = new CPQ_EmailTemplateBody.CPQ_InvocableRequest();
        request.templateDeveloperName = 'CPQ_Order_Integrity_Check_Notification';
        request.whoId = UserInfo.getUserId();
        request.whatId = quotes[0].Id;
        requestList.add(request);
        CPQ_EmailTemplateBody.getEmailBody(requestList);
    }
}