public class WrapperMultipleSelect{
    	@AuraEnabled 
        public String ListValue{get;set;}
    	@AuraEnabled 
        public Boolean Selecetd{get;set;}
        
        public WrapperMultipleSelect(String value,Boolean status){
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