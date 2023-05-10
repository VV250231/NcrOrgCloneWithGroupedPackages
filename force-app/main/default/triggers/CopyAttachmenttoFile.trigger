trigger CopyAttachmenttoFile on Attachment (after insert) {
    Set<Id> parentOppIds = new Set<Id>();
    
    for(Attachment att :Trigger.new) {
        System.debug('isprivate==='+ att.isprivate);
        String attParentId = att.ParentId;
        
        if(attParentId.startsWith('006')) {
        	parentOppIds.add(attParentId); 
        }
    }   
        
    if(!parentOppIds.isEmpty()) {
       Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Account.Subscription_Group__c FROM Opportunity WHERE Id IN :parentOppIds and Account.Subscription_Group__c = 'Digital Insight']);
       Map<Id, ContentVersion> attchIdAndctVrMap = new Map<Id,ContentVersion>(); 
       Map<Id, ContentVersion> cntVrsMap = new Map<Id, ContentVersion>();
       
       if (!oppMap.isEmpty()) {
           for(Attachment att :Trigger.new) {
                String attParentId = att.ParentId;
               
                if (attParentId.startsWith('006') && oppMap.containsKey(attParentId)) {
                    ContentVersion cv = new ContentVersion();   
                    cv.title = att.Name;
                    cv.Description = att.Description;
                    cv.VersionData =  att.Body;
                    cv.PathOnClient = att.Name; 
                    cv.Origin = 'H';
                    cv.FirstPublishLocationId = att.OwnerId;
                    attchIdAndctVrMap.put(att.id, cv);    
                }
           }
       }
        
       if (!attchIdAndctVrMap.isEmpty()) { 
            insert attchIdAndctVrMap.values();
            
            Set<Id> cvIds = new  Set<Id>();               
            for(ContentVersion cv : attchIdAndctVrMap.values()) {
                cvIds.add(cv.Id);    
            }         

            cntVrsMap = new Map<Id, ContentVersion>([Select Id, ContentDocumentId FROM ContentVersion where Id IN :cvIds]);
           
            List<ContentDocumentLink> cntLnkLst = new List<ContentDocumentLink>(); 
            for (Id attmntId : attchIdAndctVrMap.keySet()) {                
            	ContentDocumentLink clink = new ContentDocumentLink();
                clink.ContentDocumentId  = cntVrsMap.get(attchIdAndctVrMap.get(attmntId).Id).ContentDocumentId;
                clink.LinkedEntityId = Trigger.newMap.get(attmntId).ParentId;
                clink.ShareType = 'V';
                cntLnkLst.add(clink);
            }
           
            if(!cntLnkLst.isEmpty()) insert cntLnkLst;
       }
       
    }
}