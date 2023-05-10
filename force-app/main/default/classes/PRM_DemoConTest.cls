@isTest
public class PRM_DemoConTest {
    
    @isTest public static void testDemoCon (){
        // Create Partner user
        Account act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
         System.runAs(TestRecordsFactory.getUser()){
           insert act;
        }
        
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        
        // Create Demo Request
        Demo_Program__c rec = new Demo_Program__c();
        rec.QTY__c = 50;
        rec.MSRP__c = 10000;
        rec.Product_Description__c = 'Description';
        rec.Product_Group_NCR_designation__c = 'Product Group';
        rec.LT__c = 'LT';
        insert rec;
        System.assertNotEquals(rec, null,'Demo_Program__c should not be null');

        // Note - Beow all code be run as U(partner community user) but was facing issue while inserting content version so running as system admin only.
        // will make the change lateron.
        PRM_DemoCon.getFINDemoProgram();
        Demo_Program__c demoReq = PRM_DemoCon.getDemoReq(rec.Id);
        PRM_DemoCon.approvalProcessResult res = PRM_DemoCon.submitRequest(rec.Id,'comment');
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = rec.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        PRM_DemoCon.approvalProcessResult rest = PRM_DemoCon.submitRequest(rec.Id,'comment');
        List<ContentDocument> conDocList = PRM_DemoCon.getFiles(rec.Id);
        PRM_DemoCon.DataBaseOperation dbOp = PRM_DemoCon.deleteDemoReq(rec.Id);
        
    }
    
}