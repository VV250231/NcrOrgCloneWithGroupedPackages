/**************************************
Author ...............: Ajay Dixit
Date Created .........: 07 Jan 2016
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 feb 2022
Description ..........: This class is utility class to create data for test class.
***************************************/
@isTest
public class TestRecordsFactory {
    
    /**
*@purpose : Creates opportunity with defined product Datahub Ref key
*@Param : dhrk 
*@Return : opportunity
**/
    
    
    Public Static User getUser()
    {
        
       User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    //01s700000002GMc = GlobalVariable.pricebookId
    public static Opportunity createOpportunityWithProductDHRK(String dhrk, Account a) {
        
        PricebookEntry pbe=[SELECT id FROM PricebookEntry WHERE Pricebook2Id =: GlobalVariable.pricebookId AND CurrencyIsoCode = 'USD' AND Product2Id = :[SELECT id FROM product2 WHERE DataHubReferenceKey__c=:dhrk]].get(0);
        system.debug('###'+pbe);
        // create new Opportunity object 
        Opportunity opp = createSimpleOpportunity(a);
        OpportunityLineItem oli = createOpportunityLineItem(opp, pbe);
        OpportunityLineItemSchedule olis = createOpportunityLineitemSchedule(oli);
        return opp;
    }
    
    /**
*@purpose : Creates opportunity with defined product Datahub Ref key
*@Param : dhrk , Account
*@Return : opportunity
**/
    public static Opportunity createOpportunityWithProductDHRK(String dhrk) {
        PricebookEntry pbe=[SELECT id FROM PricebookEntry WHERE Pricebook2Id =:GlobalVariable.pricebookId AND CurrencyIsoCode = 'USD' AND Product2Id = :[SELECT id FROM product2 WHERE DataHubReferenceKey__c=:dhrk]].get(0);
        system.debug('###'+pbe);
        // create new Opportunity object 
        Opportunity opp = createSimpleOpportunity();
        OpportunityLineItem oli = createOpportunityLineItem(opp, pbe);
        OpportunityLineItemSchedule olis = createOpportunityLineitemSchedule(oli);
        return opp;
    }
    /**
*@purpose : Creates opportunity with defined product Datahub Ref key
*@Param : dhrk , Account
*@Return : opportunity
**/
    public static Opportunity createOpportunityLIWithProductDHRK(String dhrk, Opportunity opp) {
        PricebookEntry pbe=[SELECT id FROM PricebookEntry WHERE Pricebook2Id =:GlobalVariable.pricebookId AND CurrencyIsoCode = 'USD' AND Product2Id = :[SELECT id FROM product2 WHERE DataHubReferenceKey__c=:dhrk]].get(0);
        system.debug('###'+pbe);
        // create new Opportunity object 
        OpportunityLineItem oli = createOpportunityLineItem(opp, pbe);
        OpportunityLineItemSchedule olis = createOpportunityLineitemSchedule(oli);
        return opp;
    }
    /**
*@purpose : Creates opportunity with line item schedule record
*@Param : None 
*@Return : opportunity
**/
    public static Opportunity createOpportunityWithLineItemSchedule() {
        // create new Opportunity object 
        Opportunity opp = createSimpleOpportunity();
        OpportunityLineItem oli = createOpportunityLineItem(opp, createPriceBookEntry(createProduct()));
        OpportunityLineItemSchedule olis = createOpportunityLineitemSchedule(oli);
        return opp;
    }
    /**
*@purpose : Creates opportunity with line item record
*@Param : None 
*@Return : opportunity
**/
    public static Opportunity createOpportunityWithLineItem() {
        // create new Opportunity object 
        Opportunity opp = createSimpleOpportunity();
        OpportunityLineItem oli = createOpportunityLineItem(opp, createPriceBookEntry(createProduct()));
        return opp;
    }
    /**
*@purpose : Creates Hierarchy with defined Sol Portfolio for Advocated Soln
*@Param : solPortfolio, asl 
*@Return : Hierarchy
**/
    /*public static Hierarchy__c createHierarchy(String SolPortfolio, Advocated_Solution__c asl) {
// create new Opportunity object 
Hierarchy__c h = new Hierarchy__c(Offer_Portfolio__c=SolPortfolio);
insert h;
asl.Hierarchy__c=h.id;

return h;
}*/
    /**
*@purpose : Creates simple single opportunity record
*@Param : None 
*@Return : opportunity
**/
    public static Opportunity createSimpleOpportunity() {
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.AccountID = createAccount().id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        insert opp;
        return opp;
    }
    /**
*@purpose : Creates simple single opportunity record
*@Param : None 
*@Return : opportunity
**/
    public static Opportunity createSimpleOpportunity(Account a) {
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
        Id r2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.Industry__c = 'Financial';
       
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change -Ahad*/
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r2;
        opp.Amount = 100;
        insert opp;
        return opp;
    }
    
    
    /**
*@purpose : Creates simple single opportunity record
*@Param : None 
*@Return : opportunity
**/
    public static Opportunity createSimpleOpportunityWithContact(Contact c) {
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
        Id r3 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.Contacts__c = c.Id;
        opp.AccountID = c.AccountId;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change - Ahad*/
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r3;
        insert opp;
        return opp;
    }
    public static Opportunity createOpportunityWithContact(Contact c,Account acc) {
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
          Id r4 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.Contacts__c = c.Id;
        opp.AccountID = acc.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Hospitality'; -P360 Initial Change-Ahad*/
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Prospecting';
        opp.recordTypeId = r4;
        insert opp;
        return opp;
    }
    
    /**
*@purpose : Creates simple single Sales Org record
*@Param : None 
*@Return : Sales Org
**/
    public static Sales_Org__c createSalesOrg() {
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        return s;
    }
    /**
*@purpose : Creates simple single Account record
*@Param : MCN 
*@Return : Account
**/
    public static Account createAccount(String MCN) {
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true, 
             //MDM_Data_Source_Code__c='CDM',
            //Global_Sales_Org_Code__c='635120600',
            Master_Customer_Number__c = mcn + System.now().getTime(),
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
        insert a;
        }
        return a;
    }
    
