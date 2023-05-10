@isTest
public class ReportingFieldsFromBillingAccountTest 
{
    
    static zqu__Quote__c Quote; 
     
    public static testmethod void TestReportingFieldsFromBillingAccount() 
    {
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);

        Zuora__CustomerAccount__c BillingAccount = new Zuora__CustomerAccount__c(Name = 'Invoice Owner',Zuora__Zuora_Id__c='2c92a0fb4ffddca7015012a1ad0b4382',Zuora__Account__c=acct.id,Zuora__External_Id__c = '2c92a0fb4ffddca7015012a1ad0b4382',Zuora__MRR__c=100,Zuora__Currency__c='USD',ERPSiteNumber__c='123',ORGCode__c='123',Address__c='Address');
        insert BillingAccount;
        system.assertEquals('Invoice Owner',BillingAccount.Name);
        Zuora__CustomerAccount__c BillingAccount2 = new Zuora__CustomerAccount__c(Name = 'Subscription Owner',Zuora__Zuora_Id__c='2c92c0f84e23f50f014e2b48d26d7b0d',Zuora__Account__c=acct.id,Zuora__External_Id__c = '2c92c0f84e23f50f014e2b48d26d7b0d',Zuora__MRR__c=100,Zuora__Currency__c='USD');
        
        insert BillingAccount2;
        System.assert(BillingAccount2.Id!=null);
        system.assertEquals('Subscription Owner',BillingAccount2.Name);
        system.assertNotEquals(123,BillingAccount2.Zuora__MRR__c);

       zqu__Quote__c Quote = new zqu__Quote__c();
       Quote.Name = 'Quote For Test Class';
       Quote.zqu__Status__c ='QA Processing Complete' ;
       Quote.Provisioning_Not_Required__c = false ;
       Quote.Provisioning_Status__c = 'Complete' ;
       Quote.zqu__Account__c = acct.id ;
       Quote.zqu__Opportunity__c = Opp.Id;
       Quote.zqu__ZuoraAccountID__c = '2c92c0f84e23f50f014e2b48d26d7b0d' ;
       Quote.zqu__InvoiceOwnerId__c = '2c92a0fb4ffddca7015012a1ad0b4382';
       Quote.zqu__SubscriptionType__c = 'Amend Subscription' ;
       Quote.zqu__ZuoraSubscriptionID__c = 'hjjc' ;
       insert Quote;
       System.assert(Quote.Id!=null);
       system.assertEquals(false,Quote.Provisioning_Not_Required__c);
       system.assertNotEquals('Pending',Quote.Provisioning_Status__c); 

        Quote = [Select id , zqu__ZuoraAccountID__c , zqu__Opportunity__c  , zqu__InvoiceOwnerId__c from zqu__Quote__c where id=: Quote.id];
        
        update Quote;
        
     }
}