public class UpdateDatainFuture {
    
     @future
    public static void processRecords(List<ID> recordIds)
    {   
        
        /*List<Account> accList = [Select Id, CDM_Account_Type__c,RecordType.Name from Account where Id IN :recordIds AND RecordType.Name = 'Enterprise' and CDM_Account_Type__c = null];
        for (Account a : accList) {
            a.CDM_Account_Type__c = a.RecordType.Name;
        }
        update accList;*/
        
        List<Account> accList = [Select Id, RecordType.Name,Global_Ultimate_Lookup__c, ParentId , Parent.Global_Ultimate_Lookup__c  from Account 
                                 	WHERE (RecordType.Name = 'Customer' or RecordType.Name = 'Partner') AND Global_Ultimate_Lookup__c =null and ParentId != null
                                and Id IN :recordIds];
        
        for (Account a : accList) {
            a.Global_Ultimate_Lookup__c  = a.Parent.Global_Ultimate_Lookup__c != NULL ? a.Parent.Global_Ultimate_Lookup__c : (a.ParentId != NULL ? a.ParentId : null);
        }
        update accList;
    }

}