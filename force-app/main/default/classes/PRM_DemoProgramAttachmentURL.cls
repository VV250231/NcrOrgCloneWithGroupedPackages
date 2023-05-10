public without sharing class  PRM_DemoProgramAttachmentURL 
{
    public static String recordId {get;set;}
    
    public static List<ContentDocument> docFiles {
    get {
        docFiles = new List<ContentDocument>();
        List<ContentDocumentLink> conDocLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId ];
        Set<Id> conDocIds = new Set<Id>();
        for (ContentDocumentLink conDocLink : conDocLinkList) {
            conDocIds.add(conDocLink.ContentDocumentId);
        }
        
        docFiles = [SELECT Id, FileExtension, FileType, ContentSize, Title FROM ContentDocument WHERE  Id IN: conDocIds order by Createddate desc limit 1 ];
        return docFiles ;
        
    } set;}
    
    

}