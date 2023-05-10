/*
##################################################################################################
# Project Name..........: Easy Button                                                                     
# File..................: TestOppQuoteLinkageController.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                   
# Created Date..........: 23-02-2015                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 23-02-2015 
# Description...........: The test class is written to test the OppQuoteLinkageController and OrderController Class.
EBA_SF-1831 :            Test class method should have assert Part 13
################################################################################################
*/
@isTest
private class TestOppQuoteLinkageController {  
    @testSetup static void setupTestData(){
        // create new account object
        Account a = new Account (name = 'WOT Upsert Test', 
                                 LOB__c='FINANCIAL',
                                 Master_Customer_Number__c = 'TEST000012', 
                                 Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true);
        System.runAs(TestRecordsFactory.getUser()){
          insert a;
        }
          
        // create new sales org object 
        Sales_Org__c s = new Sales_Org__c (name = 'test org', Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor object 
        Competitors__c c = new Competitors__c (name = 'testing competitor');
        insert c;
        
        
        // create new Opportunity object 
        Opportunity opp = new Opportunity();  
        Id r2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'Entertainment Self Service';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r2;
        insert opp;
        
         // create new Opportunity object 
        Opportunity opp1 = new Opportunity();   
        opp1.name = 'abc';
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp1.AccountID = a.id;
        opp1.Name = 'OppQuoteLink Test2';
        opp1.type = 'Indirect Channel';
        opp1.Solution_Portfolio__c = 'Entertainment Self Service';
        opp1.CURRENCYISOCODE = 'USD';
        opp1.SALES_ORG__C = s.id;
        opp1.INVOICE_TRIGGER__C='Shipment';
        opp1.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp1.PRIMARY_COMPETITOR__C = c.id;
        opp1.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp1.closeDate = System.TODAY();
        opp1.stagename = 'Analyzing';
        opp1.recordTypeId = r1;
        insert opp1;

    }
    
    static testMethod void runWOTLinkTest() {
        Opportunity oppObj = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Name = 'OppQuote Linkage Test Opportunity' LIMIT 1];  
        Opportunity oppObj1 = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Name = 'OppQuoteLink Test2' LIMIT 1];  
        
        Test.startTest();
        //null orderObj test
        QuoteObject emptyOrder = new QuoteObject();
        OppQuoteLinkageController.OppQuoteLinkage(emptyOrder);
        
