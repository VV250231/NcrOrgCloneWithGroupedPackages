public class tableau_c360_controller {
 @AuraEnabled
    public static Account getMCN(String idd) {
        
        Account mcn=[Select id, Name, Master_customer_Number__c from account where id=:idd];
        return mcn;
        
    } 
}