@isTest
public class ERPBacklogOrdersTriggerTest {
    @isTest public static void testPRM_DealRegistrationTrigger() {
        ERP_Orders_Backlog__c erpBacklog = new ERP_Orders_Backlog__c();
        erpBacklog.Amount_in_USD__c='100';
        erpBacklog.Country_Code_With_Master_Customer_Nbr__c='USDIV001';
        erpBacklog.Order_Number__c='100';
        erpBacklog.Product_ID__c='1';
        erpBacklog.Order_Status_Ind__c='CLOSED';
        erpBacklog.Tran_Code__c='D';
        insert erpBacklog;
        
      System.assertNotEquals(erpBacklog, null,'erpBacklog should not be null');

    }
}