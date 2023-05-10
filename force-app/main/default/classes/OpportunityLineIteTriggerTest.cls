@isTest
public class OpportunityLineIteTriggerTest {
    static testMethod void testOli() {
        Account acc=new Account();
        acc=TestRecordsFactory.createAccount();
        System.assertNotEquals(acc, null,'Account should not be null');

        Competitors__c comp=new Competitors__c ();
        comp=TestRecordsFactory.createCompetitor();
        
        Sales_Org__c  so=new Sales_Org__c();
        so=TestRecordsFactory.createSalesOrg();
        so.Hierarchy_2__c = 'FIN_NAMER';
        update so;
		
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;        
       /* OCR_TEAM__c ocrteam = new OCR_TEAM__c();
        ocrteam.Sales_Org__c = so.Sales_Org_Code__c;
        ocrteam.Ocr_Team__c = 'Test';
        insert ocrteam;*/
        Opportunity opp1 = createSimpleOpportunityNew(acc, false);
        
       /* Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = acc.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        //opp.Solution_Portfolio__c = 'Financial Self Service'; P360 Initial Change - Ahad
        opp.CURRENCYISOCODE = 'USD';
        //opp.SALES_ORG__C = so.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
       // opp.recordTypeId = '012700000001PoZ';
        //opp.OCR_TEAM__c = 'Test';
       // opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        //insert opp;*/
        
        
        //Advocated_Solution__c adv = new Advocated_Solution__c();
        //String a = 'abc';
        //adv = TestRecordsFactory.createAdvocatedSolutionByCode(a);
        
        //Hierarchy__c h = new Hierarchy__c();
        //String x='TEST';
        //h=TestRecordsFactory.createHierarchy(x,adv);
        //insert h;
        
        Product2 p = new Product2();
        //p = TestRecordsFactory.createProduct(adv);
        p.Name = 'Test Product';
        p.Product_Category__c ='Software';
        p.Family ='Solution';
        p.service_offer_category__c='SWM';
        p.CanUseQuantitySchedule=true;
        insert p;
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(p);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp1.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=p.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        insert oli;
        //update oli;
        //TestRecordsFactory.createOpportunityLineitemSchedule(oli);
        //update oli;
        Product2 p1 = new Product2();
        //p1 = TestRecordsFactory.createProduct(adv);
        p1.Name = 'Test';
        p1.Product_Category__c ='Service';
        p1.Family ='Annuity';
        p1.service_offer_category__c='SWM';
        p1.CanUseQuantitySchedule=true;
        insert p1;
        
        PricebookEntry pe1 = new PricebookEntry();
        pe1 = TestRecordsFactory.createPriceBookEntry(p1);
        
        
       /* OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.opportunityId =opp1.Id;
        oli2.PriceBookEntryId= pe1.Id;
        oli2.Quantity=10;
        oli2.TotalPrice=1000;
        oli2.Product_Category__c=p1.Product_Category__c ;
        oli2.SW_Unattached_Code__c='UnAttached';
        insert oli2;*/
        
        Product2 p2 = new Product2();
        //p2 = TestRecordsFactory.createProduct(adv);
        p2.Name = 'Test Product';
        p2.Product_Category__c ='Software';
        p2.Family ='Solution';
        p2.service_offer_category__c='Payments Processing';
        p2.CanUseQuantitySchedule=true;
        insert p2;
        
        PricebookEntry pe2 = new PricebookEntry();
        pe2 = TestRecordsFactory.createPriceBookEntry(p2);
        
        test.startTest();
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.opportunityId =opp1.Id;
        oli3.PriceBookEntryId= pe2.Id;
        oli3.Quantity=10;
        oli3.TotalPrice=1000;
        oli3.Product_Category__c=p2.Product_Category__c ;
        oli3.SW_Unattached_Code__c='UnAttached';
        insert oli3;
        OpportunityLineItemSchedule olis= TestRecordsFactory.createOpportunityLineitemSchedule(oli3);
        //insert olis;
       // Delete oli2;
        test.stopTest();
        // syncOlitest
        SyncOli sol=new SyncOli(new Set<id>{oli.Id});
        //sol.sendEmail(new List<id> {oli.Id});
        sol.sendEmail(new List<String>{'test'}, 'test');   

        delete oli3;
    }
    
