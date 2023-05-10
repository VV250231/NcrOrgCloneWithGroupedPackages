@isTest
public class RmaConTest {
    @isTest public static void testRmaCon(){
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
        
        // Create RMA request
        RMA__c rmaRec = new RMA__c();
        rmaRec.Order_Number__c = '12345';
        rmaRec.Product_ID__c = 'PROD786';
        rmaRec.Quantity__c = 10;
        rmaRec.Reason_for_Return__c = 'Returning reason';
        rmaRec.Additional_Comments__c = 'additional comments';
        
        List<RecordType> RMArecTypes = RmaCon.getRmaRecordTypes();
        List<RMA__c> RMAlst = RmaCon.getRmaList();
        RmaCon.DataBaseOperationResult dbRes = RmaCon.saveRecord(rmaRec);
        
        rmaRec = dbRes.obj;
        rmaRec.Additional_Comments__c = 'updated comment';
        RmaCon.updateRecord(rmaRec);
        RmaCon.getRMAReq(rmaRec.Id);
        RmaCon.submitRequest(rmaRec.Id, 'comment');
        RmaCon.getFiles(rmaRec.Id);
        system.assert(rmaRec.id!=null);
    }
}