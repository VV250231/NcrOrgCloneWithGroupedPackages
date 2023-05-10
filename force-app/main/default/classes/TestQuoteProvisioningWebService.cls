@isTest
private class TestQuoteProvisioningWebService  {  
    static testMethod void runUnitTest(){
        Test.startTest();
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        system.runAs(TestRecordsFactory.getUser()) {
            insert a;
        }
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        insert o;
        
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
    
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
        String amendmentRecordTypeId = dsr.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        
        zqu__Quote__c q = new zqu__Quote__c();
        q.name = 'test-quote';
        q.zqu__Account__c = a.id ;
        q.zqu__Opportunity__c = o.id;
        q.Bundle_Flag__c = true;
        q.zqu__Status__c = 'QA Processing Complete';
        q.Rebill__c = false; 
        q.Provisioning_Not_Required__c = false;
        q.Sales_Comp_Status__c = 'Complete';
        q.Provisioning_Status__c = 'Complete';
        q.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
        q.zqu__InvoiceOwnerId__c = '2c92c0f9ext1';
        q.zqu__ExistSubscriptionID__c = 'c92c0f9ezsubId';
        q.RecordTypeId = amendmentRecordTypeId;
        insert q;
         System.assertNotEquals(a.id, null,'Quote should not be null');
        zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
        qa.name = 'abc' ;
        qa.zqu__Quote__c = q.id;
        insert qa;
        
        zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
        qp.name = 'abc';
        qp.zqu__Quote__c = q.id ;
        qp.zqu__QuoteAmendment__c = qa.id;
        qp.zqu__AmendmentType__c = 'NewProduct';
        qp.zqu__SubscriptionRatePlanZuoraId__c = 'zuora-plan1';
        insert qp ;
        
        List<zqu__QuoteRatePlanCharge__c> qrpcList = new List<zqu__QuoteRatePlanCharge__c>();
        
        zqu__QuoteRatePlanCharge__c qr1 = new zqu__QuoteRatePlanCharge__c();
        qr1.name = 'test1' ;
        qr1.zqu__ChargeType__c = 'One-Time';
        qr1.zqu__QuoteRatePlan__c = qp.id ;
        qr1.zqu__Total__c = 100;
        qr1.zqu__SubscriptionRatePlanChargeZuoraId__c = 'zoura-charge1';
        qrpcList.add(qr1) ;
        
        zqu__QuoteRatePlanCharge__c qr2 = new zqu__QuoteRatePlanCharge__c();
        qr2.name = 'test2' ;
        qr2.zqu__ChargeType__c = 'Recurring';
        qr2.zqu__QuoteRatePlan__c = qp.id ;
        qr2.zqu__Period__c = 'Month';
        qr2.zqu__Total__c = 200;
        qr1.zqu__SubscriptionRatePlanChargeZuoraId__c = 'zoura-charge2';
        qrpcList.add(qr2) ;
        
        insert qrpcList;
        Test.stopTest();
        
        zqu__Quote__c zquote = [Select Id, zqu__Number__c From zqu__Quote__c where Id = :q.id Limit 1];
        QuoteProvisioningWebService.getAllQuotes(false, 'Complete', 'QA Processing Complete', false, false);
        QuoteProvisioningWebService.updateQuote(zquote.Id, zquote.zqu__Number__c, 'Complete','QA Processing Complete', Date.today() , Date.today());
       
    }
    
    @isTest(SeeAllData=true)
    static void runProivsionTest(){
        List<zqu__Quote__c> newQuote =  [Select Id , zqu__ZuoraAccountID__c from zqu__Quote__c where zqu__SubscriptionType__c = 'New Subscription' and name LIKE '%Tammy%' limit 1];
        List<zqu__Quote__c> amendQuote = [Select Id , zqu__ZuoraAccountID__c from zqu__Quote__c where zqu__SubscriptionType__c = 'Amend Subscription' limit 1];                                             
 System.assertNotEquals(newQuote, null,'newQuote should not be null');
        if(!newQuote.isEmpty()) {
            
            for(zqu__Quote__c zqt : newQuote)
            {
                if(zqt.zqu__ZuoraAccountID__c <> NULL)
                {
                    try{
                    QuoteProvisioningWebService.getProvisioningQuoteData(newQuote.get(0).Id);
                    }
                    
                    catch(exception e)
                    {
                    system.debug('exception occured'+e);
                    }
                }
            }
        }
     
    }
}