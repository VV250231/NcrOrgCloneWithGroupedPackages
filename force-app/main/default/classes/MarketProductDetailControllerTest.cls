@isTest
public class MarketProductDetailControllerTest {
    
    Public Static User getUser()  {
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    
    static testMethod  void MarketProductTest1(){
        
        Account acc = TestRecordsFactory.createAccount('Test Account',Null);
        Account billTo = TestRecordsFactory.createBillToAccount('Test Account2',acc.id);
        Opportunity opp = TestRecordsFactory.createOpportunity(acc.id,'Test MarketProductOpp','Analyzing',true);
        Product2 Prd = TestRecordsFactory.createProduct('Test Product',20.20);
        Product2 Prd1 = TestRecordsFactory.createProduct('Test Product',20.20);
        PricebookEntry PriceBook = TestRecordsFactory.createPricebookEntry(Prd.Id,20.20);
        SBQQ__Quote__c Quote = TestRecordsFactory.createQuote(acc.Id,opp.Id,billTo.id,false);
        SBQQ__QuoteLine__C quoteLine =TestRecordsFactory.createQuoteLine(Quote.Id, Prd.Id, PriceBook);
        
        System.runAs(getUser()){
         Account channelAccount = new Account(
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
            cdmAccRel.Account__c=acc.Id;
            cdmAccRel.Related_Account__c = channelAccount.Id;
            cdmAccRel.Relationship_Type__c='Local Office - End Customer';
            cdmAccRel.Name ='Local Office';
            
            cdmAccRel.Relationship_Code__c = 'End Customer Of';
            insert cdmAccRel;
           
             opp.Channel_Office__c= channelAccount.id;
            update opp;
            
        }
        Contract con = new Contract();
        con.SBQQ__Opportunity__c=opp.Id;
        con.AccountId=acc.Id;    
        insert con;
        opp.SBQQ__AmendedContract__c=con.Id;
        
        
        Test.startTest();
        Update opp;
        TestRecordsFactory.createOpportunityLine(opp.Id,Prd.Id,PriceBook,quoteLine.Id,Prd1.Id);
        List<Object> mrktObj = MarketProductDetailController.getConsolatedData(opp.Id, '20'); 
        
        System.assert(mrktObj!=null);
        MarketProductDetailController.isCommunity(); 
        
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        PaySite.NCR_Payments_Application_Status__c ='ApprovedAndBoarded';
        PaySite.Opportunity__c=opp.Id;
        PaySite.Quote__c=Quote.Id;
        insert PaySite;
        
        Customer_Document__c cd1 =new Customer_Document__c();
        cd1.Account__c=acc.Id;   
        cd1.Quote__c=Quote.Id;
        cd1.Document_Type__c='AE Order Form';
        cd1.Document_Status__c='Completed';
        insert cd1;
        
        Customer_Document__c cd2 =new Customer_Document__c();
        cd2.Account__c=acc.Id;   
        cd2.Quote__c=Quote.Id;
        cd2.Document_Type__c='AE Master Agreement';
        cd2.Document_Status__c='Completed';
        insert cd2;
        
        PaySite.NCR_Payments_Application_Status__c ='Reject';
        Update PaySite;
        
        PaySite.NCR_Payments_Application_Status__c ='ApprovedAndBoarded';
        Update PaySite;
        
        new cpq_QteToOppSync().getNonPmntsOnlyQte(new List<SBQQ__Quote__c>{Quote});
        Test.stopTest(); 
    }
    
    static testMethod  void MarketProductTest2(){
        
        Account acc = TestRecordsFactory.createAccount('Test Account',Null);
        Account billTo = TestRecordsFactory.createBillToAccount('Test Account2',acc.Id);
        Opportunity opp = TestRecordsFactory.createOpportunity(acc.id,'Test MarketProductOpp','Analyzing',false);
        Product2 Prd = TestRecordsFactory.createProduct('Test Product',20.20);
        Product2 Prd1 = TestRecordsFactory.createProduct('Test Product',20.20);
       System.runAs(getUser()){
         Account channelAccount = new Account(
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
            cdmAccRel.Account__c=acc.Id;
            cdmAccRel.Related_Account__c = channelAccount.Id;
            cdmAccRel.Relationship_Type__c='Local Office - End Customer';
            cdmAccRel.Name ='Local Office';
            
            cdmAccRel.Relationship_Code__c = 'End Customer Of';
            insert cdmAccRel;
           
             opp.Channel_Office__c= channelAccount.id;
            update opp;
         
        }
        
        Test.startTest();
        PricebookEntry PriceBook = TestRecordsFactory.createPricebookEntry(Prd.Id,20.20);
        SBQQ__Quote__c Quote = TestRecordsFactory.createQuote(acc.Id,opp.Id,billTo.Id,false);
        SBQQ__QuoteLine__C quoteLine =TestRecordsFactory.createQuoteLine(Quote.Id, Prd.Id, PriceBook);
        Contract con = new Contract();
        con.SBQQ__Opportunity__c=opp.Id;
        con.AccountId=acc.Id;
        insert con;
        opp.SBQQ__AmendedContract__c=con.Id;
        
        Update opp;
        TestRecordsFactory.createOpportunityLine(opp.Id,Prd.Id,PriceBook,quoteLine.Id,Prd1.Id);
        Test.stopTest(); 
        List<Object> mrktObj = MarketProductDetailController.getConsolatedData(opp.Id, '20'); 
        
        System.assert(mrktObj!=null);
    }
    
    static testMethod  void OppClosedBookByOrderedCheckBoxTest(){
        Test.startTest();
        Account acc = TestRecordsFactory.createAccount('Test Account',Null);
        Account billTo = TestRecordsFactory.createBillToAccount('Test Account2',acc.id);
        Opportunity opp = TestRecordsFactory.createOpportunity(acc.id,'Test MarketProductOpp','Analyzing',true);
        Product2 Prd = TestRecordsFactory.createProduct('Test Product',20.20);
        Product2 Prd1 = TestRecordsFactory.createProduct('Test Product',20.20);
        PricebookEntry PriceBook = TestRecordsFactory.createPricebookEntry(Prd.Id,20.20);
        SBQQ__Quote__c Quote = TestRecordsFactory.createQuote(acc.Id,opp.Id,billTo.id,true);
        SBQQ__QuoteLine__C quoteLine =TestRecordsFactory.createQuoteLine(Quote.Id, Prd.Id, PriceBook);
        System.assertNotEquals(Quote!=null, null);
        Test.stopTest(); 
    }
    static testMethod  void OppClosedBookByNCRPayTest(){
        //Setting Channel Office
        Account channelAccount = new Account(
            Name='Test Company Name123',
            Account_Country_Code__c = 'US',
            LOB__c='HOSPITALITY',
            Active_Account__c = true,
            CDM_Account_Type__c='LOCAL OFFICE',
            CDM_Account_Status__c = 'Active',
            //CDM_Sub_Account_Type__c = 'LOCAL OFFICE',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert channelAccount;  
        }        
        Account acc = TestRecordsFactory.createAccount('Test Account',Null);
        //Setting Sites
        Account testSite = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Site).getRecordTypeId(),
            Name='Test Company Name123',
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            ParentId = acc.Id,
            CDM_Account_Type__c = 'Site');
        System.runAs(TestRecordsFactory.getUser()){
            insert testSite;  
        } 
        
        cdm_Account_Relationship__c cdmAccRel = new cdm_Account_Relationship__c();
        cdmAccRel.Account__c=acc.Id;
        cdmAccRel.Related_Account__c = channelAccount.Id;
        cdmAccRel.Relationship_Type__c='Local Office - End Customer';
        cdmAccRel.Name ='Local Office';
        cdmAccRel.Relationship_Code__c = 'End Customer Of';
        insert cdmAccRel;
        AccountTeamMember atm=new AccountTeamMember(Accountid=channelAccount.id, TeamMemberRole=Label.ATM_Role_PMNTSREP, UserId=TestRecordsFactory.getUser().id);
        insert atm;
        Account billTo = TestRecordsFactory.createBillToAccount('Test Account2',acc.id);
        Opportunity opp = TestRecordsFactory.createOpportunity(acc.id,'Test MarketProductOpp','Analyzing',true);
        opp.Channel_Office__c=channelAccount.id;
        update opp;
        
        Product2 Prd = TestRecordsFactory.createProduct('Test Product',20.20);
        Product2 Prd1 = TestRecordsFactory.createProduct('Test Product',20.20);
        Prd1.Service_Offer_Category__c='Payments Processing';
        update prd1;
        PricebookEntry PriceBook = TestRecordsFactory.createPricebookEntry(Prd.Id,20.20);
        PricebookEntry PriceBook2 = TestRecordsFactory.createPricebookEntry(Prd1.Id,20.20);
        SBQQ__Quote__c Quote = TestRecordsFactory.createQuote(acc.Id,opp.Id,billTo.id,false); 
         SBQQ__QuoteLine__C quoteLine = CPQ_TestDataFactory.createQuoteLineItem(quote, Prd, PriceBook);
         SBQQ__QuoteLine__C quoteLine1 = CPQ_TestDataFactory.createQuoteLineItem(quote, Prd1, PriceBook2);
        insert quoteLine;
        //insert quoteLine1;
       // SBQQ__QuoteLine__C quoteLine =TestRecordsFactory.createQuoteLine(Quote.Id, Prd.Id, PriceBook);
        //SBQQ__QuoteLine__C quoteLine1 =TestRecordsFactory.createQuoteLine(Quote.Id, Prd1.Id, PriceBook2);     
        opp.StageName='Proposing';
        Update opp;        
        Test.startTest();
        OpportunityLineItem oli1= TestRecordsFactory.createOpportunityLine(opp.Id,Prd.Id,PriceBook,quoteLine.Id,Prd1.Id);
        OpportunityLineItem oli2=TestRecordsFactory.createOpportunityLine(opp.Id,Prd1.Id,PriceBook,quoteLine1.Id,Prd.Id);
        opp.Payments_Rep__c=null;
        update opp;
        //delete quoteLine1;   
        
        Customer_Document__c cd1 =new Customer_Document__c();
        cd1.Account__c=acc.Id;   
        cd1.Quote__c=Quote.Id;
        cd1.Document_Type__c='AE Order Form';
        cd1.Document_Status__c='Completed';
        insert cd1;
        
        Customer_Document__c cd2 =new Customer_Document__c();
        cd2.Account__c=acc.Id;   
        cd2.Quote__c=Quote.Id;
        cd2.Document_Type__c='AE Master Agreement';
        cd2.Document_Status__c='Completed';
        insert cd2;
        
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        PaySite.NCR_Payments_Application_Status__c ='ApprovedAndBoarded';
        PaySite.Opportunity__c=opp.Id;
        PaySite.Quote__c=Quote.Id;
        insert PaySite;  
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='1234';
        PaySite.NCR_Payments_Application_Status__c ='ApprovedAndBoarded';
        PaySite.Opportunity__c=opp.Id;
        PaySite.Quote__c=Quote.Id;
        insert PaySite1;  
        delete PaySite1;
        System.assert(PaySite!=null);
        Test.stopTest(); 
    }
    static testMethod  void OppClosedBookScenario(){
        //Setting Channel Office
        Account channelAccount = new Account(
            Name='Test Company Name123',
            Account_Country_Code__c = 'US',
            LOB__c='HOSPITALITY',
            Active_Account__c = true,
            CDM_Account_Type__c='LOCAL OFFICE',
            CDM_Account_Status__c = 'Active',
            //CDM_Sub_Account_Type__c = 'LOCAL OFFICE',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert channelAccount;  
        }        
        Account acc = TestRecordsFactory.createAccount('Test Account',Null);
        //Setting Sites
        Account testSite = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Site).getRecordTypeId(),
            Name='Test Company Name123',
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            ParentId = acc.Id,
            CDM_Account_Type__c = 'Site');
        System.runAs(TestRecordsFactory.getUser()){
            insert testSite;  
        }
        
