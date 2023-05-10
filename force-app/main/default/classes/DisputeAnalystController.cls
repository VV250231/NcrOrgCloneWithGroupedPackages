public class DisputeAnalystController {

    @AuraEnabled
    Public static List<PicklistWrapperClass> getPicklistValues(String objectName,String fieldName){
        
        List<PicklistWrapperClass> picklistWrapper = new List<PicklistWrapperClass>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            PicklistWrapperClass wrapObj = new PicklistWrapperClass();
            wrapObj.Label=pickListVal.getLabel();
            wrapObj.value=pickListVal.getValue();
            picklistWrapper.add(wrapObj);
        } 
        
        return picklistWrapper;
    }
    
    Public Class PicklistWrapperClass{
       @AuraEnabled
       Public String Label;
       @AuraEnabled
       Public String value;
    }
    
    @AuraEnabled 
    Public Static User GetUserDetailUsingQuickLookid(String Quklookid){
        List<User> UserObj = new List<User>();
       
            if(String.isNotBlank(Quklookid)){
             UserObj = [Select Id,Name,Email,Quicklook_ID__c,Phone from User where Quicklook_ID__c =:Quklookid and isActive=true limit 1];
           }

            if(UserObj.size()>0){
               return UserObj[0];
            }
            else{
               return null;
            }
    }
}