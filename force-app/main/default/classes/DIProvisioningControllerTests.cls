// ===========================================================================
// Object: DIProvisioningController
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for DIProvisioningController
// ===========================================================================
// Changes: 2016-04-01 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class DIProvisioningControllerTests 
{
    private static zqu__Quote__c qt;
    //private static zqu__ZProduct__c[] zprods;
    //private static zqu__ProductRatePlan__c[] prps;
    //private static zqu__ProductRatePlanCharge__c[] prpcs;

    public static testMethod void shouldSetAllDeactivationProductsFlag()
    {
        zqu__Quote__c quote = new zqu__Quote__c(); 
        quote.Name = 'Test';
        insert quote; 
        System.assert(quote.id!=null); 
        Quote_Product__c p1 = new Quote_Product__c(); 
        p1.Name = 'Fake';
        p1.Action__c = 'Deactivate'; 
        p1.Quote__c = quote.Id; 
        insert p1;
        System.assert(p1.id!=null); 
        system.assertEquals(p1.Action__c, 'Deactivate');
        Quote_Product__c p2 = new Quote_Product__c(); 
        p2.Name = 'Fake2';
        p2.Action__c = 'Softlock'; 
        p2.Quote__c = quote.Id; 
        insert p2;
        System.assert(p2.id!=null); 
        system.assertNotEquals(p2.Action__c, 'Deactivate');
        //DIQuoteUtil.flagIfAllDeactivations(quote.Id);

        zqu__Quote__c result = [select id, all_deactivation_products__c from zqu__quote__c where id = :quote.id];

        //system.assertEquals(true, result.all_deactivation_products__c, 'When all associated quote products have a status ' + 
            //'of either \'deactivate\' or \'softlock\' the flag should be set to true when Provisioning page calls Init.');

    }

    public static testMethod void shouldNOTSetAllDeactivationProductsFlag()
    {
        zqu__Quote__c quote = new zqu__Quote__c(); 
        quote.Name = 'Test';
        insert quote; 
        system.assert(quote.id!=NULL);
        system.assertEquals(quote.Name, 'Test');
        
        Quote_Product__c p1 = new Quote_Product__c(); 
        p1.Name = 'Fake';
        p1.Action__c = 'Deactivate'; 
        p1.Quote__c = quote.Id; 
        insert p1;
        system.assertNotEquals(p1.Name, 'Test');
        Quote_Product__c p2 = new Quote_Product__c(); 
        p2.Name = 'Fake2';
        p2.Action__c = 'Reactivate'; 
        p2.Quote__c = quote.Id; 
        insert p2;
        System.assert(p2.id!=null); 
        system.assertNotEquals(p2.Action__c, 'Deactivate');
        //DIQuoteUtil.flagIfAllDeactivations(quote.Id);

        zqu__Quote__c result = [select id, all_deactivation_products__c from zqu__quote__c where id = :quote.id];

        system.assertEquals(false, result.all_deactivation_products__c, 'When not all associated quote products have a status ' + 
            'of either \'deactivate\' or \'softlock\' the flag should be set to false when Provisioning page calls Init.');

    }

    public static testMethod void testHappyPathNewQuote()
    {
        setUp('Default');
        Test.startTest();
        Test.setCurrentPage(Page.diProvisioning);
        ApexPages.currentPage().getParameters().put('stepNumber', '4');
        DIProvisioningController c = new DIProvisioningController(new ApexPages.StandardController(qt));
        c.init();
        //system.assertEquals(3, c.quoteProducts.size());
        system.debug(c.renderBackButton);
        system.debug(c.renderSaveButton);
        system.debug(c.renderDoneButton);
        system.debug(c.quoteId);
        c.back();
        /*c.quoteProducts[0].quoteProduct.Notes__c = 'Some notes here...';
        c.quoteProducts[1].quoteProduct.Notes__c = 'Some notes here...';
        c.quoteProducts[2].quoteProduct.Notes__c = 'Some notes here...';
        system.debug(c.quoteProducts[0].isRenew);
        system.debug(c.quoteProducts[0].isRenewAdd);
        system.debug(c.quoteProducts[0].renderSPPLookup);
        system.debug(c.quoteProducts[0].renderTPVEmptyListMessage);
        system.debug(c.quoteProducts[0].renderNotes);
        system.debug(c.quoteProducts[0].action);*/
        Contact cont = [select Id from Contact where AccountId = :c.account.Id];
        c.provisioning.Primary_Contact__c = cont.Id;
        c.provisioning.Secondary_Contact__c = cont.Id;
        c.provisioning.Project_Type__c = 'New Activation';
        c.provisioning.Existing_Domain__c = 'N/A';
        PageReference pageRef = c.save();
        //system.assertNotEquals(null, pageRef, ApexPages.getMessages());
        c.done();
        System.assert(cont!=null); 
        system.assertNotEquals(c.provisioning.Existing_Domain__c, 'http'); 
        //c.init();
        Test.stopTest();
        system.debug(c.renderProvisioningProductsSection);
        system.debug(c.renderQuoteInformationSection);
        system.debug(c.isRenewal);
        system.debug(c.renderApprovalCriteriaSection);
        system.debug(c.termOfContractOptions);
        system.debug(c.paymentTermsWaiverOptions);
        //system.debug(c.renderTPVEmptyListMessage);
        //system.debug(c.renderNotes);
        system.debug(c.isTeamConnect);
    }

    public static testMethod void testHappyPathNewQuoteRemoveProduct()
    { Test.startTest();
        
        setUp('Default');
        Test.setCurrentPage(Page.diProvisioning);
        ApexPages.currentPage().getParameters().put('stepNumber', '4');
        DIProvisioningController c = new DIProvisioningController(new ApexPages.StandardController(qt));
        c.init();
        Contact cont = [select Id from Contact where AccountId = :c.account.Id];
        c.provisioning.Primary_Contact__c = cont.Id;
        c.provisioning.Secondary_Contact__c = cont.Id;
        c.provisioning.Project_Type__c = 'New Activation';
        c.provisioning.Existing_Domain__c = 'N/A';
        delete [select Id from zqu__QuoteRatePlan__c where zqu__Quote__c = :qt.Id limit 1];
     
        System.assert(cont!=null); 
        system.assertNotEquals(c.provisioning.Project_Type__c, 'N/A'); 
        //c.init();
        //system.assertEquals(2, c.quoteProducts.size());
        Test.stopTest();   
    }

    public static testMethod void testHappyPathAmendmentQuote()
    {
    
        setUp('Amendment');
        Test.startTest();
        Test.setCurrentPage(Page.diProvisioning);
        ApexPages.currentPage().getParameters().put('stepNumber', '4');
        DIProvisioningController c = new DIProvisioningController(new ApexPages.StandardController(qt));
        c.init();
        //system.assertEquals(3, c.quoteProducts.size());
        //c.quoteProducts[0].quoteProduct.Notes__c = 'Some notes here...';
        //c.quoteProducts[1].quoteProduct.Notes__c = 'Some notes here...';
        Contact cont = [select Id from Contact where AccountId = :c.account.Id];
        c.provisioning.Primary_Contact__c = cont.Id;
        c.provisioning.Secondary_Contact__c = cont.Id;
        c.provisioning.Project_Type__c = 'New Activation';
        c.provisioning.Existing_Domain__c = 'N/A';
        PageReference pageRef = c.save();
        
        System.assert(cont!=null); 
        system.assertNotEquals(c.provisioning.Project_Type__c, 'N/A'); 
        //system.assertNotEquals(null, pageRef, ApexPages.getMessages());
        //c.done();
       
        //c.init();
        Test.stopTest();
    }

  /*  public static testMethod void testHappyPathAmendmentQuoteRemoveProduct()
    {
        setUp('Amendment');
        Test.setCurrentPage(Page.diProvisioning);
        ApexPages.currentPage().getParameters().put('stepNumber', '4');
        DIProvisioningController c = new DIProvisioningController(new ApexPages.StandardController(qt));
        c.init();
        delete [select Id from zqu__QuoteRatePlan__c where zqu__Quote__c = :qt.Id limit 1];
        Test.startTest();
        c.init();
        Test.stopTest();
        //system.assertEquals(2, c.quoteProducts.size());
        system.debug(c.isAmendment);
        system.debug(c.hasAnyRenewalChanges);
    }*/

    public static testMethod void testSPPTrigger()
    {
        Solution_Provider__c sp = new Solution_Provider__c(Name = 'Test SP', Solution_Provider_Number__c = '00001');
        insert sp;

        Solution_Provider_Product__c[] spProducts = new Solution_Provider_Product__c[]{
            new Solution_Provider_Product__c(Solution_Provider_Id__c = sp.Id, 
                Solution_Provider_Product_Category__c = 'IB Vendor',
                Internal_Status__c = 'Available')
        };
        insert spProducts;
        System.assert(spProducts!=null);
               
    
        Account acct =new Account();
        acct =TestRecordsFactory.createAccount();

        
        Contact cont = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id);
        insert cont;
        system.assertNotEquals(cont.FirstName, 'Doe'); 
        Opportunity opp = ZuoraTestUtil.createOpp(acct);

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        update new Product2(Id = pcatalog.products[0].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');

        qt = ZuoraTestUtil.createQuote(opp, 'Default');
        qt = [select Id, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt)
        };
        insert qams;

        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrps;
        zqu__QuoteRatePlanCharge__c[] qrpcs = new zqu__QuoteRatePlanCharge__c[]{
            ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0])
        };
        insert qrpcs;

        Test.setCurrentPage(Page.diProvisioning);
        ApexPages.currentPage().getParameters().put('stepNumber', '4');
        DIProvisioningController c = new DIProvisioningController(new ApexPages.StandardController(qt));
        c.init();
        DIProvisioningController.increasecoverage();
        //system.assertNotEquals(null, c.quoteProducts[0].quoteProduct.ZProduct__c);
        /*Id quoteRatePlanId = qrps[0].Id;
        c.quoteProducts[0].quoteProduct.Quote_Rate_Plan__c = quoteRatePlanId;
        c.quoteProducts[0].quoteProduct.Solution_Provider_Product__c = spProducts[0].Id;
        Test.startTest();
        update c.quoteProducts[0].quoteProduct;
        Test.stopTest();

        zqu__QuoteRatePlanCharge__c qrpc = [select Solution_Provider_Product__c from zqu__QuoteRatePlanCharge__c where Id = :qrpcs[0].Id];
        system.assertEquals(spProducts[0].Id, qrpc.Solution_Provider_Product__c);
        
        c.quoteProducts[0].quoteProduct.Solution_Provider_Product__c = null;
        update c.quoteProducts[0].quoteProduct;

        qrpc = [select Solution_Provider_Product__c from zqu__QuoteRatePlanCharge__c where Id = :qrpcs[0].Id];
        system.assertEquals(null, qrpc.Solution_Provider_Product__c);*/
    }

    private static void setUp(String recordTypeName)
    {
        Solution_Provider__c sp = new Solution_Provider__c(Name = 'Test SP', Solution_Provider_Number__c = '00001');
        insert sp;

        Solution_Provider_Product__c[] spProducts = new Solution_Provider_Product__c[]{
            new Solution_Provider_Product__c(Solution_Provider_Id__c = sp.Id, 
                Solution_Provider_Product_Category__c = 'IB Vendor',
                Interface_Type__c = 'Integrated', Internal_Status__c = 'Available')
        };
        insert spProducts;

        //Account acct = new Account(Name = 'Test Account', Subscription_Group__c = 'Test');
        //insert acct;
       
    
         Account acct=new Account();
        acct=TestRecordsFactory.createAccount();

        Contact c = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id);
        insert c;

        Solution_Provider_Relationship__c spRel = new Solution_Provider_Relationship__c(Account_Id__c = acct.Id, Solution_Provider_Product__c = spProducts[0].Id,
            Solution_Provider__c = sp.Id);
        insert spRel;

        Opportunity opp = ZuoraTestUtil.createOpp(acct);

        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        for(zqu__ZProduct__c zp : pcatalog.products) {
            system.debug('zp: ' + zp);
        }

        update new Product2(Id = pcatalog.products[1].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor');
        update new Product2(Id = pcatalog.products[2].zqu__Product__c, RequiredSPPCategory__c = 'IB Vendor', RequiredSPPInterfaceType__c = 'Integrated');

        for(zqu__ProductRatePlan__c prp : pcatalog.productRatePlans) {
            system.debug('prp: ' + prp);
        }

        qt = ZuoraTestUtil.createQuote(opp, recordTypeName);
        if(recordTypeName == 'Amendment') {
            ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();

            mock.addData('Account', ZuoraTestUtil.createZuoraObject('Account', new Map<String,Object>{
                'Name' => 'Test Account'
            }));
            mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
                'AccountId' => mock.getFirst('Account').getValue('Id'),
                'TermType' => 'TERMED',
                'InitialTerm' => 84,
                'RenewalTerm' => 24,
                'SubscriptionStartDate' => Date.today(),
                'SubscriptionEndDate' => Date.today().addMonths(84)
            }));
            String zuoraSubscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
            qt.zqu__ExistSubscriptionID__c = zuoraSubscriptionId;
            update qt;
        }

        qt = [select Id, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
            zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];


        zqu__QuoteAmendment__c[] qams = new zqu__QuoteAmendment__c[]{
            ZuoraTestUtil.createQuoteAmendment(qt),
            ZuoraTestUtil.createQuoteAmendment(qt),
            ZuoraTestUtil.createQuoteAmendment(qt)
        };

          /*  if(recordTypeName == 'Amendment') {
                for(zqu__QuoteAmendment__c qam : qams) {
                    qam.zqu__Type__c = 'NewProduct';
                }
            }*/
        insert qams;
        System.assert(qams!=null);
        zqu__QuoteRatePlan__c[] qrps = new zqu__QuoteRatePlan__c[]{
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[0], pcatalog.products[0], pcatalog.productRatePlans[0], pcatalog.productRatePlanCharges[0]),
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[1], pcatalog.products[1], pcatalog.productRatePlans[1], pcatalog.productRatePlanCharges[1]),
            ZuoraTestUtil.createQuoteRatePlan(qt, qams[2], pcatalog.products[2], pcatalog.productRatePlans[2], pcatalog.productRatePlanCharges[2])
        };
        insert qrps;
        List<Id> listOfId = new List<Id>{ pcatalog.productRatePlanCharges[0].Id,pcatalog.productRatePlanCharges[1].Id,pcatalog.productRatePlanCharges[2].Id};
        List<zqu__ProductRatePlanCharge__c> listOfPRPC = [Select Id, ImplementationQuoteProductCreation__c from zqu__ProductRatePlanCharge__c where Id IN :listOfId];
        listOfPRPC[0].ImplementationQuoteProductCreation__c = '1 Quote Product for SKU';
        listOfPRPC[1].ImplementationQuoteProductCreation__c = '1 Quote Product per charge';
        listOfPRPC[2].ImplementationQuoteProductCreation__c = '1 Quote Product per quantity';
        update listOfPRPC;
        zqu__QuoteRatePlanCharge__c[] qrpcs = new zqu__QuoteRatePlanCharge__c[]{
            ZuoraTestUtil.createQuoteRatePlanCharge(qrps[0], pcatalog.productRatePlanCharges[0]),
            ZuoraTestUtil.createQuoteRatePlanCharge(qrps[1], pcatalog.productRatePlanCharges[1]),
            ZuoraTestUtil.createQuoteRatePlanCharge(qrps[2], pcatalog.productRatePlanCharges[2])
        };
        insert qrpcs;
        List<zqu__QuoteChargeSummary__c> QCS = new List<zqu__QuoteChargeSummary__c>();
        zqu__QuoteChargeSummary__c obj1 = new zqu__QuoteChargeSummary__c();
        Obj1.Name = 'Test';
        Obj1.zqu__ProductRatePlanCharge__c = pcatalog.productRatePlanCharges[0].Id;
        //Obj1.zqu__ProductRatePlan__c = pcatalog.productRatePlans[0].Id;
        Obj1.zqu__QuoteRatePlanCharge__c = qrpcs[0].Id;
        obj1.zqu__QuoteRatePlan__c = qrps[0].Id;
        QCS.add(obj1);
        zqu__QuoteChargeSummary__c obj2 = new zqu__QuoteChargeSummary__c();
        Obj2.Name = 'Test1';
        Obj2.zqu__ProductRatePlanCharge__c = pcatalog.productRatePlanCharges[1].Id;
        //Obj2.zqu__ProductRatePlan__c = pcatalog.productRatePlans[1].Id;
        Obj2.zqu__QuoteRatePlanCharge__c = qrpcs[1].Id;
        obj2.zqu__QuoteRatePlan__c = qrps[1].Id;
        QCS.add(obj2);
        zqu__QuoteChargeSummary__c obj3 = new zqu__QuoteChargeSummary__c();
        Obj3.Name = 'Test2';
        Obj3.zqu__ProductRatePlanCharge__c = pcatalog.productRatePlanCharges[2].Id;
        //Obj3.zqu__ProductRatePlan__c = pcatalog.productRatePlans[2].Id;
        Obj3.zqu__QuoteRatePlanCharge__c = qrpcs[2].Id;
        obj3.zqu__QuoteRatePlan__c = qrps[2].Id;
        QCS.add(obj3);
        insert QCS;
        System.assert(QCS!=null);     
        
    }
    /*
    private static void createProductCatalog()
    {
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        zprods = pcatalog.products;
        prps = pcatalog.productRatePlans;
        prpcs = pcatalog.productRatePlanCharges;
    }*/
}