/*
##################################################################################################
# Project Name..........: Order Opportunity Linkage                                                                       
# File..................: TestupdateAccountIdQuoteTrigger.cls                                                        
# Version...............: 30.0 
# Created by............: IDC, Gurgaon                                                                   
# Created Date..........: 29-04-2014                                                                               
# Last Modified by......: IDC, Gurgaon
# Last Modified Date....: 25-04-2014
# Description...........: The test class is written to test the updateAccountId trigger on Quote Details.
################################################################################################
*/
@isTest
private class TestUpdateAccountIdQuoteTrigger {  
    static testMethod void unitTest() { 
        //create Account record
        User Usr = [Select Id from User Where Name = 'Soup User'];
        Account a = new Account (name = 'testing task Deletion of Closed Opp', 
                                 Master_Customer_Number__c = 'TEST000015', 
                                 Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true);
    				
					System.runAs(Usr){ insert a; }
        
        
        //create new Quote Detail record
        List<Quote_Details__c> quoteList = new List<Quote_Details__c>();
        
        Quote_Details__c quoteObj1 = new Quote_Details__c( CurrencyIsoCode = 'USD', MCN__c = 'TEST000015');
        string quoteName = '';
        
        for(integer i=0; i< 256 ; i++){
            quoteName  += 'a';
        }
        quoteObj1.Quote_Name__c = quoteName;
        quoteList.add(quoteObj1); 
        
        //create new Quote Detail record
        Quote_Details__c quoteObj2 = new Quote_Details__c(Quote_Name__c = 'Test Quote', CurrencyIsoCode = 'USD', MCN__c = 'TEST000012', Linked__c = true);
        quoteList.add(quoteObj2);
        
        insert quoteList; 
        system.assertNotEquals(quoteList[0].id, null);
       
           
         //create opportunity record
        Opportunity  opp = TestUtitlity.createOppRecord();
        Test.startTest();
         // create new SPOT Quote
       /*  SPOT_Quote__c spquote = new SPOT_Quote__c(Name = 'Test', Opportunity_Number__c = opp.Id, 
                                                    SPOT_Quote_Number__c = quoteObj2.id, CurrencyIsoCode = 'USD');
        
                                                    
        insert spquote; 
       */
        update quoteList;
        Test.stopTest();
    }
}