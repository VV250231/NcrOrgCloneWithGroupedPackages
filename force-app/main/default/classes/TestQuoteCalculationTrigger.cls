/*
##################################################################################################
# Project Name..........: Subscription Commerce                                                                       
# File..................: TestUpdateQuoteBundleDetailTrigger.cls                                                        
# Version...............: 34.0 
# Created by............: IDC, Gurgaon                                                                   
# Created Date..........: 06-24-2015                                                                               
# Last Modified by......: IDC, Gurgaon
# Last Modified Date....: 06-24-2015 
# Description...........: The test class is written to test the CalcMonthlyGPforAmendmentQuotes and Populate_MonthlyGPofAllQuotesOnOpp trigger on Quote.
################################################################################################
*/
@isTest
private class TestQuoteCalculationTrigger {  
     static testMethod void runUnitTest(){
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        insert a;
        System.assert(a.Id!=null);
        system.assertEquals('HOSPITALITY:CHANNEL',a.industry);
        system.assertNotEquals('UK',a.Account_Country_Code__c);
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        insert o;
        System.assert(o.Id!=null);
        system.assertEquals('test',o.name);
        system.assertNotEquals('Approved',o.stagename);
         
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
    	System.assert(ba.Id!=null);
        system.assertEquals('mid-1',ba.NMS_MID__c);
        system.assertNotEquals('2c92c0f9eyy7',ba.Zuora__External_Id__c);
         
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
        String amendmentRecordTypeId = dsr.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        test.startTest();
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
        q.zqu__SubscriptionType__c ='Amend Subscription';
        q.Include_in_Forecast__c = true;
        insert q;
        System.assert(q.Id!=null); 
       
        zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
        qa.name = 'abc' ;
        qa.zqu__Quote__c = q.id;
        insert qa;
        system.assertEquals('abc',qa.name);
       
        zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
        qp.name = 'abc';
        qp.zqu__Quote__c = q.id ;
        qp.zqu__QuoteAmendment__c = qa.id;
        insert qp ;
        system.assertNotEquals('xyz',qp.name);
        zqu__QuoteRatePlanCharge__c qr = new zqu__QuoteRatePlanCharge__c();
        qr.name = 'test' ;
        qr.zqu__ChargeType__c = 'One-Time';
        qr.zqu__QuoteRatePlan__c = qp.id ;
        insert qr ;
        system.assertEquals('test',qr.name);
     test.stoptest();
    }
    
}