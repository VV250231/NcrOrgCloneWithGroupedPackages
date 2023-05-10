@isTest
private class TestZquoteExtUtil {  
    static testMethod void runUnitTest(){
        Test.startTest();
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        //
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
            insert a;
        }
        //
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        insert o;
        System.assert(o.Id!=null);
        system.assertNotEquals(o.stagename, 'closed');
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
        system.assertNotEquals(ba.Zuora__Currency__c, 'AUD');
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
        insert q;
        system.assertNotEquals(q.Sales_Comp_Status__c, 'Pending');
        zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
        qa.name = 'abc' ;
        qa.zqu__Quote__c = q.id;
        insert qa;
        system.assertEquals(qa.name, 'abc');
        zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
        qp.name = 'abc';
        qp.zqu__Quote__c = q.id ;
        qp.zqu__QuoteAmendment__c = qa.id;
        qp.zqu__AmendmentType__c = 'NewProduct';
        qp.zqu__SubscriptionRatePlanZuoraId__c = 'zuora-plan1';
        insert qp ;
        system.assertEquals(qp.zqu__AmendmentType__c, 'NewProduct');
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
        system.assert(qrpcList!=NULL);
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.Zuora__External_Id__c = 'c92c0f9ezsubId';
        zsub.Zuora__Zuora_Id__c = 'c92c0f9ezsubId';
        insert zsub;
        System.assert(zsub.Id!=null);
        system.assertNotEquals(zsub.Zuora__Zuora_Id__c, '7yhg77tfvhaf');
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
        
        // for covering the portion futureShareQuoteWithAccandAccTeam future method
        User u = [SELECT Id FROM User WHERE Quicklook_ID__c = 'am251037' LIMIT 1];
        AccountTeamMember acTM = new AccountTeamMember();
        acTM.AccountId = a.id ;
        acTM.UserId = u.id ;
        insert acTM ;
        
        
        Map<id,id> quoteAccountIdMap = new Map<Id,Id>();
        quoteAccountIdMap.put(q.Id,a.id);
        ZquoteExtUtil.futureShareQuoteWithAccandAccTeam(quoteAccountIdMap);
        
        Test.stopTest();
        
        Map<ID, String> quoteIdSubIdMap = new Map<ID, String>();
        quoteIdSubIdMap.put(q.Id, q.zqu__ExistSubscriptionID__c);
        ZquoteExtUtil.calcQuoteOneTimeandMonthlyaFee(quoteIdSubIdMap);  
        
        qp.zqu__AmendmentType__c = 'UpdateProduct';
        update qp;
        ZquoteExtUtil.calcQuoteOneTimeandMonthlyaFee(quoteIdSubIdMap); 
       
    }
}