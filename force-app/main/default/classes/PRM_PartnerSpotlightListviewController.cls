public with sharing class PRM_PartnerSpotlightListviewController 
{    
    @AuraEnabled
    public static List<Partner_Spotlight__c> getPartnerSpotlight(String selectedView) 
    {
        List<Partner_Spotlight__c> lstSpotlight = new List<Partner_Spotlight__c>();
         
        String queryStr = 'SELECT Id, Name, Partner_Spotlight_Type__c, First_Name__c, Last_Name__c, Partner_Name__r.Name FROM Partner_Spotlight__c where Partner_Spotlight_Type__c = : selectedView  order by Name';
       
        lstSpotlight = (List<Partner_Spotlight__c>)Database.query(String.escapeSingleQuotes(queryStr));
        return lstSpotlight;
    }
}