public with sharing class SearchController {
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returnQuery = '';
        String objFltr = '';
        
       if(String.isNotBlank(objectName)) {
           if(objectName == 'Account') {
              objFltr = 'RecordType.Name IN (\'Customer\',\'Partner\')'; 	    
           }
            
            returnQuery = objectName+' ( Id, '+ String.join(fields,',');             
        	if(String.isNotBlank(objFltr)) returnQuery +=  ' WHERE ' + objFltr;   
            returnQuery += ')'; 
        }
        
        String searchQuery = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+ returnQuery +' LIMIT 10';
        List<List<sObject>> searchRecords = new List<List<sObject>>();  
        List<SObject> sobjList = new List<SObject>();
        
        if(String.isBlank(searchTerm) || searchTerm.length() < 2){        
            String soqlQuery = 'SELECT Id, LastViewedDate,' + String.join(fields,',') + ' FROM ' + objectName + ' WHERE LastViewedDate != NULL';
            
            if(String.isNotBlank(objFltr)) {
            	soqlQuery += ' AND ' + objFltr;     
            } 
            soqlQuery += ' ORDER BY LastViewedDate DESC LIMIT 5';
            //soqlQuery += ' FROM RecentlyViewed WHERE Type =\''+objectName+'\' ORDER BY LastViewedDate DESC LIMIT 5';
            System.debug(soqlQuery);
            sobjList = Database.query( soqlQuery );
            searchRecords.add(sobjList);
        }else{
            searchRecords = Search.Query(searchQuery);
        }
        return searchRecords.get(0);
    }

    @AuraEnabled
    public static sObject getRecentlyCreatedRecord(String recordId, List<String> fields, String objectName){
        sObject createdRecord;
        try {
            String query = 'SELECT Id, '+String.join(fields,',')+' FROM '+objectName+' WHERE Id = \''+recordId+'\'';
            List<SObject> sobjList = Database.query( query );
            createdRecord = sobjList.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return createdRecord;
    }
}