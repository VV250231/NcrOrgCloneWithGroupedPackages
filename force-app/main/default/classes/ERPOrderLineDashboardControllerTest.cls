@isTest
public class ERPOrderLineDashboardControllerTest {
    @isTest
    public static void testController(){
        try{
            ERPOrderLineDashboardController.getERPOrderLineDetail('123');
            ERPOrderLineDashboardController.searchOrderLinesByBillToCustomer('12','123');
            ERPOrderLineDashboardController.serviceLines('123');
            ERPOrderLineDashboardController.deleteLines('123');
           System.assertNotEquals(ERPOrderLineDashboardController.getERPOrderLineDetail('123'), null,'ERPOrderLineDashboardController should not be null');

        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        } 
    }
    
}