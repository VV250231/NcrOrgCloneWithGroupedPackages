public class ReparentingOfContentlink {
		
    @InvocableMethod(label='Update for Contentlink')
    public static void UpdateContentLink(List<CaseContentLogWrapper> requests)
    {
         Set<Id> recordIds=new Set<Id>{requests[0].RequestLogId};
         List<ContentDocumentLink>  insertLinks = new List<ContentDocumentLink>();
         List<ContentDocumentLink>  deleteLinks  = new List<ContentDocumentLink>();
        
         List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds]; 
         for(ContentDocumentLink cdLink:cdl){
                
                ContentDocumentLink newclnk = cdLink.clone();
  				newclnk.linkedentityid = requests[0].CaseId; 
                insertLinks.add(newclnk);
                deleteLinks.add(cdLink);
             
             
         }//This ID is the New Contract Id.
                 
 			insert insertLinks; //Insert the new ContentDocumentLink with new Contract.
  			Delete deleteLinks; //Delete the Old ContentDocumentLink with old Contract.
        	
   }
  
    
    Public class CaseContentLogWrapper{
      
        @InvocableVariable(required=true description='The pending Work Item Id to approve/reject' label='Case Id')
        public Id CaseId;
        @InvocableVariable(required=true description='Comments on why the user is approving/rejecting the record' label='RequestLogId')
        public Id RequestLogId;
    }
}