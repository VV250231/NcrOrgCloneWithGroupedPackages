@isTest
private class testInformOpportunityOwner{
    //public static Opportunity o;
    static testMethod void testHWProductSelection() {
        //PageReference pg = Page.ProductSearch;
        //Test.setCurrentPage(pg);
        //ApexPages.currentPage().getParameters().put('id', o.id);
        //ApexPages.StandardController stc = new ApexPages.StandardController(o);
        //ProductSearchExtensions pse = new ProductSearchExtensions(stc);
       /* User us =  new User();
        Profile p = [SELECT Id FROM Profile WHERE Name like '%04%'].get(0);
        us.Profileid = p.id;
        us.Email = 'gayatri.sharma@ncr.com';
        us.Quicklook_ID__c= 'sg141233';
        us.Username = 'gs@ncr.com';
        us.FirstName ='Fname1';
        us.LastName = 'lname';
        us.LocaleSidKey= 'ar';
        us.LanguageLocaleKey= 'de';
        us.TimeZoneSidKey= 'Africa/Cairo';
        us.EmailEncodingKey = 'Big5';
        us.CurrencyIsoCode= 'AUD';
        insert us; */
        
        /*User us1 =  new User();
        us1.Profileid = p.id;
        us1.Email = 'gayatri.sharma1@ncr.com';
        us1.Quicklook_ID__c= 'sg144124';
        us1.Username = 's1@ncr.com';
        us1.FirstName ='Fname2';
        us1.LastName = 'lname';
        us1.LocaleSidKey= 'ar';
        us1.LanguageLocaleKey= 'de';
        us1.TimeZoneSidKey= 'Africa/Cairo';
        us1.EmailEncodingKey = 'Big5';
        us1.CurrencyIsoCode= 'AUD';
        insert us1;
                
        User us2 =  new User();
        us2.Profileid = p.id;
        us2.Email = 'gayatri.sharma2@ncr.com';
        us2.Quicklook_ID__c= 'sg144135';
        us2.Username = 's2@ncr.com';
        us2.FirstName ='Fname3';
        us2.LastName = 'lname';
        us2.LocaleSidKey= 'ar';
        us2.LanguageLocaleKey= 'de';
        us2.TimeZoneSidKey= 'Africa/Cairo';
        us2.EmailEncodingKey = 'Big5';
        us2.CurrencyIsoCode= 'AUD';                
        insert us2;
          */   
         //Creating an account.
        Account accountRecord = TestRecordsFactory.createAccount('test', null); 
        System.assertNotEquals(accountRecord.id, null,'Account Record Should not be null');
          system.runAs(TestRecordsFactory.getUser()) {
        	update accountRecord;
        }
       /* User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];        
        System.runAS(accountUsere){
            Insert accountRecord;
        }*/
    
        
        Sales_Org__c s = new Sales_Org__c (name = 'testing Sales_Org', Is_Active_in_RoR__c = true);
        insert s;
        
        Competitors__c c = new Competitors__c (name = 'testing Competitors');
        insert c;
        Opportunity o = new Opportunity(); 
        o.name = 'test gayatri opportunity213';
        o.AccountID = accountRecord.id;
        o.Name = 'Test Opportunity';
        o.type = 'Indirect Channel';
        //o.Solution_Portfolio__c = 'Financial Self Service'; - P360 Initial Change - Ahad
        o.CURRENCYISOCODE = 'USD';
        o.SALES_ORG__C = s.id;
        o.INVOICE_TRIGGER__C='Shipment';
        //o.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        o.PRIMARY_COMPETITOR__C = c.id;
        o.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        o.closeDate = System.TODAY();
        o.stagename = 'Analyzing';
        o.recordTypeId =NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        //o.ownerId=accountRecord.Id;
        insert o;
        System.assertNotEquals(o.id, null,'Opp Record Should not be null');
        Product2 HWProduct = new Product2(Name='6691-Interactive Banker', CurrencyIsoCode='USD', Product_Category__c ='HW',Solution_Portfolio__c='Financial Self Service',/*Product_Line_Name__c='Other',*/isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true);
        insert HWProduct;
        System.debug(' HWProduct: ' + HWProduct);
        
        
       //id pb3 = NSCCommonInfoUtil.getIdOf('Standard_Price_Book');
         
       string  pb3 = NSCCommonInfoUtil.getIdOf('Standard_Price_Book');
     
    PriceBook2 stdPriceBook = new PriceBook2(Id=pb3);
    
   // PricebookEntry EntStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=HWProduct.Id, PriceBook2Id=stdPriceBook.Id, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
    //insert EntStandardPricebook;
        //PriceBook2 stdPriceBook = new PriceBook2(Id=pb3);
        // system.debug('stdPriceBook' +stdPriceBook);
        pricebook2 pricebook = TestRecordsFactory.createPriceBook();
         Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
         opp.Pricebook2Id = pricebook.Id;
         update opp;
         Product2 prod = TestRecordsFactory.createProduct();
         prod.isActive = true ;
        update  prod;
        //opp.Pricebook2Id = pricebook2.Id;
              PricebookEntry StandardPricebook = new PricebookEntry(CurrencyIsoCode='USD', Product2Id= HWProduct.Id, PriceBook2Id=stdPriceBook.Id, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        insert StandardPricebook;
       PricebookEntry EntStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD', Product2Id= HWProduct.Id, PriceBook2Id=pricebook.Id, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        insert EntStandardPricebook;
        
        OpportunityLineItem Oli = new OpportunityLineItem();
        Oli.OpportunityId = opp.Id;
        oli.UnitPrice=10;
        oli.Quantity=100;
        oli.PricebookEntryId = EntStandardPricebook.Id;
        oli.Quantity=100;
        oli.UnitPrice=10;
        insert oli;
        
        informOpportunityOwner i=new informOpportunityOwner();
        i.doSendmail(o.Id);
    }
    
   public static /*testMethod*/ void testNon_HWProductSelection() {
 
        User us =  new User();
        Profile p = [SELECT Id FROM Profile WHERE Name like '%04%'].get(0);
        us.Profileid = p.id;
        us.Email = 's.gandhi11@ncr.com';
        us.Quicklook_ID__c= 'sg14434';
        us.Username = 's12@ncr.com';
        us.FirstName ='Fname12';
        us.LastName = 'lname';
        us.LocaleSidKey= 'ar';
        us.LanguageLocaleKey= 'de';
        us.TimeZoneSidKey= 'Africa/Cairo';
        us.EmailEncodingKey = 'Big5';
        us.CurrencyIsoCode= 'AUD';
        insert us;
        
        /*User us1 =  new User();
        us1.Profileid = p.id;
        us1.Email = 's.gandhi23@ncr.com';
        us1.Quicklook_ID__c= 'sg122234';
        us1.Username = 's22@ncr.com';
        us1.FirstName ='Fname23';
        us1.LastName = 'lname5';
        us1.LocaleSidKey= 'ar';
        us1.LanguageLocaleKey= 'de';
        us1.TimeZoneSidKey= 'Africa/Cairo';
        us1.EmailEncodingKey = 'Big5';
        us1.CurrencyIsoCode= 'AUD';
        insert us1;
        
        User us2 =  new User();
        us2.Profileid = p.id;
        us2.Email = 's.gandhi45@ncr.com';
        us2.Quicklook_ID__c= 'sg11135';
        us2.Username = 's34@ncr.com';
        us2.FirstName ='Fname67';
        us2.LastName = 'lname8';
        us2.LocaleSidKey= 'ar';
        us2.LanguageLocaleKey= 'de';
        us2.TimeZoneSidKey= 'Africa/Cairo';
        us2.EmailEncodingKey = 'Big5';
        us2.CurrencyIsoCode= 'AUD';
        insert us2;
        */
        system.runas(us){
        Account a = new Account (name = 'testing Account', ownerId=us.Id,Master_Customer_Number__c = 'TEST454522',Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', Active_Account__c = true);
        insert a;
        
        Sales_Org__c s = new Sales_Org__c (name = 'testing Sales_Org', Is_Active_in_RoR__c = true);
        insert s;
        
        Competitors__c c = new Competitors__c (name = 'testing Competitors');
        insert c;
        
        Opportunity opp = new Opportunity();   
        opp.name = 'test gayatri opportunity';
        opp.AccountID = a.id;
        opp.Name = 'Test Opportunity';
        opp.type = 'Indirect Channel';
        //opp.Solution_Portfolio__c = 'Entertainment Self Service'; -P360 Initial Change - Ahad
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        opp.ownerId=us.Id;
        insert opp;
        
        Product2 CSProduct = new Product2( Name='Entertainment Product', CurrencyIsoCode='USD', Product_Category__c ='CS',Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert CSProduct;
        id pb2 = NSCCommonInfoUtil.getIdOf('Standard_Price_Book');
        PriceBook2 stdPriceBook = new PriceBook2(Id=pb2);
            system.debug('stdPriceBook' +stdPriceBook);
        
        PricebookEntry EntStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=CSProduct.Id, PriceBook2Id=stdPriceBook.Id, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        insert EntStandardPricebook;
        
        OpportunityLineItem Oli = new OpportunityLineItem();
        Oli.OpportunityId = opp.Id;
        oli.UnitPrice=10;
        oli.Quantity=100;
        oli.PricebookEntryId = EntStandardPricebook.Id;
        oli.Quantity=100;
        oli.UnitPrice=10;
        insert oli;
        
        //informOpportunityOwner i=new informOpportunityOwner();
            //i.doSendmail(opp.Id);
    }
    }
}