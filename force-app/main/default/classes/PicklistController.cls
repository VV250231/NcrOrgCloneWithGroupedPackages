/*
##################################################################################################
# Class Name............................:PicklistController.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class PicklistController {
    
    @AuraEnabled
    public static Opportunity getStage(Id recordId) {
        
        return ([  
            SELECT Id, Name ,Stagename, Price_Variance__c, Key_Criteria__c, Discontinued_Reasons__c 
            FROM Opportunity 
            WHERE Id =:recordId  
        ].get(0)); 
    }
    @AuraEnabled  
    public static List<String> getpickval()     
    {
        List<String> options = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = opportunity.Price_Variance__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) { 
            options.add(f.getLabel());
        }       
        return options; 
    }  
    
    public static opportunity saveOpportunity(opportunity Opp)  
    {
        update Opp;   
        return Opp;       
    } 
}