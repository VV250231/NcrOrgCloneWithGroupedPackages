@isTest 
private class CloneOpportunityWithScheduleTest{
    
    static testMethod void TestMethodforCloneOpportunityWithSScheduel() {
        Account a = TestRecordsFactory.createAccount();
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
        ebdedd.Name = 'EDSD_Calc';
        ebdedd.isActive__c = true;
        insert ebdedd;
        
        
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        //opp.Solution_Portfolio__c = 'Financial Self Service'; -- P360 Initial Change - Ahad
        opp.CURRENCYISOCODE = 'USD';
        
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.CanUseQuantitySchedule = true;
        insert prod;
        List<Anaplan_ProductCategory_FamilyMapping__c> customSettingList=new List<Anaplan_ProductCategory_FamilyMapping__c>();
        
        Anaplan_ProductCategory_FamilyMapping__c setting = new Anaplan_ProductCategory_FamilyMapping__c();
        setting.Name = 'Cloud';
        setting.Product_Family__c = 'Cloud';
        //insert setting; 
        customSettingList.add(setting);
        
        
        Anaplan_ProductCategory_FamilyMapping__c setting1 = new Anaplan_ProductCategory_FamilyMapping__c();
        setting1.Name = 'CS';
        setting1.Product_Family__c = 'CS';
        //insert setting1;
        customSettingList.add(setting1);
        
        
        Anaplan_ProductCategory_FamilyMapping__c setting2 = new Anaplan_ProductCategory_FamilyMapping__c();
        setting2.Name = 'HW';
        setting2.Product_Family__c = 'HW';
        //insert setting2;
        customSettingList.add(setting2);
        
        
        Anaplan_ProductCategory_FamilyMapping__c setting3 = new Anaplan_ProductCategory_FamilyMapping__c();
        setting3.Name = 'PS';
        setting3.Product_Family__c = 'PS';
        //insert setting3;
        customSettingList.add(setting3);
        
        
        Anaplan_ProductCategory_FamilyMapping__c setting4 = new Anaplan_ProductCategory_FamilyMapping__c();
        setting4.Name = 'SW';
        setting4.Product_Family__c = 'SW';
        //insert setting4 ;
        customSettingList.add(setting4);
        
        
        Anaplan_ProductCategory_FamilyMapping__c setting5 = new Anaplan_ProductCategory_FamilyMapping__c();
        setting5 .Name = 'TS';
        setting5 .Product_Family__c = 'TS';
        //insert setting5;
        customSettingList.add(setting5);
        
        insert customSettingList; 
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        
        String stdPriceBook = Test.getStandardPricebookId();	//stdPriceBook =01s700000002GMc
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;
        //01s7000000030GMAAY - CustomPricebook id
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = GlobalVariable.pricebookId, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true, CurrencyIsoCode = 'USD');
        insert customPrice;
        
        
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = customPrice.id;
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        
        insert OLI1;
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityID = opp.id;
        OLI2.PricebookEntryId = customPrice.id;
        OLI2.Quantity = 2;
        OLI2.unitprice = 20;
        OLI2.ProductClonedFromId__c=OLI1.Id;
        insert OLI2;
        
        
        OpportunityLineItemSchedule olis = new OpportunityLineitemSchedule(OpportunityLineItemId = OLI1.id, scheduleDate = System.today() + 60, type = 'Quantity', quantity = oli1.quantity);
        insert olis;
        
        test.startTest();
        OpportunityLineItemSchedule oliss = new OpportunityLineitemSchedule(OpportunityLineItemId = OLI1.id, scheduleDate = System.today() - 60, type = 'Quantity', quantity = oli1.quantity);
        insert oliss;
        //OpportunityLineItemSchedule olisas = new OpportunityLineitemSchedule(OpportunityLineItemId = OLI2.id, scheduleDate = System.today() - 60, type = 'Quantity', quantity = oli2.quantity);
        //insert olisas;
        // create new Opportunity object 
        System.assertEquals(0, OLI1.OpportunityLineItemSchedules.size());
        Opportunity opp1 = new Opportunity();
        opp1 .name = 'abc';
        opp.AccountID = a.id;
        opp1.IsClone__c=opp.id;
        opp1.isCloneWithProduct__c=true;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp1.type = 'Indirect Channel';
        //opp1.Solution_Portfolio__c = 'Financial Self Service'; -- P360 Initial Change - Ahad
        opp1.CURRENCYISOCODE = 'USD';
        
        opp1.INVOICE_TRIGGER__C = 'Shipment';
        //opp1.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        
        opp1.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp1.closeDate = System.TODAY();
        opp1.stagename = 'Analyzing';
        opp1.recordTypeId = r1;
        opp1.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp1;
        
        
        
        CustomCloneController.getData(opp.id,true ,false , false);
        test.stopTest();
    }
    
}