    /**
*@purpose : Creates simple single Account record
*@Param : None 
*@Return : Account
**/
    public static Account createAccount() {
        Account a = new Account(name = 'Test Acc',
                                LOB__c = 'FINANCIAL',
                               //  MDM_Data_Source_Code__c='CDM',
                                Master_Customer_Number__c = 'TESTMCN00001X',
                                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                                Active_Account__c = true,
                               CDM_Account_Status__c = 'Active');
        System.runAs(getUser()){
        insert a;
        }
        return a;
    }
    
    /**
    *@purpose : Creates List of simple Account records
    *@Param : None 
    *@Return : List of Accounts
    **/
    public static List<Account> createAccounts(integer noOfRecords) {
        List<Account> accLst = new List<Account>();
        
        for(integer i=0; i<noOfRecords; i++) {
            Account a = new Account(name = 'Test Acc' + i,
                                    LOB__c = 'FINANCIAL',
                                    //  MDM_Data_Source_Code__c='CDM',
                                    Master_Customer_Number__c = 'TEST001' + i,
                                    Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                                    Active_Account__c = true);
            
            accLst.add(a);      
        }
        System.runAs(getUser()){
            insert accLst;
        }
        return accLst;
    }
    
    /**
*@purpose : Creates simple single competitor record
*@Param : None 
*@Return : Competitor
**/
    public static Competitors__c createCompetitor() {
        //create new competitor object 
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        return c;
    }
    /**
*@purpose : Creates simple single product record
*@Param : None 
*@Return : product2
**/
    public static Product2 createProduct() {
        Product2 prod = new Product2();
        prod.Name = 'Orderman';
        prod.Family = 'Hardware';
        prod.CanUseQuantitySchedule = true;
        prod.Service_Offer_Category__c='HW';
        insert prod;
        return prod;
    }
    /**
*@purpose : Creates simple single product record
*@Param : None 
*@Return : product2
**/
    /* public static Product2 createProduct() {
Product2 prod = new Product2();
prod.Name = 'test';
prod.Family = 'Hardware';
//prod.Advocated_Solution_Lookup__c=asl.id;
prod.CanUseQuantitySchedule = true;
insert prod;
return prod;
}*/
    /**
*@purpose : Creates simple single custom pricebook for 2a product record
*@Param :  
*@Return : Pricebook2
**/
    public static Pricebook2 createPriceBook() {
        Pricebook2 pb = new Pricebook2(name='test PB', isActive=true);
        
        insert pb;
        return pb;
    }
    /**
*@purpose : Creates simple single custom pricebookentry for a product record
*@Param : product2 
*@Return : product2
**/
    public static PricebookEntry createPriceBookEntry(Product2 prod) {
       String stdPriceBook = Test.getStandardPricebookId();//stdPriceBook =01s700000002GMc
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = GlobalVariable.pricebookId, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true, CurrencyIsoCode = 'USD');
        insert customPrice;
        return customPrice;
    }
    
    
      /**
    *@purpose : Creates simple single custom pricebookentry for a product record
    *@Param : product2 
    *@Return : product2
    **/
    public static PricebookEntry createPriceBookEntryFromPriceBook(Product2 prod, String prcbkId) {
        String stdPriceBook = Test.getStandardPricebookId();//stdPriceBook =01s700000002GMc
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPBE = new PricebookEntry(
            Pricebook2Id = prcbkId, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert customPBE;
       
        return customPBE;
    }
    
    /**
*@purpose : Creates simple List of custom pricebookentry for a product record
*@Param : product2 
*@Return : product2
*@Developer : Saritha Karuturi
**/
    public static List<PricebookEntry> createPriceBookEntry(List <Product2> prodL) {
        List<PricebookEntry> stdPBEL=new  List<PricebookEntry>();
        List<PricebookEntry> ctmPBEL=new  List<PricebookEntry>();
        for(PRoduct2 prod:prodL){
            String stdPriceBook = Test.getStandardPricebookId();//stdPriceBook =01s700000002GMc
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = GlobalVariable.pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode = 'USD');
            stdPBEL.add(standardPrice)  ;
            ctmPBEL.add(customPrice)  ;
        }
        
        insert stdPBEL;        
        insert ctmPBEL;
        return ctmPBEL;
    }
    /**
*@purpose : Creates simple single Opportunity Line Item record
*@Param : Opportunity, Pricebook Entry 
*@Return : OpportunityLineItem
**/
    public static OpportunityLineItem createOpportunityLineItem(Opportunity opp, PricebookEntry customPrice) {
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = customPrice.id;
        OLI1.Quantity = 1000000;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='HW';
       // OLI1.source__c = 'Package';
        OLI1.Sites__c = 10;
        insert OLI1;
        return OLI1;
    }
    
    public static OpportunityLineItem createOpportunityLineItem_Product(Opportunity opp, PricebookEntry customPrice) {
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = customPrice.id;
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='HW';
        OLI1.source__c = '';
        OLI1.Sites__c = 10; 
        insert OLI1;
        return OLI1;
    }
    /**
*@purpose : Creates simple List Opportunity Line Item record
*@Param : Opportunity, Pricebook Entry 
*@Return : OpportunityLineItem
*@Developer : Saritha Karuturi
**/
    public static List<OpportunityLineItem> createOpportunityLineItem(Opportunity opp, List<PricebookEntry> customPriceL) {
        List <OpportunityLineItem> oliList=new List<OpportunityLineItem>();
        for(PricebookEntry customPrice: customPriceL){
            OpportunityLineItem OLI1 = new OpportunityLineItem();
            OLI1.OpportunityID = opp.id;
            OLI1.PricebookEntryId = customPrice.id;
            OLI1.Quantity = 2;
            OLI1.unitprice = 20;
            OLI1.Revenue_Type__c='HW';
            
            if(opp.CATM_Record__c) OLI1.Number_of_Terms__c = opp.Contract_Term_Mths__c;
                
            oliList.add(OLI1);
        }
        
        
        insert oliList;
        return oliList;
    }
    
    /**
*@purpose : Creates Advocated solution by Code
*@Param : Code 
*@Return : Advocated_Solution__c
**/
    /*public static void createAdvocatedSolutionByCode(String Code) {
        //Advocated_Solution__c asol = new Advocated_Solution__c(Advocated_Solution_id__c=Code, Name='Tst A sol');  
        //insert asol;
        //return asol;
    }*/
    /**
*@purpose : Creates simple single Opportunity Line Item Schedule record
*@Param : OpportunityLineItem 
*@Return : OpportunityLineItemSchedule
**/
    public static OpportunityLineItemSchedule createOpportunityLineitemSchedule(OpportunityLineItem oli1) {
        OpportunityLineItemSchedule olis = new OpportunityLineitemSchedule(OpportunityLineItemId = oli1.id, scheduleDate = System.today() + 60,
                                                                     type = 'Quantity', quantity = oli1.quantity);
       
        insert olis;
        return olis;
    }
    
    
    
    
    /**
*@purpose : Creates simple single Contract record
*@Param : Account
*@Return : Contract 
**/
 /*   public static Contract createContract(Account a) {
        Contract c = new Contract();
        c.Accountid = a.id;
        c.Status = 'Active';
        c.Contract_Header_ID__c = '12345';
        c.Contract_Number__c =  '12345';
        insert c;
        return c;
    }
    
    */
    /**
*@purpose : Creates simple single Service record with Line Number
*@Param :  Contract, Service Line
*@Return : Contract_Service__c 
**/
 /*   public static Contract_Service__c createContractService(Contract c, integer line) {
        Contract_Service__c cs = new Contract_Service__c();
        cs.Name = 'test';
        cs.Contract__c = c.Id;
        cs.Contract_Header_ID__c = c.Contract_Header_ID__c;
        cs.Contract_Number__c =  c.Contract_Number__c;
        cs.Service_Line_ID__c = 'TEST1234';
        cs.Line__c = line;
        insert cs;
        return cs;
    }
   */ 
    
    /**
*@purpose : Creates simple single Service Product record
*@Param :  Contract Service 
*@Return : Service_Product__c 
**/
 /*   public static Service_Product__c createServiceProduct(Contract_Service__c cs) {
        Service_Product__c sp = new Service_Product__c();
        sp.Name = 'Test';
        sp.Service__c = cs.Id;
        sp.Service_Line_ID__c = cs.Service_Line_ID__c;
        sp.Status__c = 'ACTIVE';
        sp.Subline_ID__c =  'TEST1234';
        insert sp;
        return sp;
    }
    */
    /**
*@purpose : Creates simple single Contract record
*@Param : Account
*@Return : Contact 
**/
    public static Contact createContact(Account a) {
        Contact c = new Contact();
        c.Accountid = a.id;
        c.LastName = 'test1';
        c.Email = 'test1@test.com';
        c.Business_Function__c = 'Marketing';
        if(a.Subscription_Group__c == 'Digital Insight') {
            c.Additional_Relationships__c = 'Digital Insight';
        }
        insert c;
        return c;
    }
    
   public static Opportunity createOpportunity(Account a) {
        Opportunity o = new Opportunity();
        o.Accountid = a.id;
        o.Name = 'test1';
        o.StageName='Analyzing';
        o.CloseDate =System.TODAY();
         insert o;
        return o;
        
    }
    /**
*@purpose : Creates simple single OpportunityContactRole record
*@Param : Opportunity opp, Contact con
*@Return : OpportunityContactRole 
**/
    public static OpportunityContactRole createOppContactRole(Opportunity opp, Contact con) {
        OpportunityContactRole oppConRole = new OpportunityContactRole();
        oppConRole.OpportunityId = opp.Id;
        oppConRole.ContactId = con.Id;
        oppConRole.Role = 'Primary Buyer'; 
        oppConRole.IsPrimary = true;
        insert oppConRole;
        return oppConRole;
    }
    
    
    
    /**
* @purpose : Fetch profile record
* @param ProfileName Name for the profile.
*/
    public static profile getProfile(String profileName) {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name =: profileName LIMIT 1];
        System.debug('---------profiles-------'+profiles[0].Id);
        if (profiles.size() > 0) {
            return profiles[0];
        }
        return null;
    }
    
    /**
* @purpose : create user record with specified profile Id.
* @param profileId Id of the profile which is going to used by user.
* @param numOfUsers how many user needs to be create for particular profile Id.
* @param userPrefix A stirng which wll be appear as prefix before the user name.
*/
    public static List<User> createUsers(String profileId, String userPrefix, Integer numOfUsers) {
        List<User> newUsers = new List<User>();
        for (Integer i=0;i < numOfUsers ; i++) {
            User us              =  new User();
            us.Profileid         = profileId;
            us.Username          = userPrefix+i+'@ncr.com';
            us.Email             = userPrefix+i+'@ncr.com';
            us.Alias             = 'alias'+i;           
            us.FirstName         = 'Fname'+i;
            us.LastName          = 'lname'+i;
            us.LocaleSidKey      = 'ar';
            us.LanguageLocaleKey = 'de';
            us.TimeZoneSidKey    = 'Africa/Cairo';
            us.EmailEncodingKey  = 'Big5';
            us.CurrencyIsoCode   = 'AUD';
            us.Quicklook_ID__c   = 'tm25066'+i;
            us.FederationIdentifier = 'tm25066'+i;
            newUsers.add(us);
        }
        
        try {
            System.debug('---------newUsers-------'+newUsers.size());
            if (newUsers.size() > 0)
            {
                insert newUsers;
                System.debug('---------newUsers-------'+newUsers[0].id);
            }
            else
                return null;
            // IF successfull insertion than return the user list.
            return newUsers;
        } catch(Exception ex) {
            return null;
        }       
    }
    
    
    /**
*@purpose : Creates simple single Service record with Line Number
*@Param :  opp - Parent opportunity of value prompter record
*@Return : Value_Prompter__c record
**/
    public static Value_Prompter__c createValuePrompterFromOpp(Opportunity opp) {
        Value_Prompter__c vp =new Value_Prompter__c();
        vp.Name = 'Test';
        vp.Contact__c= '1234';
        vp.Business_Issue__c = 'test';
        vp.Anxiety_Question__c = 'Test Question';
        vp.Problem__c = 'Test';
        vp.Solution__c = 'Test';
        vp.Value__c = 'Test value';
        vp.Power__c = 'Test power';
        vp.Plan__c  = 'Test Plan';
        vp.Opportunity__c =opp.Id;
        
        insert vp;
        return vp;
    }
    
    
    /**
*@purpose : Creates attachment record
*@Param :  ParentId - Attachment parent id
*@Return : Attachment 
**/
    public static Attachment createAttachment(Id ParentId) {
        Attachment a = new Attachment();
        a.body = Blob.valueOf('Test Data');
        a.Name = 'Test attachment';
        a.ParentId =  ParentId;       
        insert a;
        return a;
    }
    
    /**
*@purpose : Creates AccountTeamMember record
*@Param :  AccountId - Account Id
*@Param :  UserId- User Id
*@Return : AccountTeamMember
**/
    public static AccountTeamMember createAccountTeamMember(Id accId, Id userId) {
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = accId, UserId = userId, TeamMemberRole = 'Account Manager');
        insert accTeamMember;
        return accTeamMember;
    }
    
    /**
*@purpose : Creates Lead record
*@Return : Lead 
**/
    public static Lead createLead() {
        Lead li =new lead();
        li.LastName='Test_Mudi';
        li.Country='India';
        li.Company='NCR';
        insert li;
        return li;
    }
    
    
    
    /**
*@purpose : Creates simple single Ticket Request record
*@Param : Userid, Contact, Opportunity
*@Return : Ticket Request record
**/
    public static Ticket_Request__c createTicketRequest(User uId, Contact c, Opportunity o) {
        Ticket_Request__c tr =new Ticket_Request__c();
        tr.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
        tr.Employee_Name__c = uId.id;
        tr.Phone_Number__c = '9876543210';
        tr.Other_Employee_Reps_Attending__c = 'Test User';
        tr.Contact_Name__c = c.id;
        tr.Contacts_Guest__c = 'Test123'; 
        tr.Opportunity__c = o.id;
        tr.No_of_Tickets_Requested__c = '16';
        tr.Event_Type__c = 'Falcons';
        tr.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        
        insert tr;
        return tr;
    }
    
    /**
*@purpose : Creates simple single Ticket Request Event record
*@Return : Ticket Request record
**/
    public static Ticket_Request_Event__c createTicketRequestEvent() {
        Ticket_Request_Event__c tre =new Ticket_Request_Event__c();
        date myDate = date.newInstance(2023, 3, 21);
        
        tre.Event_Date__c= myDate;
        tre.Event_Name_Date__c='vs. Miami Dolphins on 3/21/2023';
        tre.Event_Type__c = 'Test event';
        tre.No_Of_Tickets_Available__c= '30';
        tre.Lower_Level_Tickets_Available__c= '10';
        
        tre.Suite_Tickets_Available__c='10';
        tre.VVIP_Tickets_Available__c='10';
        tre.Ticket_Type__c='Club';
        
        tre.Number_of_Parking_Passes_Available__c=10;
        tre.Notes__c = 'Suite Tickets';
        tre.Event_Date__c = Date.newInstance(2023, 3, 21);
        
        insert tre;
        return tre;
    }
    /**
*@purpose : Creates simple single Executive Briefing record
*@Param :  RecordId- Passing Account Record Id
*@Return :Executive Briefing Record record
**/
    public static Executive_Briefing__c createEXB(String a) {
        Executive_Briefing__c exb = new Executive_Briefing__c();
       // exb.Name = 'Test EXB Record';
        
        insert exb;
        return exb;
    }
    
    public static List<Opportunity> returnOpportunities(Integer noOfRecord) {
        // create new Opportunity object
        Account acc =createAccount();
        Sales_Org__c s = createSalesOrg();
        Competitors__c c = createCompetitor();
        List<Opportunity> Opportunities = new   List<Opportunity>();
        for(Integer i=0;i<noOfRecord; i++){
            Opportunity opp = new Opportunity();
            Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
            opp.name = 'abc';
            opp.AccountID = acc.id;
            opp.Name = 'OppQuote Linkage Test Opportunity';
            opp.type = 'Indirect Channel';
            opp.CURRENCYISOCODE = 'USD';
            opp.SALES_ORG__C = s.id;
            opp.INVOICE_TRIGGER__C = 'Shipment';
            opp.PRIMARY_COMPETITOR__C = c.id;
            opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
            opp.closeDate = System.TODAY();
            opp.stagename = 'Analyzing';
            opp.recordTypeId = r1;
            opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
            opp.EndCustomerUnknown__c = true; 
             opp.ForecastCategoryName ='Pipeline';
            Opportunities.add(opp);
        }
        
        
        return Opportunities;
    }
 /**
*@purpose : Creates Standard Price BookEntry
*@Param : None 
*@Return : PricebookEntry
**/
     public static PricebookEntry createStandardPriceBookEntry(Product2 prod) {
        String stdPriceBook = Test.getStandardPricebookId();//stdPriceBook =01s700000002GMc
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = stdPriceBook, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;
        
        
        return standardPrice;
    }
     /**
*@purpose : Creates opportunity with line item record with standard pricebook
*@Param : None 
*@Return : opportunity
**/
    public static Opportunity createOppWithOLIwithStdPriceBookEntry(Opportunity opp) {
        // create new Opportunity object 
       
        OpportunityLineItem oli = createOpportunityLineItem(opp, createStandardPriceBookEntry(createProduct()));
        
        return opp;
    }
    public static user createSystemUser(String profileId, String userPrefix) {

            User us              =  new User();
            us.Profileid         = profileId;
            us.Username          = userPrefix+'@ncr.com';
            us.Email             = userPrefix+'@ncr.com';
            us.Alias             = 'alias';           
            us.FirstName         = 'Fname';
            us.LastName          = 'lname';
            us.LocaleSidKey      = 'ar';
            us.LanguageLocaleKey = 'de';
            us.TimeZoneSidKey    = 'Africa/Cairo';
            us.EmailEncodingKey  = 'Big5';
            us.CurrencyIsoCode   = 'AUD';
            us.Quicklook_ID__c   = 'tm25066';
            us.Access_type__c    ='System';
            us.FederationIdentifier = 'tm25066';
        
        try {
                insert us;
            return us;
        } catch(Exception ex) {
            return null;
        }       
    }
    
    
    public static Account createAccount(String MCN,String Industry,String Region) {
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,    
            //MDM_Data_Source_Code__c='CDM',
            Master_Customer_Number__c = MCN,
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = Industry,
            CAP_Watch__c = 'CAP',
            account_region__c=Region
        );
        
        System.runAs(getUser()){
        insert a;
        }
        return a;
    }
      
    //////CPQ Test Coverage //////
        public static Account createAccount(String name, Id parentId) {
        Account acc = new Account(Name = name, BillingCountry = 'USA', CDM_Account_Status__c = 'Active');
        if(parentId != null) {
            acc.ParentId = parentId;
        }
        System.runAs(getUser()){
            insert acc;
        }
        return acc;
    }
    
    public static Account createBillToAccount(String name, Id parentId) {
        Account acc1 = new Account(Name = name, BillingCountry = 'USA',AutoPay_Setup__c='True',Bill_To__c=true);
        if(parentId != null) {
            acc1.ParentId = parentId;
            acc1.CDM_Account_Status__c='Active';
            acc1.Primary_Bill_To__c=true;
            acc1.CDM_Account_Type__c='Site';
            acc1.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
            acc1.Site_Number__c='1123';
        }
        System.runAs(getUser()){
            insert acc1;
        }
        return acc1;
    }

    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId, 
            SBQQ__PreserveBundleStructureUponRenewals__c = true, 
            ContractTerm = 12,
            StartDate = Date.today());
        insert contract;
        return contract;
    }

    public static SBQQ__Subscription__c createSubscription(
      Id accountId, Id contractId, Id productId, 
      Decimal quantity, Decimal netPrice) {
        Date endDate = Date.today().addYears(1);
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contractId, 
            SBQQ__Product__c = productId, 
            SBQQ__Quantity__c = quantity, 
            SBQQ__Account__c = accountId,
            SBQQ__NetPrice__c = netPrice * quantity,
            SBQQ__SubscriptionEndDate__c = endDate);
        insert subs;
        return subs;
    }

    public static SBQQ__Quote__c createQuote(Id accountId,Id opportunityId, Id billToAccountId, Boolean isOrdered) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = accountId, 
            SBQQ__PricebookId__c = Test.getStandardPricebookId(), 
            SBQQ__Opportunity2__c = opportunityId, 
            SBQQ__StartDate__c = system.today(),
            SBQQ__Status__c = 'Presented', 
            SBQQ__SubscriptionTerm__c = 12, 
            SBQQ__Primary__c=true,
            qtc_Ordered_Custom__c=isOrdered,
            BillingMultiplier__c = 2.5,
            qtc_Bill_To_Site__c=billToAccountId);
        insert quote;
        return quote;
    }

    public static SBQQ__QuoteLine__C createQuoteLine(Id quoteId, Id productId,PricebookEntry priceEntry) {
        SBQQ__QuoteLine__C line = new SBQQ__QuoteLine__C(
            SBQQ__Product__c = productId,
            SBQQ__Quote__c = quoteId,
            SBQQ__PricebookEntryId__c = priceEntry.Id,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__Quantity__c = 10,
            SBQQ__PriorQuantity__c=5,
            SBQQ__BillingFrequency__c='Semiannual'
        );

        insert line;
        return line;
    }

    public static Opportunity createOpportunity(Id accountId, String type, String stage , Boolean isCpq) {  
        Opportunity Opp = new Opportunity();
        Opp.AccountId = accountId;
        Opp.Name = type;
        Opp.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Opp.CloseDate = System.today().addMonths(12);
        Opp.StageName = stage;
        Opp.Pricebook2Id = Test.getStandardPricebookId(); 
        opp.Forecast_Category__c = 'Pipeline';
        opp.ForecastCategoryName = 'Pipeline';
        if(isCpq)
        Opp.cpq__c=true;
    
        insert Opp;
        return Opp;
     }

    public static PricebookEntry createPricebookEntry(Id productId, Decimal amount) {
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productId,
            UnitPrice = amount,
            IsActive = true
        );
        insert pbEntry;
        return pbEntry;
    }

    public static OpportunityLineItem createOpportunityLine(
      Id opportunityId, 
      Id productId, 
      PricebookEntry priceEntry, 
      Id lineItemId,Id MrktPrd) {
        OpportunityLineItem line = new OpportunityLineItem(
            Product2Id = productId,
            OpportunityId = opportunityId,
            PricebookEntryId = priceEntry.Id,
            TotalPrice = priceEntry.UnitPrice,
            SBQQ__QuoteLine__c = lineItemId,
            Quantity = 1,
            Topline_Product_Lkp__c=MrktPrd
            
        );

        insert line;
        return line;
    }

    public static Product2 createProduct(String name, Decimal amount) {
        Product2 product = new Product2(
            Name = name,
            IsActive = true, 
            SBQQ__SubscriptionPricing__c = 'Fixed Price', 
            SBQQ__SubscriptionTerm__c = 12, 
            SBQQ__SubscriptionType__c = 'Renewable'
        );

        insert product;
        return product;
    }
    
    /////////CPQ Test Coverage End ///////
    
}