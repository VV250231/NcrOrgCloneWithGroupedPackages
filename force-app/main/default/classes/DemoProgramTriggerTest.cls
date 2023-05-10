@isTest
public class DemoProgramTriggerTest {
    @isTest public static void testDemoProgramTrigger(){
        // Create Partner user
        Account act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
         system.runas(TestRecordsFactory.getUser())
        {
            insert act; 
        }
        //insert act;
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        
        system.runAs(u){
            // Create Demo Request
            Demo_Program__c rec = new Demo_Program__c();
            rec.QTY__c = 50;
            rec.MSRP__c = 10000;
            rec.Product_Description__c = 'Description';
            rec.Product_Group_NCR_designation__c = 'Product Group';
            rec.LT__c = 'LT';
            insert rec;
            system.assert(rec.id!=null);
            system.assertEquals(rec.Product_Group_NCR_designation__c,'Product Group');
        }
    }
}