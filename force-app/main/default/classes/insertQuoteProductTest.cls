@isTest
public class insertQuoteProductTest{
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }
 static testMethod void runTest()
 {
  Account objAccount = new Account();
       objAccount.name = 'Test Account' ;
       objAccount.Subscription_Group__c = 'Hosted Solutions' ;
     System.runAs(getUser()){
        insert objAccount;
        }
       //insert objAccount;
       
       zqu__Quote__c testQuote = new zqu__Quote__c();
       testQuote.Name          = 'Quote For Test Class';
       testQuote.zqu__Status__c ='QA Processing Complete' ;
       testQuote.Provisioning_Not_Required__c = false ;
       testQuote.Provisioning_Status__c = 'Complete' ;
       testQuote.zqu__Account__c = objAccount.id ;
       testQuote.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       testQuote.zqu__SubscriptionType__c = 'Cancel Subscription' ;
       testQuote.zqu__ZuoraSubscriptionID__c = 'hjjc' ;
       testQuote.zqu__ExistSubscriptionID__c = 'testID';
       //testQuote.CancellationAction__c= 'Softlock';
       
       insert testQuote;
       
       Quote_Product__c tempObj = new Quote_Product__c();
       tempObj.Action__c = testQuote.CancellationAction__c;
       tempObj.Quote__c = testQuote.id;
       insert tempObj;
       
       zqu__Quote__c testQuote1 = new zqu__Quote__c();
       testQuote1.id = testQuote.id;
       //testQuote1.CancellationAction__c = 'Deactivate';
       Update testQuote1;
       
  }
  static testMethod void runTest1()
  {
       Zuora__Subscription__c suscr = new Zuora__Subscription__c();
       //suscr.QuoteID__c  = testQuote.id;
       suscr.Zuora__External_Id__c  = 'testID' ;
       insert suscr;
       
       Zuora__Product__c prod = new Zuora__Product__c();
       prod.Zuora__External_Id__c = 'tt';
       insert prod;
       
      Zuora__Subscription__c objS= [select id,Zuora__External_Id__c from Zuora__Subscription__c  where id=: suscr.id ];
      Zuora__Product__c  objPro = [select id,Zuora__External_Id__c  from Zuora__Product__c  where id =:prod.id];
        
        Zuora__SubscriptionProductCharge__c subcharge2 = new Zuora__SubscriptionProductCharge__c();
        subcharge2.Zuora__Subscription__c = objS.id;
        
        subcharge2.Zuora__Product__c  = objPro.id; 
        insert subcharge2;        
      System.debug('** tania product & charges'+subcharge2);

        Zuora__SubscriptionProductCharge__c sub = [select id,Zuora__Product__r.Zuora__External_Id__c,Zuora__Subscription__r.Zuora__External_Id__c from Zuora__SubscriptionProductCharge__c  where id =: subcharge2.id];
          system.debug('==========='+ sub.Zuora__Subscription__r.Zuora__External_Id__c );
           system.debug('==========='+ sub.Zuora__Product__r.Zuora__External_Id__c );
       Account objAccount = new Account();
       objAccount.name = 'Test Account' ;
       objAccount.Subscription_Group__c = 'Hosted Solutions' ;
      System.runAs(getUser()){
        insert objAccount;
        }
       //insert objAccount;
       
       zqu__Quote__c testQuote = new zqu__Quote__c();
       testQuote.Name          = 'Quote For Test Class';
       testQuote.zqu__Status__c ='QA Processing Complete' ;
       testQuote.Provisioning_Not_Required__c = false ;
       testQuote.Provisioning_Status__c = 'Complete' ;
       testQuote.zqu__Account__c = objAccount.id ;
       testQuote.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       testQuote.zqu__SubscriptionType__c = 'Cancel Subscription' ;
       testQuote.zqu__ZuoraSubscriptionID__c = 'hjjc' ;
       testQuote.zqu__ExistSubscriptionID__c = 'testID';
       //testQuote.CancellationAction__c= 'Softlock';
       
       insert testQuote;
       
      
        
      
   }
       
       
}