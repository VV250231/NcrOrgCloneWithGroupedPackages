/*
##################################################################################################
# Class Name............................:WrapperMultipleSelectToplineNotSold                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class WrapperMultipleSelectToplineNotSold {
  
    @AuraEnabled 
        public String ListValue{get;set;} 
      @AuraEnabled 
        public Boolean Selecetd{get;set;} 
        
        public WrapperMultipleSelectToplineNotSold(String value,Boolean status){
            if(status==True){
                Selecetd=true;
                ListValue=value;
            }
            else{
                 Selecetd=false;
                 ListValue=value; 
            }
        }
}