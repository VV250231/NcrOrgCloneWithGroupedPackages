/*
##################################################################################################
# Project Name..........: Subscription Commerce Application                                                                    
# Created by............: Tania Sen                                                               
# Created Date..........: 02-09-2016                                                                               
# Last Modified by......: Tania Sen 
# Last Modified Date....: 15-09-2016 
# Description...........: The test class is written to test the trigger AutomateSendToZBilling ,
#UpdateSubscriptionChargesInZuora
# and the future class FutureClassForQuotes, 
################################################################################################
*/



@isTest
global class AutomateSendToZBillingTestClass
{
  
    static testmethod void testSendZBilling()
    {
       Test.startTest();
       // Create the custom object
       
      
       
       
       Distribution_List_For_Zuora__c objDisLst = new Distribution_List_For_Zuora__c();
       objDisLst.name = 'Test Mail';
       objDisLst.Email__c = 'testForZBilling@ncr.com' ;
       insert objDisLst;
       
       
       // Insert account
       Account objAccount = new Account();
       objAccount.name = 'Test Account' ;
       objAccount.Subscription_Group__c = 'Hosted Solutions' ;
        System.runas(TestRecordsfactory.getUser()){
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
         
       update testQuote ;
        
        //insert second Quote
       zqu__Quote__c testQuote1 = new zqu__Quote__c();
       testQuote1.Name          = 'Quote For Test Class';
       testQuote1.zqu__Status__c ='QA Processing Complete' ;
       testQuote1.Provisioning_Not_Required__c = false ;
       testQuote1.Provisioning_Status__c = 'Complete' ;
       testQuote1.zqu__Account__c = objAccount.id ;
       testQuote1.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       testQuote1.zqu__SubscriptionType__c = 'Cancel Subscription' ;
       testQuote1.zqu__ZuoraSubscriptionID__c = 'hjjcaaa' ;
       insert testQuote1;
         
      // update testQuote ;
       
       zqu__Quote__c tsObj = [select id,zqu__Number__c from zqu__Quote__c where id =: testQuote.id ];
       
       //insert subscription
       Zuora__Subscription__c  objZuSubs = new Zuora__Subscription__c ();
       objZuSubs.Zuora__QuoteType__c = 'Amend Subscription' ;
       objZuSubs.Zuora__QuoteNumber__c = tsObj.zqu__Number__c ; //objSubs.Zuora__QuoteNumber__c ;
       objZuSubs.Zuora__Zuora_Id__c = 'hjjc';
       insert objZuSubs;
       System.assert(objZuSubs.id!=null);
      
       Test.stopTest();
    }
}