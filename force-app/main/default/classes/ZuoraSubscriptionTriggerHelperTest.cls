@isTest
public class ZuoraSubscriptionTriggerHelperTest {
     private static Account a;
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }
	@testSetup static void setupTestData() 
    {
        //create account
        a = new Account(name = 'test-acc', industry = 'HOSPITALITY:CHANNEL', Account_Country_Code__c = 'US', Subscription_Group__c = 'Digital Insight');
        System.runAs(getUser())
        {
       	 insert a;
        }
        
    }
        static testMethod void Test() {
        Test.startTest();
         zqu__Quote__c qu = new zqu__Quote__c();
        //qu.Id = opp.Id;
        qu.Name = 'amit2';
       
        insert qu;
        System.assert(qu.Id!=null);
        system.assertNotEquals('xyz',qu.Name);
            
        zqu__QuoteAmendment__c amm = new zqu__QuoteAmendment__c();
        amm.Name='amit1';
        amm.zqu__Quote__c = qu.Id;
        amm.zqu__Type__c = 'UpdateProduct';
        insert amm;
        System.assert(amm.Id!=null);
        system.assertNotEquals('abc',amm.Name);
            
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Name = 'dummy';
        sub.QuoteID__c = qu.id;
        sub.Zuora__External_Id__c = 'abcde2628';    
        insert sub;
		System.assert(sub.Id!=null);
        system.assertEquals('dummy',sub.Name);       
        
        zuora__SubscriptionRatePlan__c subs = new zuora__SubscriptionRatePlan__c();
      //  subs.Id = sub.QuoteID__c;
        subs.MarketProductId__c = 'abc';
        subs.Zuora__External_Id__c = sub.Zuora__External_Id__c;
        subs.Zuora__Subscription__c= sub.Id;
       // subs.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
            insert subs;
            System.assert(subs.Id!=null);
            system.assertEquals('abc',subs.MarketProductId__c);
        
        
        zqu__QuoteRatePlan__c q = new zqu__QuoteRatePlan__c();
       // q.zqu__QuoteAmendment__c = 'RemoveProduct'; zqu__QuoteAmendment__c
            q.Name = 'Amit';
            q.zqu__QuoteAmendment__c = amm.Id;
            q.zqu__SubscriptionRatePlanZuoraId__c = subs.Zuora__External_Id__c;
            q.zqu__AmendmentType__c = 'NewProduct1';
            q.MarketProductId__c = subs.MarketProductId__c;
            q.zqu__Quote__c = qu.id;
            insert q; 
            System.assert(q.Id!=null);
            system.assertEquals('NewProduct1',q.zqu__AmendmentType__c);
        Zuora__Subscription__c sub1 = [Select id from Zuora__Subscription__c];
        delete sub1;
        Test.stopTest();
    }
}