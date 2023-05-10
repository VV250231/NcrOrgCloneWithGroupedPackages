/*
##################################################################################################
# Class Name............................:MultiselectController                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class MultiselectController {
	@AuraEnabled 
    public static List<String> getpickval_key_criteria(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = opportunity.Key_Criteria__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) { 
                    options.add(f.getLabel());
         }
       
        return options; 
    }
     
    @AuraEnabled  
    public static List<WrapperMultipleSelect> NewGetPicklistValue(String oppId){
        Map<String,Boolean> KeyOpportunityMap=new Map<String,Boolean>();
        String str1=[select Key_Criteria__c from opportunity where id=:oppId].Key_Criteria__c;
        	if(String.isNotBlank(str1) && str1.length()>1){
                for(String str : str1.split(';')){
                	KeyOpportunityMap.put(str, true); 
                } 
        }
        
      	List<WrapperMultipleSelect>  WrapperList=new List<WrapperMultipleSelect>();
        Schema.DescribeFieldResult fieldResult = opportunity.Key_Criteria__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) { 
            if(KeyOpportunityMap.containsKey(f.getLabel()))
            {
                
                WrapperList.add(new WrapperMultipleSelect(f.getLabel(),True)); 
                
            }
            else
            {
                WrapperList.add(new WrapperMultipleSelect(f.getLabel(),False)); 
            }
         }
        return WrapperList; 
       
    }
}