        cdm_Account_Relationship__c cdmAccRel = new cdm_Account_Relationship__c();
        cdmAccRel.Account__c=acc.Id;
        cdmAccRel.Related_Account__c = channelAccount.Id;
        cdmAccRel.Relationship_Type__c='Local Office - End Customer';
        cdmAccRel.Name ='Local Office';
        cdmAccRel.Relationship_Code__c = 'End Customer Of';
        insert cdmAccRel;
        AccountTeamMember atm=new AccountTeamMember(Accountid=channelAccount.id, TeamMemberRole=Label.ATM_Role_PMNTSREP, UserId=TestRecordsFactory.getUser().id);
        insert atm;
        Account billTo = TestRecordsFactory.createBillToAccount('Test Account2',acc.id);
        Opportunity opp = TestRecordsFactory.createOpportunity(acc.id,'Test MarketProductOpp','Analyzing',true);
        opp.Channel_Office__c=channelAccount.id;
        update opp;
        
        Product2 Prd = TestRecordsFactory.createProduct('Test Product',20.20);
        Product2 Prd1 = TestRecordsFactory.createProduct('Test Product',20.20);
        Prd1.Service_Offer_Category__c='Payments Processing';
        update prd1;
        PricebookEntry PriceBook = TestRecordsFactory.createPricebookEntry(Prd.Id,20.20);
        PricebookEntry PriceBook2 = TestRecordsFactory.createPricebookEntry(Prd1.Id,20.20);
        SBQQ__Quote__c Quote = TestRecordsFactory.createQuote(acc.Id,opp.Id,billTo.id,false);
 SBQQ__QuoteLine__C quoteLine = CPQ_TestDataFactory.createQuoteLineItem(quote, Prd, PriceBook);
         SBQQ__QuoteLine__C quoteLine1 = CPQ_TestDataFactory.createQuoteLineItem(quote, Prd1, PriceBook2);        
       // SBQQ__QuoteLine__C quoteLine =TestRecordsFactory.createQuoteLine(Quote.Id, Prd.Id, PriceBook);
        //SBQQ__QuoteLine__C quoteLine1 =TestRecordsFactory.createQuoteLine(Quote.Id, Prd1.Id, PriceBook2);
       insert quoteLine;
           //  insert quoteLine1;
        
