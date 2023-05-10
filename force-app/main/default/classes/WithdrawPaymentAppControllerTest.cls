@isTest
public class WithdrawPaymentAppControllerTest {
    
    static Account act;
    static Account site;
    static Contact con;
    static List<Account> sites = new List<Account>();
    
    
    @testSetup static void setupTestData() {
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            //create account
            act = CPQ_TestDataFactory.createAccount('1', null);
            insert act;

            //creat contact
            con = CPQ_TestDataFactory.createContact(act.Id, '1', null);
            insert con;

            //create sites
            
            sites.add(CPQ_TestDataFactory.createSite(act, '1', null));
            sites.add(CPQ_TestDataFactory.createSite(act, '2', null));
            insert sites;

        }
        // Create Multisite Quote
            SBQQ__Quote__c quote = CPQ_TestDataFactory.createMultiSiteQuote(act,sites[0],con);
            insert quote;

            NCR_Payments_Site__c pyamentSite = CPQ_TestDataFactory.createNcrPaymentSite(quote,sites[1]);
            insert pyamentSite;
        
        SBQQ__Quote__c singleSiteQuote = CPQ_TestDataFactory.createSingleSiteQuote(act,sites[0],con);
            insert singleSiteQuote;
    }
    
    @isTest
    static void validatePaymentAppWithdrawalTest(){
         act = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
        Con = [SELECT Id, Name FROM Contact WHERE AccountId =: act.Id LIMIT 1];
        site = [SELECT Id, Name FROM Account WHERE ParentId != null LIMIT 1];
        SBQQ__Quote__c ssQte = [SELECT Id, Name FROM SBQQ__Quote__c WHERE qtc_Multi_Site__c = false LIMIT 1];
        ssQte.Payments_Application_Signee__c = null; // It will throw error while generation JSON
        //ssQte.Name = 'Test Quote';
        update ssQte;
        site.Site_Number__c = 'Test-001';
        NCR_Payments_Site__c nps = [SELECT Id, Quote__c, Account_Sites__c FROM NCR_Payments_Site__c WHERE Quote__c != null LIMIT 1];
        nps.NCR_Payments_Application_Status__c = 'Submission Successful';
        nps.AdministratorURL__c = 'https://www.test.com';
        nps.SiteId__c = 'Test-Site'; 
        nps.Account_Sites__c = site.Id;
        nps.OrganizationId__c = 'Test Org'; 
        nps.Merchant_Application_Id__c = 'Test - MAID' ;
		nps.Cobrand__c = 'Test Cobrand';
        nps.Quote__c = ssQte.Id;
        update nps;
        Id quoteID = ssQte.Id;
        
        List<NCR_Payments_Site__c> paymentSites = [Select id, NCR_Payments_Application_Status__c,  Quote__r.Name, Quote__r.qtc_Multi_Site__c, Quote__c from NCR_Payments_Site__c where Quote__c =:quoteID];
        
        WithdrawPaymentAppController.validatePaymentAppWithdrawal(quoteID);
    }
    
    @isTest
    static void notifyToWithdrawApplication(){
        SBQQ__Quote__c ssQte = [SELECT Id, Name FROM SBQQ__Quote__c WHERE qtc_Multi_Site__c = false LIMIT 1];
        Id quoteID = ssQte.Id;
        String withdrawalComments = 'test from Devendra';
       WithdrawPaymentAppController.notifyToWithdrawApplication(quoteID, withdrawalComments); 
    }
}