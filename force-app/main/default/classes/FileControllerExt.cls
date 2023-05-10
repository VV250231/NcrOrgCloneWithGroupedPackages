//This controller extent the functionality to update a record
public with sharing class FileControllerExt {
  public boolean error {get;set;}
  public File__c file {get;set;}
  public String fileName {get;set;}
  public transient Blob fileBody {get;set;}
  public Boolean isUpdateFileProcessDone {get;set;}
  public Attachment attDoc ;
    
  public FileControllerExt(FileController controller) {
    error                   = false ;
    isUpdateFileProcessDone = false ;
    String fileId           = ApexPages.currentPage().getParameters().get('fileId');
    System.debug('fileId'+ fileId);
    // Finding Attachment Id on file record    
    List<File__c> fileList  = [
        SELECT 
            Id, Name, Pre_Approval_Document_Type__c, Proof_of_Performance_Document_Type__c,
            Claim__c, Pre_Approval__c, Attachment_ID__c, Fund_Claim__c, Fund_Request__c
        FROM File__c 
        WHERE Id=: fileId
    ];
        
    if (fileList.size() > 0) {
      file = fileList[0];
      //finding associated attacment to file
      List<Attachment> attList = [SELECT id, Name, ParentId FROM Attachment WHERE Id =: file.Attachment_ID__c LIMIT 1];
      if (attList.size() > 0) {
        attDoc = attList[0];
      } else {
        // insert new attachment.
        attDoc = new Attachment();
      }
    } else {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'File can to be modified'));
      error = true;
      return ;
    }
  }
    
  /*
   * Method updates the records.
   */  
  public void updateFileProcess() {
    try {
      System.SavePoint sp = Database.setSavePoint();
        
      Database.SaveResult fileUpdateResult = updateFile();
        
      if (fileUpdateResult == null || ! fileUpdateResult.isSuccess()) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'File can to be modified'));
        error = true;
        return;
          
      } else {
        Database.UpsertResult updateAttachmentResult = updateAttachment();
            
        if (updateAttachmentResult == null || !updateAttachmentResult.isSuccess()) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'File can to be modified'));
          error=true;
          Database.rollback(sp);
          return ;
        }
          
      }
        
      isUpdateFileProcessDone = true;
        
    } catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
    }
        
  }
    
  /*
   * Update file record
   */
  public Database.SaveResult updateFile() {
    try {
      //Might be the case user is not changig the file, he is only changing file type.So to avoid empty file name we need to check it.
      if (! String.isEmpty(fileName)) {
        file.Name = fileName;
      }
      Database.SaveResult result = Database.update(file);
      return result;
        
    } catch (Exception ex) {
      return null;
    }
  }
    
  /*
   * Upsert standard attachment under file record
   */
  public Database.UpsertResult updateAttachment() {
    
    try {       
      if (attDoc.parentId == null) {
        //att.parentId = file.Id;
        if (file.Claim__c == true && file.Pre_Approval__c == false) {
          attDoc.parentId = file.Fund_Claim__c;
        } else if (file.Claim__c == false && file.Pre_Approval__c == true) {
          attDoc.parentId = file.Fund_Request__c;
        } else if (file.Claim__c == true && file.Pre_Approval__c == true) {
          attDoc.parentId = file.Fund_Claim__c; 
        } else {
          return null;
        }
      }
                
      if (! String.isEmpty(fileName))
        attDoc.Name = fileName;
      if(fileBody != null)
        attDoc.body = fileBody;
      // reset the file for the view state
      fileBody = Blob.valueOf(' ');
            
      Database.UpsertResult  result = Database.upsert(attDoc);
            
      return result;
        
    } catch (Exception ex) {
      return null;
    }
        
  }
  
}