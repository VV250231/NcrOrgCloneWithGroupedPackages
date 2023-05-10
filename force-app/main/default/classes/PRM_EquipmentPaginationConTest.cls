@isTest
public class PRM_EquipmentPaginationConTest {
    public static testMethod void testPagination() {
        PRM_EquipmentPaginationCon.getEquipments('All Equipment','Customer_Name__c','ASC');
        PRM_EquipmentPaginationCon.getEquipments('Active Equipment','Customer_Name__c','ASC');
        PRM_EquipmentPaginationCon.getEquipments('Inactive Equipment','Customer_Name__c','ASC');
        //PRM_EquipmentPaginationCon.getEquipments('Recently Viewed','Customer_Name__c','ASC');
         System.assertNotEquals(PRM_EquipmentPaginationCon.getEquipments('All Equipment','Customer_Name__c','ASC'), null,'Equipment_Declaration__c should not be null');

    }
}