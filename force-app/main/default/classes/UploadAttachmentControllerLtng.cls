public class UploadAttachmentControllerLtng {
    
    public String selectedType {get;set;}
    public Engineers__c engineer{get;set;} 
    //public Account acc{get;set;} 
    public String fileName {get;set;}
    public  transient Blob fileBody {get;set;}
    public Id recordId;
    public Schema.Sobjecttype sobjtype;
    public boolean Accflag{get;set;}
    public boolean Engineerflag{get;set;}
    public String message{get;set;}
    
    public UploadAttachmentControllerLtng() {
        message = '';
        //Changes done by Yogesh - EBA_SF-1732
       // recordId=  ApexPages.currentPage().getParameters().get('id');
       // End Changes 
        recordId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
        sobjtype = recordId.getSObjectType();
        if (sobjtype  == Engineers__c.sObjectType) {
            Engineerflag = true;
            List<Engineers__c> engList = [SELECT Id, Status__c,Diagnostics_Request_Status__c FROM Engineers__c WHERE Id =: recordId LIMIT 1];
            if (engList.size() > 0) {
                engineer = engList[0];
            }
        }
    }

    Attachment__c obj = new Attachment__c();
    // creates a new Engineer_Attachment__c record
    private Database.SaveResult saveCustomAttachment() {
        
        if (sobjtype  == Engineers__c.sObjectType) {
            obj.Engineers__c = recordId;
            obj.Engineer_Attachment_Type__c= selectedType;
        }
        
        else if (sobjtype  == Account.sObjectType) {
            obj.Account__c = recordId; obj.Account_Attachment_Type__c = selectedType;
        }
        
        // fill out cust obj fields
        return Database.insert(obj);
    }
    
    // create an actual Attachment record with the Contact_Attachment__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = parentId;
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
    public void processUpload() {
        System.Savepoint sp = Database.setSavepoint();
        try {            
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
            
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                message = 'Could not save attachment.'; Database.rollback(sp); ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
            }
            
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
            
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                message = 'Could not save attachment.';  Database.rollback(sp);  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));            
            } else {
                // update the custom attachment record with some attachment info
                Attachment__c customAttachment = [select id from Attachment__c where id = :customAttachmentResult.getId()];
                customAttachment.Attachment_Name__c = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                Database.SaveResult dmlResult = Database.update(customAttachment, false) ;
                if (dmlResult.isSuccess()) {
                    if (obj.Engineer_Attachment_Type__c == 'IPP Order Form' && engineer.Status__c == 'Approved' && engineer.Diagnostics_Request_Status__c != 'Approved') {
                    	message = 'Please click on Diagnostics Request button to submit the Diagnostics request.';
                    } else {
                        message = 'File uploaded successfully.';
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
                }
            }
            
        } catch (Exception e) {
            message = e.getMessage();
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
           
        }     
    }
    
    public PageReference back() {
        return new PageReference('/'+recordId );
    }   
}