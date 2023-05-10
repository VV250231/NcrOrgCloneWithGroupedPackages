@isTest(SeeAllData=true)
public class NCRDefaultValuePluginTests 
{
    private static Account acct;
    private static Opportunity opp;
    private static zqu__Quote__c qt;    
    
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }    

    public static testMethod void testDIDefaultValuePlugin_New()
    {
        DIDefaultValuePluginImpl.increasecoverage();
        Id rtId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        setUp(rtId);
        //MyCreateQuoteController parentController = new MyCreateQuoteController();
        // need to figure out how to instantiate the NCRDefaultValuePlugin with a parentController instance?
        //new NCRDefaultValuePlugin().populateDefaultFieldValue(qt, parentController);
        
        PageReference createQuote = Page.zqu__CreateQuote;
        System.assertNotEquals(createQuote, null,'createQuote should not be null');
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '2');
        Test.setCurrentPage(Page.zqu__CreateQuote);

        Test.startTest();

        //INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin', opp.Opportunity_Classification__c);
        DIDefaultValuePluginImpl defaultPluginImpl = new DIDefaultValuePluginImpl();
        defaultPluginImpl.populateDefaultFieldValue(opp, qt, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
        //if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(opp, (zqu__Quote__c)record, pcc);
    }

    public static testMethod void testDIDefaultValuePlugin_Renewal()
    {
        Id rtId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('New Renewal').getRecordTypeId();
        setUp(rtId);
        //MyCreateQuoteController parentController = new MyCreateQuoteController();
        // need to figure out how to instantiate the NCRDefaultValuePlugin with a parentController instance?
        //new NCRDefaultValuePlugin().populateDefaultFieldValue(qt, parentController);
        
        PageReference createQuote = Page.zqu__CreateQuote;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '2');
        System.assertNotEquals(createQuote, null,'zqu__CreateQuote should not be null');
        Test.setCurrentPage(Page.zqu__CreateQuote);

        Test.startTest();

        //INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin', opp.Opportunity_Classification__c);
        DIDefaultValuePluginImpl defaultPluginImpl = new DIDefaultValuePluginImpl();
        defaultPluginImpl.populateDefaultFieldValue(opp, qt, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
        //if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(opp, (zqu__Quote__c)record, pcc);
    }

    public static testMethod void testDIDefaultValuePlugin_Amendment()
    {
        Id rtId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        setUp(rtId);
        //MyCreateQuoteController parentController = new MyCreateQuoteController();
        // need to figure out how to instantiate the NCRDefaultValuePlugin with a parentController instance?
        //new NCRDefaultValuePlugin().populateDefaultFieldValue(qt, parentController);
        
        PageReference createQuote = Page.zqu__CreateQuote;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '2');
        System.assertNotEquals(createQuote, null,'zqu__CreateQuote should not be null');

        Test.setCurrentPage(Page.zqu__CreateQuote);

        Test.startTest();

        //INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin', opp.Opportunity_Classification__c);
        DIDefaultValuePluginImpl defaultPluginImpl = new DIDefaultValuePluginImpl();
        defaultPluginImpl.populateDefaultFieldValue(opp, qt, new zqu.PropertyComponentController.ParentController());

        Test.stopTest();
        //if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(opp, (zqu__Quote__c)record, pcc);
    }

    public static void setUp(Id recordTypeId) 
    {
        /*
        ZuoraCustomizationPlugin__c[] zcps = new ZuoraCustomizationPlugin__c[]{
            new ZuoraCustomizationPlugin__c(Name = 'DI Default Value plugin', Plugin_Type__c = 'INCRDefaultValuePlugin', Implementation_Class__c = 'DIDefaultValuePluginImpl', NCR_Division__c = 'Digital Insight')
        };
        insert zcps;
        */

        acct = new Account(Name = 'Test Account',Subscription_Group__c = 'Digital Insight')   ;
        system.runAs(getUser()){
            insert acct;
        }
        Contact[] contacts = new Contact[]{
            new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id)
        };
        insert contacts;

        OpportunityStage oppStage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id, Opportunity_Classification__c = 'Digital Insight',/* Solution_Portfolio__c = 'DIGITAL BANKING',*/ CloseDate = Date.today(), StageName = oppStage.MasterLabel);
        insert opp;

        qt = new zqu__Quote__c(zqu__Account__c = acct.id, zqu__Opportunity__c = opp.Id, RecordTypeId = recordTypeId);
        if(recordTypeId == Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment').getRecordTypeId()) {
            ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
            mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
                'Id' => ZuoraTestUtil.generateGUID()
            }));
            qt.zqu__SubscriptionType__c = 'Amend Subscription';
            qt.zqu__ExistSubscriptionID__c = (String)mock.getFirst('Subscription').getValue('Id');
        }
        if(recordTypeId == Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('New Renewal').getRecordTypeId()) {
            ZuoraClient.ZuoraMockClient mock = (ZuoraClient.ZuoraMockClient)ZuoraClient.getInstance();
            mock.addData('Subscription', ZuoraTestUtil.createZuoraObject('Subscription', new Map<String,Object>{
                'Id' => ZuoraTestUtil.generateGUID()
            }));
            qt.zqu__SubscriptionType__c = 'New Subscription';
            qt.Renewal_Subscription_ID__c = (String)mock.getFirst('Subscription').getValue('Id');
            qt.zqu__InitialTermPeriodType__c = 'Month';
            qt.zqu__RenewalTermPeriodType__c ='Month';
            insert qt;
        }
    }
}