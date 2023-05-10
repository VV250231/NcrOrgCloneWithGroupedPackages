@isTest
public with sharing class PRM_BenefitActionPacksControllerTest {

   @testSetup
    public static void testDataSetup(){
        
        //Creating an account.
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];
        
        System.runAS(accountUsere){
            Insert accountRecord;
        }
         
        // Creating a Contact
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;

        List<Channel_Benefit_Action_Packs__c> benefitActionPackslist = new List <Channel_Benefit_Action_Packs__c>();
        benefitActionPackslist.add(PRM_TestRecordsFactory.createBenefitActionPacks( 'Test Label 1', 1,'Sales and Marketing', 'Sales and Marketing description 1','www.google.com'));
        benefitActionPackslist.add(PRM_TestRecordsFactory.createBenefitActionPacks( 'Test Label 2', 2,'Sales and Marketing', 'Sales and Marketing description 2','www.google.com'));
        benefitActionPackslist.add(PRM_TestRecordsFactory.createBenefitActionPacks( 'Test Label 3', 1,'Services', 'Services description','www.google.com'));
        Insert benefitActionPackslist; 
    }

    @isTest
    public static void getChannelBenefitActionPackMap_Test(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 

        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        system.assert(contactRecord.Id!=null);

        Test.startTest();

        System.runas(userRecord) { 
            Map<String,List<Channel_Benefit_Action_Packs__c>> benefitActionPacksMap  = PRM_BenefitActionPacksController.getChannelBenefitActionPackMap();
        }

        Test.stopTest();

    }

}