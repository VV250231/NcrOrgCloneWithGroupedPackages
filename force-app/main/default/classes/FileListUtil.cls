/* Created By : Shiv (sm250665)
 * Utility class to return wrapper list for the custom file
 * Following Singleton design pattern
 */

/**************************************
Author ...............: Shiv (sm250665)
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/
public with sharing class FileListUtil {
	
  private static FileListUtil instance = new FileListUtil();
  
  private fileListUtil() {
    System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
  }
  
  public static FileListUtil getInstance() {
  	return instance;
  }
  
  /*
   *
   * @parentId : Id of the parent record for which you want to get associated files.
   * @parentObjectAPIName : API name of the parent object of which reocrd id you are passing above.
   * @ParentFieldAPIName : API name of the lookup filed.
   * @queryFields : field list of the file record which you want to fetch.
   */
  public List<AttachmentWrapper> createFileList(Id parentId,String parentObjectAPIName, String ParentFieldAPIName, String[] queryFields) {
  		
  	List<AttachmentWrapper> fileWrapperList = new List<AttachmentWrapper>();
  	
    //create dynamic query
  	String queryStr = 'SELECT Id, Name, ( SELECT ';
  	  
  	//At least 1 field need to be pass
  	if(queryFields != null && queryFields.size() > 0) { 			
  	  for(String queryField : queryFields) {
  		queryStr += queryField+',';
      }
  		
  	} else {
  	  //return empty string
  	  return fileWrapperList;
  	}
  	
  	queryStr =queryStr.substringBeforeLast(',') +' FROM Files__r), ';
  	
  	//Adding attachment filed list to file field list.	
  	queryStr += '(SELECT Id, Name, ContentType,CreatedDate, LastModifiedDate FROM Attachments) FROM '+ parentObjectAPIName +' WHERE Id =: parentId LIMIT 1';  		 		
  	//Creating wrapper list to show data on UI
  	system.debug('####'+queryStr);
  	List<sObject> sObjectList = Database.query(String.escapeSingleQuotes(queryStr));
  	system.debug('+++++'+sObjectList);
  		
  	if(sObjectList == null || !(sObjectList.size() > 0)) {
  	  //return empty string
  	  return fileWrapperList;
  	} 
  	
  	// If object is SFDC_MDF__c
  	if (parentObjectAPIName == 'SFDC_MDF__c') {
  	  SFDC_MDF__c mdfReq = (SFDC_MDF__c) sObjectList[0];
  	  
  	  Map<Id,File__c> attIdToFileMap = new Map<Id,File__c>();
  	  Map<Id,Attachment> attMap = new Map<Id,Attachment>();
  	  
  	  for (File__c rec : mdfReq.Files__r) {
  	    if (! String.isBlank(rec.Attachment_ID__c)) {
  	      attIdToFileMap.put(rec.Attachment_ID__c,rec);
  	    }
  	  }
  	   	  
  	  for(Attachment attRec : mdfReq.Attachments){
  	  	if (attIdToFileMap.get(attRec.Id) != null) {
        		fileWrapperList.add(new AttachmentWrapper(attIdToFileMap.get(attRec.Id),attRec));
  	  	}
      }
      
  	}
  	
  	// If object is SFDC_MDF_Claim__c
  	if (parentObjectAPIName == 'SFDC_MDF_Claim__c') {
  	  SFDC_MDF_Claim__c mdfClaim = (SFDC_MDF_Claim__c) sObjectList[0];
  	  
  	  Map<Id,File__c> attIdToFileMap = new Map<Id,File__c>();
  	  Map<Id,Attachment> attMap = new Map<Id,Attachment>();
  	  
  	  for (File__c rec : mdfClaim.Files__r) {
  	    if (! String.isBlank(rec.Attachment_ID__c)) {
  	      attIdToFileMap.put(rec.Attachment_ID__c,rec);
  	    }
  	  }
  	   	  
  	  for(Attachment attRec : mdfClaim.Attachments){
  	  	if (attIdToFileMap.get(attRec.Id) != null) {
        		fileWrapperList.add(new AttachmentWrapper(attIdToFileMap.get(attRec.Id),attRec));
  	  	}
      }
  	}
  	/*	
  	List<File__c> fileList = (List<File__c>)sObjectList ;	
  	for(File__c file : fileList) {
  	  for(Attachment attRec : file.Attachments){
		fileWrapperList.add(new AttachmentWrapper(file,attRec));
      }
  	}
  	*/
  	return fileWrapperList;
  		
  }
  
  // Wrapper Class
  public with sharing class AttachmentWrapper {
    public File__c file {get;set;}
	public Attachment att {set;get;}
	    
	public string getLink() {
	  if(att != null) {
	  	return '/servlet/servlet.FileDownload?file='+att.id;
	  } else {
	  	return '';
	  }  
	}
	    
    public string getSize() {
      if (att != null) {
        return ''+(att.BodyLength/1024)+' KB';
      }
      return '';
    }
	        
    public AttachmentWrapper(Attachment att) {
      this.att = att;
    }  
	    
    public AttachmentWrapper(File__c file, Attachment att){
      this.file = file;
      this.att  = att;
    }
  }

}