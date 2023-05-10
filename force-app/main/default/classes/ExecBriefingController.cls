/*
##################################################################################################
# Project Name && Request Num..........: Executive Briefing 
# File............................: ExecutiveBriefingController.cls                                                        
# Created by................: Mohammad Ahad                                                                   
# Created Date...........: 22/08/2017                                                                              
# Last Modified by......:  Mohammad Ahad
# Last Modified Date..: 16/11/2017
# Description...............: This class is used in ExecutiveBriefingDetailComponent for Executive Briefing Project.
################################################################################################
*/

public without sharing class ExecBriefingController {
    @AuraEnabled
    public static list<Executive_Briefing__c> getReqFields(Id recordId) {
        return[
            Select Id, Name, Name__r.name, Cloud_Revenue_2015__c, HW_Revenue_2015__c, SW_Revenue_2015__c, Cloud_Revenue_2016__c, HW_Revenue_2016__c,
            SW_Revenue_2016__c, Cloud_YTD_Actual_2017__c, HW_YTD_Actual_2017__c, SW_YTD_Actual_2017__c from Executive_Briefing__c 
            where Name__r.id =: recordId
    ];
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = 
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Executive_Briefing__c' ];
        return listviews;
    }
    @AuraEnabled 
    public static Map<String,String> getLabelofEXBFields(){
        List<String> LableList=new List<String>();
        String type='Executive_Briefing__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,String> ApiLabelMap=new Map<String,String>();
        Schema.SObjectType ExBSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = ExBSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            if(!ApiLabelMap.containsKey(fieldName)){
                ApiLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
            } 
        }
        system.debug('***'+ ApiLabelMap);
        return ApiLabelMap;
        
    }
    
    @AuraEnabled
    public static String getUserProfile(Id Accountid)  
    {
        String ProfileAccess = [select id,name from profile where id=:userinfo.getProfileId()][0].Name;
        
        if(ProfileAccess.contains('Admin') )
        {
            return 'HaveAccess';  
        } 
         
       else if(!ProfileAccess.contains('Admin') ){
            return 'HaveNOAccess';     
        }   
        else   
        return 'NoAccessAtAll'; 
      } 
 
}