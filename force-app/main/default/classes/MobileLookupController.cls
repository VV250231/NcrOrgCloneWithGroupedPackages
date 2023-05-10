/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/

public with sharing class MobileLookupController {

    @RemoteAction
    public static List<sObject> getRecentRecords(String ObjectName, String FieldNames) {
        String dynamicQuery = 'SELECT ' + FieldNames + ' FROM ' + ObjectName + ' WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5';
        //List<sObject> =
        System.debug(dynamicQuery);
        List<sObject> recordList = Database.Query(String.escapeSingleQuotes(dynamicQuery));
        return recordList;
    }    
    
    @RemoteAction
    public static List<sObject> searchRecords(String searchStr, String ObjectName, String FieldNames) {
        List<sObject> recordList = new  List<sObject>();
        
        
        if(String.isNotBlank(searchStr)) {
            String whereCondition = searchStr.trim() + '%';
            String dynamicQuery = 'SELECT ' + FieldNames + ' FROM ' + ObjectName +' WHERE Name like :whereCondition ORDER BY LastModifiedDate DESC LIMIT 5 ';
            System.debug(dynamicQuery);
            recordList = Database.Query(String.escapeSingleQuotes(dynamicQuery));
            System.debug(recordList);
        } else {
            recordList = getRecentRecords(ObjectName,FieldNames);   
        }
        return recordList;
    }   
    
   

}