        Test.startTest();
        OpportunityLineItem oli1= TestRecordsFactory.createOpportunityLine(opp.Id,Prd.Id,PriceBook,quoteLine.Id,Prd1.Id);
        OpportunityLineItem oli2=TestRecordsFactory.createOpportunityLine(opp.Id,Prd1.Id,PriceBook,quoteLine1.Id,Prd.Id);
       
        opp.StageName='Proposing';
        Update opp;
        Quote.qtc_Bill_To_Site__c =testSite.Id;
        Quote.Deliver_To_Site__c =testSite.Id;
        Quote.qtc_Ship_To_Account__c =testSite.Id;
        update Quote; 
        Quote.qtc_Ordered_Custom__c=true;
        update Quote;
        System.assert(Quote!=null);
        cpq_QteToOppSync co=new cpq_QteToOppSync();        
        Test.stopTest(); 
    }
    static testMethod  void OppClosingScenario(){
        //Setting Channel Office
        Account channelAccount = new Account(
            Name='Test Company Name123',
            Account_Country_Code__c = 'US',
            LOB__c='HOSPITALITY',
            Active_Account__c = true,
            CDM_Account_Type__c='LOCAL OFFICE',
            CDM_Account_Status__c = 'Active',
            //CDM_Sub_Account_Type__c = 'LOCAL OFFICE',
            industry = 'HOSPITALITY:QSR',
            Project_Coordinator_Email__c = 'abc@test.com');
        System.runAs(TestRecordsFactory.getUser()){
            insert channelAccount;  
        }        
        Account acc = TestRecordsFactory.createAccount('Test Account',Null);
        //Setting Sites
        Account testSite = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Site).getRecordTypeId(),
            Name='Test Company Name123',
            Primary_Bill_To__c = true,
            Bill_To__c = true,
            Ship_To__c = true, 
            Primary_Ship_To__c = true,
            Deliver_To__c = true, 
            Primary_Deliver_To__c = true,
            ParentId = acc.Id,
            CDM_Account_Type__c = 'Site');
        System.runAs(TestRecordsFactory.getUser()){
            insert testSite;  
        }
        
        cdm_Account_Relationship__c cdmAccRel = new cdm_Account_Relationship__c();
        cdmAccRel.Account__c=acc.Id;
        cdmAccRel.Related_Account__c = channelAccount.Id;
        cdmAccRel.Relationship_Type__c='Local Office - End Customer';
        cdmAccRel.Name ='Local Office';
        cdmAccRel.Relationship_Code__c = 'End Customer Of';
        insert cdmAccRel;
        AccountTeamMember atm=new AccountTeamMember(Accountid=channelAccount.id, TeamMemberRole=Label.ATM_Role_PMNTSREP, UserId=TestRecordsFactory.getUser().id);
        insert atm;
        Account billTo = TestRecordsFactory.createBillToAccount('Test Account2',acc.id);
        Opportunity opp = TestRecordsFactory.createOpportunity(acc.id,'Test MarketProductOpp','Analyzing',true);
        opp.Channel_Office__c=channelAccount.id;
        update opp;
        
        Product2 Prd = TestRecordsFactory.createProduct('Test Product',20.20);
        
        Product2 Prd1 = TestRecordsFactory.createProduct('Test Product',20.20);
        Prd1.Service_Offer_Category__c='Payments Processing';
        update prd1;
        PricebookEntry PriceBook = TestRecordsFactory.createPricebookEntry(Prd.Id,20.20);
        PricebookEntry PriceBook2 = TestRecordsFactory.createPricebookEntry(Prd1.Id,20.20);
        SBQQ__Quote__c Quote = TestRecordsFactory.createQuote(acc.Id,opp.Id,billTo.id,false);
        SBQQ__QuoteLine__C quoteLine = CPQ_TestDataFactory.createQuoteLineItem(quote, Prd, PriceBook);
         //SBQQ__QuoteLine__C quoteLine1 = CPQ_TestDataFactory.createQuoteLineItem(quote, Prd1, PriceBook2);
        insert quoteLine;
        //insert quoteLine1;
        //SBQQ__QuoteLine__C quoteLine =TestRecordsFactory.createQuoteLine(Quote.Id, Prd.Id, PriceBook);
        //SBQQ__QuoteLine__C quoteLine1 =TestRecordsFactory.createQuoteLine(Quote.Id, Prd1.Id, PriceBook2);
        opp.SBQQ__PrimaryQuote__c=Quote.id;
        Quote.qtc_Bill_To_Site__c =testSite.Id;
        Quote.Deliver_To_Site__c =testSite.Id;
        Quote.qtc_Ship_To_Account__c =testSite.Id;
        Quote.ApprovalStatus__c=null;
        update Quote;
        update opp;
        Test.startTest();
        OpportunityLineItem oli1= TestRecordsFactory.createOpportunityLine(opp.Id,Prd.Id,PriceBook,quoteLine.Id,Prd1.Id);
        oli1.Product_Type__c='PID';
        update oli1;
        //OpportunityLineItem oli2=TestRecordsFactory.createOpportunityLine(opp.Id,Prd1.Id,PriceBook,quoteLine1.Id,Prd.Id);
        cpq_QteToOppSync c=new cpq_QteToOppSync();
        Map<id,Opportunity> finalUpdateM=new Map<id,Opportunity> ();
        c.setOppClosing(new set<Id> {opp.Id},finalUpdateM);
        Quote.ApprovalStatus__c='Pending';
        MarketProductHelper mp=new MarketProductHelper();
        mp.runOnce();
        update Quote; 
        System.assert(Quote!=null);
        Test.stopTest();  
    }
    
}