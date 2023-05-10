/****************************************************************************************************************
*   ClassName :   BatchNotesAndAttachmentConverter
*   Description :   This batch class is used to convert old attachment and notes to files and new notes
*   Author      :    Kapil Bhati 
*   Version     :   Initial

****************************************************************************************************************/
global class BatchNotesAndAttachmentConverter implements Database.Batchable<sObject> {
   // Created to store object name used to query note and attachment records
    global String parentType;
    // Contains filetype which can be either attachment or notes
    global string fileType;
    global BatchNotesAndAttachmentConverter(string parentType,string fileType){
        this.parentType = parentType;
        this.fileType = fileType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        if(fileType=='Attachment'){
            return Database.getQueryLocator('SELECT Id, ParentId, Name,Description, CreatedById,  CreatedDate, LastModifiedById, LastModifiedDate,  OwnerId, isPrivate, Body  FROM Attachment where  Parent.Type =:parentType');
        }
        else{
            return Database.getQueryLocator('SELECT Id, CreatedById, ParentId, Title, Body,CreatedDate, LastModifiedById, LastModifiedDate FROM Note where Parent.Type=:parentType');
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
         // process each batch of records default size is 200
        Savepoint sp = Database.setSavepoint(); 
        if(fileType=='Attachment'){
            try{
                Map<Id, List<Blob>> mapAttachmentIdLstBlob = new Map<Id, List<Blob>>();
                Map<Id, Attachment> mapIdAttachment = new Map<Id, Attachment>();
                for(sObject s: scope){
                    Attachment attach = (Attachment)s;
                    String bodyCont = attach.Body!=null ? String.valueOf(attach.Body).replace('&','&amp;')
                        .replace('<','&lt;').replace('>','&gt;')
                        .replace('"','&quot;').replace('\'','&#39;'):'.';
                    
                    Blob tmpBlob = Blob.valueOf(bodyCont);
                    if(!mapAttachmentIdLstBlob.containsKey(attach.Id)){
                        mapAttachmentIdLstBlob.put(attach.Id, new List<Blob>());
                    }
                    mapAttachmentIdLstBlob.get(attach.Id).add(tmpBlob);
                    mapIdAttachment.put(attach.Id, attach);
                }
                // converting old attachment to file
                Map<Id, List<ContentVersion>> mapActIdLstCV =  createContentVersionAttachment(mapAttachmentIdLstBlob, mapIdAttachment);
                List<ContentDocumentLink> lstCVDL = updateContentDocLink(mapActIdLstCV);
            }Catch(Exception ex){
                Database.rollback(sp);
                System.debug('Error-> '+ex.getLineNumber()+' Message : '+ex.getMessage());
                throw ex;
            }
        }
        else{
            try{
                Map<Id, List<Blob>> mapNoteIdLstBlob = new Map<Id, List<Blob>>();
                Map<Id, Note> mapIdNote = new Map<Id, Note>();
                
                for(sObject s: scope){
                    Note n = (Note)s;
                    System.debug('aaa'+ n.Id);
                    String bodyCont = n.Body!=null ? String.valueOf(n.Body).replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace('\'','&#39;'):'.';
                    Blob tmpBlob = Blob.valueOf(bodyCont);
                    if(!mapNoteIdLstBlob.containsKey(n.Id)){
                        mapNoteIdLstBlob.put(n.Id, new List<Blob>());
                    }
                    mapNoteIdLstBlob.get(n.Id).add(tmpBlob);
                    mapIdNote.put(n.Id, n);
                    
                }
                // converting old notes to enhanced notes
                Map<Id, List<ContentVersion>> mapActIdLstCV = createContentVersionNotes(mapNoteIdLstBlob, mapIdNote);
                List<ContentDocumentLink> lstCVDL = updateContentDocLink(mapActIdLstCV);
            }Catch(Exception ex){
                Database.rollback(sp);
                System.debug('Error-> '+ex.getLineNumber()+' Message : '+ex.getMessage());
                throw ex;    
            } 
        }
    }
    
    
    global void finish(Database.BatchableContext BC){
        // sending email after post-processing operations
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));      
    }
    
    // Method used to create content version record from the old attachment record
    public static Map<Id, List<ContentVersion>> createContentVersionAttachment(Map<Id, List<Blob>> mapNoteIdLstBlob, Map<Id, Attachment> mapAttachment){
        Savepoint sp = Database.setSavepoint();  
        Map<String, String> attachVsCVMap = new  Map<String, String>(); 
        for(ContentVersion cv : [SELECT Id, Original_Record__c FROM ContentVersion WHERE Original_Record__c IN :mapAttachment.keySet()]) {
            attachVsCVMap.put(cv.Original_Record__c, cv.Id);                                                                     
        }
        Map<Id, List<ContentVersion>> contentVersionMap = new Map<Id, List<ContentVersion>>();
        List<ContentVersion> newFileVersionList = new List<ContentVersion>();
        
        for(Id attachmentId : mapNoteIdLstBlob.keySet()) {
            if(!attachVsCVMap.containsKey(attachmentId)) {
                List<Blob> noteBlob = mapNoteIdLstBlob.get(attachmentId);
                
                for(Blob b:noteBlob){
                    ContentVersion newFileVersion = new ContentVersion(
                        versionData 			 = mapAttachment.get(attachmentId).body,
                        title 				     = mapAttachment.get(attachmentId).name,
                        description 			 = mapAttachment.get(attachmentId).description,
                        pathOnClient 			 = '/' + mapAttachment.get(attachmentId).name,
                        firstPublishLocationId   = mapAttachment.get(attachmentId).parentId,
                        sharingPrivacy 			 = ( mapAttachment.get(attachmentId).isPrivate ? 'P' : 'N' ),
                        createdById 			 = mapAttachment.get(attachmentId).ownerId,
                        createdDate 			 = mapAttachment.get(attachmentId).createdDate,
                        lastModifiedById 		 = mapAttachment.get(attachmentId).lastModifiedById,
                        lastModifiedDate	     = mapAttachment.get(attachmentId).lastModifiedDate,
                        Original_Record__c = mapAttachment.get(attachmentId).id,
                        Parent_Record_Id__c = mapAttachment.get(attachmentId).parentId
                    );             
                    newFileVersionList.add(newFileVersion);
                    if(!contentVersionMap.containsKey(mapAttachment.get(attachmentId).ParentId)){
                        contentVersionMap.put(mapAttachment.get(attachmentId).ParentId,new List<ContentVersion>());    
                    }
                    contentVersionMap.get(mapAttachment.get(attachmentId).ParentId).add(newFileVersion);    
                }
            }
        }
        try{
            insert newFileVersionList;
            return contentVersionMap;
        }catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
    }
    
     // Method used to update content version document with content document link
    public static List<ContentDocumentLink> updateContentDocLink(Map<Id, List<ContentVersion>> actIdLstCVMap){
        Set<String> cvSet = new Set<String>();
        Map<Id, Id> cvIdMap = new Map<Id, Id>();
        Set<Id> cdIds = new Set<Id>();
        Map<String, ContentDocumentLink> cntDocMap = new Map<String, ContentDocumentLink>();
        List<ContentDocumentLink> cdlLst = new List<ContentDocumentLink>();
        if(!actIdLstCVMap.isEmpty()) {
            for(Id accId: actIdLstCVMap.KeySet()){
                for(ContentVersion cv: actIdLstCVMap.get(accId)){
                    cvSet.add(cv.Id);
                    cvIdMap.put(cv.Id, accId);
                }
            }
            List<ContentVersion> cvLst = [SELECT ContentDocumentId FROM ContentVersion WHERE (Id IN :cvSet)];
            
            for(ContentVersion cv : cvLst) {
                cdIds.add(cv.ContentDocumentId);    
            }
            for(ContentDocumentLink cdl: [SELECT Id, ContentdocumentId, LinkedEntityId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN :actIdLstCVMap.keySet() AND ContentdocumentId IN :cdIds]) {
                cntDocMap.put(cdl.ContentdocumentId + '-' + cdl.LinkedEntityId, cdl);    
            }
            for(ContentVersion cv: cvLst){
                String parentId = cvIdMap.get(cv.Id);
                ContentDocumentLink exstCDL = cntDocMap.get(cv.ContentDocumentId + '-' + parentId);
                if(exstCDL == NULL) {
                    ContentDocumentLink cdl 	= new ContentDocumentLink(); 
                    cdl.ContentDocumentId 		= cv.ContentDocumentId; 
                    cdl.LinkedEntityId 			= cvIdMap.get(cv.Id); 
                    cdl.ShareType 				= 'I'; 
                    cdlLst.add(cdl);
                } else if(exstCDL.ShareType != 'I'){
                    exstCDL.ShareType = 'I'; 
                    cdlLst.add(exstCDL);
                }
            }
            upsert cdlLst;
        }
        return cdlLst;
    }
     // Method used to create content version record from the old notes record
    public static Map<Id, List<ContentVersion>> createContentVersionNotes(Map<Id, List<Blob>> mapNoteIdLstBlob,Map<Id, Note> mapIdNote){
        Map<String, String> noteVsCVMap = new  Map<String, String>(); // 
        
        for(ContentVersion cv : [SELECT Id, Original_Record__c FROM ContentVersion WHERE Original_Record__c IN :mapIdNote.keySet()]) {
            System.debug('origial record>>' + cv.Original_Record__c);
            noteVsCVMap.put(cv.Original_Record__c, cv.Id);                                                                     
        }
        /*Set<Id> parentIds = new Set<Id>();
        Set<Id> cdIds = new Set<Id>();
        
        for(note n : mapIdNote.values()) {
       		parentIds.add(n.ParentId);    
        }
        
        List<ContentDocumentLink> cdLinkLst = [Select Id, ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId IN :parentIds];
        
        for(ContentDocumentLink cd : cdLinkLst) {
        	cdIds.add(cd.ContentDocumentId);	    
        }
            
        List<ContentVersion> cvLst = [SELECT Id, Original_Record__c FROM ContentVersion where ContentDocumentId IN :cdIds];
        
        for(ContentVersion cv : cvLst) {
        	System.debug('origial record>>' + cv.Id + '>>' + cv.Original_Record__c);
            noteVsCVMap.put(cv.Original_Record__c, cv.Id); 
        }*/
        
        
        Map<Id, List<ContentVersion>> retMap = new Map<Id, List<ContentVersion>>();
        List<ContentVersion> lstCV = new List<ContentVersion>();
        for(Id noteId : mapNoteIdLstBlob.keySet()){
            if(!noteVsCVMap.containsKey(noteId)) {
                List<Blob> noteBlob = mapNoteIdLstBlob.get(noteId);
                system.debug('noteBlob size=='+ noteBlob.size());
                for(Blob b:noteBlob){
                    ContentVersion cv   = new ContentVersion();
                    cv.ContentLocation  = 'S';
                    cv.VersionData 		= b;
                    cv.CreatedById 		= mapIdNote.get(noteId).CreatedById;
                    cv.Title 			= mapIdNote.get(noteId).Title;  
                    cv.PathOnClient 	= mapIdNote.get(noteId).Title+'.snote';  
                    cv.Original_Record__c = noteId;
                    cv.Parent_Record_Id__c =mapIdNote.get(noteId).ParentId;
                    cv.createdById 			 = mapIdNote.get(noteId).CreatedById;
                    cv.createdDate 			 = mapIdNote.get(noteId).createdDate;
                    cv.lastModifiedById 		 = mapIdNote.get(noteId).lastModifiedById;
                    cv.lastModifiedDate	     = mapIdNote.get(noteId).lastModifiedDate;
                    lstCV.add(cv);
                    if(!retMap.containsKey(mapIdNote.get(noteId).ParentId)){
                        retMap.put(mapIdNote.get(noteId).ParentId,new List<ContentVersion>());    
                    }
                    retMap.get(mapIdNote.get(noteId).ParentId).add(cv);    
                }
            }
        }
        INSERT lstCV;
        return retMap;
    }
    
}