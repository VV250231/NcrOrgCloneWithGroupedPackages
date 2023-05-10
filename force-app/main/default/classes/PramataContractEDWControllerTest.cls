@isTest
public class PramataContractEDWControllerTest 
{
    testMethod static  void testPramata()
    {	
        
        List<Account> pramata = new List<Account>();
        Account test1 = new Account();
        test1.Name = 'Test Account for Pramata';
        Test.startTest();
        system.runAs(TestRecordsFactory.getUser()){Insert test1;}
        Pramata_Contracts_EDW__c PramataTest = new Pramata_Contracts_EDW__c(Account_Master_Lookup__c = test1.Id,Pramata_Contract_Status__c ='Current');
        insert PramataTest;
        PramataContractEDWController.pramataGetData(test1.Id);
        System.assertNotEquals(PramataTest.id, null,'PramataTest is Null');  
        Test.stopTest();
    }
    
}