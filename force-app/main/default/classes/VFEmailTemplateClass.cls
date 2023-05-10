global without sharing  class VFEmailTemplateClass {
     
    public String accountId {get;set;}
    public String ReasonCode {get;set;}
    public String CustomerNo {get;set;}
    Public List<String> ReasonCodeList = New List<String>();
    
    
    global List<Deming__c> accounts {
 
        get { 
            Set<String> MCNSet  = new Set<String>();
            MCN_Switch__mdt MCNObj = new MCN_Switch__mdt();
            MCNObj =[select id,MCN_List__c,MCN_List_New__c,Turn_On__c from MCN_Switch__mdt limit 1];
            if(String.isNotBlank(MCNObj.MCN_List_New__c)){
                MCNSet.addAll(MCNObj.MCN_List_New__c.split(','));
            }
             
            if(!MCNObj.Turn_On__c){
               if(ReasonCode == 'Customer Request') { 
                 accounts = [select Id,Customer_Name__c,Order_Id__c,Reason_Code__c,Customer_No__C from Deming__c where Cadd_Status__c = '' and EditShareWithUser__c =:accountId and Reason_Code__c= 'Customer Request' and Include_In_Process__c = false] ;
                } else  {
                 accounts = [select Id,Customer_Name__c,Order_Id__c,Reason_Code__c,Customer_No__C from Deming__c where Cadd_Status__c = '' and EditShareWithUser__c =:accountId and Reason_Code__c IN :ReasonCodeList and Include_In_Process__c = false] ;
               } 
            } 
            
            
            else{
                
                if(MCNSet.size() > 0){
                    if(ReasonCode == 'Customer Request') {
                     accounts = [select Id,Customer_Name__c,Order_Id__c,Reason_Code__c,Customer_No__C from Deming__c where     Cadd_Status__c = '' and EditShareWithUser__c =:accountId and Reason_Code__c= 'Customer Request' and Include_In_Process__c = false and Customer_No__c IN :MCNSet] ;
                    } else  {
                     accounts = [select Id,Customer_Name__c,Order_Id__c,Reason_Code__c,Customer_No__C from Deming__c where     Cadd_Status__c = '' and EditShareWithUser__c =:accountId and Reason_Code__c IN : ReasonCodeList and Include_In_Process__c = false and Customer_No__c IN :MCNSet] ;
                    } 
                } 
            }
            return accounts; 
        } 
        
        
        set;}
  
    public VFEmailTemplateClass(){
        ReasonCodeList.add('Credit Holds');
        ReasonCodeList.add('Initial Date');
        ReasonCodeList.add('Operational Holds');
        ReasonCodeList.add('Plant Capacity');
        ReasonCodeList.add('Supply');
    
    }
        
    public Set<String> getSmithAccounts() {
        Set<String> CustomerNameSet = new Set<String>();
        for(Deming__c DemObj : accounts){
            CustomerNameSet.add(DemObj.Customer_Name__c);
        }
        return CustomerNameSet;
    }
}