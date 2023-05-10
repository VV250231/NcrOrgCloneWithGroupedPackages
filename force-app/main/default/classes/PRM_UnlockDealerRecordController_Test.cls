@isTest
public class PRM_UnlockDealerRecordController_Test {
    @TestSetup static void testDataSetup(){
        User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
        System.runAs(partnerUser){
        	//Creating an Account
            Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
            accountRecord.Partner_Industry__c ='Financial';
            insert accountRecord;
            
            // Creating a Contact
            Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
            insert contactRecord;
        }
    }
    @isTest static void isLockedMethodCoverage(){
        Contact contRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'MahlaTest' LIMIT 1]; 
        //Creating an User
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contRecord.Id,'test',null);
        insert userRecord;
        Deal_Registration__c dealRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal', 'Created');
        dealRecord.Partner_Industry__c = 'Financial';
        Test.startTest();
        System.runas(userRecord){  
            insert dealRecord;
            PRM_DealRegistrationController.submitDRForApproval(dealRecord.Id, 'Testing');
        }
        Test.stopTest();
		PRM_UnlockDealerRecordController.PRM_DRLockApprovedWrapper dealInfoWrapper = PRM_UnlockDealerRecordController.islocked(dealRecord.Id);
        System.assertEquals(false, dealInfoWrapper.isApproved);
        System.assertEquals(true, dealInfoWrapper.isLock);
    }
    static testmethod  void DealRegistrationTest() 
    {  
        Deal_Registration__c deal = new Deal_Registration__c();
        deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
        deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
        deal.Is_this_part_of_an_RFP__c =true;   
        insert deal;
        //system.assertEquals(false,PRM_UnlockDealerRecordController.islocked(deal.id));
        system.assertEquals(true,PRM_UnlockDealerRecordController.unlockRecord(deal.id));
        
    }
}