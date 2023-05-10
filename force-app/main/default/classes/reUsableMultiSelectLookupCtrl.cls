public With Sharing class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, string filerName, string filerValue) {
        List<String> accountId = new List<String>{filerValue};
        List<String> fltrValues = new List<String>{filerValue};    
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
 
        List<string> lstExcludeitems = new List<string>(); 
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id); 
        }
        
        if(ObjectName == 'user') lstExcludeitems.add(UserInfo.getUserId());
        
        String sQuery; 
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        if(ObjectName =='opportunity'){
           sQuery =  'select id, Name,Opportunity_Number__c,AccountId,StageName from ' + ObjectName + ' where Opportunity_Number__c LIKE :searchKey'; 
        }else if(ObjectName == 'contact') {
           sQuery =  'select id, Name,AccountId from ' +ObjectName + ' where Name LIKE :searchKey';
        } else if(ObjectName == 'user') {
            if (String.isNotBlank(searchKeyWord)) {
        		sQuery = 'SELECT Id, Name, Quicklook_ID__c from '  + ObjectName + ' WHERE isActive = true AND Name LIKE :searchKey';
            } else {
            	sQuery = 'SELECT Id, Name, Quicklook_ID__c from '  + ObjectName + ' WHERE isActive = true AND LastViewedDate != NULL';    
            }
        }
        
        if (String.isNotBlank(filerName)) {     
        	sQuery += ' AND ' + filerName + ' IN :fltrValues';	    
        }          
        
        sQuery += ' AND Id NOT IN :lstExcludeitems';
        
        if (ObjectName == 'user' && String.isBlank(searchKeyWord)) {
        	 sQuery += ' ORDER BY LastViewedDate DESC';    
        } else {
       		 sQuery += ' ORDER BY CREATEDDATE DESC';    
        }
       
        sQuery += ' LIMIT 5';
        System.debug(sQuery);
        
        List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    public static List<sObject> getRecentRecords(String ObjectName, String FieldNames) {
        String dynamicQuery = 'SELECT ' + FieldNames + ' FROM ' + ObjectName + ' WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5';
        System.debug(dynamicQuery);
        List<sObject> recordList = Database.Query(String.escapeSingleQuotes(dynamicQuery));
        return recordList;
    }  
    
    @AuraEnabled
    Public Static String AddMultipleContactToTicketRequest(List<SObject> Junction_Ticket_Contact){
       
        
        try{
            system.debug(':::::'+Junction_Ticket_Contact);
            insert Junction_Ticket_Contact;
            system.debug(':::::'+Junction_Ticket_Contact);  
            return 'success';
        }
        catch(Exception ex){AuraHandledException e = new AuraHandledException(ex.getMessage());throw e;}
        //return '';        
    }
    
    
    
    
}