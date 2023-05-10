/*
##################################################################################################
# Project Name..........: Subscription Commerce                                                                       
# File..................: TestUpdateQuoteBundleDetailTrigger.cls                                                        
# Version...............: 34.0 
# Created by............: IDC, Gurgaon                                                                   
# Created Date..........: 06-24-2015                                                                               
# Last Modified by......: IDC, Gurgaon
# Last Modified Date....: 06-24-2015 
# Description...........: The test class is written to test the UpdateQuoteBundleDetail  trigger on Quote.
################################################################################################
*/
@isTest
private class TestQuoteBundlingandReportingTrigger {  
    @testSetup static void setupTestData(){
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        insert a;
        system.assertNotEquals('test-quote',a.name);
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        insert o;
        system.assertEquals('test',o.name);
        
        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c();
        ba.name = 'test-billing';
        ba.Aloha_Key__c = 'aloha-1';
        ba.Enterprise_ID__c = 'test-ent-1';
        ba.ERPSiteNumber__c = 'test-123';
        ba.NMS_Lead__c = true;
        ba.NMS_MID__c =  'mid-1';
        ba.POS_System__c = 'NCR';
        ba.Reseller_POS_Sales_Rep__c = 'Tammy';
        ba.Zuora__External_Id__c = '2c92c0f9ext1'; 
        ba.Zuora__MRR__c = 100.00; 
        ba.Zuora__Currency__c = 'USD';
        ba.ORGCode__c ='org-1';
        ba.Zuora__Account__c = a.Id;
        insert ba;
    	system.assertNotEquals('test-quote',ba.name);
        
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
        String amendmentRecordTypeId = dsr.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        
        zqu__Quote__c q = new zqu__Quote__c();
        q.name = 'test-quote';
        q.zqu__Account__c = a.id ;
        q.zqu__Opportunity__c = o.id;
        q.zqu__Status__c = 'QA Processing Complete';
        q.Rebill__c = false; 
        q.Provisioning_Not_Required__c = false;
        q.Sales_Comp_Status__c = 'Complete';
        q.Provisioning_Status__c = 'Complete';
        q.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
        q.zqu__InvoiceOwnerId__c = '2c92c0f9ext1';
        q.zqu__ExistSubscriptionID__c = 'c92c0f9ezsubId';
        q.RecordTypeId = amendmentRecordTypeId;
        q.BundleNameNew__c = 'Usage Fee' ;
        insert q;
        system.assertNotEquals('QA Complete',q.zqu__Status__c);
        system.assertEquals('test-quote',q.name);
        
        zqu__ProductRatePlanCharge__c prpc =  new zqu__ProductRatePlanCharge__c();
        prpc.name = 'Test prpc' ;
        insert prpc;
        
        
        zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
        qa.name = 'abc' ;
        qa.zqu__Quote__c = q.id;
        insert qa;
        
        zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
        qp.name = 'abc';
        qp.zqu__Quote__c = q.id ;
        qp.zqu__QuoteAmendment__c = qa.id;
        insert qp ;
        
        zqu__QuoteRatePlanCharge__c qr = new zqu__QuoteRatePlanCharge__c();
        qr.name = 'test' ;
        qr.zqu__ChargeType__c = 'One-Time';
        qr.zqu__QuoteRatePlan__c = qp.id ;
        qr.zqu__ProductRatePlanCharge__c = prpc.id;
        insert qr ;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.Zuora__External_Id__c = 'c92c0f9ezsubId';
        zsub.Zuora__Zuora_Id__c = 'c92c0f9ezsubId';
        insert zsub;
        
        List<Zuora__SubscriptionProductCharge__c> chargeList = new List<Zuora__SubscriptionProductCharge__c>();
        
        Zuora__SubscriptionProductCharge__c subcharge1 = new Zuora__SubscriptionProductCharge__c();
        subcharge1.Zuora__External_Id__c ='zoura-charge1';
        subcharge1.Zuora__RatePlanId__c = 'zuora-plan1'; 
        subcharge1.Zuora__Price__c = 100.00;
        subcharge1.Zuora__ExtendedAmount__c = 100.00;   
        subcharge1.Zuora__Type__c =  'One-Time';
        subcharge1.Zuora__Subscription__c = zsub.Id;
        chargeList.add(subcharge1);
        
        Zuora__SubscriptionProductCharge__c subcharge2 = new Zuora__SubscriptionProductCharge__c();
        subcharge2.Zuora__External_Id__c ='zoura-charge2';
        subcharge2.Zuora__RatePlanId__c = 'zuora-plan1'; 
        subcharge2.Zuora__Price__c = 100.00;
        subcharge2.Zuora__ExtendedAmount__c = 100.00;   
        subcharge2.Zuora__Type__c =  'Recurring';
        subcharge2.Zuora__BillingPeriod__c = 'Month';
        subcharge2.Zuora__Subscription__c = zsub.Id;
        chargeList.add(subcharge2);
        insert chargeList;
        System.assert(chargeList[0].Id!=null);
     
    }
    
    static testMethod void testQuoteBundleDetail() { 
        zqu__Quote__c zQuote = [Select Id from zqu__Quote__c where name = 'test-quote' Limit 1];
        zQuote.BundleNameNew__c = 'Not a Bundle' ;
        update zQuote;
        System.assert(zQuote.Id!=null);
        system.assertEquals('Not a Bundle',zQuote.BundleNameNew__c);
        system.assertNotEquals('test-quote1',zQuote.name);
       
        //update zQuote; 
    }
    
      
       
   
    
  
}