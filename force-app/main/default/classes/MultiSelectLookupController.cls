/*##################################################################################################
# Description...........: This class is for CEC functionality.This class is controller class 
of LWC - lwcMultiSelectLookup 
# Created by......: Sushant, Saurav, Yogesh, Monika 
# Created Date....: Nov 2021. 
# Story Number ......: EBA_SF-1607 , EBA_SF-1606 , EBA_SF-1605 , EBA_SF-1554
##################################################################################################*/
public with sharing class MultiSelectLookupController {
    //This method retrieves the data from database table. It search input is '*', then retrieve all records
    @AuraEnabled (cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, String fieldAPINames,String filterFieldAPIName,String strInput,String objid){
        
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')){
            strInput = '';
        }
        String str = strInput + '%';
        String strQueryField = '';
        List<String> fieldList = fieldAPINames.split(',');
        List<String> temp =  filterFieldAPIName.split(','); 
        String strQuery ='';   
        system.debug('objid'+objid);
        
        //fieldList.add('AccountId');
        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }
        
        
        if(objectName !='Opportunity') {
            strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                + ' FROM ' 
                + String.escapeSingleQuotes(objectName) 
                + ' WHERE ' + String.escapeSingleQuotes(temp.get(0)) + '  LIKE \'' + str + '%\''
                + ' ORDER BY ' + filterFieldAPIName
                + ' LIMIT 50';
        } 
        
        else{
            temp.add('AccountId');
            if(objid.startsWith('006')){
                opportunity accIds = [Select Accountid,id from opportunity where id=:objid];
                objid =String.ValueOf(accIds.AccountId);
            }
            strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                + ' FROM ' 
                + String.escapeSingleQuotes(objectName) 
                + ' WHERE (' + String.escapeSingleQuotes(temp.get(0)) + '  LIKE \'' + str + '%\''
                + ' OR ' + String.escapeSingleQuotes(temp.get(1)) + '  LIKE \'' + str + '%\''
                + ') AND ' + String.escapeSingleQuotes(temp.get(2)) +' =\''+ objid +'\''
                + 'AND Stagename Not In (\'Closed/Booked\',\'Closed/Booked - NonFunnel\', \'Closed/Lost\') ' 
                + ' ORDER BY ' + String.escapeSingleQuotes(temp.get(0))
                + ' LIMIT 50';                                                            
        }
        
        
        System.debug('strQuery=' + strQuery);
        System.debug('objid=' + objid);
        
        List<SObject> lstResult = database.query(strQuery);
        System.debug('lstResult=' + lstResult);
        System.debug('fieldList'+fieldList);
        //create list of records that can be easily be parsable at js controller.
        for(String strField:fieldList){
            for(SObject sobj:lstResult){                
                
                if(strField != 'Id' && strField != 'Name' && objectName !='Opportunity'){
                    SObjectQueryResult result = new SObjectQueryResult();
                    result.recordId = (String) sobj.get('Id');
                    result.recordName = (String) sobj.get('Name');
                    result.recordEmail = (String) sobj.get(strField);
                    lstReturnResult.add(result);
                }
                
                if(strField != 'Id' && strField != 'Name' && strField != 'AccountId' && objectName =='Opportunity'){
                    SObjectQueryResult result = new SObjectQueryResult();
                    result.recordId = (String) sobj.get('Id');
                    result.recordName = (String) sobj.get('Name');
                    result.recordOppId = (String) sobj.get('Opportunity_Number__c');
                    lstReturnResult.add(result);
                }
            }
        }
        
        return lstReturnResult;
    }
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;
        
        @AuraEnabled
        public String recordName;
        
        @AuraEnabled
        public String recordEmail;
        
        @AuraEnabled
        public String recordOppId;
    }
    
}