@isTest
private class UploadAttachmentControllerLtngTest {

    static testMethod void testUploadAttachmentControllerLtng() {
       	Engineers__C eng = new Engineers__C();
    	eng.First_name__c ='ABC';
	    eng.Last_Name__c ='XYZ';
	    eng.Active_Engineer__c =true;
	    eng.Email_Address__c ='xyz@ncr.com';
	    eng.City__c='noWhere';
	    eng.Type_of_Portal_Access__c ='Portal Access';
	    eng.Status__c = 'Created';
	    insert eng;
	    
	    Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        insert obj1;
        
        ApexPages.currentPage().getParameters().put('id', eng.Id);
        
        
        UploadAttachmentControllerLtng controller = new UploadAttachmentControllerLtng();
        controller.fileBody = Blob.valueOf('Test body');
        controller.fileName = 'test';
        controller.selectedType = 'IPP Order Form';
        controller.processUpload();
        controller.back();
        system.assertEquals(controller.message,'File uploaded successfully.');
        UploadAttachmentControllerLtng controller1 = new UploadAttachmentControllerLtng();
     
        controller1.selectedType = 'IPP Order Form';
        controller1.processUpload();
              
    }
}