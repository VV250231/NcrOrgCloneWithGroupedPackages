public with sharing class HierarchyController {
    @AuraEnabled
    public static Account getAccountBasics(String accId) {       
        Account acc = [SELECT Id,Name,CDM_Account_Type__c, Global_Ultimate_Enterprise__c, Domestic_Ultimate_Enterprise__c, Global_Ultimate_Lookup__c, Domestic_Ultimate_Lookup__c from Account where Id= :accId limit 1];
        system.debug(URL.getSalesforceBaseUrl().toExternalForm() +'/' +acc.id);
        return acc;      
    }
    @AuraEnabled
    public static List<Account> getAccountSites(String accId, Integer intOffSet) {
        System.debug('>>>>' + accId);
        List<Account> sites = new List<Account>(); 
        // find global ultimate parent
        Account acc = [SELECT Id,Recordtype.Name, ParentId from Account where Id= :accId limit 1]; 
        
        if (acc.Recordtype.Name == Label.RT_Acc_Customer || acc.Recordtype.Name == Label.RT_Acc_Partner) {
            sites = getSites(acc.Id);
        } 
        //Empty If statement was commented
        /*else if(acc.Recordtype.Name == Label.RT_Acc_Enterprise) {
// show message, sites not appliale for enterprises    
}*/
        
        
        return sites;      
    }
    
    public static List<Account> getSites(String parentAccId) {
        List<Account> sites = [SELECT Id, Name, Site_Number__c, Primary_Bill_To__c, Primary_Ship_To__c, Primary_Deliver_To__c, BillingAddress 
                               FROM Account WHERE ParentId = :parentAccId and RecordType.Name = 'Site'];
        return sites;
    }
    
    
    @AuraEnabled
    public static String getAccountHierarchyData(String accId) {
        System.debug('>>>>' + accId);
        List<AccountWrapper> accWraperList = new List<AccountWrapper>(); 
        // find global ultimate parent
        Account acc = [SELECT Id,Recordtype.Name, Global_Ultimate_Lookup__c,ParentId, Parent.Global_Ultimate_Lookup__c  from Account where Id= :accId limit 1];    /* Global_Ultimate_Parent_Id__c*/ 
        String GUParentId; // = acc.Global_Ultimate_Lookup__c;
        
        if(acc.Recordtype.Name == 'Enterprise')
            GUParentId =  acc.Global_Ultimate_Lookup__c != NULL ? acc.Global_Ultimate_Lookup__c : acc.Id ; 
        else if(acc.Recordtype.Name == 'Customer' || acc.Recordtype.Name == 'Partner')
            GUParentId =  acc.Parent.Global_Ultimate_Lookup__c != NULL ? acc.Parent.Global_Ultimate_Lookup__c  : acc.ParentId;
        
        System.debug(acc);
        System.debug(GUParentId);
        List<Account> accList = [SELECT Id, Name from Account where Id = :GUParentId LIMIT 1];
        
        if(!accList.isEmpty()) {
            AccountWrapper aWraper = new AccountWrapper() ; 
            aWraper.name = accList.get(0).Id;
            aWraper.label = accList.get(0).Name;
            aWraper.expanded = true;
            
            Map<Id, List<AccountWrapper>> childAccountMap = findChildAccounts(new Set<Id>{GUParentId});
            
            if(!childAccountMap.isEmpty()) {
                aWraper.items = childAccountMap.get(GUParentId);  
            }
            accWraperList.add(aWraper);
            System.debug(JSON.serializePretty(accWraperList));
        }
        
        return JSON.serializePretty(accWraperList, true);        
    }
    
    
    public static Map<Id, List<AccountWrapper>> findChildAccounts(Set<Id> parentAccIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, ParentId FROM Account where ParentId IN :parentAccIds and RecordType.Name != 'Site']);
        Map<Id, AccountWrapper> accountWrapperMap = new Map<Id, AccountWrapper>();
        Map<Id, List<AccountWrapper>> parentAccountIdMap = new Map<Id, List<AccountWrapper>>();
        
        if(!accountMap.isEmpty()) {             
            List<AccountWrapper> tempAccWrapperList;
            
            for (Id accId : accountMap.keySet()) { 
                Account acc = accountMap.get(accId); 
                
                //Account wrrapper
                AccountWrapper aWraper = new AccountWrapper() ; 
                aWraper.name = acc.Id;
                aWraper.label = acc.Name;      
                aWraper.expanded = false;
                accountWrapperMap.put(accId, aWraper);
                
                tempAccWrapperList = parentAccountIdMap.get(acc.ParentId);
                
                if (tempAccWrapperList == NULL) {
                    tempAccWrapperList = new List<AccountWrapper>();  
                    parentAccountIdMap.put(acc.ParentId, tempAccWrapperList);
                }
                
                tempAccWrapperList.add(aWraper);
            }
            Map<Id, List<AccountWrapper>> childAccountMap = findChildAccounts(accountMap.keySet());
            
            if(!childAccountMap.isEmpty()) {
                for(Id parentAccId : childAccountMap.keySet()) {
                    tempAccWrapperList = childAccountMap.get(parentAccId);
                    AccountWrapper accWrap = accountWrapperMap.get(parentAccId);
                    accWrap.items = tempAccWrapperList;     
                }    
            }
        }
        return parentAccountIdMap;
    }
    @AuraEnabled
    public static Map<String,Customer360RelatedConf__mdt> getConfs() {
        Map<String,Customer360RelatedConf__mdt> cmap = new Map<String,Customer360RelatedConf__mdt>();
        System.debug('Hello world');
        for(Customer360RelatedConf__mdt c:[Select DeveloperName,FieldsToDisplay__c,RecordsCount__c,SortedDirection__c,SortingField__c,FieldsForViewAll__c from Customer360RelatedConf__mdt]){
            cmap.put(c.DeveloperName,c);
        }
        return cmap;
    }
    @AuraEnabled
    public static List<String> getCols(String sObjectName, String fields, String allFields) {
        List<String> results = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map <String, Schema.SObjectField> FsMap = d.fields.getMap();
            results.add(getJSON(sObjectName,fields.split(','),FsMap));
            results.add(getJSON(sObjectName,allFields.split(','),FsMap));
        }
        catch(Exception e){
            results.add(e.getLineNumber() + ' : ' + e.getMessage());
        }
        return results;
    }
    public static String getJSON(String sObjectName,String[] fields,Map <String, Schema.SObjectField> FsMap) {
        String result = '';
        try{
            for(String fld: fields){
                if(FsMap.containsKey(fld)){
                    Schema.SObjectField f = FsMap.get(fld) ;
                    Schema.DescribeFieldResult dfr = f.getDescribe();
                    String typ = String.valueOf(dfr.getType());
                    if(typ=='STRING'||typ=='PICKLIST'){
                        typ='text';
                    }
                    if(typ=='date'){
                        typ='date-local';
                    }
                    
                    if(dfr.isNameField()){
                        if(result != ''){
                            result += ',';
                        }
                        String jsonPart = '{';
                        jsonPart += ' label: "' + dfr.getLabel() + '",';
                        jsonPart += ' fieldName: "LinkName'+ '",' ;
                        jsonPart += ' type: "url' +'",';
                        jsonPart += ' typeAttributes: '+'{'+'label: '+'{'+' fieldName:'+ '"Name" }'+',';
                        jsonPart += 'target: "_top'+ '"},';
                        jsonPart += 'sortable: "true'+ '"';
                        jsonPart += '}';
                        result += jsonPart;
                    }
                    else{
                        if(result != ''){
                            result += ',';
                        }
                        String jsonPart = '{';
                        jsonPart += 'label: "' + dfr.getLabel() + '",';
                        jsonPart += 'type: "' + typ + '",';
                        jsonPart += 'fieldName: "' + dfr.getName() + '"';
                        //if(typ!='BOOLEAN'){
                        jsonPart += ',sortable: "true'+ '"';
                        //}
                        if(typ=='date-local'){
                            jsonPart += ',typeAttributes:{month:"2-digit", day:"2-digit"}';
                        }
                        if(typ=='currency'){
                            jsonPart += ',cellAttributes: { alignment: "left" }';
                        }
                        jsonPart += '}';
                        result += jsonPart;
                    }
                }
                else if (fld == 'Account.Name'){
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += 'label: "' + 'Account Name' + '",';
                    jsonPart += 'type: "' + 'text' + '",';
                    jsonPart += 'fieldName: "' + 'AccountName' + '",';
                    jsonPart += 'sortable: "true'+ '"';
                    jsonPart += '}';
                    result += jsonPart;
                }else if (fld == 'Owner.LastName'){
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += 'label: "' + 'Owner Last Name' + '",';
                    jsonPart += 'type: "' + 'text' + '",';
                    jsonPart += 'fieldName: "' + 'OwnerName' + '",';
                    jsonPart += 'sortable: "true'+ '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
            }   
        }catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+result+']';
    }
    
    
    public Class AccountWrapper {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Boolean expanded {get;set;}
        @AuraEnabled
        public List<AccountWrapper> items {get;set;}
    }
    
}