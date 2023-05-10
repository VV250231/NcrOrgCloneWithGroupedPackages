@isTest
public class PRM_TriggersControllerTest { 
    @isTest
    public static void getTriggersStatusTest(){
        
       Boolean check= PRM_TriggersController.getTriggersStatus('PopulateNextTierRevenue'); 
        
        system.assertEquals(check,true);
        
    }
}