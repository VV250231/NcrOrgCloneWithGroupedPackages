public class LeadHelpController {

    @AuraEnabled 
    public static List<Lead_Help_Industry_Config__mdt> getLeadContacts(String leadId) {  
        List<Lead_Help_Industry_Config__mdt> leadConList = [Select MasterLabel, Industry_Order__c, 
                    (Select Region__c, Region_Order__c, 
                     Contact_Person_Name__c, Contact_Person_Email__c 
                     from Lead_Help_Configs__r) 
                     from Lead_Help_Industry_Config__mdt order by Industry_Order__c];     
        
        return leadConList;
    }
    
    
    
     @AuraEnabled 
     public static Boolean validateLeadOnLoadHelp(String leadId) { 
        String currUserId = Userinfo.getUserId();
        Boolean disableHelp = false;
         
         if(String.isNotBlank(leadId)) {
            List<Lead> leadList = [Select Id, RecordType.Name from Lead WHERE Id = :leadId and isConverted = false Limit 1];
            
            if (leadList == NULL || (leadList.isEmpty())) {
                disableHelp = true;     
            } else {
                List<Lead_Help_Access__c> useraccess = [SELECT Id, User__c, Disabled_Help_Box__c 
                                                FROM Lead_Help_Access__c 
                                                WHERE User__c = :currUserId LIMIT 1]; 
         
                 if (!useraccess.isEmpty() && useraccess.get(0).Disabled_Help_Box__c) {
                     disableHelp = true;
                 }    
            }  
         }
         return disableHelp;
     }
    
    
     @AuraEnabled 
     public static void updateUserSetting() { 
        Lead_Help_Access__c lha = new Lead_Help_Access__c(User__c = Userinfo.getUserId(), Disabled_Help_Box__c = true,
                                                         Unique_Id__c = Userinfo.getUserId());
        upsert lha Unique_Id__c;  
     }
}