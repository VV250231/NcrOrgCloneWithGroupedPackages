/*******
* This test class includes coverage for Apex class CPQQuoteExpiringJob,CPQQuotesToExpireRecords and Cpq_UpdtOppStgOnDocExpire
* Created By: Dharmendra Kumar Pandey
* Created Date: 20-AUG-2022
* 
**************/
@isTest
public class CPQQuoteExpireJobTest {
    private static final Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();
    static Account acc;
    static Opportunity opp;
    static Opportunity opp1;
    static SBQQ__Quote__c quote;
    static SBQQ__Quote__c quote1;
    
    @testSetup
    static void  setupTestData(){
        acc  = TestRecordsFactory.createAccount();
        opp  = TestRecordsFactory.createSimpleOpportunity(acc);
        opp.closeDate = System.TODAY()- 200;
        opp.CPQ__c = TRUE;
        update opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__Opportunity2__c = opp.Id, 
            SBQQ__Primary__c=true);
        insert quote;
        
        Customer_Document__c custdoc  = NEW Customer_Document__c(
            Account__c = acc.id,
            Quote__c = quote.Id,
            Document_Type__c = 'AE ORDER FORM', 
            Document_Sent_Date__c = System.Today() - 200);
        
        insert custdoc;
        
    }
    
    /***
     * To test cases
     * 1- Quote expire job run ==> Quotes to be expired and fullfillment order Quote Expired, if expire condition passed
     * 
     * 
     ****/
    
    //Case tested: Quote Expire after opportunity Closed/Lost Manually      
    @isTest
    public static void oppCloseTest(){
        acc = [select id from Account LIMIT 1];
 		opp = [Select id, StageName,ForecastCategoryName,Closed_Lost_Comments__c,Are_we_the_Incumbent__c,Lose_to_a_Competitor__c,
               Primary_Loss_Reason__c,qtc_auto_closedlost__c,Primary_Product_Type__c from Opportunity limit 1]; 
        opp.StageName='Closed/Lost';
        opp.ForecastCategoryName = 'Omitted';
        opp.Closed_Lost_Comments__c = 'test3';
        opp.Are_we_the_Incumbent__c='No';
        opp.Lose_to_a_Competitor__c = 'No';
        opp.Primary_Loss_Reason__c ='Non Responsive';
        opp.qtc_auto_closedlost__c = false;
        opp.Primary_Product_Type__c = 'HW';
        Test.startTest();
        update opp;
        System.assert(opp.StageName=='Closed/Lost','opp should close lost');
        Test.stopTest();
    }
    
    /***
     * To test cases
     * 1- Manually Opp made close/lost ==> all linked quotes expired if pass expire condition
     * 2- Opp Close Lost Job run ==> Find quotes expired and close opp if pass close/lost condition
     * 
     ****/
    @isTest
    public static void oppTest(){
        Test.StartTest();
        acc = [select id from Account LIMIT 1];
        opp1 = new Opportunity();
        opp1  = TestRecordsFactory.createSimpleOpportunity(acc);
        opp1.closeDate = System.TODAY()- 200;
        opp1.CPQ__c = true;
       // opp1.IsClosed=false;
        opp1.Closed_Lost_Comments__c = 'test';
        update opp1;
        
        //Case tested:Opportunity Closed Lost after Quote Expired 150
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__Opportunity2__c = opp1.Id,
            SBQQ__Primary__c=true
            //SBQQ__Status__c = 'Expired',
        	//SBQQ__ExpirationDate__c= System.TODAY()- 200
        	);
        insert quote1;
        quote1.SBQQ__Status__c='Expired';
        quote1.SBQQ__ExpirationDate__c = System.TODAY()- 200;
        update quote1;
            
        Customer_Document__c custdoc11  = NEW Customer_Document__c(
            Account__c = acc.id,
            Quote__c = quote1.Id,
            Document_Type__c = 'AE ORDER FORM', 
            Document_Sent_Date__c = System.Today() - 200);
        
        insert custdoc11;

		//Case tested: Quote Expire after expire date passed        
        Opportunity opp2 = new Opportunity();
        opp2  = TestRecordsFactory.createSimpleOpportunity(acc);
        opp2.CPQ__c = true;
        update opp2;
         SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__Opportunity2__c = opp2.Id,
            SBQQ__Primary__c=true
        	);
        insert quote2;
        quote2.SBQQ__ExpirationDate__c = System.TODAY()- 200;
        update quote2;
        
        String cron = '0 0 10 ? * *';
        String jobID = System.schedule('Cpq_UpdtOppStgOnDocExpire Test Only', cron, new Cpq_UpdtOppStgOnDocExpireSchedular());
        System.debug('opp close/lost jobID:'+jobID);
        
        CPQQuoteExpiringJob qc = new CPQQuoteExpiringJob();
        database.executebatch(qc,5);
        
        Cpq_UpdtOppStgOnDocExpire c = new Cpq_UpdtOppStgOnDocExpire();
        database.executebatch(c,10);

        SBQQ__Quote__c q = [Select id,Name,SBQQ__Opportunity2__r.CPQ__c,SBQQ__Primary__c,SBQQ__Opportunity2__r.IsClosed,SBQQ__Opportunity2__r.CloseDate,SBQQ__Status__c,SBQQ__ExpirationDate__c,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Id,SBQQ__Opportunity2__r.Primary_Loss_Reason__c,SBQQ__Opportunity2__r.StageName from SBQQ__Quote__c where id =:quote1.ID];
        System.Debug('q.SBQQ__ExpirationDate__c:'+q.SBQQ__ExpirationDate__c+' q.SBQQ__Status__c:'+q.SBQQ__Status__c+' SBQQ__Primary__c:'+q.SBQQ__Primary__c+
                     ' SBQQ__Status__c:'+q.SBQQ__Status__c+' SBQQ__ExpirationDate__c:'+q.SBQQ__ExpirationDate__c+' SBQQ__Opportunity2__r.CPQ__c:'+
                     q.SBQQ__Opportunity2__r.CPQ__c+' SBQQ__Opportunity2__r.IsClosed:'+q.SBQQ__Opportunity2__r.IsClosed+' SBQQ__Opportunity2__r.CloseDate:'+
                     q.SBQQ__Opportunity2__r.CloseDate);
		Test.StopTest();
       //System.assert(opp1.StageName=='Closed/Lost','opp should close lost');
       
    }

    @IsTest
    static void retrieveQuotesTest(){
        
       // Test.startTest();
            acc = [select id from Account LIMIT 1];
            Opportunity opp2 = new Opportunity();
            opp2  = TestRecordsFactory.createSimpleOpportunity(acc);
            opp2.CPQ__c = true;
            update opp2;
             SBQQ__Quote__c quote2 = new SBQQ__Quote__c(
                SBQQ__Account__c = acc.Id,
                SBQQ__Opportunity2__c = opp2.Id,
                SBQQ__Primary__c=true
                );
            insert quote2;
            quote2.SBQQ__ExpirationDate__c = System.TODAY()+ 2;

            quote2.SBQQ__SalesRep__c = UserInfo.getUserId();
            update quote2;

            SBQQ__Quote__c q = [Select id,Name,SBQQ__Opportunity2__r.CPQ__c,SBQQ__Primary__c,SBQQ__Opportunity2__r.IsClosed,SBQQ__Opportunity2__r.CloseDate,SBQQ__Status__c,SBQQ__ExpirationDate__c,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Id,SBQQ__Opportunity2__r.Primary_Loss_Reason__c,SBQQ__Opportunity2__r.StageName from SBQQ__Quote__c where id =:quote2.ID];
            System.Debug('q.SBQQ__ExpirationDate__c:'+q.SBQQ__ExpirationDate__c+' q.SBQQ__Status__c:'+q.SBQQ__Status__c+' SBQQ__Primary__c:'+q.SBQQ__Primary__c+
                         ' SBQQ__Status__c:'+q.SBQQ__Status__c+' SBQQ__ExpirationDate__c:'+q.SBQQ__ExpirationDate__c+' SBQQ__Opportunity2__r.CPQ__c:'+
                         q.SBQQ__Opportunity2__r.CPQ__c+' SBQQ__Opportunity2__r.IsClosed:'+q.SBQQ__Opportunity2__r.IsClosed+' SBQQ__Opportunity2__r.CloseDate:'+
                         q.SBQQ__Opportunity2__r.CloseDate);

            QuoteListWrapper qlw = CPQQuotesToExpireRecords.retrieveQuotes1(UserInfo.getUserId());
            List<SBQQ__Quote__c> lstQ = qlw.quotetList;
            
            System.assert(lstQ.size()>0,'quotes expected');

            SBQQ__Quote__c qt = CPQQuotesToExpireRecords.getQuote(quote2.Id);

            System.assert(qt!=null,'no quoe found');

         //   Test.stopTest();
        
    }
    
    
}