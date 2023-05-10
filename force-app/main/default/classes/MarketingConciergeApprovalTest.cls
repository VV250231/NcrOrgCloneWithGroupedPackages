@isTest
private class MarketingConciergeApprovalTest 
{
	static testMethod void myUnitTest() 
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
      	Attachment objAttach  = new Attachment();
      	objAttach.Body = Blob.valueOf('Hi');
      	objAttach.ParentId = mc.Id;
      	objAttach.Name = 'Test';
      	insert objAttach;
      	
        MarketingConciergeApproval.submitforApproval(mc.id, UserInfo.getUserId());
        String result=MarketingConciergeApproval.submitforApproval(mc2.id, UserInfo.getUserId());
        system.assert(result!=null);
        
    }
}