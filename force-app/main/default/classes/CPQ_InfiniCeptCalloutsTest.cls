@isTest
public with sharing class CPQ_InfiniCeptCalloutsTest{
    
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

        List<Product2> products = CPQ_TestDataFactory.createProducts(10);
            insert products;

            List<PricebookEntry> pbEntries = CPQ_TestDataFactory.createPriceBookEntries(Test.getStandardPricebookId(), products);
            insert pbEntries;

            Map<Id,PricebookEntry> productIdToPBEntery = new Map<Id,PricebookEntry>();
            for (PricebookEntry pbEntry : pbEntries) {
                productIdToPBEntery.put(pbEntry.Product2Id, pbEntry);
            }

            // Create Multisite Quote
            SBQQ__Quote__c quote = CPQ_TestDataFactory.createMultiSiteQuote(act,sites[0],con);
            insert quote;

            NCR_Payments_Site__c pyamentSite = CPQ_TestDataFactory.createNcrPaymentSite(quote,sites[1]);
            insert pyamentSite;

            for (Product2 product : products) {
                CPQ_TestDataFactory.createQuoteLineItem(quote, product, productIdToPBEntery.get(product.Id));
            }

            // Create Single site quote
            SBQQ__Quote__c singleSiteQuote = CPQ_TestDataFactory.createSingleSiteQuote(act,sites[0],con);
            insert singleSiteQuote;
            for (Product2 product : products) {
                CPQ_TestDataFactory.createQuoteLineItem(singleSiteQuote, product, productIdToPBEntery.get(product.Id));
            }

            List<JP_EndPoint__c> endpoints = new List<JP_EndPoint__c>();
            endpoints.add(new JP_EndPoint__c(name = 'JPTemplate', EndPoint_URL__c = 'https://ncrstag-stag.apigee.net/payos/api/v1.0/application/template'));
            endpoints.add(new JP_EndPoint__c(name = 'SubmitApplication', EndPoint_URL__c = 'https://ncrstag-stag.apigee.net/payos/api/v1.0/application?partial=true&'));
            insert endpoints;
    }
    
    @isTest
    static void testMultiSiteUnderWriting() {

        act = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
        Con = [SELECT Id, Name FROM Contact WHERE AccountId =: act.Id LIMIT 1];
        site = [SELECT Id, Name FROM Account WHERE ParentId != null LIMIT 1];
        SBQQ__Quote__c msQte = [SELECT Id, Name FROM SBQQ__Quote__c WHERE qtc_Multi_Site__c = true LIMIT 1];
        SBQQ__Quote__c ssQte = [SELECT Id, Name FROM SBQQ__Quote__c WHERE qtc_Multi_Site__c = false LIMIT 1];
        System.debug('*** ssQte : '+ssQte);
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:JetPay/oauth/client_credential/accesstoken?grant_type=client_credentials', 
                'CPQ_jsonAccessToken');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application/template', 
                'CPQ_jsonTemplate');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application?partial=true&', 
                'CPQ_jsonSubmitApplication');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        CPQ_InfiniCeptCallouts.submitAppRequest(msQte.Id);
        List<NCR_Payments_Site__c> paymentSites = [SELECT Account_Sites__c, InfiniceptApplicationId__c, 
                NCR_Payments_Application_Status__c 
                FROM NCR_Payments_Site__c 
                WHERE Account_Sites__c =: site.Id];
        System.debug('***'+paymentSites);
        CPQ_InfiniCeptCallouts.submitAppRequest(ssQte.Id);
        Test.stopTest();   
    }

    @isTest
    static void testSingleSiteUnderWriting() {

        act = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
        Con = [SELECT Id, Name FROM Contact WHERE AccountId =: act.Id LIMIT 1];
        site = [SELECT Id, Name FROM Account WHERE ParentId != null LIMIT 1];
        SBQQ__Quote__c ssQte = [SELECT Id, Name FROM SBQQ__Quote__c WHERE qtc_Multi_Site__c = false LIMIT 1];
        System.debug('*** ssQte : '+ssQte);
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:JetPay/oauth/client_credential/accesstoken?grant_type=client_credentials', 
                'CPQ_jsonAccessToken');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application/template', 
                'CPQ_jsonTemplate');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application?partial=true&', 
                'CPQ_jsonSubmitApplication');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        CPQ_InfiniCeptCallouts.submitAppRequest(ssQte.Id);
        Test.stopTest();   
    }

    @isTest
    static void testJSONGenerationError() {

        act = [SELECT Id, Name FROM Account WHERE ParentId = null LIMIT 1];
        Con = [SELECT Id, Name FROM Contact WHERE AccountId =: act.Id LIMIT 1];
        site = [SELECT Id, Name FROM Account WHERE ParentId != null LIMIT 1];
        SBQQ__Quote__c ssQte = [SELECT Id, Name FROM SBQQ__Quote__c WHERE qtc_Multi_Site__c = false LIMIT 1];
        ssQte.Payments_Application_Signee__c = null; // It will throw error while generation JSON
        update ssQte;
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:JetPay/oauth/client_credential/accesstoken?grant_type=client_credentials', 
                'CPQ_jsonAccessToken');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application/template', 
                'CPQ_jsonTemplate');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application?partial=true&', 
                'CPQ_jsonSubmitApplication');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        Test.startTest();
        CPQ_InfiniCeptCallouts.submitAppRequest(ssQte.Id);
        Test.stopTest();   
    }
