@isTest
public class BackUp_Account_NPS_Score_Test {
 @isTest
    private static void UnitTestMethod(){
        Account acc = TestRecordsFactory.createAccount();
        acc.NPS__c=9;
        update acc;
        List<Account> accList = [SELECT Id, NPS__c,Previous_Year_NPS__c,X2_years_old_NPS__c FROM Account WHERE NPS__c != null Limit 1];
        Test.startTest();
        BackUp_Account_NPS_Score nps = new BackUp_Account_NPS_Score();
        Id batchId = Database.executeBatch(nps);
        Test.stopTest();
    }
}