/**************************************
Author ...............: Pandey, Dharmendra Kumar
Modified Date.........: 15-July-2021
Description...........: Update quote's all payment application status field qtc_Status_of_all_Applications__c
						Called from cpq_NCRPaySitesToOppSyncTrigger.apxt
***************************************/
@isTest
public with sharing class CPQNCRPaymentSitesTriggerHandlerTest {
    
    @isTest
    static void quotePayAppStatusTest(){
        
        //qtc_Number_of_Sites_with_Payments__c
        //qtc_Multi_Site__c
        //qtc_Multi_Site_Type__c = PP Only
        //qtc_Multi_Site_Relationship__c = Parent
        //NCR_Payments_Application_Status__c
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(qtc_Multi_Site__c=true,qtc_Number_of_Sites_with_Payments__c=2,qtc_Multi_Site_Type__c='PP Only',qtc_Multi_Site_Relationship__c ='Parent');
        NCR_Payments_Site__c testPay1 = new NCR_Payments_Site__c();
        NCR_Payments_Site__c testPay2 = new NCR_Payments_Site__c();
        Account   testAccount = new Account(Name='Test Company Name123');
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        
        System.runAs( Usr ){
            Test.startTest();
            insert testAccount;
            insert testQuote;
            testPay1.Quote__c =  testQuote.id;  
            testPay1.Account_Sites__c=testAccount.id;
            testPay2.Quote__c =  testQuote.id;  
            testPay2.Account_Sites__c=testAccount.id;

            insert testPay1;
            insert testPay2;
            Test.stopTest();
        }  
        
        SBQQ__Quote__c queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, 'Pending', 'Expected status Pending');
        
        //Case#2 quote's no of payment site field increased, expected all application status 'Pending'
        testQuote.qtc_Number_of_Sites_with_Payments__c = 3;
        update testQuote;
        
		queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, 'Pending', 'Expected status Pending');

        //Case#3 Application's staus updated to Approved, expected Quote's all appplication status changed to Approved
        NCR_Payments_Site__c testPay3 = new NCR_Payments_Site__c(Quote__c =  testQuote.id,Account_Sites__c=testAccount.id);
        insert testPay3;
        testPay1.NCR_Payments_Application_Status__c='ApprovedAndBoarded';
        testPay2.NCR_Payments_Application_Status__c='ApprovedAndBoarded';
        testPay3.NCR_Payments_Application_Status__c='ApprovedAndBoarded';
        List<NCR_Payments_Site__c> pLst = new List<NCR_Payments_Site__c>();
        pLst.add(testPay1);
        pLst.add(testPay2);
        pLst.add(testPay3);
        update pLst;
        
		queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, 'ApprovedAndBoarded', 'Expected status ApprovedAndBoarded');
        
        //Case#4 delete all payment sites, expected all apppliation status on quote is null
        delete pLst;
        queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, null, 'Expected status null');
        
        //Case#5 if quote not have payment site and nu# of payment site on quote updated then quote's all papp status will be null.
       	testQuote.qtc_Number_of_Sites_with_Payments__c = 2;
        update testQuote;
     	queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, null, 'Expected status null');
        
       //case#6 non multi site ,  sigle site Pending and Approved test
	    testPay1.NCR_Payments_Application_Status__c=null;
        testPay1.Id = null;
        insert testPay1;
        testQuote.qtc_Multi_Site__c=false;
        testQuote.qtc_Number_of_Sites_with_Payments__c=null;
        testQuote.qtc_Multi_Site_Type__c=null;
        testQuote.qtc_Multi_Site_Relationship__c =null;
        update testQuote;
        queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, 'Pending', 'Expected status Pending');
        testPay1.NCR_Payments_Application_Status__c='ApprovedAndBoarded';
       	update testPay1;
        queriedQuote = [SELECT id,qtc_Status_of_all_Applications__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Status_of_all_Applications__c, 'ApprovedAndBoarded', 'Expected status ApprovedAndBoarded');
        
    }
}