/*
    static MultiStaticResourceCalloutMock prepareToken(){
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:JetPay/oauth/client_credential/accesstoken?grant_type=client_credentials', 
                'CPQ_jsonAccessToken');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application/template', 
                'CPQ_jsonTemplate');
        multimock.setStaticResource('https://ncrstag-stag.apigee.net/payos/api/v1.0/application?partial=true&', 
                'CPQ_jsonSubmitApplication');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        return multimock;
    }    
  */  
    private static JPLogs__c prepareJPLog(String quoteID, String e){
        JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=quoteID+'- Outbound',
                                          status__c = ('Failure-Exception :' +e).left(250));
        insert log;
        JPLogs__c l = [SELECT Id, Name FROM JPLogs__c WHERE name like :quoteID LIMIT 1];
        return l;
    }
    private static SBQQ__Quote__c prepareDataForWithdrawalRequest(){
        //Id quoteID;
        String withdrawalComments = 'test comment from Devendra';
        //setupTestData method will setup data by default
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
        CPQ_InfiniCeptCallouts.bypassQuoteTrigger = true;
        List<NCR_Payments_Site__c> paymentSites = [Select id, Name, NCR_Payments_Application_Status__c, Quote__r.Name, 
                                                Quote__r.qtc_Multi_Site__c, Account_Sites__r.Parent.Master_Customer_Number__c, 
                                                SiteId__c, OrganizationId__c, Merchant_Application_Id__c, Account_Sites__c, 
                                                Quote__r.SBQQ__Account__c, Cobrand__c, AdministratorURL__c, Account_Sites__r.Name, 
                                                Account_Sites__r.Site_Number__c, Quote__c from NCR_Payments_Site__c 
                                                where Quote__c = :quoteID ];
        List<JP_EndPoint__c> endpoints = new List<JP_EndPoint__c>();
            endpoints.add(new JP_EndPoint__c(name = 'WithdrawApplication', EndPoint_URL__c = 'https://ncrstag-stag.apigee.net/payos/api/v1.0/application/{mrchntAppId}/withdrawn'));
            insert endpoints;
        return ssQte;
    }
    
    @isTest
    static void testSendWithdrawalRequestValidation() {
        String withdrawalComments = 'test comment from Devendra';
        SBQQ__Quote__c ssQte = prepareDataForWithdrawalRequest();
        //JPLogs__c log = prepareJPLog(ssQte.Id, 'test exception');
        CPQ_InfiniCeptCallouts.bypassQuoteTrigger = false;
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new CPQ_InfiniceptCalloutsFailedMock());
        CPQ_InfiniCeptCallouts.sendWithdrawalRequest(ssQte.Id, null);
        Test.stopTest();
    }
    
    @isTest
    static void testSendWithdrawalRequestFailed() {
        String withdrawalComments = 'test comment from Devendra';
        SBQQ__Quote__c ssQte = prepareDataForWithdrawalRequest();
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new CPQ_InfiniceptCalloutsFailedMock());
        CPQ_InfiniCeptCallouts.sendWithdrawalRequest(ssQte.Id, withdrawalComments);
        Test.stopTest();
    }
    @isTest
    static void testSendWithdrawalRequestBlank() {
        String withdrawalComments = 'test comment from Devendra';
        SBQQ__Quote__c ssQte = prepareDataForWithdrawalRequest();
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new CPQ_InfiniceptCalloutsFailedMock());
        CPQ_InfiniCeptCallouts.sendWithdrawalRequest(ssQte.Id, null);
        Test.stopTest();
    }
    
    @isTest
    static void testSendWithdrawalRequestSuccess() {
        String withdrawalComments = 'test comment from Devendra';
        SBQQ__Quote__c ssQte = prepareDataForWithdrawalRequest();
       
       Test.SetMock(HttpCallOutMock.class, new CPQ_InfiniceptCalloutsSuccessMock());
        
        Test.startTest();
        //System.debug('paymentSites : ' + paymentSite);
        CPQ_InfiniCeptCallouts.sendWithdrawalRequest(ssQte.Id, withdrawalComments);
        CPQ_InfiniCeptCallouts.sendWithdrawalRequest(ssQte.Id, null);    
        Test.stopTest();
    }
   // @isTest
 class CPQ_InfiniceptCalloutsSuccessMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        //sample request
        //{"siteId":"94a9634b-c702-47cc-9d02-3157af130f83","organizationId":"e2d83032-f3ea-4250-841c-521d7e18a070","message":"test","MCN":"ATL864","dbaName":"Test AAS33","applicationUrl":"https://merchantapp.io:443/ncralohapfintegration/CoBrands/MerchantUW?applicationId=210985","applicationId":"210985"}
         HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('Application 210547 was not found in the cobrand ncralohapfintegration.');
        response.setStatusCode(200);
        return response;
    }}
    
    class CPQ_InfiniceptCalloutsFailedMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
         HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('Application 210547 was not found in the cobrand ncralohapfintegration.');
        response.setStatusCode(404);
        return response;
    }}
    
    class CPQ_InfiniceptCalloutsBlankMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
         HttpResponse response = null;
        
        return response;
    }}

  /*  
    public static HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"UserResponseABM":{"UserResponse":{"Message":"User created successfully test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test testtest test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test tes."},"ResponseHeader":{"Status":"SUCCESS","Timestamp":"2021-01-25T04:03:49.305-05:00","TransactionID":"0090f804-76ca-4fff-98d8-6dfc27e9af99"}}}');
        response.setStatusCode(200);
        return response; 
    }*/ 
    
}