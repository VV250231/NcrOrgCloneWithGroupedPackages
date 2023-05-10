@isTest
private class QuotePreventDeleteTriggerTest {
    static testMethod void runUnitTest() {
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        a.Subscription_Group__c = 'Digital Insight';
        insert a;
        System.assert(a.Id!=null);
        system.assertEquals('HOSPITALITY:CHANNEL',a.industry);
        system.assertNotEquals('UK',a.Account_Country_Code__c);
        
        Opportunity opp = ZuoraTestUtil.createOpp(a);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Default'); 
        
        qt = [select Id, zqu__Primary__c from zqu__Quote__c where Id = :qt.Id];
        System.assert(qt.Id!=null);
        qt.zqu__Primary__c = true;
        update qt;
        delete qt;
        undelete qt; 
        
    }
}