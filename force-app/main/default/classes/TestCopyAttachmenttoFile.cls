@isTest
private class TestCopyAttachmenttoFile {

    static testMethod void runTest() {
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        Account acc = new Account(Id=opp.AccountId, Subscription_Group__c = 'Digital Insight');
        update acc;
        Attachment att = TestRecordsFactory.createAttachment(opp.Id);
        system.assert(att.id!=null);
        
    }
}