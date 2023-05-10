@isTest
public class OrderControllerTest {
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
        
        Id includeInFnnlRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        
        // create new Opportunity object 
        Opportunity opp = new Opportunity();   
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
        //  opp.recordTypeId = '012700000001PoZ';
        opp.recordTypeId = includeInFnnlRtId;
        insert opp;
        
        // create new Opportunity object 
        Opportunity opp1 = new Opportunity();   
        opp1.name = 'abc';
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
        // opp1.recordTypeId = '012700000001PoZ';
        opp.recordTypeId = includeInFnnlRtId;
        insert opp1;
        
    }
    
    @isTest
    public static void collectionData(){	
        Account a =[Select id, Master_Customer_Number__c from Account where Master_Customer_Number__c='TEST000012'];
        Test.startTest();
        List<Opportunity> Opportunities ;
        Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity opp = Opportunities[0];
        insert opp;
        QuBy_Detail__c qbObj = new QuBy_Detail__c();
        qbObj.Name ='Test';
        qbObj.Quote_Number__c='1234';
        insert qbObj;
        String ids=qbObj.id;
        OrderController obj = new OrderController();
        obj.getQuByQuote(ids);
        obj.getQuByQuote(null);
        opportunity opps = [Select id, Opportunity_Number__c from Opportunity where id=:opp.id];
        QuBy_Detail__c qby = [Select id, Quote_Number__c from QuBy_Detail__c where id =:qbObj.id];
        QuoteObject objQuote = new QuoteObject();
        objQuote.AccountId =a.Id;
        objQuote.opportunityNumber = opps.Opportunity_Number__c;
       
       
        //objQuote.orderId = qby.Quote_Number__c;
        System.debug('@@@@'+opps.Opportunity_Number__c);
        obj.getOpptybyOpptyNum(opps.Opportunity_Number__c);
        //  obj.getOpptybyOpptyNum(null);
        System.debug('@@@@'+[Select id, Quote_Number__c from QuBy_Detail__c where id =:qbObj.id]);
        // System.debug('@@@@'+qbOb.Quote_Number__c);
        obj.getQuByByQuoteNum(qby.Quote_Number__c);
        // obj.getQuByByQuoteNum(null);
        obj.updateQuByDetail(qbObj);
        obj.quoteAssociation(opp, qbObj);
        
        obj.attachQubYQuote(objQuote);
        obj.createQubyDetail(objQuote);
        obj.dettachQuByQuote(objQuote);
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
        system.assertEquals( searchReq2.offerPortfolio,oppObj.Solution_Portfolio__c);
        
        OppQuoteLinkageController.OppSearchRequest searchReq3 = searchReq;
        searchReq3.custNumber = 'TEST12';
        OppQuoteLinkageController.NSCOppSearch(searchReq3);
       
        
        obj.runOppSearch(searchReq);
        obj.runOppSearch(searchReq1);
        obj.runOppSearch(searchReq3);
        Test.stopTest();
    }
    
     @isTest
    public static void collectionData2(){	
        Account a =[Select id, Master_Customer_Number__c from Account where Master_Customer_Number__c='TEST000012'];
        Test.startTest();
        List<Opportunity> Opportunities ;
        Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity opp = Opportunities[0];
        insert opp;
        QuBy_Detail__c qbObj = new QuBy_Detail__c();
        qbObj.Name ='Test';
        qbObj.Quote_Number__c='1234';
        qbObj.Opportunity__c=opp.id;
        insert qbObj;
        String ids=qbObj.id;
        OrderController obj = new OrderController();
        obj.getQuByQuote(ids);
        obj.getQuByQuote(null);
        opportunity opps = [Select id, Opportunity_Number__c from Opportunity where id=:opp.id];
        QuBy_Detail__c qby = [Select id, Quote_Number__c,Opportunity__c from QuBy_Detail__c where id =:qbObj.id];
        QuoteObject objQuote = new QuoteObject();
        objQuote.AccountId =a.Id;
        objQuote.opportunityNumber = opps.Opportunity_Number__c;
        objQuote.quoteNumber ='1234';
        obj.attachQubYQuote(objQuote);
        obj.dettachQuByQuote(objQuote);

        Test.stopTest();
    }
}