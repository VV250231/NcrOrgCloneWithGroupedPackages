//Author: Aashirwaad Mahatha
// Purpose: Class written to cover the code coverage of ShowErrorOnQuoteWizard.
// ===========================================================================
// Changes: 2020-04-09 Akshun Singh
//           Class created
@isTest
public class ShowErrorOnQuoteWizardTest {
    private static Account acct;
    private static Opportunity opp;
    private static zqu__Quote__c qt;
    private static SObject quoteDB;
    
	Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }
    
     @testsetup
    public static void setUp() 
    {
        acct = new Account(Name = 'Test Account',Subscription_Group__c = 'Hospitality Hosted Solutions');
        
        System.runAs(getUser()){
        insert acct;
        }
		        
        Contact[] contacts = new Contact[]{
            new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id)
        };
        insert contacts;
		system.debug('@@@@Contacts'+contacts);
        OpportunityStage oppStage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        system.debug('@@@oppStage'+oppStage);
        opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id,  CloseDate = Date.today(), StageName = oppStage.MasterLabel);
        
       // System.runAs(getUser()){
        insert opp;
       // }
        qt = new zqu__Quote__c(zqu__Account__c = acct.id, zqu__Opportunity__c = opp.Id,zqu__InitialTermPeriodType__c = 'Month',
                               zqu__InvoiceOwnerId__c= '2c92a0fd590128e4015901c5522b533d',Subscription_Group__c = ''
                               ,zqu__RenewalTermPeriodType__c = 'Month');
        quoteDB = qt;
        insert quoteDB;
        
        
        
        //add
        Zuora__Subscription__c  subs = new Zuora__Subscription__c ();
        subs.Zuora__Zuora_Id__c = 'test12352';
        insert subs;
        
        Zuora__CustomerAccount__c cusAccObj = new Zuora__CustomerAccount__c();
        cusAccObj.Zuora__Batch__c = 'Batch10';
        cusAccObj.Zuora__AccountNumber__c= 'A00520558';
        cusAccObj.Subscription_Group__c ='Hospitality Hosted Solutions';
        cusAccObj.Zuora__PurchaseOrderNumber__c ='';
        cusAccObj.Zuora__Zuora_Id__c = 'test12352';        
        cusAccObj.Zuora__Account__c = acct.id;
        insert cusAccObj;
        
       // user u = [select id from user where Quicklook_ID__c = 'am251037'];
        zqu__Quote__c qt = new zqu__Quote__c(zqu__Account__c = acct.id, zqu__Opportunity__c = opp.Id,zqu__InitialTermPeriodType__c = 'Month',
                                             zqu__InvoiceOwnerId__c= 'test12352',Subscription_Group__c = 'Hospitality Hosted Solutions',zqu__Status__c='New',
                                             zqu__RenewalTermPeriodType__c = 'Month');
        
        insert qt;
        
    }
    @isTest
    public static  void method1(){    
       // system.debug('AAAAAAAA '+[SELECT Id,Zuora__AccountNumber__c,Subscription_Group__c,Zuora__Batch__c,Zuora__Zuora_Id__c, Zuora__PurchaseOrderNumber__c FROM Zuora__CustomerAccount__c].size());
        test.startTest();
        zqu__Quote__c qt = [select id,Subscription_Group__c from zqu__Quote__c where Subscription_Group__c = 'Hospitality Hosted Solutions' limit 1];
        qt.Subscription_Group__c = '';
        
        update qt; 
        test.stopTest();
    }
}