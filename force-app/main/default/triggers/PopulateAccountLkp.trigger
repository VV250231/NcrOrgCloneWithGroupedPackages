trigger PopulateAccountLkp on Daily_Order_Combined__c (before Insert, before Update) {

    Set<String> CCMCNSet = new Set<String>();
    Map<String, String> CCMCN_AccIdMap = new  Map<String, String>();
    
    for(Daily_Order_Combined__c doc : Trigger.New) {
        if(doc.MCN__c != null) {
            CCMCNSet.add(doc.Customer_Country_Code__c + doc.MCN__c);    
        }   
    }
    
    if (!CCMCNSet.isEmpty()) {
        List<Account> accList = [SELECT Id,Country_with_Master_customer_Number__c FROM Account WHERE Country_with_Master_customer_Number__c IN :CCMCNSet]; 
        
        for(Account a : accList)  {
            CCMCN_AccIdMap.put(a.Country_with_Master_customer_Number__c, a.Id);        
        }  
        
        if(!CCMCN_AccIdMap.isEmpty()) {
        
            for(Daily_Order_Combined__c doc : Trigger.New) {
            
                if(doc.MCN__c != null) {
                    if(CCMCN_AccIdMap.containsKey(doc.Customer_Country_Code__c + doc.MCN__c))  {
                        doc.Account__c = CCMCN_AccIdMap.get(doc.Customer_Country_Code__c + doc.MCN__c);   
                    }  else {
                         doc.Account__c = NULL;
                    }
                }   
            }
            
        }
    }
    
    

}