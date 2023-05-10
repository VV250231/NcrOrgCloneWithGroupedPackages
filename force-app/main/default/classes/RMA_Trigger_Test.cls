@isTest
public class RMA_Trigger_Test {
    static Account act;
    static Contact con;
    static User u;

    @TestSetup
    static void makeData(){
        User soupUser = PRM_TestRecordsFactory.createSoupUser();
        insert soupUser;
       
        
    }

    @isTest
    public static void testPartnerInformationUpdate() {
        User soupUser = [SELECT id, Name FROM User WHERE Profile.Name = 'Soup Integration' LIMIT 1];
        System.runAs(soupUser) {
            act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
            insert act;
        }
        con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        System.runAs(u) {
            // Create RMA request
            RMA__c rmaRec = new RMA__c();
            rmaRec.Order_Number__c = '12345';
            rmaRec.Product_ID__c = 'PROD786';
            rmaRec.Quantity__c = 10;
            rmaRec.Reason_for_Return__c = 'Returning reason';
            rmaRec.Additional_Comments__c = 'additional comments';
            insert rmaRec;
            system.assertEquals(rmaRec.Product_ID__c,'PROD786');
        }
    }
}