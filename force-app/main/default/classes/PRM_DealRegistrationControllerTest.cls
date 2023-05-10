@isTest
public class PRM_DealRegistrationControllerTest{

    @testSetup
    public static void testDataSetup(){
        //Creating an account.
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
        accountRecord.Partner_Industry__c ='Financial;Hospitality;Travel;Telecom & Technology;Retail';
        system.runAs(TestRecordsFactory.getUser()){ 
        	insert accountRecord;
        }

        // Creating a Contact
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;

        //Creating Deal Registration
        List<Deal_Registration__c> dealRegistrationList = new List<Deal_Registration__c>();
        dealRegistrationList.add(PRM_TestRecordsFactory.createDealRegistration('Test Deal', 'Created'));

        Insert dealRegistrationList;
       
        PRM_DealRegistrationController.DealRegistration('Retail',''); 
    }

     @isTest
     public static void testGetDealRegistration(){
         //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
		system.assert(contactRecord.LastName!=NULL);
        //Creating User
        Test.startTest();
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;

       // Test.startTest();
        System.runas(userRecord) { 
            
            PRM_DealRegistrationController.getDealRegistration('All');
            PRM_DealRegistrationController.getDealRegistration('Created');
        }
        Test.stopTest();
     }


    @isTest
     public static void testDealRegistrationDetail(){
         //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
		system.assert(contactRecord.LastName!=NULL);
        //Creating User
        Test.startTest();
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;

        //Test.startTest();
        System.runas(userRecord) {  
            Deal_Registration__c dealRegistrationRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Created');
            Insert dealRegistrationRecord;
            PRM_DealRegistrationController.getDealRegistrationDetail(dealRegistrationRecord.Id);
            PRM_DealRegistrationController.getEditDetails(dealRegistrationRecord.Id);
        }
        Test.stopTest();
     }

      @isTest
     public static void testSaveDealRegistration(){
         //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
		system.assert(contactRecord.LastName!=NULL);
        //Creating User
         Test.startTest();
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;

       // Test.startTest();
            System.runas(userRecord) {  
                PRM_DealRegistrationController.getPicklistValues();
                PRM_DealRegistrationController.saveDealRegistration(PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Created'), null, null, null, null, null, null,'--None--', '--None--','--None--', '');
            Test.stopTest();
        }
     } 

    @isTest
     public static void testSubmitDRForApproval(){
         //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
		system.assert(contactRecord.LastName!=NULL);
        //Creating User
         Test.startTest();
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;

        //Test.startTest();
            System.runas(userRecord) {  
                Deal_Registration__c dealRegistrationRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Created');
                Insert dealRegistrationRecord;
                PRM_DealRegistrationController.submitDRForApproval(dealRegistrationRecord.Id, 'Test');
            Test.stopTest();
        }
     } 

     @isTest
     public static void testApprovalSubmitForExtension(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
		system.assert(contactRecord.LastName!=NULL);
        //Creating User
        Test.startTest();
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;

        //Test.startTest();
            System.runas(userRecord) {  
                Deal_Registration__c dealRegistrationRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Approved');
                Insert dealRegistrationRecord;
                PRM_DealRegistrationController.approvalSubmitForExtension(dealRegistrationRecord.Id, 'Test');
            Test.stopTest();
        }
     }
      @isTest
     public static void testDistributor(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        contactRecord.Partner_User__c=  UserInfo.getUserId();
        update contactRecord;
         PRM_DealRegistrationController.knowIfDistributorOrNot();
		system.assert(contactRecord.LastName!=NULL);
      
     }
}