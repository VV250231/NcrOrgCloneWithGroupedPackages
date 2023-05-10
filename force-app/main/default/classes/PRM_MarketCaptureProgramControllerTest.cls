@isTest
public with sharing class PRM_MarketCaptureProgramControllerTest {

    @testSetup
    public static void testDataSetup(){
        
        //Creating an account.
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null); 
        accountRecord.Partner_Industry__c ='Hospitality;Financial';
        
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];        
        System.runAS(accountUsere){
            Insert accountRecord;
        }
        
        // Creating a Contact
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;


        //Creating Market Share Captures List 
        List <Market_Share_Captures__c> marketShareCapturesList = new List <Market_Share_Captures__c>();
        marketShareCapturesList.add(PRM_TestRecordsFactory.createMarketShareCaptures('Retail','test Retail Desc one','http://testurl.com'));
        marketShareCapturesList.add(PRM_TestRecordsFactory.createMarketShareCaptures('Retail','test Retail Desc Two','http://testurl.com'));
        marketShareCapturesList.add(PRM_TestRecordsFactory.createMarketShareCaptures('Financial','test Financial Desc one','http://testurl.com'));
        marketShareCapturesList.add(PRM_TestRecordsFactory.createMarketShareCaptures('Financial','test Financial Desc Two','http://testurl.com'));
        marketShareCapturesList.add(PRM_TestRecordsFactory.createMarketShareCaptures('Hospitality','test Hospitality Desc','http://testurl.com'));

        //Insert DML on Market Share Captures  
        Insert marketShareCapturesList;

    }

    @isTest
    public static void getMarketShareCaptureMap_Test(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 

        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        

        Test.startTest();

        System.runas(userRecord) { 
            Map<String, List<PRM_MarketCaptureProgramController.MarketCaptureProgram>> marketCaptureProgramMap  = PRM_MarketCaptureProgramController.getMarketShareCaptureMap();
            system.assert(marketCaptureProgramMap.size() >0);
        }

        Test.stopTest();

    }

}