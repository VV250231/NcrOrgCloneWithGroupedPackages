@isTest(SeeAllData=true)
public class tableau_c360_controllerTest {
@isTest static void testgetMCN() {
    	Account a=[Select id from Account Limit 1].get(0);
        tableau_c360_controller.getMCN(a.id);
        system.assertNotEquals(tableau_c360_controller.getMCN(a.id),null);
    }
}