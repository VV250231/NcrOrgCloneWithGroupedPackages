@isTest
public class CPQEmailInstallSheetForQuote_Test {
    static Account account;
    static Opportunity opp;
    static Account channelAccount;  
    
    Public Static User getUser()  {
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    
    @isTest
    public static void  sheetTest(){
        System.runAs(getUser()){
            account = new Account(name = 'Test Acc',
                                  LOB__c='HOSPITALITY',
                                  Master_Customer_Number__c = 'TESTMCN00001X',
                                  Account_Country_Code__c = 'US',
                                  CurrencyIsoCode = 'USD',
                                  CDM_Account_Status__c = 'Active',
                                  Active_Account__c = true);
            insert account;
            
            channelAccount = new Account(
                Name='Test Company Name123',
                Account_Country_Code__c = 'US',
                LOB__c='HOSPITALITY',
                Active_Account__c = true,
                CDM_Account_Type__c='LOCAL OFFICE',
                CDM_Account_Status__c = 'Active',
                //CDM_Sub_Account_Type__c = 'LOCAL OFFICE',
                industry = 'HOSPITALITY:QSR',
                Project_Coordinator_Email__c = 'abc@test.com');
            insert channelAccount;
            
            cdm_Account_Relationship__c cdmAccRel = new cdm_Account_Relationship__c();
            cdmAccRel.Account__c=account.Id;
            cdmAccRel.Related_Account__c = channelAccount.Id;
            cdmAccRel.Relationship_Type__c='Local Office - End Customer';
            cdmAccRel.Name ='Local Office';
            //  cdmAccRel.Account_Number__c = 'TESTMCN00001X';
            cdmAccRel.Relationship_Code__c = 'End Customer Of';
            insert cdmAccRel;
            
            opp = new Opportunity();
            opp.name = 'abc';
            opp.AccountID = account.id;
            opp.Channel_Office__c= channelAccount.id;
            opp.closeDate = System.TODAY();
            opp.stagename = 'Analyzing';
            opp.CPQ__c = TRUE;
            insert opp;
        }
        
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Integer prorationDayOfMonth = 25;
        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            SBQQ__Account__c = account.Id,
            SBQQ__Opportunity2__c = opp.Id,
         SBQQ__Primary__c=true   
        );
        insert testQuote;
        
        Product2 testProduct = new Product2( 
            Name ='Test Product',
            CurrencyIsoCode='USD',
            isactive=true, 
            Annuity_product__c = false, 
            CanUseQuantitySchedule = true,
            ProductCode = 'H400-0001-0000',
            product_type__c = 'PID',
            family='Hardware'
        );
        insert testProduct;
        
        String standardPriceBook = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry = new PricebookEntry(
            CurrencyIsoCode='USD', 
            Product2Id=testProduct.id,
            PriceBook2Id=standardPriceBook, 
            UnitPrice=15.00, 
            UseStandardPrice=false, 
            isactive = true
        );
        insert testPriceBookEntry;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            Is_Subscriptioned__c = true,
           // Product_Type__c = 'Package',
            qtc_Bundle_Type__c = 'Core',
            qtc_Component_List_Term_Price__c = 295,
            qtc_Component_Net_Term_Price__c = 295,
            qtc_Group_ID__c = 1,
            //qtc_MRR__c = 0,
            //qtc_Product_Type__c = 'PID',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__PricebookEntryId__c = testPriceBookEntry.Id,
            SBQQ__NetPrice__c = 25,
            SBQQ__ListPrice__c = 30,
            SBQQ__Quantity__c = 1,
            SBQQ__Discount__c = 10,
            SBQQ__DefaultSubscriptionTerm__c = 5,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__EndDate__c = Date.today().addMonths(12),
            SBQQ__Product__c = testProduct.Id,
            product_type__c = 'PID'
        );
        insert testQuoteLine;
        
        List<SBQQ__QuoteLine__c> add_line = new List<SBQQ__QuoteLine__c> ();
        //add_line.add(new SBQQ__QuoteLine__c(SBQQ__PricebookEntryId__c = testPriceBookEntry.Id, SBQQ__Quote__c = testQuote.Id, SBQQ__Quantity__c = 1));
        add_line.add(testQuoteLine);
        upsert add_line;
        
        List<Product2> lstProducts = new List<Product2>();
        lstProducts.add(new product2(name='B', family='Hardware', ProductCode = 'H400-0001-0000',product_type__c = 'PID' ));
        lstProducts.add(new product2(name='C', family='Hardware', ProductCode = 'H400-0001-0000', product_type__c = 'PID'));
        lstProducts.add(testProduct);
       	upsert lstProducts;
        
        List<CPQInstallSheetForQuoteController.ProductDetailsClass> pd = new List<CPQInstallSheetForQuoteController.ProductDetailsClass>(); 
        CPQInstallSheetForQuoteController.ProductDetailsClass p1 = new CPQInstallSheetForQuoteController.ProductDetailsClass();
        p1.Name = 'Test Product';
        p1.quantity = '10';
        p1.ProductID = lstProducts[0].id;
        p1.ProductFamily = 'hardware';
        pd.add(p1);    
        
        
        Test.startTest(); 
         SBQQ.TriggerControl.disable();
        upsert testQuoteLine;
        insert new NCR_CPQBLG_Email__c(Name='Default Workflow Email',Email__c='sp185453@ncr.com');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setHtmlBody('strEmail');
        
        PageReference pageRef = Page.CPQInstallSheetForQuotePage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',testQuote.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
        CPQEmailInstallSheetForQuote Obj = new CPQEmailInstallSheetForQuote(sc); 
        CPQEmailInstallSheetForQuote.sendProducts();
        
        CPQInstallSheetForQuoteController Obj1 = new CPQInstallSheetForQuoteController();
        obj1.addDynamicRows(add_line);
        obj1.getproductDetails();
        obj1.setproductDetails(pd);

 

        SBQQ.TriggerControl.enable();
        Test.stopTest();          
    } 
    
}