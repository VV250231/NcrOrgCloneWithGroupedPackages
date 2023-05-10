@isTest
private class UpdateSiteonQuoteExtensionTest{
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2025';
    
    static testmethod void test() {
        Zqu__Quote__c zqObj = new Zqu__Quote__c(Bill_To_Site_Number__c='Error',Ship_To_Site_Number__c='Error');
        insert zqObj;
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('UpdateSiteonQuoteExtensionTest', CRON_EXP, new UpdateSiteonQuoteExtension());
        Test.stopTest();
        Zqu__Quote__c zqObj1 = [select IsSiteNoChanged__c from Zqu__Quote__c where id=:zqObj.id];
        System.assert(zqObj1.IsSiteNoChanged__c==true);
    }
}