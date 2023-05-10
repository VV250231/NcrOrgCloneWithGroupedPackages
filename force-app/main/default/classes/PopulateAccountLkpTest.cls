@isTest
private class PopulateAccountLkpTest {
     static testMethod void runUnitTest() {
         Account acc=TestRecordsFactory.createAccount('DOC1234');
         
         Daily_Order_Combined__c doc = new Daily_Order_Combined__c(Customer_Name__c = acc.Name, MCN__c = acc.Master_Customer_Number__c, Customer_Country_Code__c = acc.Account_Country_Code__c, 
                                             Transaction_Date__c= Date.today(), Today__c = 100, WTD__c = 100, HW__c = 100,SW__c = 100, PS__c= 100, TS__c= 100);
         insert doc;
         system.assert(doc.id!=null); 
     }

}