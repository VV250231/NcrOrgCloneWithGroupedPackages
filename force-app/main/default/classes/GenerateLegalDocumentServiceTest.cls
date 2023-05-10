@isTest
public class GenerateLegalDocumentServiceTest implements HttpCalloutMock{
    
     
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"UserResponseABM":{"UserResponse":{"Message":"User created successfully test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test testtest test test test test test test test test test test test test test test test test test test test test test test test test test test test test test test tes."},"ResponseHeader":{"Status":"SUCCESS","Timestamp":"2021-01-25T04:03:49.305-05:00","TransactionID":"0090f804-76ca-4fff-98d8-6dfc27e9af99"}}}');
        response.setStatusCode(200);
        return response; 
    } 
    @isTest static  void creditAppTest(){ 
        Account a =TestRecordsFactory.createAccount();
        Contact c= TestRecordsFactory.createContact(a);
      Opportunity opp1 = GenerateLegalDocumentServiceTest.getOpportunity(a, c);
           
        Opportunity o1= GenerateLegalDocumentService.validateGenerateCreditApplication(opp1.id);
        System.assertEquals(opp1.id, o1.id);
    }
    @isTest static  void createNewUserTest(){ 
        CPQMyNcrRequestAsync.bypassQuoteTrigger=true;
        Account a =TestRecordsFactory.createAccount();
        Contact c= TestRecordsFactory.createContact(a);
        SBQQ__Quote__c quo = new SBQQ__Quote__c();
        quo.SBQQ__PrimaryContact__c = c.id;
        insert quo;
        String OrderFormNote='Test';
        test.startTest();
        GenerateLegalDocumentService.validateCreditApplicationStatus(quo.id);
        GenerateLegalDocumentService.newUser(quo.id);
        String msg = GenerateLegalDocumentService.SaveACHContactOnQuote(c.id,quo.id);
        Contact c1 = new Contact();
        c1.Accountid = a.id;
        c1.LastName = 'test1';
        c1.Email = 'test2@test.com';
        c1.Business_Function__c = 'Marketing';
        if(a.Subscription_Group__c == 'Digital Insight') {
            c1.Additional_Relationships__c = 'Digital Insight';
        }
        insert c1;
        //AccountContactRelation contactR = new AccountContactRelation(ContactId =c1.Id, AccountId=a.id);
        //insert contactR;
        GenerateLegalDocumentService.GetAllACHContacts(a.id);
        GenerateLegalDocumentService.getMultiSiteQuote(quo.id);
       // GenerateLegalDocumentService.SaveOrderFormNoteOnQuote(OrderFormNote, quo.id);
        test.stopTest();
        system.assertNotEquals(msg, null); 
    }
    @isTest static  void createNewUserTest1(){ 
        CPQMyNcrRequestAsync.bypassQuoteTrigger=true;
        Account a =TestRecordsFactory.createAccount();
        Contact c= TestRecordsFactory.createContact(a);
        SBQQ__Quote__c quo = new SBQQ__Quote__c();
        quo.SBQQ__PrimaryContact__c = c.id;
        insert quo;
        SBQQ__Quote__c quo1 =GenerateLegalDocumentService.validateCreditApplicationStatus(quo.id);
        SOUP_Endpoint__c customSettingObj = new SOUP_Endpoint__c();
        customSettingObj.Name='Autopay';
        customSettingObj.Endpoint_URL__c='https://osbcert-ha.ncr.com/ext/ea/services/MyNCR/Payment/api/createUser';
        customSettingObj.Username__c='sa231082';
        customSettingObj.Password__c='hzt$A46HprByVSDw85TC@EGKb&kjL#';
        insert  customSettingObj;
        Test.setMock(HttpCalloutMock.class, new GenerateLegalDocumentServiceTest());     
        test.startTest();
        GenerateLegalDocumentService.newUser(quo.id);
        System.assertEquals(quo.id, quo1.id);
        test.stopTest();
    }
    
     private static Customer_Document__c getCLMDoc(Id quoteId, Id accountId){
       // Account testAccount = TestRecordsFactory.createAccount('Test Account',Null);
        Customer_Document__c doc = new Customer_Document__c(
            Account__c = accountId,
        	Quote__c = quoteId,
        	Document_Type__c = 'AE Order Form',
        	Document_Status__c = 'Sent for Signature');
        insert doc;
        return doc;
    }
    @isTest
    static void getQuotesWithCLMDocTest(){
        Integer prorationDayOfMonth = 25;
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Account testAccount;
        Account deliverToSite;
        
        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        
        System.runAs(CPQ_TestDataFactory.getSoupUser()){ 
            
            testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            
            insert deliverToSite;
        }
        
        SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false,
            qtc_Legal_Document_Status__c='Sent for Signature'
        );
        insert masterQuote;
        Customer_Document__c docMasterQuote = GenerateLegalDocumentServiceTest.getCLMDoc(masterQuote.Id,testAccount.Id);
        
        SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Child',
            qtc_Multi_Site_Parent_Quote__c = masterQuote.id,
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
        insert childQuote;
        Customer_Document__c docChildQuote = GenerateLegalDocumentServiceTest.getCLMDoc(childQuote.Id,testAccount.Id);
        Test.startTest();
        Map<String,String> mp = GenerateLegalDocumentService.getQuotesWithCLMDoc(childQuote);
        GenerateLegalDocumentService.getQuotesWithCLMDoc(masterQuote);
        Test.stopTest();
        system.assert(mp != null ,'Ouote not returned'); 
        
    }
    
    @isTest
    public static void testResendAutoPayRequest(){
        //List<Account> a = [SELECT ID FROM ACCOUNT WHERE NAME= 'TestAccountContract' LIMIT 1];
        //List<CONTACT> c = [SELECT ID FROM CONTACT WHERE Email ='pqr@pqr.com.invalid' LIMIT 1];
        Map<String,String> fieldApiNameToFieldValue = new Map<String,String>();
        fieldApiNameToFieldValue.put('MDM_Enterprise_Nbr__c', 'Test EE');
        fieldApiNameToFieldValue.put('MDM_Customer_Entity_Nbr__c', 'Test CE');
        Account a = CPQ_TestDataFactory.createAccount('Test Account',fieldApiNameToFieldValue);
        Contact c=  CPQ_TestDataFactory.createContact(a.id,'Test Contact',Null);
        User soupUser = TestRecordsFactory.getUser();
        System.runAs( soupUser ){
            insert a;
        }
        c.email = 'test@pqr.com';
        insert c;
        List<Id> Ids = new List<Id>();
        List<List<Id>> Ids1 = new List<List<Id>>();
        Ids.add(a.Id);
        Ids.add(c.Id);
        Ids1.add(Ids);
        //Test.setMock(HttpCalloutMock.class, new GenerateLegalDocumentServiceTest()); 
        test.startTest();
        List<String> st = GenerateLegalDocumentService.invokeResendAutoPayRequest(Ids1);
        test.stopTest();
        system.assert(st != null ,'Ids not returned'); 
    }
    
    @isTest
    public static void testrequestToMYNCR(){
        Integer prorationDayOfMonth = 25;
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Account testAccount;
        Account deliverToSite;
         Account billToSite;
         Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        
        System.runAs(CPQ_TestDataFactory.getSoupUser()){ 
            
            testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            billToSite =  CPQ_TestDataFactory.createSite(testAccount, '2', null);
            
            insert deliverToSite;
            insert billToSite;
        }
         Contact c= TestRecordsFactory.createContact(testAccount);
        
        SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true
        );
        insert masterQuote;
        Customer_Document__c docMasterQuote = GenerateLegalDocumentServiceTest.getCLMDoc(masterQuote.Id,testAccount.Id);
        test.startTest();
        masterQuote.qtc_Bill_To_Site__c = billToSite.Id;
        update masterQuote;
        test.stopTest();
        system.assert(masterQuote.qtc_Bill_To_Site__c != null ,'Ids not returned');
    }
    
    @isTest
    public static void testRequestToMyNCRFromOrder(){
        Integer prorationDayOfMonth = 25;
        Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;
        Account testAccount;
        Account deliverToSite;
         Account billToSite;
         Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        
        
        System.runAs(CPQ_TestDataFactory.getSoupUser()){ 
            
            testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
            insert testAccount;
            deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
            billToSite =  CPQ_TestDataFactory.createSite(testAccount, '2', null);
            
            insert deliverToSite;
            insert billToSite;
        }
         Contact c= TestRecordsFactory.createContact(testAccount);
         Opportunity opp1 = GenerateLegalDocumentServiceTest.getOpportunity(testAccount, c);
         
        SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c=opp1.Id,
            SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Bill_To_Site__c=deliverToSite.id,
            qtc_Ship_To_Account__c=deliverToSite.id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true
        );
        insert masterQuote;
        Customer_Document__c docMasterQuote = GenerateLegalDocumentServiceTest.getCLMDoc(masterQuote.Id,testAccount.Id);
        opp1.SBQQ__PrimaryQuote__c =  masterQuote.Id;
        update opp1;
        Order o = new Order( 
            Status = 'Draft',
            Type='New',
            OpportunityId = opp1.Id,
            blng__BillingAccount__c = testAccount.Id,
            AccountId = testAccount.Id,
             SBQQ__Quote__c=masterQuote.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today() + 60,
            blng__BillingDayOfMonth__c = '1',
            qtc_Bill_To_Site__c=deliverToSite.Id,
             Deliver_To_Site__c=deliverToSite.Id,
             qtc_Ship_To_Account__c=deliverToSite.Id,
            BillToContactId = c.id,
            ShipToContactId = c.Id
        );
        insert o;
        Test.startTest();
        o.qtc_Bill_To_Site__c = billToSite.Id;
        update o;
        Test.stopTest();
        system.assert(o.qtc_Bill_To_Site__c != null ,'Ids not returned'); 

    }
    
    private static Opportunity getOpportunity( Account a, Contact c ){
        Opportunity opp1 = new Opportunity();
		opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        opp1.name = 'OpportunityForMultiSiteQuote';
        opp1.AccountID = a.id;
        opp1.stagename = 'Analyzing';
        opp1.Contacts__c = c.Id; // Primary Contact
    //    opp1.Channel_Office__c = partAct.Id;
        opp1.closeDate = System.TODAY();
        opp1.type = 'New Customer';
        opp1.INVOICE_TRIGGER__C = 'Shipment';
        opp1.Forecast_Category__c = 'Pipeline';
        opp1.ForecastCategoryName = 'Pipeline';
        opp1.LeadSource = 'Email';
        opp1.CPQ__c = true;
        opp1.CURRENCYISOCODE = 'USD';      
        opp1.Skip_Validation_Rule_for_Lead_Conversion__c = true;
        insert opp1;
        
        return opp1;
    }
    
    @isTest
    public static void testValidateAccount(){
        
        Account a =TestRecordsFactory.createAccount();
        Contact c= TestRecordsFactory.createContact(a);
        Opportunity opp = new Opportunity();
        a.MDM_Enterprise_Nbr__c = null;
        a.MDM_Customer_Entity_Nbr__c = null;
        c.email = 'pqr@pqr.com';
        GenerateLegalDocumentService.validateAccount(a,c);
        
        a.MDM_Enterprise_Nbr__c = 'Test';
        a.MDM_Customer_Entity_Nbr__c = null;
        c.email = 'pqr@pqr.com';
        GenerateLegalDocumentService.validateAccount(a,c);
        
        a.MDM_Enterprise_Nbr__c = 'EE_PENDING';
        a.MDM_Customer_Entity_Nbr__c = 'CE_PENDING';
        c.email = 'pqr@pqr.com';
        GenerateLegalDocumentService.validateAccount(a,c);
        
        a.MDM_Enterprise_Nbr__c = 'Test';
        a.MDM_Customer_Entity_Nbr__c = 'CE_PENDING';
        c.email = 'pqr@pqr.com';
        GenerateLegalDocumentService.validateAccount(a,c);
        
        a.MDM_Enterprise_Nbr__c = 'Test';
        a.MDM_Customer_Entity_Nbr__c = 'Test';
        c.email = 'pqr@pqr.com';
        GenerateLegalDocumentService.validateAccount(a,c);
        
         SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c=opp.Id,
            SBQQ__Account__c = a.Id,
            ACH_Recipient__c=c.id,
            SBQQ__Type__c = 'Quote',
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true
        );
         GenerateLegalDocumentService.getAccountOfEnterpriseUI(quote);
    }
	 @isTest
    public static void testSaveQuoteFields(){
         Account a =TestRecordsFactory.createAccount();
         Contact c= TestRecordsFactory.createContact(a);
         Opportunity opp = new Opportunity();
         SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c=opp.Id,
            SBQQ__Account__c = a.Id,
            ACH_Recipient__c=c.id,
            SBQQ__Type__c = 'Quote',
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true
        );
        insert quote;
        GenerateLegalDocumentService.SaveQuoteFields('Order Notes',quote.id);
    }
    @isTest
    public static void testcreateLogsNew(){
         Account a =TestRecordsFactory.createAccount();
    	GenerateLegalDocumentService.createLogsNew(a, null,null, null, null,null, null);
    }
}