@isTest
public class selectProductControllerTest{
 static testMethod void runTest()
 {
  
     // Insert account
       Account objAccount = new Account();
       objAccount.name = 'Test Account' ;
       objAccount.Subscription_Group__c = 'Hosted Solutions' ;
        system.runas(TestRecordsFactory.getUser())
        {
            insert objAccount;
        }
       
       zqu__Quote__c testQuote = new zqu__Quote__c();
       testQuote.Name          = 'Quote For Test Class';
       testQuote.zqu__Status__c ='QA Processing Complete' ;
       testQuote.Provisioning_Not_Required__c = false ;
       testQuote.Provisioning_Status__c = 'Complete' ;
       testQuote.zqu__Account__c = objAccount.id ;
       testQuote.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       testQuote.zqu__SubscriptionType__c = 'Amend Subscription' ;
       testQuote.zqu__ZuoraSubscriptionID__c = 'hjjc' ;
       insert testQuote;
        system.assert(testQuote !=null);
       selectProductController.methodToReturnWrapper(testQuote.id);
     
 }
}