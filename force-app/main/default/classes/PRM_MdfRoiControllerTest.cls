@isTest
public class PRM_MdfRoiControllerTest {
    @testSetup
    public static void testDataSetup(){
        
        //Creating an account.
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null); 
        // accountRecord.Partner_Industry__c ='Hospitality;Financial';
        
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];        
        System.runAS(accountUsere){
            Insert accountRecord;
        }
        
        Test.startTest();
        // Creating a Contact
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;
        
        // Creating a fund request 
        SFDC_MDF__c fundRequest = PRM_TestRecordsFactory.createFundRequest('Test Fund',accountRecord.Id,'Approved');
        Insert fundRequest;
        PRM_TestRecordsFactory.insertAttachment(fundRequest.Id,'test attach');
        
        //Creating a fund claim        
        SFDC_MDF_Claim__c fundClaim = PRM_TestRecordsFactory.createFundClaim('Test Claim', accountRecord.Id,fundRequest.Id,'Approved');
        Insert fundClaim;
        PRM_TestRecordsFactory.insertAttachment(fundClaim.Id,'test attach'); 
        Test.stopTest(); 
        
    }
    
    @isTest
    public static void getFundClaimMapTest(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        system.assert(userRecord!=NULL);
        Test.startTest();
        
        System.runas(userRecord) { 
            PRM_MdfRoiController.getFundClaimMap();
            List <SFDC_MDF_Claim__c> claimList = PRM_PartnerClaimsList.getPartnerClaimList();
        }
        
        Test.stopTest(); 
    } 
    
    @isTest
    public static void mdfDetailRecordTest(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        
        Test.startTest();
        
        System.runas(userRecord) { 
            // Creating a fund request 
            SFDC_MDF__c fundRequest = PRM_TestRecordsFactory.createFundRequest('Test Fund1',contactRecord.AccountId,'Approved');
            Insert fundRequest;
            
            //Creating a fund claim        
            SFDC_MDF_Claim__c fundClaim = PRM_TestRecordsFactory.createFundClaim('Test Claim1', contactRecord.AccountId,fundRequest.Id,'Approved');
            Insert fundClaim; 
             system.assert(fundClaim!=NULL);
            PRM_MdfRoiController.mdfDetailRecord(fundRequest.Id);
        }
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void savePartnerFundROITest(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        system.assert(contactRecord.LastName!=NULL);
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        
        Test.startTest(); 
        System.runas(userRecord) {  
            // Creating a fund request 
            SFDC_MDF__c fundRequest = PRM_TestRecordsFactory.createFundRequest('Test Fund1',contactRecord.AccountId,'Approved');
            Insert fundRequest;
            
            //Creating a fund claim        
            SFDC_MDF_Claim__c fundClaim = PRM_TestRecordsFactory.createFundClaim('Test Claim1', contactRecord.AccountId,fundRequest.Id,'Approved');
            Insert fundClaim; 
            
            Partner_Fund_ROI__c fund_ROI = PRM_MdfRoiController.savePartnerFundROI(fundRequest.Id, fundClaim.Id, '2000', NULL); 
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void roiOperationTest(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        system.assert(contactRecord.LastName!=NULL);
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        
        Test.startTest(); 
        System.runas(userRecord) {  
            
            // Creating a fund request 
            SFDC_MDF__c fundRequest = PRM_TestRecordsFactory.createFundRequest('Test Fund1',contactRecord.AccountId,'Approved');
            Insert fundRequest;
            
            //Creating a fund claim        
            SFDC_MDF_Claim__c fundClaim = PRM_TestRecordsFactory.createFundClaim('Test Claim1', contactRecord.AccountId,fundRequest.Id,'Approved');
            Insert fundClaim; 
            
            Partner_Fund_ROI__c fund_ROI  = new Partner_Fund_ROI__c();
            fund_ROI.Current_Revenue_earned__c =2000.12;
            Insert fund_ROI;  
            
            PRM_MdfRoiController.roiSubmitForApproval(fund_ROI.id, 'comment');
            List<Partner_Fund_ROI__c> fundList = PRM_MdfResultList.getPartnerFundROIList(); 
            
            Partner_Fund_ROI__c fund_ROI1 = PRM_MdfRoiController.getPartnerFundROI(fund_ROI.Id);
            
            
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void roiDeleteTest(){
        //Creating User 
        Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        system.assert(contactRecord.LastName!=NULL);
        //Creating User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord;
        
        Test.startTest(); 
        System.runas(userRecord) {  
            
            // Creating a fund request 
            SFDC_MDF__c fundRequest = PRM_TestRecordsFactory.createFundRequest('Test Fund1',contactRecord.AccountId,'Approved');
            Insert fundRequest;
            
            //Creating a fund claim        
            SFDC_MDF_Claim__c fundClaim = PRM_TestRecordsFactory.createFundClaim('Test Claim1', contactRecord.AccountId,fundRequest.Id,'Approved');
            Insert fundClaim; 
            
            List <Partner_Fund_ROI__c> fund_ROIList  = new List<Partner_Fund_ROI__c>();
            fund_ROIList.add(new Partner_Fund_ROI__c(Current_Revenue_earned__c =2000.12));
            fund_ROIList.add(new Partner_Fund_ROI__c(Status__c='Drafted', Current_Revenue_earned__c =2000.12));
            fund_ROIList.add(new Partner_Fund_ROI__c(Status__c='Drafted', Current_Revenue_earned__c =2000.12)); 
            Insert fund_ROIList;
            PRM_TestRecordsFactory.insertAttachment(fund_ROIList[0].Id,'test attach');
            
            PRM_MdfRoiController.deleteFundROIWithID(fund_ROIList[0].Id);
            PRM_MdfRoiController.deleteFundROIList();
            
        }
        
        Test.stopTest();
    }
}