@isTest
private class GroomOpportunityProductsTest {
     static testMethod void testOli() {
        Account acc=TestRecordsFactory.createAccount();
        Competitors__c comp=TestRecordsFactory.createCompetitor();
        Sales_Org__c  so=TestRecordsFactory.createSalesOrg();       
        Opportunity opp1 = createSimpleOpportunityNew(acc, true);
       
        Product2 p1 = new Product2();
        //p2 = TestRecordsFactory.createProduct(adv);
        p1.Product_Type__c  = 'Topline';
        p1.Name = 'Test Product';
        p1.Product_Category__c ='Software';
        p1.Family ='Solution';
        p1.service_offer_category__c='Payments Processing';
        p1.CanUseQuantitySchedule=true;
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Product_Type__c  = 'PID';
        p2.Name = 'Test Product';
        p2.Product_Category__c ='Software';
        p2.Family ='Solution';
        p2.service_offer_category__c='SW';
        p2.CanUseQuantitySchedule=true;
        //p2.Topline_Product_Lkp__c = p1.Id;
        insert p2;
       
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1 = TestRecordsFactory.createPriceBookEntry(p1);
        
        /*PricebookEntry pbe2 = new PricebookEntry();
        pbe2 = TestRecordsFactory.createPriceBookEntry(p2);*/
      	
        /*String stdPriceBook = Test.getStandardPricebookId();//stdPriceBook =01s700000002GMc
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = stdPriceBook, Product2Id = p2.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = GlobalVariable.pricebookId, Product2Id = p2.Id,
            UnitPrice = 12000, IsActive = true, CurrencyIsoCode = 'USD');
        insert customPrice;*/
        TriggerHandlerBase.bypass('OpportunityTriggerHandler');
        TriggerHandlerBase.bypass('OpportunityTriggerDispatcher');
        /**/
         Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Solution',Product_Category__c='Software');
         insert prod;
         
         Id pricebookId = Test.getStandardPricebookId();
         
         PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
         insert standardPrice;
         
         Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
         insert customPB;
         
         PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
         insert customPrice;
         
         Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Prospecting', Pricebook2Id=customPB.Id);
         opp.Forecast_Category__c ='Pipeline';
         insert opp;
         
         //OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
         //insert oli;
         OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= customPrice.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=prod.Product_Category__c ;
       oli.Product_Type__c = 'PID';
        //oli.Topline_Product_Lkp__c = p1.Id;
        insert oli;
        Test.startTest();
         Database.executeBatch(new GroomOpportunityProducts());
         GroomOpportunityProducts.groomdata(new Set<Id>{oli.Id});
         System.assert(oli.id!=null);
         Test.stopTest();
         
    }
    
 public static Opportunity createSimpleOpportunityNew(Account actt, Boolean isCPQ) {
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
   		Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.AccountID = actt.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        opp.CPQ__c = isCPQ;
     opp.pricebook2Id  = GlobalVariable.pricebookId;
        //opp.Contacts__c = createContact(actt).Id;
        insert opp;
        return opp;
    }    
   
}