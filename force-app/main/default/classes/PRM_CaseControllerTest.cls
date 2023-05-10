@isTest(SeeAllData = true)
public class PRM_CaseControllerTest 
{
	static testmethod void testCaseController()
    {
       	Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPT Partner').getRecordTypeId();
        case c = new case();
        c.RecordTypeId = recTypeId;
        c.Status ='new';
        c.Subject='General';
        c.Category__c = 'MDF';
        //c.contactId = UserInfo.getUserId();
        insert c;
        system.assert(c.Status!=null);
        
        PRM_CaseController.getCases('All Cases');
        PRM_CaseController.getCases('All Open Cases');
        PRM_CaseController.getCases('My Cases');
        PRM_CaseController.getCaseDetail(c.Id);
        PRM_CaseController.getCaseDetail('');
        PRM_CaseController.createComment(c.Id, 'Test');
       
       
        
        PRM_CaseController.saveChunk(c.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = c.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_CaseController.saveChunk(c.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
        
        PRM_CaseController.getAttachments(c.Id);
        PRM_CaseController.getCaseComments(c.Id);
        
        case objCase = new case();
        objCase.RecordTypeId = recTypeId;
        objCase.Status ='new';
        objCase.Subject='General';
        c.Category__c = 'MDF';
        //PRM_CaseController.saveCase(objCase, null , null);
        PRM_CaseController.getPicklistValues();
        
    }

}