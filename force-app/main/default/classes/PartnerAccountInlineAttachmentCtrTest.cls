@isTest
public with sharing class PartnerAccountInlineAttachmentCtrTest 
{
    static testMethod void testAttachments()
    {
        Account acc=new Account(Name='Acme Inc');
        System.runAs(TestRecordsFactory.getUser()){insert acc;}
        
        Attachment attach=new Attachment();   	
    	attach.Name = 'Unit Test Attachment';
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	attach.body = bodyBlob;
        attach.parentId = acc.id;
        insert attach;
        
        Note objNote = new Note();
	    objNote.Title = 'Naming Criteria';
	    objNote.Body = 'Testing Note.';
	    objNote.ParentId = acc.Id;
	
	    insert objNote;
	    
        PartnerAccountInlineAttachmentController controller = new PartnerAccountInlineAttachmentController(new ApexPages.StandardController(acc));
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:acc.id];
        System.assertEquals(1, attachments.size());
        
        PartnerAccountInlineAttachmentController.getPartnerAccountAttachment(acc.id);
    }
}