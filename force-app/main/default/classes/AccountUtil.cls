public class AccountUtil {

    public Account populateAccwithMCN(Account acc, set<string> recordTypeSet) {
        Account accountobj = null;
        
        if (acc != null) { 
           
            set<string> picklistValuesSet = NSCCommonInfoUtil.getInstance().getNonRORCtrs_PicklistVals();
      
            
           /* if (acc.AccountRequestRecordType__c == 'Alaric Customer') {
                accountobj.Master_Customer_Number__c = accountobj.SequenceNumber__c+'ALC';    
            }
            else if (acc.AccountRequestRecordType__c == 'Digital Insight Customer Account') {
                accountobj.Master_Customer_Number__c = accountobj.SequenceNumber__c + 'DI';           
            } */
            // commented AccountRequestRecordType__c-EBA_SF-688
            if((acc.Master_Customer_Number__c ==null || acc.Master_Customer_Number__c =='')     
                && (recordTypeSet.contains(acc.RecordTypeId)) && (picklistValuesSet != null) 
                && (picklistValuesSet.contains(acc.Account_Country_Code__c))) { 
                  
                accountobj = acc.clone(true, false);
                accountobj.Master_Customer_Number__c = accountobj.SequenceNumber__c+accountobj.Account_Country_Code__c;
            }
        }
        return accountobj;
    }  
    
    
    
}