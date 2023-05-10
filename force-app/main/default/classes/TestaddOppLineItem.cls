/*
##################################################################################################
# Project Name..........: Sales Logix                                                                    
# File..................: TestaddoppRole                                                        
# Created by............: Sakshi Gandhi                                                                  
# Created Date..........: 25-06-2015                                                                               
################################################################################################
*/
@isTest
private class TestaddOppLineItem {  
    static testMethod void runUnitTest() {
          // create new account object
        Account a = TestRecordsFactory.createAccount();
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
        opp.Name = 'Test Opportunity';
        /*opp.SalesLogixId__c = 'aaaaa';*/
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
        
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Hardware';
        insert prod;
         String stdPriceBook = Test.getStandardPricebookId();     //stdPriceBook =01s700000002GMc
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice = 10000,CurrencyIsoCode ='USD', IsActive = true);
        insert standardPrice;
        //Pricebook2Id ='01s7000000030GMAAY'
         PricebookEntry customPrice = new PricebookEntry(
         Pricebook2Id =GlobalVariable.pricebookId, Product2Id = prod.Id,
         UnitPrice = 12000, IsActive = true,CurrencyIsoCode = 'USD' );
        insert customPrice;
        
        OpportunityLineItem OLI1 = new OpportunityLineItem();
         OLI1.OpportunityID = opp.id;
         OLI1.PricebookEntryId = customPrice.id;
         OLI1.Quantity = 2;
         OLI1.unitprice = 20;
         insert OLI1;
   //-------------------------- Object Deletion EBA_SF-1717---OpportunityLineItem2__c------------------------------------
            
       // OpportunityLineItem2__c OLI = new OpportunityLineItem2__c ();
      //  OLI.Quantity__c= 100;
      //  OLI.Product_Name__c = 'test'; 
        /*OLI.SalesLogixId__c ='aaaaa';*/
        //OLI.Unit_Price__c = '20';
     // insert OLI;
   //-------------------------- Object Deletion EBA_SF-1717---OpportunityLineItem2__c------------------------------------
     
        Opportunity opp1 = new Opportunity();  
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp1.name = 'abcd';
        opp1.AccountID = a.id;
        opp1.Name = 'Test Opportunity';
        /*opp1.SalesLogixId__c = 'afdsfaa';*/
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
        system.assert(opp1.Id !=null);
        
        
    }
}