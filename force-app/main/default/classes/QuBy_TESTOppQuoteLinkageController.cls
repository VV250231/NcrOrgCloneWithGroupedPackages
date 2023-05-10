/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: QuBy_TESTOppQuoteLinkageController.cls                                  
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 23-08-2016
# Description...........: This class is used as generalised class for QuBy quote creation.
                          This class is also used for opportunity search from QuBy.                          
##################################################################################################*/
@isTest
private class QuBy_TESTOppQuoteLinkageController {  
    @testSetup static void setupTestData(){
        // create new account object
        Account a = new Account (name = 'QUBY Upsert Test', 
                                 LOB__c='FINANCIAL',
                                 Master_Customer_Number__c = 'TEST000012', 
                                 Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true);
        System.runAs(TestRecordsFactory.getUser()){ insert a; }
          
        // create new sales org object 
        Sales_Org__c s = new Sales_Org__c (name = 'test org', Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor object 
        Competitors__c c = new Competitors__c (name = 'testing competitor');
        insert c;
        Id r = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        //RecordType r = [Select id from RecordType where developername='IncludeinFunnel'];
        // create new Opportunity object 
        Opportunity opp = new Opportunity();   
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'FINANCIAL SELF SERVICE';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r;
        Test.startTest();
        insert opp;
        
         // create new Opportunity object 
        Opportunity opp1 = new Opportunity();   
        opp1.name = 'abc';
        opp1.AccountID = a.id;
        opp1.Name = 'OppQuoteLink Test2';
        opp1.type = 'Indirect Channel';
        opp1.Solution_Portfolio__c = 'FINANCIAL SELF SERVICE';
        opp1.CURRENCYISOCODE = 'USD';
        opp1.SALES_ORG__C = s.id;
        opp1.INVOICE_TRIGGER__C='Shipment';
        opp1.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp1.PRIMARY_COMPETITOR__C = c.id;
        opp1.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp1.closeDate = System.TODAY();
        opp1.stagename = 'Analyzing';
        opp1.recordTypeId = r;
        insert opp1;
		Test.stopTest();
    }
    
    
    static testMethod void runQUBYLinkTest() {
        Opportunity oppObj = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Name = 'OppQuote Linkage Test Opportunity' LIMIT 1];  
        Opportunity oppObj1 = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Name = 'OppQuoteLink Test2' LIMIT 1];  
         System.assert(oppObj1.id!=null);
        
         
        // invalid app test                                                                                                                   
        QuoteObject OrderObj1 = new QuoteObject();
        OrderObj1.appName = 'test app';
        
        QuoteObject OrderObj2 = new QuoteObject();
        OrderObj2.appName = 'QUBY_LINK';
        OrderObj2.opportunityNumber = oppObj.Opportunity_Number__c;
        OrderObj2.quoteNumber= '1234';

        OppQuoteLinkageController.OppQuoteLinkage(OrderObj1);
        //OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
         
        OrderObj2.quoteName = 'TEST Quote1';
        /*OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.MCN = 'TEST1234';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.quoteAmount  = 1000; 
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.quoteCurrency = 'USD'; 
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.lastModifiedDate = Date.today(); 
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.versionNumber= '1.0';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);*/
        Test.startTest(); 
        OrderObj2.Status= 'Submitted';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        OrderObj2.accountCountryCode = 'US';
        OppQuoteLinkageController.OppQuoteLinkage(OrderObj2);
        
        // more field length for country code
        QuoteObject OrderObj3 = new QuoteObject();
        OrderObj3.appName = 'QUBY_LINK';
        OrderObj3.accountCountryCode = 'test';
       
         // null opportunity number
        QuoteObject OrderObj4 = new QuoteObject();
        OrderObj4.appName = 'QUBY_LINK';
        OrderObj4.accountCountryCode = 'US';
        
        // invalid opporunity number
        QuoteObject OrderObj5 = new QuoteObject();
        OrderObj5.appName = 'QUBY_LINK';
        OrderObj5.opportunityNumber = '1234';
        
        
        QuoteObject QUBYOrderObj = new QuoteObject();
        QUBYOrderObj.appName = 'QUBY_LINK';
        QUBYOrderObj.quoteName = 'QUBY Quote1';
        QUBYOrderObj.quoteNumber= '1234';
        QUBYOrderObj.ERPOrderNumber= '1234';
        QUBYOrderObj.MCN= 'TEST000012';
        QUBYOrderObj.quoteAmount= 1000;
        QUBYOrderObj.quoteCurrency= 'USD';
        QUBYOrderObj.submittedDate= Datetime.now();
        QUBYOrderObj.lastModifiedDate= Datetime.now();
        QUBYOrderObj.versionNumber= '1.0';
        QUBYOrderObj.Status= 'Submitted';
        QUBYOrderObj.opportunityNumber= oppObj.Opportunity_Number__c;
        QUBYOrderObj.accountCountryCode = 'US';
        QUBYOrderObj.userQuickLookId = 'test';
        
   
        //OppQuoteLinkageController.OppQuoteLinkage(OrderObj3);
        //OppQuoteLinkageController.OppQuoteLinkage(OrderObj4);
        //OppQuoteLinkageController.OppQuoteLinkage(OrderObj5);
                                                               
       // OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        //OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        
        QUBYOrderObj.opportunityNumber = '1234';
        QUBYOrderObj.quoteNumber= '1234';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        QUBYOrderObj.opportunityNumber = oppObj1.Opportunity_Number__c;
        QUBYOrderObj.appName = 'QUBY_DELINK';
        
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        
        // Delink Operation
        /*QUBYOrderObj.opportunityNumber = oppObj1.Opportunity_Number__c;
        QUBYOrderObj.appName = 'QUBY_DELINK';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        
        // Delink Operation
        QUBYOrderObj.opportunityNumber = oppObj.Opportunity_Number__c;
        QUBYOrderObj.appName = 'QUBY_DELINK';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        
        
        QUBYOrderObj.opportunityNumber = oppObj.Opportunity_Number__c;
        QUBYOrderObj.appName = 'QUBY_LINK';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
     
        QUBYOrderObj.appName = 'QUBY_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        
        QUBYOrderObj.quoteNumber = '4321';
        QUBYOrderObj.appName = 'QUBY_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        
        QUBYOrderObj.opportunityNumber = '4321';
        QUBYOrderObj.appName = 'QUBY_DELETE';
        OppQuoteLinkageController.OppQuoteLinkage(QUBYOrderObj);
        */
        Test.stopTest();
    }
    
    
    static testMethod void ruOppSearchTest() {
        Opportunity oppObj = [SELECT Id, Opportunity_Number__c, Name, Solution_Portfolio__c, Owner.Quicklook_ID__c 
                                FROM Opportunity WHERE Name = 'OppQuote Linkage Test Opportunity' LIMIT 1];  
        
        system.assert(oppObj.id!=null);
        Test.startTest() ;  
        
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
        
        //OrderController.hack1();
        //OrderController.hack2();
        //OrderController.hack3();
        //OrderController.hack4();
        //OrderController.hack5();
        
        Test.stopTest();
    }
}