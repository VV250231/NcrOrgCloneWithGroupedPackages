/****************************************************************************************************************
* Author        :   Ajay Dixit
* Description   :   Tracks Credit Collection ativity, this component is to add fields dynamically to Customer Discussions section on Credit Tab in Account
****************************************************************************************************************/

public class credit_Activity_Controller {
    
/****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   objName  :   Name of Object
id   :   API Name of Picklist field
sortValues  :   Boolean decide do sort or not
* Return        :   sObject
* Description   :   pass object name and Id to get all fields for sObject record
****************************************************************************************************************/
    @AuraEnabled
    public static String getFieldsString(string objName, string excludeString) {
        
        String fieldnames = '';
        try {
            List <String> excludeList=excludeString.toLowerCase().replaceAll('; ',';').split(';');
            Set <String> excludeSet=new Set<String>();
            for(String s:excludeList){
                excludeset.add(s);
            }
            Map < String, Schema.SObjectType > m = Schema.getGlobalDescribe();
            Schema.SObjectType s = m.get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            
            //get fields
            Map < String, Schema.SObjectField > fields = r.fields.getMap();
            system.debug('##'+fields);
            for (string field: fields.keySet()) {
                system.debug('###'+field);
                if(field.containsIgnoreCase('__c') && !field.containsIgnoreCase('Account__c') && !(excludeset.contains(field.toLowerCase()))){
                    system.debug('####'+field);
                    if (fieldnames == '') {
                        fieldnames = fields.get(field).getDescribe().getName();
                    } else {
                        fieldnames += ',' + fields.get(field).getDescribe().getName();
                    }   
                }
                
            }
            system.debug('@@@'+fieldnames);
            return fieldnames;
            
        } catch (Exception e) {
            System.debug('get Fields Error' + e.getMessage());
            return 'ERROR: Error Occured fetching field.'+e.getMessage();
        }
    }
    @AuraEnabled
    public static List <String> getFields(string objName, string excludeString) {
        try{
            List <String> fieldList=new List<String>();
            List <String> fieldListFinal=new List<String>();
            
            String fields=getFieldsString(objName, excludeString);
            fieldList=fields.split(',');
            //remove id
            for(String s:fieldList){
                if(s.toLowerCase()!='id'){
                    fieldListFinal.add(s);
                }
            }
            system.debug('@@'+fieldListFinal);
            return fieldListFinal;
            
        } catch (Exception e) {
            System.debug('get Fields Error' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static Credit_Detail__c getCreditDetail(String allFields, Id creditId) 
    {  
        try{
            string qury = 'Select '+allFields+ '  FROM Credit_Detail__c WHERE Account__c =:creditId';
            Credit_Detail__c credit=Database.query(String.escapeSingleQuotes(qury));
            return credit;   
        }catch (Exception e) {
            System.debug('fetch error' + e.getMessage());
            return null;
        }
        
    } 
    
    
}