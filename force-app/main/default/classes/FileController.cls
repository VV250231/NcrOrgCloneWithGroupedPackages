public with sharing class FileController {
    
    private String parentId;
    private String fieldAPI;
    public File__c file{get;set;}
    public String fileName {get;set;}
    public String fildDescription {get;set;}
    public transient Blob fileBody {get;set;}
    public boolean isSuccess {get;set;}
    
    public FileController() {
        file      = new File__c();
        isSuccess = false;
        //Changes done by Yogesh - EBA_SF-1732
       // parentId  = ApexPages.currentPage().getParameters().get('pid');
       // fieldAPI  = ApexPages.currentPage().getParameters().get('fieldapi');
         parentId  = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('pid'));
        fieldAPI  = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fieldapi'));
        //End Changes
    }
    
    // creates a new file record
    private Database.SaveResult saveCustomFile(String fieldAPI, String parentId, String attachmentId) {
        // fill out cust obj fields
        file.Name = fileName ;
        file.put(fieldAPI,parentId); 
        file.put('Attachment_ID__c',attachmentId);
        return Database.insert(file);
    }
    
    // create an actual Attachment record with the file as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Attachment attachment = new Attachment();
        attachment.body       = this.fileBody;
        attachment.name       = this.fileName;
        attachment.parentId   = parentId;
        
        Database.SaveResult result;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
    
    /**
* Upload process is:
*  1. Save Standard Attachment
*  2. Insert new File Record with Attachment Id
**/
    public void processAttachment() {
        System.SavePoint sp = DataBase.setSavePoint();
        try {    
            // Saving Attachment under the record.
            Database.SaveResult attachmentResult = saveStandardAttachment(parentId);
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not save attachment.')); Database.rollback(sp); return;
            }
            
            //Saving File Record
            Database.SaveResult customFileResult = saveCustomFile(this.fieldAPI, this.parentId, attachmentResult.getId());
            
            if (customFileResult == null || !customFileResult.isSuccess()) {
               ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not save attachment.'));Database.rollback(sp); return;
            }
            isSuccess = true;  
        } catch (Exception ex) {
            Database.rollback(sp); ApexPages.AddMessages(ex);return;
        }
    }
    
    // Returns Pre Approval File List which can be used as Proff of Performance document as well.
    public List<File__c> preAppFileList {
        get {
            System.debug('parentId'+ parentId);
            List<SFDC_MDF_Claim__c> mdfClaimList = [SELECT Id, Name, Fund_Request__c FROM SFDC_MDF_Claim__c WHERE Id =: parentId LIMIT 1];
            System.debug('mdfClaimList'+ mdfClaimList);
            if (mdfClaimList.size() > 0) {
                if (preAppFileList == null) {
                    preAppFileList = [SELECT Id, Name, Claim__c, Pre_Approval__c, Attachment_ID__c, Fund_Claim__c, CP_Is_Cloned__c FROM File__c WHERE Fund_Request__c =: mdfClaimList[0].Fund_Request__c AND CP_Is_Cloned__c =: false];
                } else {
                    return preAppFileList;
                }     
            } else {
                return null;
            }
            
            return preAppFileList;      
        }
        set;
    }
   
  public void updatePreAppFileList() {
    // if user want to use Pre Approval Document as Claim document.
    // Create Clone for the Attachment
    // Create Clone for the file record.
    List<File__c> filesToUpdateList = new List<File__c>();
    
    Map<Id, File__c> fileAttIdMap = new Map<Id, File__c>();
    Set<Id> attIds = new Set<Id>();
      
    for (File__c f : preAppFileList) {
    	 if (f.Claim__c == true){
         	fileAttIdMap.put(f.Id, f);  
            attIds.add(f.Attachment_ID__c);
         }
    }
      
    if(!attIds.isEmpty()) {
    	Map<Id, Attachment> attMap = new Map<Id, Attachment>([SELECT Id, Name, Body FROM Attachment WHERE ID IN :attIds]);
        List<Attachment> claimAttLst = new List<Attachment>();
        List<File__c> claimFileLst = new List<File__c>();
        
        for(File__c f : fileAttIdMap.values()) {
        	Attachment preAtt = attMap.get(f.Attachment_ID__c); 
            
            if (preAtt != NULL) {
           		claimAttLst.add(new Attachment(Name = preAtt.Name+'-claim', Body=preAtt.Body, ParentId=parentId));
               
                File__c newFile = new File__c();
                newFile.Name = f.Name+'-claim' ;
                newFile.Fund_Claim__c = parentId;
                //newFile.put('Attachment_ID__c',saveResult.getId());
                newFile.Claim__c = true;
                claimFileLst.add(newFile);
            } 
            
            f.CP_Is_Cloned__c = true;
            filesToUpdateList.add(f);
        }
        
        System.SavePoint sp = DataBase.setSavePoint();
        List<Database.SaveResult> saveResults = Database.Insert(claimAttLst);
        
        integer count = 0;
        for(Database.SaveResult sr : saveResults) {
            if(sr.isSuccess()) {
            	claimFileLst.get(count).put('Attachment_ID__c',sr.getId());   
                count++;
            } else {
            	System.debug('Error:' + (sr.getErrors()).get(0).getMessage()); 
                Database.rollback(sp); return;
            }
        } 
        
        List<Database.SaveResult> saveFileResults = Database.Insert(claimFileLst);
        
        for(Database.SaveResult sr : saveFileResults) {
            if(!sr.isSuccess()) {
            	System.debug('Error:' + (sr.getErrors()).get(0).getMessage()); 
                Database.rollback(sp); return;
            } 
        } 
        
       if (!filesToUpdateList.isEmpty()) {
       		update filesToUpdateList;
            isSuccess = true;
       }
        
    }   
  }
    
}