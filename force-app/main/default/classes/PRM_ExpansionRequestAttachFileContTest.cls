@isTest
public class PRM_ExpansionRequestAttachFileContTest {
    
    static testMethod void myUnitTest() 
    {
       Expansion_Request__c ex = new Expansion_Request__c();
            ex.Territory_1__c = 'Test1234';
            ex.Territories_currently_served__c = 'Test';
            ex.Discussed_this_request_with_CAM__c = 'Yes';
            insert ex;
        
        System.assertNotEquals(ex, null,'Expansion_Request__c should not be null');

        PRM_ExpansionRequestAttachFileCont.saveChunk(ex.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = ex.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        PRM_ExpansionRequestAttachFileCont.saveChunk(ex.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }

}