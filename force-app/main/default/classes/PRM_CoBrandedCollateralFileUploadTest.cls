@isTest
public class PRM_CoBrandedCollateralFileUploadTest 
{
    static testMethod void myUnitTest() 
    {
        Co_Branded_Collateral__c  mc = new Co_Branded_Collateral__c ();
        mc.Status__c = 'Draft';
        insert mc;
        system.assert(mc.Status__c!=null);
           
      
        
        PRM_CoBrandedCollateralFileUpload.saveChunk(mc.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = mc.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_CoBrandedCollateralFileUpload.saveChunk(mc.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }
}