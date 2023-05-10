public with sharing class RelatedListController {
 public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';
    public static final String IsViewAll = 'isViewAll';
     @AuraEnabled
    public static Account getAccountBasics(String accId) {       
        Account acc = [SELECT Id,Name,CDM_Account_Type__c, Global_Ultimate_Enterprise__c, Domestic_Ultimate_Enterprise__c, Global_Ultimate_Lookup__c, Domestic_Ultimate_Lookup__c from Account where Id= :accId limit 1];
         system.debug(URL.getSalesforceBaseUrl().toExternalForm() +'/' +acc.id);
        return acc;      
    }
    @AuraEnabled
    public static String initData(String jsonData){
        System.debug(jsonData);
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedFieldApiName));
        
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);
    }
    
    @AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
        Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
        String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
        String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);
		Boolean isViewAll = (Boolean)root.get(IsViewAll);  
        System.debug('isViewAll***'+isViewAll);
        List <id> ids=new List<id>();
        ids.addAll(allChildAccounts(recordId));
        system.debug('###'+ids);
        String query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedFieldApiName+ ' IN: ids';
        if(sobjectApiName=='Opportunity'){
            query += ' AND (IsClosed!=true OR (IsClosed=true AND CreatedDate>=LAST_N_YEARS:3))';
        }
         system.debug('###'+orderBy);
        query+= ' ORDER BY ' +orderBy;
        /*if(!isViewAll){
            query+=' Limit :numberOfRecords';
        }*/
        system.debug('query'+query);
        System.debug('noOfRecods'+numberOfRecords);
        return Database.query(String.escapeSingleQuotes(query));
    }
    public static List<id> allChildAccounts(Id parentAccId) {
        List<id> allChildAccIds=new List<Id>();
        Set<Id> parentAccIds=new Set<id>();
        parentAccIds.add(parentAccId);
        allChildAccIds.add(parentAccId);
        while((parentAccIds).size()>0){
          parentAccIds=findChildAccounts(parentAccIds);  
            allChildAccIds.addAll(parentAccIds);
        }
        system.debug('All Childs'+allChildAccIds);
        return allChildAccIds;
    }
    public static Set<id> findChildAccounts(Set<Id> parentAccIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, ParentId FROM Account where ParentId IN :parentAccIds]);
        
        return(accountMap.keySet());
        
    }    
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
                name = cr.getRelationshipName();
                break;
            }
        }
        return name;
    }

    @AuraEnabled
    public static Boolean deleteRecord(Id recordId){
        Sobject sobj = recordId.getSObjectType().newSObject(recordId);
        Database.DeleteResult result = Database.delete(sobj, true);
        return result.isSuccess();
    }       
    
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }    
    
}