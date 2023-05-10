@isTest
public class ExpansionRequestApprovalCMPContTest {
    
    static testMethod void testExpansionRequestApprovalCMPCont() 
    { 
       Expansion_Request__c ex = new Expansion_Request__c();
            ex.Territory_1__c = 'Test1234';
            ex.Territories_currently_served__c = 'Test';
            ex.Discussed_this_request_with_CAM__c = 'Yes';
        	ex.Status__c = 'Draft';
            insert ex;
        
       Expansion_Request__c ex2 = new Expansion_Request__c();
            ex2.Territory_1__c = 'Test1234';
            ex2.Territories_currently_served__c = 'Test';
            ex2.Discussed_this_request_with_CAM__c = 'Yes';
        	ex2.Status__c = 'Draft';
            insert ex2;
        
        Expansion_Request__c ex3 = new Expansion_Request__c();
            ex3.Territory_1__c = 'Test1234';
            ex3.Territories_currently_served__c = 'Test';
            ex3.Discussed_this_request_with_CAM__c = 'Yes';
        	ex3.Status__c = 'Approved';
            insert ex3;
        	ex3.Status__c = 'Approved';
        	update ex3;
        ExpansionRequestApprovalCMPCont.submitApprovalRequest(ex3.id, 'Test');
        ex3.Status__c = 'Submitted';
        update ex3;
        ExpansionRequestApprovalCMPCont.submitApprovalRequest(ex3.id, 'Test');
        Attachment objAttach  = new Attachment();
        objAttach.Body = Blob.valueOf('Hi');
        objAttach.ParentId = ex.Id;
        objAttach.Name = 'Test';
        insert objAttach;
         System.assertEquals(objAttach.ParentID,ex.ID);
       
        
        Expansion_Request__c objEX = [Select (Select Id, ParentId, RecordType, Title, FileType, ContentSize, FileExtension, ContentUrl, ExternalDataSourceName, 
                                                    ExternalDataSourceType, SharingOption From CombinedAttachments)
                                        From Expansion_Request__c where Id =: ex.Id];
        
        System.debug('-----------objEX----------'+objEX.CombinedAttachments.size());
        
        ExpansionRequestApprovalCMPCont.submitApprovalRequest(objEX.id, 'Test');
        ExpansionRequestApprovalCMPCont.submitApprovalRequest(ex2.id, 'Test');
        ExpansionRequestApprovalCMPCont.submitApprovalRequest(ex3.id, 'Test');
    }

}