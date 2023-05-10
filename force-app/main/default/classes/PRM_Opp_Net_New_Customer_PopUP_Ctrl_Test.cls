@isTest
public class PRM_Opp_Net_New_Customer_PopUP_Ctrl_Test {

    @isTest
    public static void getOpportunityDetailTest(){
        Opportunity opportunityTestRecord = new Opportunity();
        opportunityTestRecord.Name='Test Opportunity';
        opportunityTestRecord.CAM_TAM_Confirm_Net_New_Customer__c = false;
        opportunityTestRecord.Net_New_Customer__c = true;
        opportunityTestRecord.StageName='Analyzing';
        opportunityTestRecord.CloseDate = Date.today()+10;
        Insert opportunityTestRecord;
                System.assertNotEquals(opportunityTestRecord,NULL,'opportunityTestRecord not be NULL');

        Test.startTest();
        PRM_Opp_Net_New_Customer_PopUP_Contoller.getOpportunityDetail(opportunityTestRecord.id);
        Test.stopTest();
        
    }
    
     @isTest
    public static void setConfrimNetNewCustomerTest(){
        Opportunity opportunityTestRecord = new Opportunity();
        opportunityTestRecord.Name='Test Opportunity';
        opportunityTestRecord.CAM_TAM_Confirm_Net_New_Customer__c = true;
        opportunityTestRecord.Net_New_Customer__c = true;
        opportunityTestRecord.StageName='Analyzing';
        opportunityTestRecord.CloseDate = Date.today()+10;
        Insert opportunityTestRecord;
        System.assertNotEquals(opportunityTestRecord,NULL,'opportunityTestRecord not be NULL');
        Test.startTest();
        PRM_Opp_Net_New_Customer_PopUP_Contoller.setConfrimNetNewCustomer(opportunityTestRecord.id,true);
        Test.stopTest();
        
    }
	
}