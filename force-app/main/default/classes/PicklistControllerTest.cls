/*
##################################################################################################
# Class Name............................:PicklistControllerTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@Istest
Public class PicklistControllerTest {
    static testmethod void testPicklist() {
    Opportunity opp=new Opportunity(
    Name='TestOpp' ,
    Stagename='Forecast Category',
    Price_Variance__c='NCR within 5%',
    Key_Criteria__c='Business Benefits',
    Discontinued_Reasons__c='Mergers/Acquisitions/Divestitures',
    CloseDate=system.today());
    insert opp; 
   
    PicklistController.getpickval();
    PicklistController.saveOpportunity(opp);
    PicklistController.getStage(opp.id);
    System.assertNotEquals(PicklistController.getStage(opp.id),null);
       
    }
}