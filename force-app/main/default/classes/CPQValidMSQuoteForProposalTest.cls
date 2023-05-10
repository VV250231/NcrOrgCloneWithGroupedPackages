@isTest
public class CPQValidMSQuoteForProposalTest {
    @isTest 
    private static void getQulifiedQuotesForProposal(){
        Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = TestRecordsFactory.createAccount('Test Account',Null);
        Account deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '1', null);
        
         SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            Deliver_To_Site__c = deliverToSite.id,
             qtc_Multi_Site__c=true,
             qtc_Multi_Site_Type__c = 'AE Only',
             qtc_Multi_Site_Relationship__c='Parent'
        );
 		insert masterQuote;
        
        Contract testContract = new Contract(
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
            qtc_Multi_Site_Relationship__c='Parent'
        );
        insert amendQuote;
        
        List<ID> quoteIds = new List<ID>();
        quoteIds.add(amendQuote.Id);
        List<ID> quoteIdsParent = new List<ID>();
        quoteIdsParent.add(masterQuote.Id);
        Test.startTest();
        CPQValidMSQuoteForProposal.getQulifiedQuotesForProposal(quoteIds);
        CPQValidMSQuoteForProposal.getQulifiedQuotesForProposal(quoteIdsParent);
        Test.stopTest();
    }
}