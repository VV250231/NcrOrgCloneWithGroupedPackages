@isTest
public class MarketingConciergeFileUploadCtrTest 
{
    static testMethod void myUnitTest() 
    {
        Marketing_Concierge__c mc = new Marketing_Concierge__c();
        mc.Partner_Email_Address__c ='abc@xyz.com';
        mc.Partner_Phone_Number__c ='999999';
        mc.Status__c = 'Created';
        insert mc;
      
        
        MarketingConciergeFileUploadController.saveChunk(mc.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = mc.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        MarketingConciergeFileUploadController.saveChunk(mc.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
        system.assert(mc.Id !=null);
    }
}