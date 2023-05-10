/*
##################################################################################################
# Class Name............................:WrapperMultipleSelectTopline                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class WrapperMultipleSelectTopline {

      @AuraEnabled 
        public String ListValue{get;set;}
      @AuraEnabled 
        public Boolean Selecetd{get;set;}
        
        public WrapperMultipleSelectTopline(String value,Boolean status){ 
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