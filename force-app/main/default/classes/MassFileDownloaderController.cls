public with sharing class MassFileDownloaderController {
    
@AuraEnabled(cacheable=true)
public static ContentDocumentLink[] getFiles(String[] caseId) {
    
        List<ContentDocumentLink> ct=[ SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.FileExtension, 
        ContentDocument.LatestPublishedVersionId  FROM ContentDocumentLink 
        where LinkedEntityId IN :caseId and LinkedEntity.Type='Case'];
        System.debug('Test: '+ct);
        return ct;
        //SELECT
        //Id, Title, FileExtension, LatestPublishedVersionId
        //FROM ContentDocument where Title in ('nsc_sha2_2022','error102722111353768')

}

@AuraEnabled(cacheable=true)
public static ContentDocument[] getFilesByIds(String[] contentDocumentIds, String[] caseId) {
    return [
        SELECT
        Id, Title, FileExtension, LatestPublishedVersionId
        FROM ContentDocument
        WHERE Id IN :contentDocumentIds and Parentid = :caseId
    ];
}

@AuraEnabled(cacheable=true)
public static Case[] getCases(String searchKey, String sortBy,String sortDirection) {
List<Case> cs = new List<Case>();
List<Case> finalCs = new List<Case>();
String rName = '%' + 'Deals' + '%';
String query = 'Select Id, LastModifieddate,LastModifiedby.Name,Status,CaseNumber, Subject, Description,(Select id from contentdocumentlinks) FROM Case';
query += ' Where RecordType.Name LIKE :rName';

if ( searchKey != null && searchKey != '' ) {   
    String key = '%' + searchKey + '%';
    query += ' AND CaseNumber LIKE :key';
}

if ( sortBy != null && sortDirection != null ) {
    query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
}
system.debug('query---'+query);
cs = Database.query( query );
for(Case c: cs){
if(c.contentdocumentlinks !=null && (c.contentdocumentlinks).size() > 0)
finalCs.add(c);
}
return finalCs;
}
}