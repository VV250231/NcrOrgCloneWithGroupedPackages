trigger updateAccountId on Quote_Details__c (before insert,before update) { 
   
   if(Trigger.isInsert){
        List<String> mcns=new List<String>();
        Map<String,String> mapIdMCN= new Map<String,String>();
        //Map<String,Account> mapAcc= new Map<String,Account>();
        
        for(Integer i = 0; i<Trigger.size; i++){
            if(Trigger.new[i].MCN__c!=null){
                 mcns.add(Trigger.new[i].MCN__c);
            }
        }
        
        List<Account> AccountIds= [Select Id, Master_Customer_Number__c from Account where Master_Customer_Number__c in :mcns];
        
        for(Account a: AccountIds){
            mapIdMCN.put(a.Master_Customer_Number__c,a.Id);
            //mapAcc.put(a.Master_Customer_Number__c,a);            
        }
        
        for(Integer i = 0; i<Trigger.size; i++){
            String value=Trigger.new[i].Quote_Name__c; 
            if (value != null && value.length() > 255){
                value = value.substring(0, 255);
                Trigger.new[i].Quote_Name_255__c= value;
            }
            else{
                Trigger.new[i].Quote_Name_255__c= value;
            }
            if(mapIdMCN.get(Trigger.new[i].MCN__c)!=null){
                Trigger.New[i].Account__c=mapIdMCN.get(Trigger.new[i].MCN__c);
                //Trigger.New[i].Region__c=mapAcc.get(Trigger.new[i].MCN__c).Region__c;
            }
            else{
                Trigger.New[i].Account__c=null;
                //Trigger.New[i].Region__c=null;
            }
        }
   }
    // need to add after update on this object records, update the linked quotes on SPOT_Quote__c
    
    if(Trigger.isupdate){
    List<String> mcns=new List<String>();
    Map<String,String> mapIdMCN= new Map<String,String>();
    //Map<String,Account> mapAcc= new Map<String,Account>();
    for(Integer i = 0; i<Trigger.size; i++){
        if(Trigger.new[i].MCN__c!=null){
             mcns.add(Trigger.new[i].MCN__c);
        }
    }
    List<Account> AccountIds= [Select Id,Master_Customer_Number__c from Account where Master_Customer_Number__c in :mcns];
    
    for(Account a: AccountIds){
        mapIdMCN.put(a.Master_Customer_Number__c,a.Id);
        //mapAcc.put(a.Master_Customer_Number__c,a);
    }
    System.debug('gayatri isupdate 456'+AccountIds.size()+'--test -'+mapIdMCN.size());
    for(Integer i = 0; i<Trigger.size; i++){
        System.debug('gayatri isupdate 123'+mapIdMCN.get(Trigger.new[i].MCN__c));
        String value=Trigger.new[i].Quote_Name__c; 
        if (value != null && value.length() > 255){
            value = value.substring(0, 255);
            Trigger.new[i].Quote_Name_255__c= value;
        }
        else{
            Trigger.new[i].Quote_Name_255__c= value;
        }
        if(mapIdMCN.get(Trigger.new[i].MCN__c)!=null){
            Trigger.New[i].Account__c=mapIdMCN.get(Trigger.new[i].MCN__c);
            //Trigger.New[i].Region__c=mapAcc.get(Trigger.new[i].MCN__c).Region__c;
        }
        else{
            Trigger.New[i].Account__c=null;
            //Trigger.New[i].Region__c=null;
        }
    }    
        System.debug('gayatri isupdate 1');
        List<Id> linkedSPOTOrdersList= new List<Id>();
        for(Integer i = 0; i<Trigger.size; i++){
            if(Trigger.new[i].Linked__c==true && Trigger.old[i].CurrencyIsoCode.equalsIgnoreCase(Trigger.old[i].CurrencyIsoCode)){
                linkedSPOTOrdersList.add(Trigger.new[i].Id);
            }
            else{   
            }
        }
        System.debug('gayatri isupdate 2');
        /*List<SPOT_Quote__c> linkedSPOTOrders= [Select Id,SPOT_Quote_Number__c from SPOT_Quote__c where SPOT_Quote_Number__c in :linkedSPOTOrdersList];
        list<SPOT_Quote__c> updateSPOTOrdersList= new list<SPOT_Quote__c> ();
        Map<Id,Id> linkedSPOTOrdersMap= new Map<Id,Id> ();
        System.debug('gayatri isupdate 3');
        for(SPOT_Quote__c ob: linkedSPOTOrders){
            linkedSPOTOrdersMap.put(ob.SPOT_Quote_Number__c,ob.Id);
        }       
        System.debug('gayatri isupdate 4');
        for(Integer i = 0; i<Trigger.size; i++){
            System.debug('gayatri isupdate 4 linkedSPOTOrdersMap.containskey(Trigger.new[i].id) :'+linkedSPOTOrdersMap.containskey(Trigger.new[i].id));
            System.debug('gayatri isupdate 4 Trigger.new[i].id :'+Trigger.new[i].id);
            if(linkedSPOTOrdersMap.containskey(Trigger.new[i].id)){
                System.debug('gayatri isupdate 4 linkedSPOTOrdersMap.get(Trigger.new[i].Id) :'+linkedSPOTOrdersMap.get(Trigger.new[i].Id));
                SPOT_Quote__c ob=new SPOT_Quote__c(id=linkedSPOTOrdersMap.get(Trigger.new[i].Id));                            
              
                ob.CurrencyIsoCode=trigger.new[i].CurrencyIsoCode;
                ob.Quote_Name__c=trigger.new[i].Quote_Name__c;
                updateSPOTOrdersList.add(ob);
            }
            else{
            }
        }
        if(updateSPOTOrdersList.size()>0){
            update updateSPOTOrdersList;
        }*/
    }
    
}