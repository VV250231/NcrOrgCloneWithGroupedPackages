@isTest
public class AutoPopulateProcessIntanceTest {
    @TestSetup static void testDataSetup(){
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
        accountRecord.Partner_Industry__c ='Financial;Hospitality;Travel;Telecom & Technology;Retail';
        User soupUser = [Select Id from User WHERE Name = 'Soup User'];
        System.runAs(soupUser) {
            Insert accountRecord;
        }
        // Creating a Contact
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;
    }
    @isTest
    public static void schedulerClassCoverage(){
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        Test.startTest();
        System.runas(userRecord) {  
            Deal_Registration__c dealRegistrationRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Created');
            dealRegistrationRecord.Is_Workflow_Scheduled_for_Sales_Leader__c = FALSE;
            Insert dealRegistrationRecord;
            PRM_DealRegistrationController.submitDRForApproval(dealRegistrationRecord.Id, 'Test');
            Test.stopTest();
        }
        
        AutoPopulateProcessInstanceScheduler ref = new AutoPopulateProcessInstanceScheduler();
        String sch = '0 0 * * * ?'; 
        System.schedule('Test Territory Check', sch, ref);
        
        System.assertEquals(FALSE, [SELECT Is_Workflow_Scheduled_for_Sales_Leader__c FROM Deal_Registration__c LIMIT 1].Is_Workflow_Scheduled_for_Sales_Leader__c);
    }
    @isTest
    public static void batchClassCoverage(){
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        Test.startTest();
        System.runas(userRecord) {  
            Deal_Registration__c dealRegistrationRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Created');
            dealRegistrationRecord.Is_Workflow_Scheduled_for_Sales_Leader__c = FALSE;
            Insert dealRegistrationRecord;
            PRM_DealRegistrationController.submitDRForApproval(dealRegistrationRecord.Id, 'Test');
            Test.stopTest();
        }
        AutoPopulateProcessInstance batch = new AutoPopulateProcessInstance();
        Database.executeBatch(batch);
        System.assertEquals(FALSE, [SELECT Is_Workflow_Scheduled_for_Sales_Leader__c FROM Deal_Registration__c LIMIT 1].Is_Workflow_Scheduled_for_Sales_Leader__c);
    }
}