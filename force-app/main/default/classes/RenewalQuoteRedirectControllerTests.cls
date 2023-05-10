// ===========================================================================
// Object: RenewalQuoteRedirectControllerTests
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for RenewalQuoteRedirectControllerTests
// ===========================================================================
// Changes: 2016-05-12 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=true)
public class RenewalQuoteRedirectControllerTests 
{
    static ZuoraTestUtil.ProductCatalog pcatalog;
    static Account acct;
    static Opportunity opp;
    static zqu__Quote__c qt;
    static String subscriptionId;
    
    public static testMethod void testDI() 
    {
        setUp();
        system.assertNotEquals(0, pcatalog.products.size());
        ApexPages.currentPage().getParameters().put('subscriptionId', subscriptionId);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        RenewalQuoteRedirectController c = new RenewalQuoteRedirectController(
            new ApexPages.StandardController(
                new zqu__Quote__c(zqu__Opportunity__c = opp.Id, zqu__Account__c = acct.Id,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month')
            )
        );
        PageReference pageRef = c.init();
    }

        public static testMethod void testDI2() 
    {
        setUp();
        system.assertNotEquals(0, pcatalog.products.size());
        ApexPages.currentPage().getParameters().put('subscriptionId', subscriptionId);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        RenewalQuoteRedirectController c = new RenewalQuoteRedirectController(
            new ApexPages.StandardController(
                new zqu__Quote__c(zqu__Opportunity__c = opp.Id, zqu__Account__c = acct.Id,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month')
            )
        );
        zqu__Quote__c qt = new zqu__Quote__c(zqu__Opportunity__c = opp.Id, zqu__Account__c = acct.Id,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month',zqu__ZuoraSubscriptionID__c = subscriptionId,
                                            zqu__Status__c = 'Sent to Z-Billing',Renewal_Subscription_ID__c = '8a8aa2e37efcf5a9017f00b6c475074d',zqu__ZuoraAccountID__c = '2c92a0fd590128e4015901c5522b533f',zqu__StartDate__c = Date.newInstance(2022,2,1));
        insert qt;
        ZuoraClient.updateZuoraSubscription(qt.Id);
        ZuoraClient.updateZuoraAccount(qt.Id);
        ZuoraClient.activateSubscription(subscriptionId,Date.newInstance(2022,2,1));
    }
    
    public static testMethod void testNonDI() 
    {
        setUp();
        for(Schema.PicklistEntry ple : Opportunity.Opportunity_Classification__c.getDescribe().getPicklistValues()) {
            if(ple.getValue() != 'Digital Insight') {
                opp.Opportunity_Classification__c = ple.getValue();
                break;
            }
        }
      /*  for(Schema.PicklistEntry ple :  opp.Solution_Portfolio__c.getDescribe().getPicklistValues()) {
            if(ple.getValue() != 'Digital Banking') {
                opp.Solution_Portfolio__c= ple.getValue();
                break;
            }
        }*/
        
        update opp;

        system.assertNotEquals(0, pcatalog.products.size());
        ApexPages.currentPage().getParameters().put('subscriptionId', subscriptionId);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        RenewalQuoteRedirectController c = new RenewalQuoteRedirectController(
            new ApexPages.StandardController(
                new zqu__Quote__c(zqu__Opportunity__c = opp.Id, zqu__Account__c = acct.Id,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month')
            )
        );
        PageReference pageRef = c.init();
    }

    private static void setUp()
    {
        User Usr = [Select Id from User Where Name = 'Soup User'];
        pcatalog = ZuoraTestUtil.createOneProductCatalog('Recurring', 'Volume Pricing');
        
        acct = new Account(Name = 'Test Account',Subscription_Group__c = 'Digital Insight');
        System.runAs(Usr){
            insert acct;
        }

        opp = ZuoraTestUtil.createOpp(acct);
        //qt = ZuoraTestUtil.createQuote(opp, '');

        //qt = [select Id, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
        //  zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :qt.Id];
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
        subscriptionId = (String)mock.getFirst('Subscription').getValue('Id');
        mock.addData('RatePlan', ZuoraTestUtil.createZuoraObject('RatePlan', new Map<String,Object>{
            'SubscriptionId' => subscriptionId,
            'ProductRatePlanId' => pcatalog.productRatePlans[0].zqu__ZuoraId__c
        }));
        String ratePlanId = (String)mock.getFirst('RatePlan').getValue('Id');
        mock.addData('RatePlanCharge', ZuoraTestUtil.createZuoraObject('RatePlanCharge', new Map<String,Object>{
            'RatePlanId' => ratePlanId,
            'ProductRatePlanChargeId' => pcatalog.productRatePlanCharges[0].zqu__ZuoraId__c,
            'Quantity' => 1, 'ChargeType' => 'Recurring', 'ChargeModel' => 'Volume Pricing'
        }));
        String ratePlanChargeId = (String)mock.getFirst('RatePlanCharge').getValue('Id');
        mock.addData('RatePlanChargeTier', ZuoraTestUtil.createZuoraObject('RatePlanChargeTier', new Map<String,Object>{
            'RatePlanChargeId' => ratePlanChargeId, 'StartingUnit' => 0, 'EndingUnit' => 1,
            'Tier' => 1, 'Price' => 1000
        }));
        mock.addData('RatePlanChargeTier', ZuoraTestUtil.createZuoraObject('RatePlanChargeTier', new Map<String,Object>{
            'RatePlanChargeId' => ratePlanChargeId,
            'Tier' => 2, 'Price' => 900, 'StartingUnit' => 2
        }));
    }


}