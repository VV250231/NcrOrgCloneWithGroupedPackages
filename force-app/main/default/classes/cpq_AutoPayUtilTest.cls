@isTest
public with sharing class cpq_AutoPayUtilTest {
    

    @testSetup static void setupTestData() {
        Account act;
        List<Account> sites;
        Contact con;
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            //create account
            act = CPQ_TestDataFactory.createAccount('1', null);
            insert act;

            //creat contact
            con = CPQ_TestDataFactory.createContact(act.Id, '1', null);
            insert con;

            //create sites
            sites = new List<Account>();
            Account site = CPQ_TestDataFactory.createSite(act, '1', null);
            site.AutoPay_Setup__c = '';
            sites.add(site);
            insert sites;
          
        }

         // Create Opportunity
         Opportunity op = CPQ_TestDataFactory.createCpqOpportunity(act.Id,'1',null);
         insert op;

         List<Product2> products = CPQ_TestDataFactory.createProducts(10);
         insert products;

         List<PricebookEntry> pbEntries = CPQ_TestDataFactory.createPriceBookEntries(Test.getStandardPricebookId(), products);
         insert pbEntries;

         Map<Id,PricebookEntry> productIdToPBEntery = new Map<Id,PricebookEntry>();
         for (PricebookEntry pbEntry : pbEntries) {
             productIdToPBEntery.put(pbEntry.Product2Id, pbEntry);
         }

         // Create Single site quote
         SBQQ__Quote__c singleSiteQuote = CPQ_TestDataFactory.createSingleSiteQuote(act,sites[0],con);
         singleSiteQuote.SBQQ__Opportunity2__c = op.Id;
         insert singleSiteQuote;
         for (Product2 product : products) {
             CPQ_TestDataFactory.createQuoteLineItem(singleSiteQuote, product, productIdToPBEntery.get(product.Id));
         }
    }

    @isTest
    public static void handleOppOwnerNotificationTest() {
        List<Id> siteIds = new List<Id>();
        List<Id> quoteIds = new List<Id>();
        List<Account> sites = [SELECT Id FROM Account WHERE Name = 'site1'];
        if (sites.size() > 0) {
            sites[0].AutoPay_Setup__c = 'Manual';
            update sites[0];
            siteIds.add(sites[0].Id);
        }

        for (SBQQ__Quote__c q : [SELECT Id FROM SBQQ__Quote__c]) {
            quoteIds.add(q.Id);
        }
        Test.startTest();
        cpq_AutoPayUtil.handleOppOwnerNotification(siteIds,quoteIds);
        Test.stopTest();
    }
}