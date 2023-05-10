public with sharing class OpenHelpDeskandCasesHandler {
    
    @AuraEnabled(cacheable =true)
    public static List<Open_Help_Desk_Case__c> getHelpDeskCases(String accountID) { 

        List<Open_Help_Desk_Case__c> getHlpDsk = new List<Open_Help_Desk_Case__c>();
        
        getHlpDsk = [SELECT Id, Name, OwnerId, priority_code__c, more_then_24_hours__c, less_then_24_hours__c, gems_customer_name__c, customer_nbr__c, Unique_ID__c FROM Open_Help_Desk_Case__c where Account_Master_Lookup__c = :accountID ORDER BY priority_code__c ASC ];
        
        return getHlpDsk;
    }
}