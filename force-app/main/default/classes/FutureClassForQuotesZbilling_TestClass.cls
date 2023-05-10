/*
##################################################################################################
# Project Name..........: Subscription Commerce Application                                                                    
# Created by............: Tania Sen                                                               
# Created Date..........: 18-04-2017                                                                               
# Last Modified by......: Tania Sen 
# Last Modified Date....: 18-05-2017
# Description...........: The test class is written to test the trigger AutomateSendToZBilling ,
# and the future class FutureClassForQuotesZbilling
################################################################################################
*/



@isTest(SeeAllData=true)
global class FutureClassForQuotesZbilling_TestClass
{
  Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }
    
    
    static testmethod void testSendZBilling()
    {
       Test.startTest();
       // Create the custom object
    
      
        
       
       // Insert account
       Account objAccount = new Account();
       objAccount.name = 'Test Account' ;
       objAccount.Subscription_Group__c = 'Hosted Solutions' ;
       //insert objAccount;
        System.runAs(getUser()){
        insert objAccount;
        }
       
       zqu__Quote__c testQuote = new zqu__Quote__c();
       testQuote.Name          = 'Quote For Test Class';
       testQuote.zqu__Status__c ='New' ;
       //testQuote.Provisioning_Not_Required__c = false ;
       //testQuote.Provisioning_Status__c = 'Complete' ;
       testQuote.zqu__Account__c = objAccount.id ;
       testQuote.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       testQuote.zqu__SubscriptionType__c = 'Amend Subscription' ;
       testQuote.zqu__ZuoraSubscriptionID__c = 'hjjc' ;
       testQuote.ImplementationRequired__c = 'No';
       testQuote.zqu__Service_Activation_Date__c =  Date.today();
       testQuote.Track_Approval_Steps__c ='Step1';
       insert testQuote;
         
      
       
       zqu__Quote__c tsObj = [select id,zqu__Number__c,ImplementationRequired__c from zqu__Quote__c where id =: testQuote.id ];
       System.assertEquals(tsObj.ImplementationRequired__c, 'No','Implementation Required is NO');  
       Quote_Product__c objQP = new Quote_Product__c ();
       objQP.Action__c = 'Activate';
       objQP.Quote__c  = tsObj.id;
       insert objQP;
        
        //insert subscription
       Zuora__Subscription__c  objZuSubs = new Zuora__Subscription__c ();
       objZuSubs.Zuora__QuoteType__c = 'Amend Subscription' ;
       objZuSubs.Zuora__QuoteNumber__c = tsObj.zqu__Number__c ; //objSubs.Zuora__QuoteNumber__c ;
       objZuSubs.Zuora__Zuora_Id__c = 'hjjc';
       insert objZuSubs;
       System.assertNotEquals(objZuSubs.Id, null,'Zuora Subscription is null'); 
       testQuote.zqu__Status__c ='QA Processing Complete' ;
       update testQuote ;
      
       ScheduleZbillingofQuote obj = new ScheduleZbillingofQuote();
       obj.execute(null);
       Test.stopTest();
    }
    
   static testmethod void testSendZBilling2()
    {
       Test.startTest();
          
           // Insert account
       Account objAccount = new Account();
       objAccount.name = 'Test Account' ;
       objAccount.Subscription_Group__c = 'Hosted Solutions' ;
       //insert objAccount;
        System.runAs(getUser()){
        insert objAccount;
        }
       
      // List<zqu__Quote__c> singleQuoteObjlst = [select id from zqu__Quote__c where  zqu__Status__c = 'QA Processing Complete' and zqu__ZuoraAccountID__c != null and Is_NCR_Quote__c = true limit 1];
       
       List<zqu__Quote__c> lstQuotes = new List<zqu__Quote__c >();
       
       for(integer i=0;i < 32;i++)
       {
       zqu__Quote__c testQuote = new zqu__Quote__c();
       testQuote.Name          = 'Quote For Test Class' + i;
       testQuote.zqu__Status__c ='QA Processing Complete' ;
       //testQuote.Provisioning_Not_Required__c = false ;
       //testQuote.Provisioning_Status__c = 'Complete' ;
       testQuote.zqu__Account__c = objAccount.id ;
       testQuote.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       testQuote.zqu__SubscriptionType__c = 'New Subscription' ;
       testQuote.ImplementationRequired__c = 'No';
       testQuote.zqu__Service_Activation_Date__c =  Date.today();
       
       
       lstQuotes.add(testQuote);
       }
       System.assertEquals(lstQuotes.size(), 32,'Quotes are null'); 
       insert lstQuotes;
       
       /**if(singleQuoteObjlst != null && singleQuoteObjlst.size() > 0)
       {
           singleQuoteObjlst[0].Provisioning_Not_Required__c  = true ;
           lstQuotes.add(singleQuoteObjlst[0]);
           update lstQuotes;
       }**/
      
       Test.stopTest();
    }
}