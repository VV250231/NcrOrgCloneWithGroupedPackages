trigger creditDetailBreakup on Credit_Detail_Break_Up__c (before update, before insert) {
    List<Credit_Detail__c> cdLst=new List<Credit_Detail__c>();
    Set<String> unqIds=new Set<String>();
    Map<String, Id> mapAcct=new Map<String, Id> ();
    for(Credit_Detail_Break_Up__c cdb:trigger.new){
        unqIds.add(cdb.Unique_ID_Credit_Detail__c);   
        
    }
    //Fetch accounts related to
    List<Account> accs=[Select id,Country_with_Master_customer_Number__c from Account where  Country_with_Master_customer_Number__c in :unqIds];
    //loop to create map
    for(Account acc:accs){
        mapAcct.put(acc.Country_with_Master_customer_Number__c, acc.id); 
    }
    //again iterate to find valid and invalid records
    for(Credit_Detail_Break_Up__c cdb:trigger.new){
        if(mapAcct.get(cdb.Unique_ID_Credit_Detail__c)!=null){
            Credit_Detail__c cd=new Credit_Detail__c(Unique_ID__c=cdb.Unique_ID_Credit_Detail__c);                        
            cd.Account__c = mapAcct.get(cdb.Unique_ID_Credit_Detail__c); 
            cd.Customer_Payment_Terms__c=cdb.Customer_Payment_Terms__c;
            if (UserInfo.getName() == 'iPaas Administrator') {
                cd.iPaaS_Update_Successful__c = true;
            }
            cdLst.add(cd);  
        }     
    }
    
    Database.UpsertResult[] rsltsAcc = Database.upsert( cdLst, Credit_Detail__c.Fields.Unique_ID__c,false );
    //fetch all credit detils
    List<Credit_Detail__c> cdLstNew=[Select id,Unique_ID__c from  Credit_Detail__c where Unique_ID__c in :unqIds];
    //create Map
    Map<String,Id> cdMap=new Map<String,Id> ();
    for(Credit_Detail__c cd:cdLstNew){ 
        cdMap.put(cd.Unique_ID__c, cd.id); 
    }
    //Create only those which have account
    for(Credit_Detail_Break_Up__c cdb:trigger.new){
        if(mapAcct.get(cdb.Unique_ID_Credit_Detail__c)!=null){
            cdb.Credit_Detail__c =cdMap.get(cdb.Unique_ID_Credit_Detail__c);
            

        }
        else{
            cdb.addError(system.label.CrP +cdb.Unique_ID_Credit_Detail__c);
        }
        //Error msg for custom label CrP
        //Account Record Does Not Exist in Salesforce with MCN:'+cdb.Unique_ID_Credit_Detail__c 
    }   
}