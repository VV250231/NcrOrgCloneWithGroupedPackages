@isTest
private class UpdateSiteonQuoteTest{
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2025';
    
    static testmethod void test() {
        Test.startTest();
        // List<Zqu__Quote__c> QuoteList = new List<Zqu__Quote__c>([select id , name , Zqu__Number__c , Bill_To_Site_Number__c , Ship_To_Site_Number__c,Zqu__InvoiceOwnerId__c, Zqu__ZuoraAccountID__c , zqu__Account__c  from Zqu__Quote__c where name like '%test%' AND (zqu__Opportunity__r.Account.Subscription_Group__c != 'Digital Insight' OR zqu__Opportunity__r.Account.Subscription_Group__c != 'Digital Insight- Billing Hold' )  /*zqu__Opportunity__r.Solution_Portfolio__c != 'DIGITAL BANKING'*/ limit 5]);
        List<Zqu__Quote__c> QuoteList = new List<Zqu__Quote__c>();
        // List<Zuora__CustomerAccount__c> BillingAccountList = new List<Zuora__CustomerAccount__c> ([select id , ERPSiteNumber__c , BillToFlag__c from Zuora__CustomerAccount__c where SourceSystem__c =: 'Oracle ERP' AND BillToFlag__c = 'Yes' limit 1]);
        List<Zuora__CustomerAccount__c> BillingAccountList = new List<Zuora__CustomerAccount__c>();
        Zqu__Quote__c zqObj = new Zqu__Quote__c(name='test1',Bill_To_Site_Number__c='test');
        QuoteList.add(zqObj);
        insert QuoteList;
        Account acc=TestRecordsFactory.createAccount('abc');
        Zuora__CustomerAccount__c zuoraCustObj = new Zuora__CustomerAccount__c(Zuora__Account__c=acc.id,SourceSystem__c='Oracle ERP',BillToFlag__c='Yes',ERPSiteNumber__c='test');
        BillingAccountList.add(zuoraCustObj);
        insert zuoraCustObj;
        Customer_Product_Setup__c custProd = new Customer_Product_Setup__c(Related_Quote__c=zqObj.id,Add_to_Existing_ENT_ID__c='test',Software_Key_Number__c='test');
        insert custProd;
        for(Zqu__Quote__c Quote : QuoteList)
        {
            Quote.Bill_To_Site_Number__c = BillingAccountList[0].ERPSiteNumber__c ;
            Quote.Ship_To_Site_Number__c = BillingAccountList[0].ERPSiteNumber__c ;
        }
        
        update QuoteList ;
        
        
        // Schedule the test job
        String jobId = System.schedule('UpdateSiteonQuoteTest', CRON_EXP, new UpdateSiteonQuote());
        Test.stopTest();
        Zuora__CustomerAccount__c zcObj = [select id,Aloha_Key__c from Zuora__CustomerAccount__c where id=:zuoraCustObj.id];
        System.assert(zcObj.Aloha_Key__c=='test');
        
    }
}