@isTest
public class PS_Schedule_NewClassTest {
    Public Static User getUser()
    {
        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        PS_Schedule_NewClass.isCommunity();
        PS_Schedule_NewClass.getUserInfo(); 
        return Usr;
    } 
    
    
    
    
    public static testMethod void runUnitTest1(){
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'HW';
        prod.Service_Offer_Category__c= 'HW';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true); 
        insert pb;
        
        
        Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='SW',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert SWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem l1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(SWProduct1));
        Product2 HWProduct1 = new Product2( Name='Orderman1', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='HW',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        OpportunityLineItem l2 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        l2.Source__c = null;
        update l2;
        l1.Source__c = null;
        update l1;
        OpportunityLineItem l3 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
        l3.Source__c = null;
        update l3;
        test.startTest();
        Set<id> setOfAdmin=new Set<id>();
        List <OpportunityLineItem> oliL=new List<OpportunityLineItem>();
        oliL.add(l2);
        List<PS_Schedule_NewClass.dataWrapper> returnList=new List<PS_Schedule_NewClass.dataWrapper> ();
        OpportunityLineItemSchedule olis = new OpportunityLineitemSchedule(OpportunityLineItemId = l1.id, scheduleDate = System.today() + 60, type = 'Quantity', quantity = l1.quantity);
        insert olis;
        OpportunityLineItemSchedule olis2 = new OpportunityLineitemSchedule(OpportunityLineItemId = l2.id, scheduleDate = System.today() + 60, type = 'Quantity', quantity = l2.quantity);
        insert olis2;
        OpportunityLineItemSchedule olis3 = new OpportunityLineitemSchedule(OpportunityLineItemId = l3.id, scheduleDate = System.today() + 60, type = 'Quantity', quantity = l3.quantity);
        insert olis3;
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(l1.OpportunityID); 
        PS_Schedule_NewClass.getOpportunityById(L1.OpportunityID);
        PS_Schedule_NewClass.getCurrentDate();
        try{
            PS_Schedule_NewClass.SubmitManegeSchedule('123');
        }
        catch(exception e){
            
        }
        //PS_Schedule_NewClass.fetchAddedPackageDetails( String Oppid, String masterOLI)
        String[] Product_Selected_From_Favorite_Section=new String[]{HWProduct1.Id};
        Boolean[] isSubscriptioned=new Boolean[]{true};
        List<String> serviceOLIList = new List<String>{'New'} ;
        List<String> HWMMntcTypes = new List<String>{'Connected HWM'} ;
        List<String> QtyTypes = new List<String>{'Cards'} ;
        System.assertEquals(serviceOLIList[0], 'New');
        try{
            PS_Schedule_NewClass.InsertOpportunityLineItemPS(new String[]{prod.Id}, l1.OpportunityId, isSubscriptioned,serviceOLIList, HWMMntcTypes,QtyTypes);
        } Catch(Exception e){
            System.debug('exception');
        }
        PS_Schedule_NewClass.InsertOpportunityLineItemPS(Product_Selected_From_Favorite_Section, l1.OpportunityId, isSubscriptioned,serviceOLIList, HWMMntcTypes,QtyTypes);
        
        
        System.runAs(getUser()){
            PS_Schedule_NewClass.getOpportunityById(L1.OpportunityID);
        }
        test.stopTest();
        
    }
    public static testMethod void runUnitTest11(){
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'HW';
        prod.Service_Offer_Category__c= 'HW';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        System.assertEquals(prod.Product_Category__c, 'HW');
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        
    }
    
    public static testMethod void runUnitTest12(){
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'HW';
        prod.Service_Offer_Category__c= 'HW';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        System.assertEquals(prod.Product_Category__c, 'HW');
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        
    }
    public static testMethod void runUnitTest2(){
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'SW';
        prod.Service_Offer_Category__c= 'SW';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        System.assertEquals(prod.Product_Category__c, 'SW');
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));        
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        
    }
    public static testMethod void runUnitTest22(){
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'SW';
        prod.Service_Offer_Category__c= 'SW';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        System.assertEquals(prod.Product_Category__c, 'SW');
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        
    }
    public static testMethod void runUnitTest23(){
        
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'SW';
        prod.Service_Offer_Category__c= 'SW';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        System.assertEquals(prod.Product_Category__c, 'SW');
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        
    }
    
    public static testMethod void runUnitTest3(){
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'Soft';
        prod.Service_Offer_Category__c= 'Soft';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        System.assertEquals(prod.Product_Category__c, 'Soft');
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));        
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        PS_Schedule_NewClass.removeSchedule(new String[]{HWProduct1.Id}, OLI1.OpportunityID); 
        
    }
    
    public static testMethod void runUnitTest32(){
        
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'Soft';
        prod.Service_Offer_Category__c= 'Soft';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        System.assertEquals(prod.Product_Category__c, 'Soft');
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        PS_Schedule_NewClass.removeOLI(new String[]{OLI1.Id}, OLI1.OpportunityID);
    }
    
    public static testMethod void runUnitTest33(){
        
        
        
        Account a = new Account();
        a.name = 'test-acc';
        a.industry = 'HOSPITALITY:CHANNEL';
        a.Account_Country_Code__c = 'US';
        System.runAs(getUser()){
            insert a;
        }
        
        Opportunity o = new Opportunity();
        o.accountid = a.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a.id;
        o.Amendment_Quotes_Monthly_GP__c = 10;
        o.Advocated_Solution__c = '3RD PARTY SOFTWARE';
        o.Solution_Portfolio__c = 'HOSPITALITY';
        insert o;
        
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Solution';
        prod.Product_Category__c = 'Soft';
        prod.Service_Offer_Category__c= 'Soft';
        prod.CanUseQuantitySchedule = true;
        insert prod; 
        
        
        
        
        
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        insert pb;
        System.assertEquals(prod.Product_Category__c, 'Soft');
        
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        insert HWProduct1;
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(o, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        
        //  Opportunity oli11=[select Id from Opportunity where Name='OppQuote Linkage Opportunity'];
        PS_Schedule_NewClass.getData(OLI1.OpportunityID); 
        
    }
    
    @isTest(SeeAllData=true)
    public static void myTestforgetSubsOnlyProd() {
        
        Subscription_only_products__c sop = new Subscription_only_products__c();
        sop.Product_Name__c='test';
        sop.Name='test';
        sop.Product_Revenue_Type__c='Cloud';
        //cs.Other fiels values
        insert sop;
        PS_Schedule_NewClass.getSubsOnlyProd();
    }
    
    
    
}