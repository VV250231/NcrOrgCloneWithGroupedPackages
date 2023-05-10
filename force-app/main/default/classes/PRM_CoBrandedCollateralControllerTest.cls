@isTest
public class PRM_CoBrandedCollateralControllerTest 
{
	static testMethod void myUnitTest() 
    {
        Co_Branded_Collateral__c  mc = new Co_Branded_Collateral__c ();
        mc.Status__c = 'Draft';
        insert mc;
      
        PRM_CoBrandedCollateralController.getCoBrandedCollateral('All');
        PRM_CoBrandedCollateralController.getCoBrandedCollateral('Draft');
        
        PRM_CoBrandedCollateralController.getCoBrandedCollateralDetail(mc.Id);
        PRM_CoBrandedCollateralController.getEditCoBrandedCollateralDetail(mc.Id);
        system.assert(mc.Id!=null);
        
        PRM_CoBrandedCollateralController.getPicklistValues();
        PRM_CoBrandedCollateralController.saveChunk(mc.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = mc.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_CoBrandedCollateralController.saveChunk(mc.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
        
        PRM_CoBrandedCollateralController.getCBCAttachments(mc.Id);
        PRM_CoBrandedCollateralController.saveCoBranded(new Co_Branded_Collateral__c (Status__c = 'Draft'));
        
        PRM_CoBrandedCollateralController.saveEditedCoBranded(mc);
        
        PRM_CoBrandedCollateralController.submitApprovalRequest(mc.Id, 'Test');
        
    }
}