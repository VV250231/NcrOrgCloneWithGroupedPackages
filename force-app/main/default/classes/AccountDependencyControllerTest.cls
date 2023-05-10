@isTest //(SeeAllData=true)
private class AccountDependencyControllerTest {
    
    static testMethod void myTest() {
        Account acc=TestRecordsFactory.createAccount();
        Contact c =  TestRecordsFactory.createContact(acc);
        acc = [Select Id, Name, Master_Customer_Number__c, Account_Country_Code__c FROM Account WHERE Id = :acc.Id limit 1];
        
        Opportunity opp = TestRecordsFactory.createOpportunity(acc);
        opp.StageName='Closed/Lost';
        opp.Are_we_the_Incumbent__c='Test';
        opp.Closed_Lost_Comments__c='Test';
        opp.Lose_to_a_Competitor__c='Test';
        opp.Primary_Loss_Reason__c='Test';
        opp.Primary_Product_Type__c='HW';
        update opp;
        Analysis_Acc_Master__c am = new Analysis_Acc_Master__c(Input_Account_Id__c = acc.Id, Input_Master_Customer_Number__c = acc.Master_Customer_Number__c, Input_Operating_Unit__c = acc.Account_Country_Code__c, CheckAddress__c = true);
        insert am;
        System.debug('@@@@'+am.Input_Account_Id__c);
        //new AccountDependencyController().codeCoverage();
        
        Test.startTest();
        AccountDependencyController accdep = new AccountDependencyController();
        AccountDependencyController accdepTrue = new AccountDependencyController(true);
        Database.executeBatch(accdep); 
        System.assertEquals(1, [Select count() from Analysis_Acc_Master__c where CheckAddress__c=true]);
        
        //Database.executeBatch(new AccountAddressFinder());
        Test.stopTest();
    }
      static testMethod void myTest1() {
        Account acc=TestRecordsFactory.createAccount();
        Contact c =  TestRecordsFactory.createContact(acc);
        acc = [Select Id, Name, Master_Customer_Number__c, Account_Country_Code__c FROM Account WHERE Id = :acc.Id limit 1];
        
        Opportunity opp = TestRecordsFactory.createOpportunity(acc);
       
        Analysis_Acc_Master__c am = new Analysis_Acc_Master__c(Input_Account_Id__c = acc.Id, Input_Master_Customer_Number__c = acc.Master_Customer_Number__c, Input_Operating_Unit__c = acc.Account_Country_Code__c, CheckAddress__c = true);
        insert am;
        System.debug('@@@@'+am.Input_Account_Id__c);
        //new AccountDependencyController().codeCoverage();
        
        Test.startTest();
        AccountDependencyController accdep = new AccountDependencyController();
        AccountDependencyController accdepTrue = new AccountDependencyController(true);
        Database.executeBatch(accdep); 
        System.assertEquals(1, [Select count() from Analysis_Acc_Master__c where CheckAddress__c=true]);
        //Database.executeBatch(new AccountAddressFinder());
        Test.stopTest();
    }
    
}