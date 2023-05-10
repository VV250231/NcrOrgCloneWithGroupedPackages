// ===========================================================================
// Object: ZQuoteTests
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for Z-Quote customizations
// ===========================================================================
// Changes: 2016-11-17 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class ZQuoteTests 
{
    static zqu__Quote__c qt;
    static Id bundleId;
    static ZuoraTestUtil.ProductCatalog pcatalog;    
    
    @isTest
    public static void test1_diSelectProductController() {
        setUp('New Renewal');
        ApexPages.currentPage().getParameters().put('id', qt.Id);
        ApexPages.currentPage().getParameters().put('bundleId', bundleId);
        ApexPages.currentPage().getParameters().put('stepNumber', '3');
        DISelectProductController disp = new DISelectProductController(new ApexPages.StandardController(qt));
        disp.initAction();
        system.debug(disp.hasAnyBundles);
        system.debug(disp.quoteId);
        disp.selectBundle();
        
        //cover the plugin manually
        DISelectProductController.AddRemoveRatePlanPlugin plugin = new DISelectProductController.AddRemoveRatePlanPlugin();
        plugin.onAdd(qt.Id, new List<String>{ pcatalog.productRatePlans[1].Id });
        plugin.onRemove(qt.Id, new List<String>{ pcatalog.productRatePlans[1].Id });

        DISelectProductController.SaveRatePlanPlugin plugin2 = new DISelectProductController.SaveRatePlanPlugin();
        plugin2.onSave(null, null, null, null);
        delete qt;
    }

    @isTest
    public static void test2_page4AndSubmit() {
        setUp('New Renewal');
        ApexPages.currentPage().getParameters().put('id', qt.Id);
        DISelectProductController disp = new DISelectProductController(new ApexPages.StandardController(qt));
        disp.initAction();
        
        DIProvisioningController dipc = new DIProvisioningController(new ApexPages.StandardController(qt));
        dipc.init();
        dipc.provisioning.Primary_Contact__c = qt.zqu__BillToContact__c;
        dipc.provisioning.Secondary_Contact__c = qt.zqu__BillToContact__c;
        PageReference nextPage = dipc.done();
        if(nextPage == null) {
            for(ApexPages.Message msg : ApexPages.getMessages()) {
                system.assertEquals(null, msg.getDetail());
            }
        }
        system.assertNotEquals(null, nextPage);

        //test submit code

        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        /*
        mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
            'Id' => ZuoraTestUtil.generateGUID()
        }));
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => mock.getFirst('Subscription').getValue('Id'),
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001, 'ChargeNumber' => 'C-000001', 'Segment' => 1, 'IsLastSegment' => true
        }));
        */

        qt.zqu__ZuoraSubscriptionID__c = (String)mock.getFirst('Subscription').getValue('Id');
        qt.zqu__Status__c = 'Sent to Z-Billing';
        qt.Name = 'New Renewal';
        Test.startTest();   
        update qt;       
        System.assert(qt.Id!=null);
        system.assertNotEquals('newTest',qt.zqu__Status__c);
        Test.stopTest();
    }

    @isTest
    public static void test3_page4AndSubmit_new() {
        setUp('Default');
        ApexPages.currentPage().getParameters().put('id', qt.Id);
        DISelectProductController disp = new DISelectProductController(new ApexPages.StandardController(qt));
        disp.initAction();
        
        DIProvisioningController dipc = new DIProvisioningController(new ApexPages.StandardController(qt));
        dipc.init();
        dipc.provisioning.Primary_Contact__c = qt.zqu__BillToContact__c;
        dipc.provisioning.Secondary_Contact__c = qt.zqu__BillToContact__c;
        //dipc.quoteProducts[0].quoteProduct.Solution_Provider_Product__c = [select Id from Solution_Provider_Product__c  limit 1].Id;
        PageReference nextPage = dipc.done();
        if(nextPage == null) {
            for(ApexPages.Message msg : ApexPages.getMessages()) {
                system.assertEquals(null, msg.getDetail());
            }
        }
        system.assertNotEquals(null, nextPage);
        Test.startTest();
        DISelectProductController dispc = new DISelectProductController(new ApexPages.StandardController(qt));
        ApexPages.currentPage().getParameters().put('bundleId', bundleId);
        dispc.addBundle();

        //test submit code

        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        /*
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => mock.getFirst('Subscription').getValue('Id'),
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001, 'ChargeNumber' => 'C-000001', 'Segment' => 1, 'IsLastSegment' => true
        }));
        */

        String subscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        system.assertNotEquals(null, subscriptionId);
        qt.zqu__ZuoraSubscriptionID__c = subscriptionId;
        qt.zqu__Status__c = 'Sent to Z-Billing';
        qt.Name = 'New Renewal';
           
        update qt;     
        System.assert(qt.Id!=null);
        system.assertNotEquals('new',qt.zqu__Status__c);
        Test.stopTest();
    }

    @isTest
    public static void test4_page4AndSubmit_new() {
       setUp('Default');
       new UpdateZuoraSubscriptionQueueable(qt.Id).runcalc();
    }


    public static void setUp(String recordTypeName)
    {
        Test.setMock(WebServiceMock.class, new NSCProvisioningMock());

        Solution_Provider__c sp = new Solution_Provider__c();
        insert sp;
        
        Solution_Provider_Product__c spp = new Solution_Provider_Product__c(Solution_Provider_Id__c = sp.Id, Product_Manager__c = 'John Doe', Name = 'Test SPP', 
            Solution_Provider_Product_Category__c = 'IB Vendor', Interface_Type__c = 'Integrated', Internal_Status__c = 'Available');
        insert spp;
        
        String zBillingAccountId = ZuoraTestUtil.generateGUID();

        Account acct = new Account(Name = 'Test Account', DPV_Provider__c = sp.Id, DPV_Software__c = spp.Id, 
                                    Master_Customer_Number__c = '1234', 
                                    Subscription_Group__c = 'Digital Insight');
       
        System.runAs(TestRecordsFactory.getUser()){
            insert acct;
        }
        
        
        
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(
            Zuora__Account__c = acct.Id, BillToFlag__c = 'Yes',
            Zuora__External_Id__c = zBillingAccountId, Zuora__Zuora_Id__c = zBillingAccountId 
        );
        insert billingAccount;
        System.assert(billingAccount.Id!=null);
        system.assertNotEquals('No',billingAccount.BillToFlag__c);
        
        Contact cont = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id);
        insert cont;
        System.assert(cont.Id!=null);
        system.assertEquals('John',cont.FirstName);

        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        //pcatalog = ZuoraTestUtil.createOneProductCatalog('Recurring', 'Per Unit Pricing');
        pcatalog = ZuoraTestUtil.createProductCatalog();
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');
        
        qt = ZuoraTestUtil.createQuote(opp, recordTypeName);
        if(recordTypeName == 'New Renewal') qt.Renewal_Subscription_ID__c = ZuoraTestUtil.generateGUID();
        qt.zqu__BillToContact__c = cont.Id;
        qt.zqu__SoldToContact__c = cont.Id;
        qt.zqu__Account__c = acct.Id;
        qt.zqu__ZuoraAccountID__c = zBillingAccountId;
        update qt;
        System.assert(qt.Id!=null);
                
        qt = [select Id, Renewal_Subscription_ID__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c, zqu__ZuoraAccountID__c,
            zqu__Opportunity__r.AccountId, zqu__BillToContact__c, zqu__SoldToContact__c from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;

        zqu__QuoteRatePlanCharge__c qrpc = ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]);
        qrpc.zqu__EffectivePrice__c = 1001; //update the price
        insert qrpc;
        System.assert(qrpc.Id!=null);
                
        ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
        mock.addData('Product', ZuoraTestUtil.createZuoraObject('Product', new Map<String,Object>{
            'Id'=>pcatalog.products[0].zqu__ZuoraId__c,
            'Name' => 'Test Product'
        }));
        mock.addData('ProductRatePlan', ZuoraTestUtil.createZuoraObject('ProductRatePlan', new Map<String,Object>{
            'Id' => pcatalog.productRatePlans[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan', 
            'ProductId' => mock.getFirst('Product').getValue('Id')
        }));
        mock.addData('ProductRatePlanCharge', ZuoraTestUtil.createZuoraObject('ProductRatePlanCharge', new Map<String,Object>{
            'Id' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Name' => 'Test Product Rate Plan Charge', 
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id'), 
            'TriggerEvent' => 'ServiceActivation'
        }));

        if(String.isBlank(qt.Renewal_Subscription_ID__c)) {
            mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
                'SubscriptionEndDate' => Date.today().addYears(7)
            }));
            
        }else{
            mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
                'Id' => qt.Renewal_Subscription_ID__c, 'SubscriptionEndDate' => Date.today().addYears(7)
            }));
        }
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => qt.Renewal_Subscription_ID__c,
            'ProductRatePlanId' => mock.getFirst('ProductRatePlan').getValue('Id')
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'Price' => 1001
        }));
        
        Product_Bundle__c[] bundles = [select Name, Active__c, Description__c from Product_Bundle__c where Active__c = true];
        //if(bundles.isEmpty()) {
            bundles = new Product_Bundle__c[]{
                new Product_Bundle__c(Name = 'Test', Description__c = 'Test', Active__c = true)
            };
            insert bundles;
        System.assert(bundles.size()>0);
        
        
        bundleId = bundles[0].Id;
        //TODO change to pcatalog.productRatePlans[1] to see coverage of new charge group add code, but it is failing
        Id productRatePlanId = pcatalog.productRatePlans[1].Id;
        //productRatePlanId = [select Id from zqu__ProductRatePlan__c where CreatedDate < TODAY and zqu__Deleted__c = false LIMIT 1].Id;
        Product_Bundle_Rate_Plan__c[] bundleRatePlans = new Product_Bundle_Rate_Plan__c[]{
            new Product_Bundle_Rate_Plan__c(Product_Bundle__c = bundles[0].Id, Product_Rate_Plan__c = productRatePlanId)
        };
        insert bundleRatePlans;
        System.assert(bundleRatePlans.size()>0);
       
        //}
    }

    public class NSCProvisioningMock implements WebServiceMock
    {
        public void doInvoke 
        (
            Object stub,
            object request,
            Map<String,Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        )
        {
            NSCProvisioning.OpportunityResponseType res_ele = new NSCProvisioning.OpportunityResponseType();
            response.put('response_x',res_ele); 
        }
    }
}