@isTest
public class CoBrandedCollateralTriggerTest {
    @isTest public static void testCoBrandedCollateralTrigger()
    {
        // Create Partner user
          User Usr = [Select Id from User Where Name = 'Soup User'];
        
      
        Account act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
         System.runAs(Usr){
             insert act;
         }
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        System.assertNotEquals(u.id, null,'User is null');  
        
        system.runAs(u){
            // Create Demo Request
            Co_Branded_Collateral__c  mc = new Co_Branded_Collateral__c ();
            mc.Status__c = 'Draft';
            insert mc;
        }
    }
}