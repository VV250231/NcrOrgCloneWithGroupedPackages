// ===========================================================================
// Object: ZQuoteUpdateUtilTests
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for ZQuoteUpdateUtil
// ===========================================================================
// Changes: 2017-04-26 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class ZQuoteUpdateUtilTests {
    public static testMethod void test2_onDelete() {
        ZuoraOptions__c zopts = ZuoraOptions__c.getInstance();
        zopts.Update_Quotes_on_Subscription_Sync__c = true;
        upsert zopts;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c(Zuora__Zuora_Id__c = ZuoraTestUtil.generateGUID(),
                                                                Name = 'A-S999999');
        insert zsub;
        
        system.assertNotEquals('A-S111111', zsub.Name);
        
        Account acct = new Account(Name = 'Test Account');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
            insert acct;
        }
        //Account acct = new Account(Name = 'Test Account');
        //insert acct;
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');

        qt.zqu__ExistSubscriptionID__c = zsub.Zuora__Zuora_Id__c;   
        update qt;
        
        Test.startTest();
        delete zsub;
        Test.stopTest();
    }
    
    public static testMethod void test1(){
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        Account acct = new Account(Name = 'Test Account');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
            insert acct;
        }
       // Account acct = new Account(Name = 'Test Account');
       // insert acct;
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'SubscriptionEndDate' => Date.today().addYears(7), 'Status' => 'Expired', 'Version' => 1
        }));
        String originalId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => originalId, 'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));

        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'SubscriptionEndDate' => Date.today().addYears(7), 'Status' => 'Active', 'Version' => 2, 'OriginalId' => originalId
        }));
        
        qt.zqu__ExistSubscriptionID__c = originalId;
        update qt;
        
        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        insert qam;
        
        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.getFirst('RatePlan').getValue('Id');
        insert qrp;
        system.assert(qrp.zqu__SubscriptionRatePlanZuoraId__c != Null);
        ZQuoteUpdateUtil.updateQuote(qt.Id);
        
    }

    public static testMethod void test3_fromController(){
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        
        Account acct = new Account(Name = 'Test Account');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
            insert acct;
        }
        //Account acct = new Account(Name = 'Test Account');
        //insert acct;
                
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'SubscriptionEndDate' => Date.today().addYears(7), 'Status' => 'Expired', 'Version' => 1
        }));
        String originalId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => originalId, 'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));

        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'SubscriptionEndDate' => Date.today().addYears(7), 'Status' => 'Active', 'Version' => 2, 'OriginalId' => originalId
        }));
        
        qt.zqu__ExistSubscriptionID__c = originalId;
        update qt;
        
        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        insert qam;
        
        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.getFirst('RatePlan').getValue('Id');
        insert qrp;
        
        ApexPages.currentPage().getParameters().put('id',qt.Id);
        Test.setCurrentPage(Page.QuoteUpdate);
        QuoteUpdateController c = new QuoteUpdateController(new ApexPages.StandardController(qt));
        system.assertEquals(null, c.initAction());
        c.goBack();
    }

    public static testMethod void test4_fromController_exception(){
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();

        Account acct = new Account(Name = 'Test Account');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
            insert acct;
        }
        
        //Account acct = new Account(Name = 'Test Account');
        //insert acct;
        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'Amendment');
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'SubscriptionEndDate' => Date.today().addYears(7), 'Status' => 'Expired', 'Version' => 1
        }));
        String originalId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => originalId, 'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));

        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'SubscriptionEndDate' => Date.today().addYears(7), 'Status' => 'Expired', 'Version' => 2, 'OriginalId' => originalId
        }));
        
        qt.zqu__ExistSubscriptionID__c = originalId;
        update qt;
        
        zqu__QuoteAmendment__c qam = ZuoraTestUtil.createQuoteAmendment(qt);
        insert qam;
        
        zqu__QuoteRatePlan__c qrp = ZuoraTestUtil.createQuoteRatePlan(qt, qam, pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]);
        qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)mock.getFirst('RatePlan').getValue('Id');
        insert qrp;
        
        ApexPages.currentPage().getParameters().put('id',qt.Id);
        Test.setCurrentPage(Page.QuoteUpdate);
        QuoteUpdateController c = new QuoteUpdateController(new ApexPages.StandardController(qt));
        system.assertEquals(null, c.initAction());
    }

}