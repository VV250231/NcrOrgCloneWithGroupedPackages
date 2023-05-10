trigger caseFileAttachmentsDeletion on ContentDocument (before delete) {
    
    if(Trigger.isBefore && Trigger.isDelete){
        Set<id> caseIds = new Set<id>();
        List<CaseComment> ccList = new List<CaseComment>();     
        List<Id> contentDocId = new List<Id>();
        Map<Id, Id> contDocLinkedMap = new Map<Id, Id>();
        
        id disputeRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        
        for(ContentDocument con : Trigger.old){
            contentDocId.add(con.Id);
        }
        
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE 
                                       ContentDocumentId IN : contentDocId]){
                                           if(cdl.LinkedEntityId.getSobjectType() == Case.SobjectType){
                                               caseIds.add(cdl.LinkedEntityId);
                                           }
                                       }
        
        system.debug('<><><>caseIds:'+caseIds);
        for(Case c: [Select Id from Case where Id in :caseIds and Recordtypeid=:disputeRecordTypeId])
        {  
            CaseComment cc = new CaseComment();
            cc.CommentBody='ATTACHMENT DELETED'; 
            cc.ParentId=c.Id; 
            ccList.add(cc);
        }  
        system.debug('<><><>caseIds:'+ccList);
        Insert ccList;
    }
}