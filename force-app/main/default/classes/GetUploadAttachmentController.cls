public with sharing class GetUploadAttachmentController {

  
    
    public String fileName {get;set;}
    public  transient Blob fileBody {get;set;}
    public Id recordId;
    
    
     public GetUploadAttachmentController () {
          //Changes done by Yogesh - EBA_SF-1732
       // recordId=  ApexPages.currentPage().getParameters().get('id');
          recordId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')); 
          System.debug('recordid'+ recordId);
         //End Changes 
     }

    
    // creates a new Engineer_Attachment__c record
    private Database.SaveResult saveCustomAttachment() {
      Attachment__c obj = new Attachment__c();
        obj.Case__c= recordId;
           
        
        // fill out cust obj fields
        return Database.insert(obj);
        }
    
    // create an actual Attachment record with the Contact_Attachment__c as parent
    private Database.SaveResult saveStandardAttachment(Id recordId) {
        Database.SaveResult result;
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = recordId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
    
    /**
    * Upload process is:
    *  1. Insert new Engineer_Attachment__c record
    *  2. Insert new Attachment with the new Engineer_Attachment__c record as parent
    *  3. Update the Engineer_Attachment__c record with the ID of the new Attachment
    **/
    public PageReference processUpload() {
     //   try {
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not save attachment.'));  return null;
            }
            
            System.debug('--->'+customAttachmentResult.getId());
            
        
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not save attachment.'));  return null;
            } else {
                // update the custom attachment record with some attachment info
                Attachment__c customAttachment = [select id from Attachment__c where id = :customAttachmentResult.getId()];
                customAttachment.Attachment_Name__c = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                update customAttachment;
            }
        
      /*  } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        } */
        
       
        return new PageReference('/'+recordId );
    }
    
    public PageReference back() {
        return new PageReference('/'+recordId );
    }   

}