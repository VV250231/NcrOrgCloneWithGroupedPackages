/*
##################################################################################################
# Project Name..........: Order Opportunity Linkage                                                                       
# File............................: TestUtilityTest.cls                                                        
# Version.....................: 30.0 
# Created by................: IDC, Gurgaon                                                                   
# Created Date...........: 29-04-2014                                                                               
# Last Modified by......: IDC, Gurgaon
# Last Modified Date..: 29-04-2014
# Description.........: The test class is basically written to test the TestUtility class .
################################################################################################
*/
@isTest
private class TestUtilityTest {  

    @isTest(SeeAllData = true)
    static void unitTest() { 
        
            //create opportunity record
            Opportunity  opp = TestUtitlity.createOppRecord();
            System.assertNotEquals(Opp.id, null,'Opp should not be null');
            // create product record
            Product2 prdObj1 = TestUtitlity.createAnnuityProduct();
            Product2 prdObj2 = TestUtitlity.createNonAnnuityProduct();
            
            // create pricebookentry record
            
            //PricebookEntry pricebookentryObj = TestUtitlity.createPriceBookEntryRecord(prdObj2.Id);
            
            
            //create opportunitylineitem record
            test.startTest();
            //OpportunityLineItem oli =  TestUtitlity.createOppLineItem(opp.Id , pricebookentryObj.Id);
            OpportunityLineItem oli = TestUtitlity.createOppLineItem(opp.id, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()).id);
            //TestUtitlity.testHack_1();
            test.stopTest();
    }
    
    /*static testMethod void unitTest2(){
    test.startTest();
        // create Order Country record
        Order_Country__c oc = TestUtitlity.createOrderCountryRecord();
        test.stopTest();
    }*/
}