    static testMethod void testOli2() {
        Account acc=new Account();
        acc=TestRecordsFactory.createAccount();
        System.assertNotEquals(acc, null,'Account should not be null');

        Competitors__c comp=new Competitors__c ();
        comp=TestRecordsFactory.createCompetitor();
        
        Sales_Org__c  so=new Sales_Org__c();
        so=TestRecordsFactory.createSalesOrg();
        so.Hierarchy_2__c = 'FIN_NAMER';
        update so;
        
        Renewable_Products__c renewPrds = new Renewable_Products__c(name='Record1', Product_Revenue_Types__c='HWM,SWM,Managed Service');
		insert renewPrds;
        
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        Opportunity opp1 = createSimpleOpportunityNew(acc, false);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
      
        Product2 p = new Product2();
        //p = TestRecordsFactory.createProduct(adv);
        p.Name = 'Test Product';
        p.Product_Category__c ='Software';
        p.Family ='Solution';
        p.service_offer_category__c='SWM';
        p.CanUseQuantitySchedule=true;
        insert p;
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(p);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp1.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=p.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        oli.Opportunity_Line_Item_Type__c = 'New';
        oliList.add(oli);
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.opportunityId =opp1.Id;
        oli1.PriceBookEntryId= pe.Id;
        oli1.Quantity=10;
        oli1.TotalPrice=1000;
        oli1.Product_Category__c=p.Product_Category__c ;
        oli1.SW_Unattached_Code__c='Attached';
        oli1.Opportunity_Line_Item_Type__c = 'Renewal';
        oliList.add(oli1);
       
        try{
            insert oliList;
        }
        catch(Exception e){
            System.debug('Exception Caught'+e.getMessage());
        }
        //update oli;
        //TestRecordsFactory.createOpportunityLineitemSchedule(oli);
        //update oli;
        Product2 p1 = new Product2();
        //p1 = TestRecordsFactory.createProduct(adv);
        p1.Name = 'Test';
        p1.Product_Category__c ='Service';
        p1.Family ='Annuity';
        p1.service_offer_category__c='SWM';
        p1.CanUseQuantitySchedule=true;
        insert p1;
        
        PricebookEntry pe1 = new PricebookEntry();
        pe1 = TestRecordsFactory.createPriceBookEntry(p1);
        
        
       /* OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.opportunityId =opp1.Id;
        oli2.PriceBookEntryId= pe1.Id;
        oli2.Quantity=10;
        oli2.TotalPrice=1000;
        oli2.Product_Category__c=p1.Product_Category__c ;
        oli2.SW_Unattached_Code__c='UnAttached';
        insert oli2;*/
        
        Product2 p2 = new Product2();
        //p2 = TestRecordsFactory.createProduct(adv);
        p2.Product_Type__c  = 'Topline';
        p2.Name = 'Test Product';
        p2.Product_Category__c ='Software';
        p2.Family ='Solution';
        p2.service_offer_category__c='Payments Processing';
        p2.CanUseQuantitySchedule=true;
        insert p2;
           
        PricebookEntry pe2 = new PricebookEntry();
        pe2 = TestRecordsFactory.createPriceBookEntry(p2);
        
        test.startTest();
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.opportunityId =opp1.Id;
        oli3.PriceBookEntryId= pe2.Id;
        oli3.Quantity=10;
        oli3.TotalPrice=1000;
        oli3.Product_Category__c=p2.Product_Category__c ;
        oli3.SW_Unattached_Code__c='UnAttached';
        oli3.Opportunity_Line_Item_Type__c = 'Renewal';
        insert oli3;
        OpportunityLineItemSchedule olis= TestRecordsFactory.createOpportunityLineitemSchedule(oli3);
        //insert olis;
       // Delete oli2;
        test.stopTest();
        // syncOlitest
        SyncOli sol=new SyncOli(new Set<id>{oli.Id});
        //sol.sendEmail(new List<id> {oli.Id});
        sol.sendEmail(new List<String>{'test'}, 'test');   

        delete oli3;
    }
    
   static testMethod void testOli3() {
        Account acc=TestRecordsFactory.createAccount();
        System.assertNotEquals(acc, null,'Account should not be null');

        Competitors__c comp=TestRecordsFactory.createCompetitor();
        Sales_Org__c  so=TestRecordsFactory.createSalesOrg();       
        Opportunity opp1 = createSimpleOpportunityNew(acc, true);
        opp1 = [SELECT Id, PriceBook2Id FROM Opportunity WHERE Id = :opp1.Id];      
        String oppPriceBookId = GlobalVariable.CPQPricebookId;
      
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
        p2.service_offer_category__c='Payments Processing';
        p2.CanUseQuantitySchedule=true;
        p2.Topline_Product_Lkp__c = p1.Id;
        insert p2;
       
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1 = TestRecordsFactory.createPriceBookEntryFromPriceBook(p1, oppPriceBookId );
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2 = TestRecordsFactory.createPriceBookEntryFromPriceBook(p2, oppPriceBookId );
       
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp1.Id;
        oli.PriceBookEntryId= pbe2.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=p2.Product_Category__c ;
        oli.Product_Type__c = 'PID';
        oli.Topline_Product_Lkp__c = p1.Id;
        insert oli;
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
        //opp.Contacts__c = createContact(actt).Id;
        insert opp;
        return opp;
    }
}