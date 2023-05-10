@isTest

public class Cpq_UpdtOppStgOnDocExpireTest {
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
        
     Customer_Document__c Custdoc  = NEW Customer_Document__c(
        Account__c = acc.id,
       Quote__c = quote.Id,
       Document_Type__c = 'AE ORDER FORM', 
        Document_Sent_Date__c = System.Today() - 200);
         
        insert Custdoc;

}

    @isTest
    public static void batchTest(){
        Test.StartTest();
        acc = [select id from Account LIMIT 1];
        opp1 = new Opportunity();
         opp1  = TestRecordsFactory.createSimpleOpportunity(acc);
          opp1.closeDate = System.TODAY()- 200;
         opp1.CPQ__c = TRUE;
        opp1.Closed_Lost_Comments__c = 'test';
         update opp1;
      
    
         SBQQ__Quote__c quote1 = new SBQQ__Quote__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__Opportunity2__c = opp1.Id,
            SBQQ__Primary__c=true);
        insert quote1;
         Customer_Document__c Custdoc11  = NEW Customer_Document__c(
        Account__c = acc.id,
        Quote__c = quote1.Id,
       Document_Type__c = 'AE ORDER FORM', 
        Document_Sent_Date__c = System.Today() - 200);
         
        insert Custdoc11;
        String cron = '0 0 10 ? * *';
        String jobID = System.schedule('Cpq_UpdtOppStgOnDocExpire', cron, new Cpq_UpdtOppStgOnDocExpireSchedular());
         Test.StopTest();
    }
     
    
}