@isTest
public class PRM_EULAAttachFileContTest 
{
    static testMethod void myUnitTest() 
    {
        EULA_submission__c es = new EULA_submission__c();
        es.Customer_Name__c ='Test';
        es.Solution_Name_or_Identifying_PID__c ='xyz';
        es.Status__c = 'Created';
        insert es;
       System.assertNotEquals(es, null,'EULA_submission__c should not be null');

        
        PRM_EULAAttachFileCont.saveChunk(es.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = es.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_EULAAttachFileCont.saveChunk(es.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }
}