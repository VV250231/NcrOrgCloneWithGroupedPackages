@isTest
private class TestdefaultQuoteChargeFieldsTrigger {  
    static testMethod void runUnitTest(){
         Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        system.runas(TestRecordsFactory.getUser())
        {
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
        
        zqu__Quote__c q = new zqu__Quote__c();
        q.name = 'test-quote';
        q.zqu__Account__c = a.id ;
        q.zqu__Opportunity__c = o.id;
        q.zqu__Status__c = 'QA Processing Complete';
        q.Rebill__c = false; 
        q.Provisioning_Not_Required__c = false;
        q.Sales_Comp_Status__c = 'Complete';
        q.Provisioning_Status__c = 'Complete';
        insert q;
        
        zqu__QuoteCharge__c qc = new zqu__QuoteCharge__c();
        qc.name = 'test' ;
        qc.zqu__ChargeType__c = 'One-Time';
        qc.zqu__Quote__c = q.id ;
        qc.PartnerCommission__c = '100';
        qc.Cost__c = '100';
        insert qc; 
        
        system.assertEquals(qc.name,'test');
    
    }
}