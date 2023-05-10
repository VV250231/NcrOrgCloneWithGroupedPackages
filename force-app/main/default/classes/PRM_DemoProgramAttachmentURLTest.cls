@isTest
public class PRM_DemoProgramAttachmentURLTest 
{
	 @isTest public static void testDemoCon()
     {
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
         
        PRM_DemoProgramAttachmentURL obj = new PRM_DemoProgramAttachmentURL();
        PRM_DemoProgramAttachmentURL.recordId = rec.Id;
         
        List<ContentDocument> lstFiles = PRM_DemoProgramAttachmentURL.docFiles;
     }
}