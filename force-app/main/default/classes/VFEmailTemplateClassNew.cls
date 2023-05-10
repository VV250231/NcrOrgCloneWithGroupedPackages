global class VFEmailTemplateClassNew {
    public String RecordId {get;set;} 
   global Deming_Log__c Customes {
 
        get{  
            if(String.isNotBlank(RecordId)){
                Customes=[Select id,Customer_Names__c,User__c from Deming_Log__c where Id =:RecordId];
            }
            return Customes; 
        } 
        set;}
    
    public List<String> getCustName(){
           List<String> Customerlisttoreturn = new List<String>();
           List<String> TemplistCustomerName= new List<String>();
           if(String.isNotBlank(Customes.Customer_Names__c)){
               Customerlisttoreturn = (List<String>)System.JSON.deserialize(Customes.Customer_Names__c, List<String>.class);
               
           }    
           return Customerlisttoreturn;
        
    }
}