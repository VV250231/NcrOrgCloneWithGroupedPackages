@isTest
private class EULASubmissionsApprovalContTest 
{
    static testMethod void testEULASubmissionsApprovalCont() 
    { 
        EULA_submission__c es = new EULA_submission__c();
        es.Customer_Name__c ='Test';
        es.Solution_Name_or_Identifying_PID__c ='abc';
        es.Address__c = 'xyz';
        es.Date_of_Agreement__c = system.today();
        es.End_Date_of_Agreement__c = system.today() + 1;
        es.Status__c = 'Created';
        insert es;
        
        EULA_submission__c es2 = new EULA_submission__c();
        es2.Customer_Name__c ='Test';
        es2.Solution_Name_or_Identifying_PID__c ='abc123';
        es2.Address__c = 'xyz';
        es2.Date_of_Agreement__c = system.today();
        es2.End_Date_of_Agreement__c = system.today() + 1;
        es2.Status__c = 'Created';
        insert es2;
        es2.Status__c = 'Approved';
        update es2;
        EULASubmissionsApprovalCont.submitApprovalRequest(es.id, 'Test');
        Attachment objAttach  = new Attachment();
        objAttach.Body = Blob.valueOf('Hi');
        objAttach.ParentId = es.Id;
        objAttach.Name = 'Test';
        insert objAttach;
        
        EULA_submission__c objES = [Select (Select Id, ParentId, RecordType, Title, FileType, ContentSize, FileExtension, ContentUrl, ExternalDataSourceName, 
                                                    ExternalDataSourceType, SharingOption From CombinedAttachments)
                                        From EULA_submission__c where Id =: es.Id];
        
        System.debug('-----------objES----------'+objES.CombinedAttachments.size());
        
        EULASubmissionsApprovalCont.submitApprovalRequest(objES.id, 'Test');
        EULASubmissionsApprovalCont.submitApprovalRequest(es2.id, 'Test');
        
        System.assertNotEquals(objES, null,'EULA_submission__c should not be null');

        
    }
}