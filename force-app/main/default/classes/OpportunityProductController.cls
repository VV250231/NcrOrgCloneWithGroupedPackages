/*
##################################################################################################
# Class Name............................:OpportunityProductController                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class OpportunityProductController {
    
    public static String CurrentUserDefaultCurrency{get;set;}
    
    @AuraEnabled      
    public static List<Opportunity> getOpportunity(Id OpportunityId) {
     CurrentUserDefaultCurrency=userInfo.getDefaultCurrency();    
    List<Opportunity> ListOpportuniytData=new List<Opportunity>();
     Opportunity OpportunityIsoValues=[SELECT Id, Name,CurrencyIsoCode,Soln_Opp_Amount__c,Annuity_Contract__c,Hardware_Products__c,Software_Products__c,Services_Products__c,Cloud_Products__c, 
            PS_Products__c,Total_Quote_Amount_QUBY__c,Total_Quote_Closed_Amount_QUBY__c,Total_Quote_Open_QUBY__c,Solution_Quote_Amount_QUBY__c,Annuity_Quote_Amount_QUBY__c,Software_Products_QUBY__c,Hardware_Products_QUBY__c,Services_Products_QUBY__c,Cloud_Products_QUBY__c,PS_Products_QUBY__c,
            HW_R__c,HW_NR__c,SW_R__c,SW_NR__c,PS_R__c,PS_NR__c,Cloud_R__c, TS_NR__c, TS_R__c, HWM_R__c, HWM_NR__c, SWM_NR__c, SWM_R__c, Managed_Services_NR__c, Managed_Services_R__c FROM Opportunity  
            WHERE Id =:OpportunityId][0];
        
     Opportunity OpportunityConvertedValues=[SELECT Id, Name,CurrencyISOCode,convertCurrency(Soln_Opp_Amount__c),convertCurrency(Annuity_Contract__c),convertCurrency(Hardware_Products__c),convertCurrency(Software_Products__c),convertCurrency(Services_Products__c),convertCurrency(Cloud_Products__c), 
            convertCurrency(PS_Products__c),convertCurrency(Total_Quote_Amount_QUBY__c),convertCurrency(Total_Quote_Closed_Amount_QUBY__c),convertCurrency(Total_Quote_Open_QUBY__c),convertCurrency(Solution_Quote_Amount_QUBY__c),convertCurrency(Annuity_Quote_Amount_QUBY__c),convertCurrency(Software_Products_QUBY__c),convertCurrency(Hardware_Products_QUBY__c),convertCurrency(Services_Products_QUBY__c),convertCurrency(Cloud_Products_QUBY__c),convertCurrency(PS_Products_QUBY__c),
            convertCurrency(HW_R__c),convertCurrency(HW_NR__c),convertCurrency(SW_R__c),convertCurrency(SW_NR__c),convertCurrency(PS_R__c),convertCurrency(PS_NR__c), convertCurrency(Cloud_R__c), convertCurrency(TS_NR__c), convertCurrency(TS_R__c), convertCurrency(HWM_R__c), convertCurrency(HWM_NR__c), convertCurrency(SWM_NR__c), convertCurrency(SWM_R__c), convertCurrency(Managed_Services_NR__c), convertCurrency(Managed_Services_R__c) FROM Opportunity  
            WHERE Id =:OpportunityId][0];  
        
        /*return [    
            SELECT Id, Name,CurrencyISOCode,Soln_Opp_Amount__c,Annuity_Contract__c,Hardware_Products__c,Software_Products__c,Services_Products__c,Cloud_Products__c, 
            PS_Products__c,Total_Quote_Amount_QUBY__c,Total_Quote_Closed_Amount_QUBY__c,Total_Quote_Open_QUBY__c,Solution_Quote_Amount_QUBY__c,Annuity_Quote_Amount_QUBY__c,Software_Products_QUBY__c,Hardware_Products_QUBY__c,Services_Products_QUBY__c,Cloud_Products_QUBY__c,PS_Products_QUBY__c FROM Opportunity  
            WHERE Id =:OpportunityId   
        ][0]; */
        
        ListOpportuniytData.add(OpportunityIsoValues);
        ListOpportuniytData.add(OpportunityConvertedValues);
        return ListOpportuniytData;
    }
    
    @AuraEnabled
    public static String getUserLocalCurrenctCode() {
        return userInfo.getDefaultCurrency();  
    }  
    
    @AuraEnabled
    public static Map<String, String> getFieldsDetailMap() {
        Map<String,Schema.SObjectField> fieldsMap = Opportunity.sObjectType.getDescribe().fields.getMap();
        Map<String, String> fieldInfoMap = new Map<String, String>();
        
        for( string fieldApiName : fieldsMap.keySet() ){            
            Schema.DescribeFieldResult fieldResult = fieldsMap.get( fieldApiName ).getDescribe();
            fieldInfoMap.put(fieldResult.getName(), fieldResult.getLabel());
        }
        return fieldInfoMap;
    } 
    /**********************************
    @AuraEnabled        
    public static Opportunity getOpportunity( Id OpportunityId ) {
        return [ SELECT Id, Name,Soln_Opp_Amount__c,Annuity_Contract__c,Hardware_Products__c,Software_Products__c,Services_Products__c,Cloud_Products__c, PS_Products__c FROM Opportunity WHERE Id =:OpportunityId ][0]; 
    }
    **********************************/ 
}