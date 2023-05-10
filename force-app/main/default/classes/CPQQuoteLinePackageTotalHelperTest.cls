/**************************************
Author ...............: Pandey, Dharmendra Kumar
Modified Date.........: 30-JAN-2020
Description...........: RollUp child lines, list and net price at parent level.

***************************************/
@isTest (seealldata=false)
public with sharing class CPQQuoteLinePackageTotalHelperTest {

    
    public TestMethod static void calculatePackageAndSubPackageTotals_Method(){
          
        List<Product2> productData = Test.loadData(Product2.sObjectType,'CPQProductData');
         system.debug('productData  :'+productData.size() );
        Id pbid = Test.getStandardPricebookId();
        List<SBQQ__Quote__c> q= Test.loadData(SBQQ__Quote__c.sObjectType,'CPQQuoteTestData');
        List<SBQQ__QuoteLineGroup__c> quoteLinesGroup = Test.loadData(SBQQ__QuoteLineGroup__c.sObjectType,'CPQLineGroup');
        List<SBQQ__QuoteLine__c> quoteLinespackg = Test.loadData(SBQQ__QuoteLine__c.sObjectType,'CPQPackageData');
        List<SBQQ__QuoteLine__c> quoteLines = Test.loadData(SBQQ__QuoteLine__c.sObjectType,'CPQQuoteLineTestData');
       
        // set up foundation.
       /* Product2 p0 = new Product2(Name='Aloha Essentials 2.0', Product_Type__c='Package', IsActive=true, SBQQ__PricingMethod__c='List', SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionType__c='Renewable', SBQQ__SubscriptionTerm__c=1,SBQQ__ChargeType__c = 'Recurring',
                                  SBQQ__BillingType__c='Advance',SBQQ__BillingFrequency__c='Monthly');
        insert p0;
        
        Product2 p1 = new Product2(Name='Product-1', Product_Type__c='PID', IsActive=true, SBQQ__PricingMethod__c='List', SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionType__c='Renewable', SBQQ__SubscriptionTerm__c=1,SBQQ__ChargeType__c = 'Recurring',SBQQ__BillingType__c='Advance',SBQQ__BillingFrequency__c='Monthly');
        insert p1;
        
        Product2 p2 = new Product2(Name='Product-1', Product_Type__c='SID', IsActive=true, SBQQ__PricingMethod__c='List', SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionType__c='Renewable', SBQQ__SubscriptionTerm__c=1,SBQQ__ChargeType__c = 'Recurring',SBQQ__BillingType__c='Advance',SBQQ__BillingFrequency__c='Monthly');
        insert p2;
        
        Id pbid = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(Product2Id=p0.id, Pricebook2Id=pbid, UnitPrice=0, IsActive=true);
        insert pbe;
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=p1.id, Pricebook2Id=pbid, UnitPrice=10, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=p2.id, Pricebook2Id=pbid, UnitPrice=20, IsActive=true);
        insert pbe2;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Primary__c=true, SBQQ__StartDate__c=Date.today(), SBQQ__SubscriptionTerm__c=36
                                             ,SBQQ__ProrationDayOfMonth__c='30',BillingMultiplier__c=36,SBQQ__Type__c='Quote');
        insert q;
        
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c=q.id, Name='Test');
        insert qlg;
        
        SBQQ__QuoteLine__c pg = new SBQQ__QuoteLine__c(SBQQ__Quote__c=q.id, SBQQ__Group__c=qlg.id,qtc_Group_ID__c=1,  SBQQ__Product__c=p0.id, SBQQ__Quantity__c=1,SBQQ__DefaultSubscriptionTerm__c=1,Product_Type__c='Package');
        insert pg;
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=q.id, SBQQ__Group__c=qlg.id,qtc_Group_ID__c=1, SBQQ__Product__c=p1.id, SBQQ__Quantity__c=1,SBQQ__RequiredBy__c=pg.id,SBQQ__DefaultSubscriptionTerm__c=1,Product_Type__c='PID');
        insert ql1;
        
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=q.id, SBQQ__Group__c=qlg.id,qtc_Group_ID__c=1, SBQQ__Product__c=p2.id, SBQQ__Quantity__c=2,SBQQ__RequiredBy__c=pg.id,SBQQ__DefaultSubscriptionTerm__c=1,Product_Type__c='SID');
        insert ql2;
        */
        Test.startTest();

        update q ;
        
        Test.stopTest();
        List<SBQQ__QuoteLine__c> lines=[select qtc_Net_Price_Display__c,qtc_Component_Net_Term_Price__c,Name,SBQQ__RequiredBy__r.Name,qtc_Pass_Through__c,Product_Type__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: q[0].Id];
        
        System.assertEquals(30,lines[0].qtc_Component_Net_Term_Price__c, 'Expected Price 26');
       
       // System.assertEquals(50,lines[0].qtc_Component_Net_Term_Price__c, 'Expected Price 50');
        //System.assertEquals(50,lines[0].qtc_Component_List_Term_Price__c, 'Expected Price 50');
    }
    
}