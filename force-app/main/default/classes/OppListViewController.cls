/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/
public inherited sharing class OppListViewController {

    @AuraEnabled 
    public static OpptWrapper getAcctOpps(Id accId, String pklstFltr, String searchVal, String fieldFilters) {
        System.debug('>>>' + fieldFilters);
        OpptWrapper wrapper = new OpptWrapper();
        List<Opportunity> OppList = new List<Opportunity>();
        Boolean stage = false;
        String soqlQuery = '';
        
        if (String.isNotBlank(accId) && String.isNotBlank(pklstFltr)) {
            String stzdAccId =  String.escapeSingleQuotes(accId);
            String stzdpklstFltr = String.escapeSingleQuotes(pklstFltr);
            
            List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :stzdAccId];
            if(!accList.isEmpty()) wrapper.AccountName = accList.get(0).Name;
                
            if(stzdpklstFltr.equals('THIS_QUARTER') || stzdpklstFltr.equals('NEXT_QUARTER') || stzdpklstFltr.equals('THIS_YEAR')){
                stage=false;
                soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed =' + stage + ' AND Accountid=:stzdAccId AND CloseDate =' + stzdpklstFltr;
            }
            else if(stzdpklstFltr.equals('Previous_Year_Closed_Opportunity')){
                stage=true;
                soqlQuery = 'select id,name,AccountId,StageName,Amount,CloseDate,Opportunity.Account.Name,ForecastCategoryName from Opportunity WHERE isClosed ='+stage+' AND Accountid=:stzdAccId AND CloseDate = LAST_YEAR';
            }
            
            
            else if(stzdpklstFltr.equals('Total_Closed_Opportunity')){
                stage=true;
                soqlQuery = 'select id,name,AccountId,StageName,Amount,CloseDate,Opportunity.Account.Name,ForecastCategoryName from Opportunity WHERE isClosed ='+stage+' AND Accountid=:stzdAccId';
            }
            
            else if(stzdpklstFltr.equals('All_Lost_Opportunity')) {
                stage=true;
                String stgName='Closed/Lost';
                soqlQuery = 'select id,name,AccountId,StageName,Amount,CloseDate,Opportunity.Account.Name,ForecastCategoryName from Opportunity WHERE Accountid=:stzdAccId AND StageName=:stgName';
            } 
        }
        
        String searchFilter = evalSearchFilter(searchVal);
        //if (String.isNotBlank(searchFilter))  soqlQuery =  soqlQuery + ' AND ' + searchFilter;
        
        String fieldFilterQuery='';
        if(String.isNotBlank(fieldFilters)) {
            List<FieldFilterWrapper> wrapperFilterList = (List<FieldFilterWrapper>) System.JSON.deserialize(fieldFilters, List<FieldFilterWrapper>.class);    
            
            if(wrapperFilterList != null && wrapperFilterList.size() > 0) {
                for(FieldFilterWrapper fltr : wrapperFilterList) {
                    String fieldfilter =  evalFilter(fltr);
                    
                    if(String.isNotBlank(fieldfilter)) {
                        fieldFilterQuery =  fieldFilterQuery + ' AND ' + fieldfilter;
                    }
                }
            }
        }
        
        String soqlQuery2 = ' Order by Amount Desc limit 10000';
        System.debug(String.escapeSingleQuotes(soqlQuery)+String.escapeSingleQuotes((String.isNotBlank(searchFilter)?' AND '+searchFilter:''))+(String.isNotBlank(fieldFilterQuery)?fieldFilterQuery:'')+soqlQuery2);
        
        for(Opportunity OppOj :database.query(String.escapeSingleQuotes(soqlQuery)+String.escapeSingleQuotes((String.isNotBlank(searchFilter)?' AND '+searchFilter:''))+(String.isNotBlank(fieldFilterQuery)?fieldFilterQuery:'')+soqlQuery2)) {
            OppList.add(OppOj); 
        }  
        
        wrapper.oppList = OppList;
        return wrapper;
    }
    
    public static String evalSearchFilter(String searchVal) { 
        if (String.isNotBlank(searchVal)){
             searchVal = '%' + String.escapeSingleQuotes(searchVal)  + '%';
            //String searchQuery = '(Name LIKE ' + searchVal + ' OR StageName LIKE '+ searchVal + ' OR Forecast_Category__c LIKE '  + searchVal + ' OR Account.Name LIKE '  + s + ')'; 
            String searchQuery = '(Name LIKE :searchVal OR StageName LIKE :searchVal OR Forecast_Category__c LIKE :searchVal OR Account.Name LIKE :searchVal)'; 
            return searchQuery;      
        }  return null;     
    }
    
    public static String evalFilter(FieldFilterWrapper fltrwrapper) {
        String filterQuery = '';
        FilterUtil fltrUtil = new FilterUtil();
        
        switch on fltrwrapper.selectedOPR { // double quotes are reuired for string values, also need to strig escape comp value
           when 'equals' {
              filterQuery = fltrUtil.evalEqualFilter(fltrwrapper);
           }
           when 'not equal to' {
              filterQuery = fltrUtil.evalNotEqualFilter(fltrwrapper);
           }
           when 'less than' {
               filterQuery = fltrUtil.evalLessThanFilter(fltrwrapper);
           }
           when 'greater than' {
               filterQuery = fltrUtil.evalGreaterThanFilter(fltrwrapper);
           }
           when 'less or equal' {
               filterQuery = fltrUtil.evalLessOREqualFilter(fltrwrapper);
           }
           when 'greater or equal' {
               filterQuery = fltrUtil.evalGreaterOREqualFilter(fltrwrapper);
           }
           when 'contains' {
               filterQuery = fltrUtil.evalContainsFilter(fltrwrapper);
           }
           when 'does not contain' {
               filterQuery = fltrUtil.evalNotContainsFilter(fltrwrapper);
           }
           when 'starts with' {
               filterQuery = fltrUtil.evalStartsWithFilter(fltrwrapper); 
           }
        }
        return filterQuery;
    }
    
    
    
    @AuraEnabled 
    public static Map<String, FieldWrapper> getFieldsInfo() {
        Map<String, FieldWrapper> fieldInfoMap = new Map<String, FieldWrapper>();
        List<String> oppFields = new List<String>{'Name', 'StageName', 'Forecast_Category__c', 'Amount', 'CloseDate'}; 
        List<String> textOprtrList = new List<String>{'equals','not equal to','less than','greater than','less or equal','greater or equal','contains','does not contain' ,'starts with'};
        List<String> nbroprtrList = new List<String>{'equals','not equal to','less than','greater than','less or equal','greater or equal'};
            
        Map<String, Schema.SObjectField> fieldMap =  Opportunity.getSObjectType().getDescribe().fields.getMap();  
        
        for(String field : oppFields) {
            FieldWrapper fldwrapObj = new FieldWrapper();
            Schema.DescribeFieldResult dfr =  fieldMap.get(field).getDescribe(); 
              
            Schema.DisplayType fieldType = dfr.getType();
            fldwrapObj.fieldName = dfr.getLocalName();
            fldwrapObj.fieldLabel = (fldwrapObj.fieldName == 'Name' ? 'Opportunity Name' : dfr.getLabel()); 
            fldwrapObj.fieldType = fieldType.name();
            fldwrapObj.operatorOptions = new List<String>();
            fldwrapObj.pklstOptions =  new List<String>();
            
            if(fieldType == Schema.DisplayType.String) {
                fldwrapObj.operatorOptions.addAll(textOprtrList);
            } else if(fieldType == Schema.DisplayType.Date || fieldType == Schema.DisplayType.Currency) {
                fldwrapObj.operatorOptions.addAll(nbroprtrList);
            } else if (fieldType == Schema.DisplayType.Picklist) {
                List<String> pklstOptions = new List<String>();
                
                for(Schema.PicklistEntry ple : dfr.getPicklistValues()) {
                    pklstOptions.add(ple.getLabel());       
                }
                
                fldwrapObj.operatorOptions.addAll(textOprtrList);
                fldwrapObj.pklstOptions.addAll(pklstOptions);
            }
            
            fieldInfoMap.put(dfr.getLocalName(), fldwrapObj);
        }
        
        FieldWrapper accNameWrap = new FieldWrapper();
        accNameWrap.fieldName = 'Account.Name';
        accNameWrap.fieldLabel = 'Account Name';
        accNameWrap.fieldType = 'STRING';
        accNameWrap.operatorOptions = new List<String>();
        accNameWrap.pklstOptions =  new List<String>();
        accNameWrap.operatorOptions.addAll(textOprtrList);
        fieldInfoMap.put(accNameWrap.fieldName, accNameWrap);
        
        return fieldInfoMap;
    }
    
    @AuraEnabled 
    public static List<String> getAllCurrency() {
        List<String> allCurrList = new List<String>();
        for(CurrencyType c : [SELECT IsoCode FROM CurrencyType]){
            allCurrList.add(c.IsoCode);
        }
        return allCurrList ;
    }
    
    public class OpptWrapper {
        @AuraEnabled
        public String AccountName{get; private set;}
        @AuraEnabled
        public List<Opportunity> oppList{get; private set;}
    }
    
    
    public class FieldWrapper {
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldLabel{get; set;}
        @AuraEnabled
        public String fieldType{get; private set;}
        @AuraEnabled
        public List<String> operatorOptions{get; private set;}
        @AuraEnabled
        public List<String> pklstOptions{get; private set;}
       
    }
    
     public class FieldFilterWrapper {
       /*public FieldFilterWrapper() {} commented empty block */
       
       public FieldFilterWrapper(String fieldName, String fieldLabel, String fieldType, String selectedOPR, String selectedValue, List<String> selectedOptions, String mode) {
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldType =  fieldType;
            this.selectedOPR = selectedOPR;
            this.selectedValue = selectedValue;
            this.selectedOptions = selectedOptions;
            this.mode = mode;
        }
        
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String selectedOPR{get;set;}
        @AuraEnabled
        public String selectedValue{get;set;}
        @AuraEnabled
        public List<String> selectedOptions{get;set;}
        @AuraEnabled
        public String mode{get;set;}
    }
    
}