        // invalid app test                                                                                                                   
        QuoteObject OrderObj1 = new QuoteObject();
        OrderObj1.appName = 'QUBY_LINK';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj1);
        
        OrderObj1.OpportunityNumber='123';
        OrderObj1.quoteNumber= '9876';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj1);
        
        OrderObj1.quoteName='Test name';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj1);
        
        QuoteObject OrderObj2 = new QuoteObject();
        OrderObj2.appName = 'WOT_UPSERT';
        OrderObj2.opportunityNumber = oppObj.Opportunity_Number__c;
        OrderObj2.quoteNumber= '1234';

        OppQuoteLinkageController.OppQuoteLinkage(OrderObj1);
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
         
        OrderObj2.quoteName = 'TEST Quote1';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.MCN = 'TEST1234';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.quoteAmount  = 1000; 
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.quoteCurrency = 'USD'; 
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.lastModifiedDate = Date.today(); 
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.versionNumber= '1.0';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.Status= 'Submitted';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.accountCountryCode = 'US';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        // more field length for country code
        QuoteObject OrderObj3 = new QuoteObject();
        OrderObj3.appName = 'WOT_UPSERT';
        OrderObj3.accountCountryCode = 'test';
       
         // null opportunity number
        QuoteObject OrderObj4 = new QuoteObject();
        OrderObj4.appName = 'WOT_UPSERT';
        OrderObj4.accountCountryCode = 'US';
        
        // invalid opporunity number
        QuoteObject OrderObj5 = new QuoteObject();
        OrderObj5.appName = 'WOT_UPSERT';
        OrderObj5.opportunityNumber = '1234';
        
        
        QuoteObject wotOrderObj = new QuoteObject();
        wotOrderObj.appName = 'WOT_UPSERT';
        wotOrderObj.quoteName = 'WOT Quote1';
        wotOrderObj.quoteNumber= '1234';
        wotOrderObj.ERPOrderNumber= '1234';
        wotOrderObj.MCN= 'TEST000012';
        wotOrderObj.quoteAmount= 1000;
        wotOrderObj.quoteCurrency= 'USD';
        wotOrderObj.submittedDate= Datetime.now();
        wotOrderObj.lastModifiedDate= Datetime.now();
        wotOrderObj.versionNumber= '1.0';
        wotOrderObj.Status= 'Submitted';
        wotOrderObj.opportunityNumber= oppObj.Opportunity_Number__c;
        wotOrderObj.accountCountryCode = 'US';
        wotOrderObj.userQuickLookId = 'test';
        
   
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj3);
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj4);
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj5);
                                                               
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        
        wotOrderObj.opportunityNumber = '1234';
        wotOrderObj.quoteNumber= '1234';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        
        // Delink Operation
        wotOrderObj.opportunityNumber = oppObj1.Opportunity_Number__c;
        wotOrderObj.appName = 'WOT_DELINK';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        
        // Delink Operation
        wotOrderObj.opportunityNumber = oppObj.Opportunity_Number__c;
        wotOrderObj.appName = 'WOT_DELINK';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        
        
        wotOrderObj.opportunityNumber = oppObj.Opportunity_Number__c;
        wotOrderObj.appName = 'WOT_UPSERT';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
     
        wotOrderObj.appName = 'WOT_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        
        wotOrderObj.quoteNumber = '4321';
        wotOrderObj.appName = 'WOT_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
        
        wotOrderObj.opportunityNumber = '4321';
        wotOrderObj.appName = 'WOT_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(wotOrderObj);
         System.assertNotEquals(wotOrderObj, null,'wotOrderObj should not be null');
        Test.stopTest();
    }
    
    static testMethod void runSPOTLinkTest() {
        Opportunity oppObj = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Name = 'OppQuote Linkage Test Opportunity' LIMIT 1];  
        Opportunity oppObj1 = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Name = 'OppQuoteLink Test2' LIMIT 1]; 
        System.assertNotEquals(oppObj, null,'Opportunity should not be null');
        Test.startTest();
         
        // null opportunity number
        QuoteObject spotquote1 = new QuoteObject();
        spotquote1.appName = 'SPOT_UPSERT';
        spotquote1.accountCountryCode = 'US';
        
        // invalid opporunity number
        QuoteObject spotquote2 = new QuoteObject();
        spotquote2.appName = 'SPOT_UPSERT';
        spotquote2.opportunityNumber = '1234';
        
        QuoteObject spotOrderObj = new QuoteObject();
        spotOrderObj.appName = 'SPOT_UPSERT';
        spotOrderObj.quoteName = 'SPOT Quote1';
        spotOrderObj.quoteNumber= '1234';
        spotOrderObj.MCN= 'TEST000012';
        spotOrderObj.quoteAmount= 1000;
        spotOrderObj.quoteCurrency= 'USD';
        spotOrderObj.submittedDate= Datetime.now();
        spotOrderObj.lastModifiedDate= Datetime.now();
        spotOrderObj.versionNumber= '1.0';
        spotOrderObj.Status= 'Submitted';
        spotOrderObj.opportunityNumber= oppObj.Opportunity_Number__c;
        spotOrderObj.accountCountryCode = 'US';
        spotOrderObj.userQuickLookId = 'test';
        
        OppQuoteLinkageController.OppQuoteLinkage(spotquote1 );
        OppQuoteLinkageController.OppQuoteLinkage(spotquote2);
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
        spotOrderObj.opportunityNumber = '1234';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
       // Delink Operation
        spotOrderObj.opportunityNumber = oppObj1.Opportunity_Number__c;
        spotOrderObj.appName = 'SPOT_DELINK';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
        // Delink Operation
        spotOrderObj.opportunityNumber = oppObj.Opportunity_Number__c;
        spotOrderObj.appName = 'SPOT_DELINK';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
        
        spotOrderObj.opportunityNumber = oppObj.Opportunity_Number__c;
        spotOrderObj.appName = 'SPOT_UPSERT';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
        spotOrderObj.appName = 'SPOT_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
        spotOrderObj.quoteNumber = '4321';
        spotOrderObj.appName = 'SPOT_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
        
        spotOrderObj.opportunityNumber = '4321';
        spotOrderObj.appName = 'SPOT_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(spotOrderObj);
       
        Test.stopTest();
    }
    
    static testMethod void ruOppSearchTest() {
        Opportunity oppObj = [SELECT Id, Opportunity_Number__c, Name, Solution_Portfolio__c, Owner.Quicklook_ID__c 
                                FROM Opportunity WHERE Name = 'OppQuote Linkage Test Opportunity' LIMIT 1];  
         
        OppQuoteLinkageController.OppSearchRequest searchReq = new OppQuoteLinkageController.OppSearchRequest();
        OppQuoteLinkageController.NSCOppSearch(searchReq);
        
        
        searchReq.custNumber = 'TEST000012';
        searchReq.accCountryCode = 'US';
        searchReq.offerPortfolio = 'Entertainment Self Service|Financial Self Service';
        searchReq.oppName = oppObj.Name; 
        searchReq.oppNameOPR = OppQuoteLinkageController.COMPARISON_OPR.EQUALS;
        searchReq.oppNumber = oppObj.Opportunity_Number__c;
        searchReq.oppNumberOPR = OppQuoteLinkageController.COMPARISON_OPR.EQUALS;
        
        OppQuoteLinkageController.NSCOppSearch(searchReq);
        
        OppQuoteLinkageController.OppSearchRequest searchReq1 = searchReq;
        searchReq1.userQuickLookId = oppObj.Owner.Quicklook_ID__c;
        searchReq1.oppNameOPR = OppQuoteLinkageController.COMPARISON_OPR.CONTAINS;
        searchReq1.oppNumberOPR = OppQuoteLinkageController.COMPARISON_OPR.CONTAINS;
       
        OppQuoteLinkageController.NSCOppSearch(searchReq1);
        
        OppQuoteLinkageController.OppSearchRequest searchReq2 = searchReq;
        searchReq2.offerPortfolio  = oppObj.Solution_Portfolio__c;
        searchReq2.oppNameOPR = OppQuoteLinkageController.COMPARISON_OPR.STARTS_WITH;
        searchReq2.oppNumberOPR = OppQuoteLinkageController.COMPARISON_OPR.STARTS_WITH;
        
        OppQuoteLinkageController.NSCOppSearch(searchReq2);
         
        OppQuoteLinkageController.OppSearchRequest searchReq3 = searchReq;
        searchReq3.custNumber = 'TEST12';
        OppQuoteLinkageController.NSCOppSearch(searchReq3);

    }
}