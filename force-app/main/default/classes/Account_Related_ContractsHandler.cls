public class Account_Related_ContractsHandler {
    //public static boolean recursiveFlag  = false ; 
    public static void allContractedproducts(List<SObject> newItems, Map<Id, Account> updateAccMap){
        
        Map<Id,list<string>> mapAccwithContracts = new Map<Id,list<string>>();
        List<Account> lstAcctoUpdate = new List<Account>();
        Set<Id> setAccIds = new set<Id>();
        if(newItems!=null&& ! newItems.IsEmpty()){
            for(Contract objAccContr : (list<Contract>) newItems) {
                setAccIds.add(objAccContr.AccountId);
            }
            if(setAccIds!=null && !setAccIds.IsEmpty()){
                Map<Id, Contract> mapAccContracts = new Map<Id, Contract>([SELECT Id, AccountId, Status, Products__c FROM Contract
                                                                           where (Status ='Activated' OR Status ='At Risk') AND AccountId =: setAccIds
                                                                           AND Products__c !=null]);
                
                if(!mapAccContracts.IsEmpty() && mapAccContracts.size()>0){
                    for(Contract ObjContr : mapAccContracts.values()){
                        if(string.isNotBlank(ObjContr.AccountId)){
                            system.debug('ObjContr.AccountId '+ObjContr.AccountId);
                            if(!mapAccwithContracts.containskey(ObjContr.AccountId) ){
                                
                                /*List<string> allproducts = new List<string>();
//if(ObjContr.Products__c!= null){
allproducts.addall(ObjContr.Products__c?.split(','));
set<string> setallproducts = new set<string>();
setallproducts.addall(allproducts);*/
                                mapAccwithContracts.put(ObjContr.AccountId,ObjContr.Products__c?.split(',')); 
                                system.debug('mapAccwithContracts' +mapAccwithContracts);
                                //}
                            }
                            else{
                                
                                List<string> allproducts = new List<string>();
                                if(ObjContr.Products__c!= null){
                                    
                                    allproducts.addall(ObjContr.Products__c?.split(','));
                                    //if(allproducts!= null &&!allproducts.IsEmpty()){
                                    //set<string> setallproducts = new set<string>();
                                    //setallproducts =mapAccwithContracts.get(ObjContr.AccountId);
                                    //setallproducts.addall(allproducts);
                                    //system.debug('setallproducts'+setallproducts);
                                    //mapAccwithContracts.remove(ObjContr.AccountId);
                                    //mapAccwithContracts.put(ObjContr.AccountId,setallproducts);                   
                                    //
                                    //if(mapAccwithContracts.containskey(ObjContr.AccountId)){
                                    
                                    system.debug('allproducts ' +allproducts);
                                    mapAccwithContracts.get(ObjContr.AccountId)?.addall(allproducts);   
                                    system.debug('mapAccwithContracts' +mapAccwithContracts);
                                    //} 
                                    //}
                                    //}                
                                }
                            } 
                        }
                    }
                }
            }
            if(!mapAccwithContracts.IsEmpty() && mapAccwithContracts.size()>0){
                for(Id objKey:mapAccwithContracts.keyset()){
                    //set<string> setallproducts = new set<string>();
                    list<string> uniqueproducts  = new list<string>();
                    system.debug('mapAccwithContracts.keyset'+objKey);
                    system.debug('mapAccwithContracts.get(objKey)'+mapAccwithContracts.get(objKey));
                    if(mapAccwithContracts.get(objKey)!= null){
                        for(string str : mapAccwithContracts.get(objKey)){
                            if(!uniqueproducts.contains(str.trim())){
                                uniqueproducts.add(str.trim());
                                system.debug('uniqueproducts' +uniqueproducts);
                            }   
                        }
                        //uniqueproducts.clear();
                        //uniqueproducts.addall(setallproducts);
                        system.debug('mapAccwithContracts.get(objKey)'+uniqueproducts);
                        
                        Account acnt = updateAccMap.get(objKey);
                        if (acnt == null) {
                            acnt = new account(id=objKey);
                            updateAccMap.put(objKey, acnt);
                        } 
                        acnt.All_Contracted_Products__c = string.join(uniqueproducts,', ');   
                        //lstAcctoUpdate.add(new Account(Id = objKey, All_Contracted_Products__c = string.join(uniqueproducts,', ')));
                        
                    }
                }
            }
            /*if(!lstAcctoUpdate.IsEmpty() && lstAcctoUpdate != null){ //commented to prevent account update from class
list<Database.SaveResult> results = Database.update(lstAcctoUpdate,false);
}*/
        } 
        
    }   
    public static void sumCOntracts(set<ID>AccIds, Map<Id, Account> updateAccMap){
        
        //set<ID>AccIds = new set<ID>();
        system.debug('reached here') ;
        map<id,double> amtmap2 = new map<id,double>();
        map<id,double> amtmap = new map<id,double>();
        map<id,integer> amtmap3 = new map<id,integer>();
        for(aggregateresult ag : [select AccountId ,SUM(Actual_ACV__c) SOA,SUM(Total_Contract_Value__c) STCA,Count(ID)contr FROM Contract
                                  where (Status ='Activated' OR Status ='At Risk') AND AccountId in:AccIds GROUP BY AccountId])
            
        {
            system.debug('ag'+ag.get('contr'));
            amtmap.put((ID)ag.get('AccountId'), double.valueof(ag.get('SOA')));
            amtmap2.put((ID)ag.get('AccountId'), double.valueof(ag.get('STCA'))); 
            amtmap3.put((ID)ag.get('AccountId'),integer.valueof(ag.get('contr')));
        }
        
        list<account>acclist = new list<account>();
        for(id iid : AccIds){
            Account acnt = updateAccMap.get(iid);
            if(acnt == null) {
                acnt = new account(id=iid);
                updateAccMap.put(iid, acnt);
            }
            
            if(amtmap.containskey(iid)){
                acnt.Contract_Actual_ACV__c = amtmap.get(iid);
                acnt.Contract_TCV__c = amtmap2.get(iid);
                acnt.Count_of_Contracts__c = amtmap3?.get(iid);
                system.debug('iid'+amtmap3?.get(iid));
            }
            else{
                acnt.Contract_Actual_ACV__c = 0;
                acnt.Contract_TCV__c = 0;
                acnt.Count_of_Contracts__c = 0;
            } 
            //acclist.add(acnt);  
        }
        
        /*
if(acclist.size()>0){ //commented to prevent account update from class
update acclist;
}*/
        
    }
    //Gray - method to count all active CATM contrats on account
    public static void  countOfContracts(Set<Id> accIds , Map<Id, Account> updateAccMap) {
        Map<Id, Account> accMap =  new Map<Id, Account>();
        for(Account acc:updateAccMap.values()){
        	acc.CATM_NDA__c=False;
            acc.Count_of_Active_Contracts__c = 0;
        }
        for(Aggregateresult agg : [SELECT count(Id) totalCtrct,AccountId, CATM_NDA__c FROM Contract where accountId IN :accIds 
                                   AND isDeleted = FALSE AND Catm_Record__c = TRUE
                                   GROUP BY AccountId, CATM_NDA__c]) {
                                       
                                       Id accId =  (ID)agg.get('AccountId');
                                       Boolean NDACtrt = (Boolean)agg.get('CATM_NDA__c');
                                       Integer totalCtrct  = agg.get('totalCtrct') != null ? Integer.valueOf(agg.get('totalCtrct')) : 0;
                                       
                                       if(updateAccMap.get(accId) != null) {
                                           updateAccMap.get(accId).Count_of_Active_Contracts__c +=  totalCtrct;
                                           updateAccMap.get(accId).CATM_NDA__C = false;
                                           
                                       } else {
                                           Account acc = new Account(Id = accId, Count_of_Active_Contracts__c =  totalCtrct, CATM_NDA__C = false); 
                                           updateAccMap.put(accId, acc);    
                                       }
                                       
                                       if(NDACtrt && !updateAccMap.get(accId).CATM_NDA__C) {
                                       		updateAccMap.get(accId).CATM_NDA__C = NDACtrt;        
                                       }
                                       
                                       /**if(agg.CATM_NDA__c!=Null && agg.CATM_NDA__c==TRUE){
                                           updateAccMap.get(accId).CATM_NDA__C='TRUE';
                                       }**/
                                   }
                /*for(Contract c : [SELECT Id, AccountId,CATM_NDA__c FROM Contract where accountId IN :accIds 
                                   AND isDeleted = FALSE AND Catm_Record__c = TRUE
                                 ]){
                                     Id accId =  (ID)c.get('AccountId');
                                      if(c.CATM_NDA__c==TRUE){
                                           updateAccMap.get(accId).CATM_NDA__C=TRUE;
                                       }
                                  }*/
        /*Account acc = [select id, Count_of_Active_Contracts__c from Account where id =: accId];

if(cList.size() > 0) {
acc.Count_of_Active_Contracts__c = cList.size();
}
else {
acc.count_of_active_contracts__c = 0;
}

update acc; */
    }
    
}