@isTest
public class CPQ_QuotesNotYetSignedTest {
    
    private static Customer_Document__c getCLMDoc(Id quoteId){
        Account testAccount = TestRecordsFactory.createAccount('Test Account',Null);
        Customer_Document__c doc = new Customer_Document__c(
            Account__c = testAccount.id,
        	Quote__c = quoteId,
        	Document_Type__c = 'AE Amendment',
        	Document_Status__c = 'Sent for Signature');
        insert doc;
        return doc;
    }
    
	@isTest
    private static void  getNotSignedQuotesTest(){
        Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
        insert testAccount;
        Account deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
        insert deliverToSite;
   
        
         SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
              SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Bill_To_Site__c =deliverToSite.Id,
            Deliver_To_Site__c =deliverToSite.Id,
            qtc_Ship_To_Account__c =deliverToSite.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
 		insert masterQuote;
        
         SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
              SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Bill_To_Site__c =deliverToSite.Id,
            Deliver_To_Site__c =deliverToSite.Id,
            qtc_Ship_To_Account__c =deliverToSite.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Child',
            qtc_Multi_Site_Parent_Quote__c = masterQuote.id,
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
 		insert childQuote;
        
     
        Test.startTest();
        CPQ_QuotesNotYetSigned.getNotSignedQuotes(masterQuote.id);
        Test.stopTest();
    }
    @isTest
    private static void  getQuotesWithCLMDocTest(){
         Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
        insert testAccount;
        Account deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
        insert deliverToSite;
        
         SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
              SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Bill_To_Site__c =deliverToSite.Id,
            Deliver_To_Site__c =deliverToSite.Id,
            qtc_Ship_To_Account__c =deliverToSite.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
 		insert masterQuote;
        Customer_Document__c docMasterQuote = CPQ_QuotesNotYetSignedTest.getCLMDoc(masterQuote.Id);
        
         SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
              SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Bill_To_Site__c =deliverToSite.Id,
            Deliver_To_Site__c =deliverToSite.Id,
            qtc_Ship_To_Account__c =deliverToSite.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Child',
            qtc_Multi_Site_Parent_Quote__c = masterQuote.id,
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
 		insert childQuote;
        Customer_Document__c docChildQuote = CPQ_QuotesNotYetSignedTest.getCLMDoc(childQuote.Id);
        
       /* Contract testContract = new Contract(
            StartDate = startDate,
            AccountId=testAccount.Id,
            SBQQ__Quote__c=masterQuote.Id
            );
        insert testContract;
        
         List<SBQQ__Quote__c> quoteLst = [ 	SELECT Id, Name
                							FROM SBQQ__Quote__c
                							WHERE Id =: masterQuote.Id
                							LIMIT 1 ];

        SBQQ__Quote__c amendQuote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            SBQQ__MasterContract__c = testContract.Id,
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Amendment',
            Deliver_To_Site__c = deliverToSite.id,
            qtc_Original_Quote_Number__c=quoteLst[0].Name,
            SBQQ__OriginalQuote__c=quoteLst[0].Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
        insert amendQuote;
        Customer_Document__c docAmendQuote = CPQ_QuotesNotYetSignedTest.getCLMDoc(amendQuote.Id);
      */  
        Test.startTest();
        CPQ_QuotesNotYetSigned.getQuote(masterQuote.id);
        CPQ_QuotesNotYetSigned.getQuotesWithCLMDoc(masterQuote);
        CPQ_QuotesNotYetSigned.getQuotesWithCLMDoc(childQuote);
        Test.stopTest();
    }
}