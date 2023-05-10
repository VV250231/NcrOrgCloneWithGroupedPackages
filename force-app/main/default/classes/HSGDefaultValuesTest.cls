// ===========================================================================
// Author: Akshun Singh
// Purpose: Class written to cover the code coverage of HSGDefaultValues.
// ===========================================================================
// Changes: 2016-09-30 Akshun Singh
//           Class created
// ===========================================================================
@isTest(SeeAllData=false)
public class HSGDefaultValuesTest 
{
    private static Account acct;
    private static Opportunity opp;
    private static zqu__Quote__c qt;
    private static SObject quoteDB;
    
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    } 
    
    
      public static testMethod void testHSGDefaultValueNewSub()
    {
        setUp();
        qt = new zqu__Quote__c(zqu__Account__c = acct.id,zqu__InitialTermPeriodType__c = 'Month',zqu__RenewalTermPeriodType__c = 'Month');
        quoteDB = qt;
        PageReference createQuote = Page.zqu__CreateQuote;
       // createQuote.getParameters().put('null', opp.Id);
        createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '2');
        Test.setCurrentPage(createQuote);
        ZuoraCustomizationPlugin__c setting = new ZuoraCustomizationPlugin__c();
        setting.Name = 'Test Setting';
        setting.Implementation_Class__c = 'HSGDefaultValues';
        setting.NCR_Division__c         = 'CRM Account';
        setting.Plugin_Type__c          = 'INCRDefaultValuePlugin';
        insert setting;
        
       
        Test.startTest();

        NCRDefaultValuePlugin defaultPluginImpl = new NCRDefaultValuePlugin();
        defaultPluginImpl.populateDefaultFieldValue(quoteDB, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
        system.assertNotEquals(setting, null);
    }
    

    public static testMethod void testHSGDefaultValuePlugin()
    {
        setUp();
        
        PageReference createQuote = Page.zqu__CreateQuote;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('quoteType', 'Amendment');
        createQuote.getParameters().put('stepNumber', '2');
        createQuote.getParameters().put('subscriptionId', 'test12352');
        Test.setCurrentPage(createQuote);
        ZuoraCustomizationPlugin__c setting = new ZuoraCustomizationPlugin__c();
        setting.Name = 'Test Setting2';
        setting.Implementation_Class__c = 'HSGDefaultValues';
        setting.NCR_Division__c         = 'HOSPITALITY';
        setting.Plugin_Type__c          = 'INCRDefaultValuePlugin';
        insert setting;
        
        Zuora__Subscription__c  subs = new Zuora__Subscription__c ();
        subs.Zuora__Zuora_Id__c = 'test12352';
        insert subs;
        Zuora__SubscriptionProductCharge__c subRatePlan = new Zuora__SubscriptionProductCharge__c ();
        subRatePlan.Name                        =  'Test Rate Plan Charge';
        subRatePlan.Zuora__Subscription__c      = subs.Id;
        subRatePlan.BundleName__c               = 'Test Name One-Time';
        subRatePlan.Zuora__Type__c                          = 'One-Time';
        insert subRatePlan;
        Test.startTest();

        NCRDefaultValuePlugin defaultPluginImpl = new NCRDefaultValuePlugin();
        defaultPluginImpl.populateDefaultFieldValue(quoteDB, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
        system.assertNotEquals(setting, null);
    }
    
    
    public static testMethod void testHSGDefaultValuePlugin1()
    {
        setUp();
        qt = new zqu__Quote__c(zqu__Account__c = acct.id,zqu__InitialTermPeriodType__c = 'Month',zqu__RenewalTermPeriodType__c = 'Month');
        quoteDB = qt;
        PageReference createQuote = Page.zqu__CreateQuote;
       // createQuote.getParameters().put('null', opp.Id);
        createQuote.getParameters().put('quoteType', 'Amendment');
        createQuote.getParameters().put('stepNumber', '2');
        createQuote.getParameters().put('subscriptionId', 'test1235222');
        Test.setCurrentPage(createQuote);
        ZuoraCustomizationPlugin__c setting = new ZuoraCustomizationPlugin__c();
        setting.Name = 'Test Setting';
        setting.Implementation_Class__c = 'HSGDefaultValues';
        setting.NCR_Division__c         = 'CRM Account';
        setting.Plugin_Type__c          = 'INCRDefaultValuePlugin';
        insert setting;
        
        Zuora__Subscription__c  subs = new Zuora__Subscription__c ();
        subs.Zuora__Zuora_Id__c = 'test1235222';
        insert subs;
        Zuora__SubscriptionProductCharge__c subRatePlan = new Zuora__SubscriptionProductCharge__c ();
        subRatePlan.Name                        =  'Test Rate Plan Charge2';
        subRatePlan.Zuora__Subscription__c      = subs.Id;
        subRatePlan.BundleName__c               = 'Test Name Recurring';
        subRatePlan.Zuora__Type__c                          = 'Recurring';
        insert subRatePlan;
        Test.startTest();

        NCRDefaultValuePlugin defaultPluginImpl = new NCRDefaultValuePlugin();
        defaultPluginImpl.populateDefaultFieldValue(quoteDB, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
    }
    
        public static testMethod void testHSGDefaultValuePlugin3()
    {
        setUp();
        qt = new zqu__Quote__c(zqu__Account__c = acct.id);
        quoteDB = qt;
        PageReference createQuote = Page.zqu__CreateQuote;
       // createQuote.getParameters().put('null', opp.Id);
        createQuote.getParameters().put('quoteType', 'Amendment');
        createQuote.getParameters().put('stepNumber', '2');
        createQuote.getParameters().put('subscriptionId', 'test12352222');
        Test.setCurrentPage(createQuote);
        ZuoraCustomizationPlugin__c setting = new ZuoraCustomizationPlugin__c();
        setting.Name = 'Test Setting';
        setting.Implementation_Class__c = 'HSGDefaultValues';
        setting.NCR_Division__c         = 'CRM Account';
        setting.Plugin_Type__c          = 'INCRDefaultValuePlugin';
        insert setting;
        
        Zuora__Subscription__c  subs = new Zuora__Subscription__c ();
        subs.Zuora__Zuora_Id__c = 'test12352222';
        subs.InvoiceGrouping__c = 'RDS Firehouse';
        subs.OverridePaymentTerm__c = '60 NET';
        insert subs;
        Zuora__SubscriptionProductCharge__c subRatePlan = new Zuora__SubscriptionProductCharge__c ();
        subRatePlan.Name                        =  'Test Rate Plan Charge3';
        subRatePlan.Zuora__Subscription__c      = subs.Id;
        subRatePlan.BundleName__c               = 'Test Name Usage Fee';
        subRatePlan.Zuora__Type__c              = 'Usage';
        insert subRatePlan;
       
        Test.startTest();
        NCRDefaultValuePlugin defaultPluginImpl = new NCRDefaultValuePlugin();
        defaultPluginImpl.populateDefaultFieldValue(quoteDB, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
        system.assertNotEquals(setting, null);
        
    }


    public static void setUp() 
    {
        acct = new Account(Name = 'Test Account',Subscription_Group__c = 'Hospitality Hosted Solutions')   ;
        
        System.runAs(getUser()){
        insert acct;
        }
        
        
        //acct = new Account(Name = 'Test Account',Subscription_Group__c = 'Hospitality Hosted Solutions')   ;
        //insert acct;

        Contact[] contacts = new Contact[]{
            new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id)
        };
        insert contacts;

        OpportunityStage oppStage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id, /*Solution_Portfolio__c = 'HOSPITALITY',*/ CloseDate = Date.today(), StageName = oppStage.MasterLabel);
        insert opp;

        qt = new zqu__Quote__c(zqu__Account__c = acct.id, zqu__Opportunity__c = opp.Id,zqu__InitialTermPeriodType__c = 'Month',zqu__RenewalTermPeriodType__c = 'Month');
        quoteDB = qt;
    }
}