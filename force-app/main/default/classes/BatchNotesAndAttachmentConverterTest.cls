@isTest
public class BatchNotesAndAttachmentConverterTest {
    
    public static testMethod void testBatchAttachmentConverter() {
        // Inserting case record
        Case cse=new Case();
        insert cse;
        //Inserting attachment record
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cse.id;
        insert attach;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:cse.id];
        System.assertEquals(1, attachments.size());
        
        Test.startTest();
        BatchNotesAndAttachmentConverter obj  = new BatchNotesAndAttachmentConverter('Case','Attachment');
        Database.executeBatch(obj,1);
        Test.stopTest();
    }
    public static testMethod void testBatchNoteConverter() {
        // Inserting contact record
        Contact cse=new Contact(Lastname='Test');
        insert cse;
        //Inserting note record
        Note n=new Note();   	
        n.title='Unit Test Attachment';
        n.body='Unit Test Attachment Body';
        n.parentId=cse.id;
        insert n;
        
        List<Note> notes=[select id from Note where parent.id=:cse.id];
        System.assertEquals(1, notes.size());
       
        Test.startTest();
        BatchNotesAndAttachmentConverter obj  = new BatchNotesAndAttachmentConverter('Contact','Notes');
        Database.executeBatch(obj,1);
        Test.stopTest();
    }
}