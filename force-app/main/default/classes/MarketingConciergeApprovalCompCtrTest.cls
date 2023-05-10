@isTest
private class MarketingConciergeApprovalCompCtrTest 
{
    static testMethod void testMarketingConciergeApprovalCompCtr() 
    { 
        Marketing_Concierge__c mc = new Marketing_Concierge__c();
        mc.Partner_Email_Address__c ='abc@xyz.com';
        mc.Partner_Phone_Number__c ='999999';
        mc.Status__c = 'Created';
        insert mc;
        
        Marketing_Concierge__c mc2 = new Marketing_Concierge__c();
        mc2.Partner_Email_Address__c ='abc@xyz.com';
        mc2.Partner_Phone_Number__c ='999999';
        mc2.Status__c = 'Created';
        insert mc2;
        
        Marketing_Concierge__c mc3 = new Marketing_Concierge__c();
        mc3.Partner_Email_Address__c ='abc@xyz.com';
        mc3.Partner_Phone_Number__c ='999999';
        mc3.Status__c = 'Approved';
        insert mc3;
        mc3.Status__c = 'Approved';
        update mc3;
        MarketingConciergeApprovalCompController.submitApprovalRequest(mc3.id, 'Test');
        mc3.Status__c = 'Submitted';
        update mc3;
        MarketingConciergeApprovalCompController.submitApprovalRequest(mc3.id, 'Test');
        system.assert(mc3.Status__c=='Submitted');
        Attachment objAttach  = new Attachment();
        objAttach.Body = Blob.valueOf('Hi');
        objAttach.ParentId = mc.Id;
        objAttach.Name = 'Test';
        insert objAttach;
        
        Marketing_Concierge__c objMC = [Select (Select Id, ParentId, RecordType, Title, FileType, ContentSize, FileExtension, ContentUrl, ExternalDataSourceName, 
                                                    ExternalDataSourceType, SharingOption From CombinedAttachments)
                                        From Marketing_Concierge__c where Id =: mc.Id];
        
        System.debug('-----------objMC----------'+objMC.CombinedAttachments.size());
        
        MarketingConciergeApprovalCompController.submitApprovalRequest(objMC.id, 'Test');
        MarketingConciergeApprovalCompController.submitApprovalRequest(mc2.id, 'Test');
        MarketingConciergeApprovalCompController.submitApprovalRequest(mc3.id, 'Test');
        
    }
}