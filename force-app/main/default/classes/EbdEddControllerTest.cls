/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: EbdEddControllerTest.Test class                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-29-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-29-2016
# Description...............: This test class is the written with respect to Apex class:EbdEddController
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/

@IsTest
Public class  EbdEddControllerTest{
    
    static testMethod void EddandEbdSetMethod() {
        /* Product2 p01 = new Product2();
p01.CurrencyIsoCode = 'USD';
p01.Family = 'Solution';
p01.Name = '1902-ECPIX LSI';
p01.Product_Category__c = 'PRODUCTCATEGORY: ';
p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
p01.Solution_Portfolio__c = 'Payment Solutions';
p01.Division__c='DIVISION: ';
p01.isActive=true; 
insert p01;*/
        test.startTest();    
        Product2 p01= TestRecordsFactory.createProduct();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        PricebookEntry pbe=TestRecordsFactory.createPriceBookEntry(p01);
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe); 
        OpportunityLineItemSchedule opp1 = TestRecordsFactory.createOpportunityLineitemSchedule(oli);
        EbdEddController.getOppDetail(opp.id);
        EbdEddController.saveEbdEdd(opp);
        System.assertEquals(null, EbdEddController.saveEbdEdd(opp));
        EbdEddController.ValidateScheduleDate(opp.id);
        EbdEddController.getLatestDate();
        EbdEddController.saveEbdEdd(null);
        System.assertEquals('Attempt to de-reference a null object', EbdEddController.saveEbdEdd(null));
        opp.Name=null;
        EbdEddController.saveEbdEdd(opp);
        test.stopTest(); 
    }
    
}