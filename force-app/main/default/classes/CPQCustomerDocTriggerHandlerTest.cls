@isTest
public with sharing class CPQCustomerDocTriggerHandlerTest {
    
    @isTest
    static void updateLegalDocStatus(){
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(qtc_Legal_Document_Status__c='Sent For Signature');
        //SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        Customer_Document__c testDoc = new Customer_Document__c(Document_Status__c='Completed',Document_Type__c='AE Order Form');
        Account   testAccount = new Account(Name='Test Company Name123');
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        DateTime d1 = datetime.newInstance(2021, 9, 15, 12, 30, 0);
        Customer_Document__c testDoc2 = new Customer_Document__c(Document_Sent_Date__c=d1,Document_Type__c='AE Shipment/Order Authorization');

        System.runAs( Usr ){
            Test.startTest();
            insert testAccount;
            insert testQuote;
            testDoc.Quote__c =  testQuote.id; 
            testDoc.Account__c=testAccount.id;
            testDoc2.Quote__c =  testQuote.id;  
            testDoc2.Account__c=testAccount.id;
            insert testDoc;
            insert testDoc2;
            Test.stopTest();
        }  
        
        SBQQ__Quote__c queriedQuote = [SELECT id,qtc_Legal_Document_Status__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(queriedQuote.qtc_Legal_Document_Status__c, 'Completed', 'Expected status Completed');
        
    } 
}