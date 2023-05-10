/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/


public without sharing class LookupAccountSupportController {
	@AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText,String sub_fld_text){
        
       searchText='' + String.escapeSingleQuotes(searchText.trim()) + '%';
       // searchText='\'' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
       // searchText='' + searchText + '%';
       System.debug('fld_API_Search '+fld_API_Search);
                                      String query;
                                      if(fld_API_Search!=null){
         query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
            			' FROM '+objectName+
            				' WHERE ('+fld_API_Search+' LIKE :searchText';//+
                                    if(objectName == 'User'){
                                         query+=' AND isActive=true '; 
                                      } 
                                      // changed for EBA_SF-1263 - line 16 -18 by Varsha
                                      if(objectName == 'NCR_Employee_Detail__c'){
                                         query+=' OR Quicklook_id__c LIKE :searchText';//change by Varsha for the bug EBA_SF-1899
                                         query+=') AND (InActive__c=false '; 
                                      } 
                                      if(objectName=='Account'){
                                      	query+=' AND Master_customer_number__c!=null';    
                                      }
            			query+= ') LIMIT '+lim;
                                      }
                                      else{
                                          query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
            			' FROM '+objectName+
            				' WHERE (Name LIKE :searchText OR Master_customer_number__c Like: searchText) ';//+
                                      if(objectName=='Account'){
                                      	query+=' AND ( Master_customer_number__c!=null';    
                                      }
            			query+= ') LIMIT '+lim;
                                      }
        System.debug('Query '+query);
        List<sObject> sobjList = Database.query(String.escapeSingleQuotes(query));
       //List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        System.debug('Object Record '+sobjList);
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            obj.subtxt = String.valueOf(s.get(sub_fld_text));
            //obj.val = String.valueOf(s.get(fld_API_Val))  ;
            obj.ObjRecord = s;
            lstRet.add(obj);
        } 
         return JSON.serialize(lstRet) ;
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String subtxt{get;set;}
        //public String val{get;set;}
        public Object ObjRecord{get;set;}
    }
}