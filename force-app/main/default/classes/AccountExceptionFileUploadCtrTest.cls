@isTest
public class AccountExceptionFileUploadCtrTest 
{
    static testMethod void myUnitTest() 
    {
       Exception_Account__c ea = new Exception_Account__c();
        ea.Name ='test';
        insert ea;
       
       Account_Exception__c ae = new Account_Exception__c();
        ae.Customer_Name__c = ea.Id;
        ae.Primary_Contact_Name__c ='abcd';
        ae.Primary_Solution__c = 'test123';
        ae.Primary_Competitor__c = 'test';
        ae.Opportunity_Value__c = 78;
        ae.Expected_Close_Date__c = system.today();
        insert ae;
      
        
        AccountExceptionFileUploadController.saveChunk(ae.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = ae.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        AccountExceptionFileUploadController.saveChunk(ae.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
    }
}