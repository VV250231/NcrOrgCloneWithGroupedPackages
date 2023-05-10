/*************************************************************************************************
* Author        :   Varsha  
* Date          :   29th sept 2021
* Param         :   
* Return        :   
* Description   :   This class will handle the fileAttachmentTrigger Logic
# Modification History.: 
Story No#         Date            DevName           		Description
EBA_SF-1446    29th Sep 2021    Varsha Pal         Consolidation of ContentDocumentLink trigger                  
***************************************************************************************************/
public class FileTriggerHandler {
    public static id disputeRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
    public static void insrtCaseCmnt(List<ContentDocumentLink> docs,String action){
        Set<id> caseIds = new Set<id>();
        List<CaseComment> ccList = new List<CaseComment>();   
        for(ContentDocumentLink cd : docs){
            //Check if added attachment is related to Case or not
            if(cd.LinkedEntityId.getSobjectType() == Case.SobjectType){
                caseIds.add(cd.LinkedEntityId);
            }
        }
        if(!caseIds.isEmpty()){
            for(Case c: [Select Id from Case where Id in :caseIds and Recordtypeid=:disputeRecordTypeId])
            {
                CaseComment cc = new CaseComment();
                if(action=='insert'){
                    cc.CommentBody='ATTACHMENT ADDED'; 
                }else{
                	cc.CommentBody='ATTACHMENT DELETED'; 
                }
                cc.ParentId=c.Id; 
                ccList.add(cc);
            }  
            Insert ccList;    
        }
    }
    /*public static void insrtCaseCmntOnFileDelete(List<ContentDocumentLink> docs){
        Set<id> caseIds = new Set<id>();
        List<CaseComment> ccList = new List<CaseComment>();   
        for(ContentDocumentLink cd : docs){
            //Check if added attachment is related to Case or not
            if(cd.LinkedEntityId.getSobjectType() == Case.SobjectType){
                caseIds.add(cd.LinkedEntityId);
            }
        }
        if(!caseIds.isEmpty()){
            for(Case c: [Select Id from Case where Id in :caseIds and Recordtypeid=:disputeRecordTypeId])
            {  
                CaseComment cc = new CaseComment();
                cc.CommentBody='ATTACHMENT DELETED'; 
                cc.ParentId=c.Id; 
                ccList.add(cc);
            }  
            Insert ccList;  
        }
    }*/
    public static void delImgOnFileDelete(List<ContentDocumentLink> docs){
        Set<id> Imageids = new Set<id>();
        Integer casesAssociatedWithImage;
        List<ContentDocument> contentDocumentToDelete = new List<ContentDocument>();
        for(ContentDocumentLink cdl : docs){
            Imageids.add(cdl.ContentDocumentId); // Take Id of parentid- Actual Image  
        }
        
        //Count number of cases on which parentid is above id
        if(!Imageids.isEmpty()){
            List<AggregateResult> results=[SELECT count(LinkedEntityId) cases FROM ContentDocumentLink where ContentDocumentId in :Imageids  group by ContentDocumentId];
            if(results.size()>0){
            	casesAssociatedWithImage= (Integer) results[0].get('cases');
            }
            //Check if number of cases is equal to 1, if yes then delete
            if(casesAssociatedWithImage ==1){
                for(Id cid : Imageids) 
                {  
                    ContentDocument cd = new ContentDocument(id=cid);
                    contentDocumentToDelete.add(cd);
                }
                
                if(contentDocumentToDelete != null && contentDocumentToDelete.size()>0)
                    Delete contentDocumentToDelete;
            }
        }
    }   
    
    Public static void updateDealsDeskCase(List<ContentDocumentLink> docs){
         Set<id> caseIds = new Set<id>();
        List<Case> ccList = new List<Case>();     
        List<Id> contentDocId = new List<Id>();
        Map<Id, Id> contDocLinkedMap = new Map<Id, Id>();
        
        id DDRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Deals Desk').getRecordTypeId();
        
        for(ContentDocumentLink cdl : docs){ 
                                           if(cdl.LinkedEntityId.getSobjectType() == Case.SobjectType){
                                               caseIds.add(cdl.LinkedEntityId);
                                           }
                                       }
        
        system.debug('<><><>caseIds:'+caseIds);
        for(Case c: [Select Id from Case where Id in :caseIds and Recordtypeid=:DDRecordTypeId])
        {  
            Case cc = new Case();
            cc.id=c.id;
            ccList.add(cc);
        }  
        system.debug('<><><>caseIds:'+ccList);
        update ccList;
    }
    
    
}