/****************************************************************************************************************
* Author        :   Ajay Dixit  , Puneet Bhatia  
* Description   :   This class will hold several methods helpful in triggers, classes etc.
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
****************************************************************************************************************/


public with sharing class NSCCommonInfoUtil {
    
    // private static variable referencing the class
    private static NSCCommonInfoUtil instance = null;
    private static User LtngUsr = null;
    private Map<String,Theater_Area_Mapping__c> TheaterAreaMappingInfo;
    private Map<String,Theater_Area_Mapping__c> SMB_TheaterAreaMappingInfo;
    private  map<Integer,map<integer,Date>> mpFscalMnthEndDt;
    
    private Set<String> Non_ROR_Countries_Picklist_Vals;
    private user isLtngUsr;
    
    public  Map<String, Id> recordTypeMap=new Map<String, Id>();
    public  Map<String, Id> profileNameIDMap=new Map<String, Id>();    
    public  Set<Id> systemUsers=new Set<Id>();
    
    
    Private Set<String> prdCat_PicklistVals ;
    // The constructor is private 
    
    // Get USD exchange rate from multicurrency table
    public Map<String,Decimal> CurrencyConversionRateMap = new Map<String,Decimal>();
    
    
    
    // The constructor is private 
    private NSCCommonInfoUtil() {
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    
    // a static method that returns the instance of the record type
    public static NSCCommonInfoUtil getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) instance = new NSCCommonInfoUtil();
        return instance;
    }
    
    
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit

* Return        :   Map<string, id>
* Description   :   Get a Map of Key=Profile Name, Value=ID of profile
****************************************************************************************************************/
    
    public Map<String, Id> getMapOfAllProfiles() {
        if(profileNameIDMap.isEmpty()){            
            for (Profile p : [SELECT Id, Name FROM profile]) { 
                profileNameIDMap.put(p.Name.toUpperCase(), p.Id); 
            }   
        }
        
        return profileNameIDMap; //return the map
    }
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   name of profile
* Return        :   ID of profile
* Description   :   get profile ID of respective profile name
****************************************************************************************************************/
    
    public  Id getProfileId(String profilename) {
        if(profileNameIDMap.isEmpty()){            
            for (Profile p : [SELECT Id, Name FROM profile]) { 
                profileNameIDMap.put(p.Name.toUpperCase(), p.Id); 
            }   
        }       
        return profileNameIDMap.get(profilename.toUpperCase()); //return the map
    }
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   objName  :   Name of Object
id   :   API Name of Picklist field
sortValues  :   Boolean decide do sort or not
* Return        :   sObject
* Description   :   pass object name and Id to get all fields for sObject record
****************************************************************************************************************/
    public  sObject getObject(string objName, string id) {
        
        String fieldnames = '';
        sObject obj;
        try {
            Map < String, Schema.SObjectType > m = Schema.getGlobalDescribe();
            Schema.SObjectType s = m.get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            
            //get fields
            Map < String, Schema.SObjectField > fields = r.fields.getMap();
            for (string field: fields.keySet()) {
                if (fieldnames == '') {
                    fieldnames = field;
                } else {
                    fieldnames += ',' + field;
                }
            }
            
            //create SQL
            String sql = 'SELECT ' + fieldnames + ' FROM ' + objName + ' WHERE Id=\'' + id + '\'';
            System.debug(sql);
            obj = database.query(String.escapeSingleQuotes(sql));
            
        } catch (Exception e) {
            System.debug('get Fields Error' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return obj;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   objectName  :   Name of Object
fieldName   :   API Name of Picklist field
sortValues  :   Boolean decide do sort or not
* Return        :   List<string>
* Description   :   Get a list of a field's picklist values.
****************************************************************************************************************/
    //creates a map of all Record Type Names to Ids based upon a passed Object
    public  Map<String, Id> buildMapOfRecordTypes(String passedSobjectType) {
        Map<String, Id> returnMap = new Map<String, Id>(); //the return map variable
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = :passedSobjectType]) { //grab the recordtypes for the specified sObject
            returnMap.put(rt.Name, rt.Id); //put the details into our map (Name -> Id)
        }
        return returnMap; //return the map
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   objectName  :   Name of Object
fieldName   :   API Name of Picklist field
sortValues  :   Boolean decide do sort or not
* Return        :   List<string>
* Description   :   Get a list of a field's picklist values.
****************************************************************************************************************/
    
    //creates a map of all Record Type Names to Ids based upon a passed Object
    //Key=SobjectType in upper case example ACCOUNT.CUSTOMER is key for customer recordtype on account object
    //value is recordtypeid
    public  Map<String, Id> buildMapOfAllRecordTypes(String passedSobjectType) {
        if(recordTypeMap.isEmpty()){            
            for (RecordType rt : [SELECT Id, Name, SobjectType FROM RecordType]) { 
                recordTypeMap.put(rt.SobjectType.toUpperCase()+'.'+rt.Name.toUpperCase(), rt.Id); //put the details into our map (Name -> Id)
            }   
        }
        
        return recordTypeMap; //return the map
    }
    
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   objectName  :   Name of Object
fieldName   :   API Name of Picklist field
sortValues  :   Boolean decide do sort or not
* Return        :   List<string>
* Description   :   Get a list of a field's picklist values.
****************************************************************************************************************/
    public  List<string> getPicklistValues( string objectName, string fieldName, boolean sortValues ) {
        List<string> values = new List<string>();
        List <String> typs=new List<String>{objectName};
            Schema.DescribeSobjectResult dsr=schema.describeSObjects(typs).get(0);
        Schema.DescribeFieldResult fmd=dsr.fields.getMap().get(fieldName).getDescribe();
        for ( Schema.PickListEntry entry : fmd.getPickListValues() ) {
            values.add( entry.getValue() );
        }
        if ( sortValues ) {
            values.sort();
        }
        return values;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   objectName  :   Name of Object
fieldName   :   API Name of Picklist field
sortValues  :   Boolean decide do sort or not
* Return        :   List<SelectOption>
* Description   :   Get a field's picklist values as list of SelectOptions that can be used with a VF page.
****************************************************************************************************************/
    public  List<SelectOption> getPicklistAsSelectOptions( string objectName, string fieldName, boolean sortValues ) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        for ( string value : getPicklistValues( objectName, fieldName, sortValues ) ) {
            selectOptions.add( new SelectOption( value, value ) );
        }
        return selectOptions;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   objectName      :   Name of Object
standardOnly    :   Boolean decide standred field only
* Return        :   string
* Description   :   Returns a preformatted soql select statement
with all viewable fields in alphabetical order
****************************************************************************************************************/
    public  string selectStar( string objectName, boolean standardOnly ) {
        SObjectType objToken = Schema.getGlobalDescribe().get( objectName );
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<string, SObjectField> fields = objDef.fields.getMap(); 
        Set<string> fieldSet = fields.keySet();
        List<string> fieldList = new List<string>{};
            fieldList.addAll( fields.keySet() );
        fieldList.sort();
        List<string> fieldsToQuery = new List<string>{};
            
            for ( string fieldName:fieldList ) {
                SObjectField fieldToken = fields.get( fieldName );
                DescribeFieldResult selectedField = fieldToken.getDescribe();
                
                //respect CRUD/FLS
                if ( selectedField.isAccessible() ) {
                    if( standardOnly && !fieldName.endsWith('__c') ){
                        //only add standard fields
                        fieldsToQuery.add( selectedField.getName() );
                    }else if( !standardOnly ){
                        //add standard and custom fields
                        fieldsToQuery.add( selectedField.getName() );
                    }
                } else {
                    System.debug( 'not accessible: ' + selectedField.getName() );
                }
            }
        
        string querystring = 'SELECT ';
        querystring += string.join( fieldsToQuery, ', ' );
        querystring += ' FROM ' + objectName + ' ';
        
        return querystring;
    }
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   objectAPIName       :   SObject name
objectFieldList     :   Set A set of fields from the given SObject that should be included within the query
relationshipFields  :   Set A set of any relationship fields, such as those from parent records, that should be included in the query
filter              :   String The filter clause for the query
orderBy             :   String The order by clause for the query
limitTo             :   String The limit clause for the query
* Return        :   string              :   String A dyanmic SOQL query
* Description   :   Generates a dynamic SOQL query based on a given object, field list, and other parameters
****************************************************************************************************************/
    public  String BuildSoqlString( String objectAPIName, set<String> objectFieldList, set<String> relationshipFields, String filter, String orderBy, Integer limitTo ){
        
        String soql = 'SELECT ' + String.escapeSingleQuotes(String.join( new list<String>( objectFieldList ),',') );
        if ( relationshipFields!=null && !relationshipFields.isEmpty() ){
            soql += ', ' + String.escapeSingleQuotes(String.join(new list<String>( relationshipFields ),',') ); 
        }
        soql += ' FROM ' + String.escapeSingleQuotes( objectAPIName );
        if ( filter != null && filter != '' ){
            soql += ' WHERE ' + filter;
        }
        if ( orderBy != null && orderBy!='' ){
            soql += ' ORDER BY ' + String.escapeSingleQuotes(orderBy);
        }
        if ( limitTo != null && limitTo > 0 ){
            soql += ' LIMIT ' + String.escapeSingleQuotes(String.valueOf(limitTo));
        }
        
        return soql;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   ListToSort          :   List<SelectOption>
* Return        :   List<SelectOption>  :   Sorted List.
* Description   :   This is a simple quicksort algorithm to sort a SelectOption list (dropdown) by label alphabetically.
****************************************************************************************************************/
    public  List<SelectOption> sortOptionList( List<SelectOption> ListToSort )  {
        
        if(ListToSort == null || ListToSort.size() <= 1) {
            return ListToSort;                  
        }
        
        List<SelectOption> Less = new List<SelectOption>();     
        List<SelectOption> Greater = new List<SelectOption>();  
        
        integer pivot = 0;              
        // save the pivot and remove it from the list       
        SelectOption pivotValue = ListToSort[pivot];        
        ListToSort.remove(pivot);               
        for(SelectOption x : ListToSort) {          
            if(x.getLabel().compareTo(pivotValue.getLabel()) <= 0) {
                Less.add(x);
            } else if(x.getLabel().compareTo(pivotValue.getLabel()) > 0) {
                Greater.add(x);
            }   
        }       
        List<SelectOption> returnList = new List<SelectOption> ();      
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue); 
        returnList.addAll(SortOptionList(Greater)); 
        
        return returnList; 
    }
    
    // get all records from Theater_Area_Mapping__c object
    public Map<String,Theater_Area_Mapping__c> getTheaterAreaMapping() {
        if (TheaterAreaMappingInfo == null) {
            TheaterAreaMappingInfo = new Map<String,Theater_Area_Mapping__c>();
            
            for(Theater_Area_Mapping__c ar : [select id, Area__c,CDM_SMB_Flag__c, Account_Country_Code__c,Theater__c, Region__c, LOB__C from Theater_Area_Mapping__c where CDM_SMB_Flag__c=false]) {
                String countryLOB = ar.Account_Country_Code__c + ar.LOB__C;
                TheaterAreaMappingInfo.put(countryLOB,ar);
            }   
        }
        return TheaterAreaMappingInfo;
    }
    // get all records from Theater_Area_Mapping__c object where CDM_SMB_Flag__c=true	
    public Map<String,Theater_Area_Mapping__c> SMB_getTheaterAreaMapping() {	
        if (SMB_TheaterAreaMappingInfo == null) {	
            SMB_TheaterAreaMappingInfo = new Map<String,Theater_Area_Mapping__c>();	
            
            for(Theater_Area_Mapping__c ar : [select id, Area__c,CDM_SMB_Flag__c,Account_Country_Code__c,Theater__c, Region__c, LOB__C from Theater_Area_Mapping__c where CDM_SMB_Flag__c=true]) {	
                String countryLOB = ar.Account_Country_Code__c + ar.LOB__C;	
                SMB_TheaterAreaMappingInfo.put(countryLOB,ar);	
            }   	
        }	
        return SMB_TheaterAreaMappingInfo;	
    }
    
    public Set<String> getNonRORCtrs_PicklistVals() {
        if (Non_ROR_Countries_Picklist_Vals == null) {
            Non_ROR_Countries_Picklist_Vals = new Set<String>(); 
            
            for(Schema.PicklistEntry ple : Account.Non_ROR_Countries__c.getDescribe().getPicklistValues()) {
                Non_ROR_Countries_Picklist_Vals.add(ple.getValue());
            }    
        }
        return Non_ROR_Countries_Picklist_Vals;  
    }
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   String queueName, String Typ (nillable to specify group type)
* Return        :   Set of Ids
* Description   :   returns set<id>, This is base method responsible for querying the Queue member 
****************************************************************************************************************/
    
    public Set<Id> getQueueUsers(String queueName, String typ) {
        Set <Id> queueUserSet=new Set<Id>();
        list<GroupMember>userIDs=new List<GroupMember>{};
            if(typ!=null){
                userIDs = [select UserOrGroupId from GroupMember where GroupId IN (select id from Group where type=:typ AND DeveloperName=:queueName)];
            }else{
                userIDs = [select UserOrGroupId from GroupMember where GroupId IN (select id from Group where DeveloperName=:queueName)];
            }
        for(GroupMember rec:userIDs){
            queueUserSet.add(rec.UserOrGroupId);
        }
        return queueUserSet;
    }
    
    
    public Set<String> getPrdCat_PicklistVals() {
        if (prdCat_PicklistVals == null) {
            prdCat_PicklistVals = new Set<String>();
            
            for(Schema.PicklistEntry ple : Product2.Product_Category__c.getDescribe().getPicklistValues()) {
                if(!ple.getValue().equals('IPS')) {
                    prdCat_PicklistVals.add(ple.getValue());
                }
            }  
        }
        return prdCat_PicklistVals;
    }
    
    
    
    public Map<String,Decimal> CollectLocaleConversionRate()
    { 
        
        if(CurrencyConversionRateMap.keySet().size() == 0){
            for(CurrencyType ConvertRateObj : [SELECT Id, IsoCode, ConversionRate FROM CurrencyType])
            {
                CurrencyConversionRateMap.put(ConvertRateObj.IsoCode,ConvertRateObj.ConversionRate);
            }
        }
        
        return CurrencyConversionRateMap;
    }
    /****************************************************************************************************************
* Author        :   Nagendra
* Param         :   User Id
* Return        :   Boolean
* Description   :   returns true if user has ligthning permission else false
****************************************************************************************************************/
    public  boolean userHasLightningPermission(String userId){
        User u;
        if(LtngUsr != null) {
            u = LtngUsr;   
        } else {
            u =[ select id,Profile.Name,Profile.PermissionsLightningExperienceUser  from user where id =:userId ];
            LtngUsr = u;
        }
        if(u.Profile.PermissionsLightningExperienceUser){
            return true;
        }else{
            return false;
        }
        //return false;
    }
    /****************************************************************************************************************
* Author        :   Nagendra
* Param         :   
* Return        :   map<year,map<month,FiscalEndDate>>
Description   : in case opportunity has ORDERMAN products then EDSD would be fiscal end date
****************************************************************************************************************/
    public map<Integer,map<integer,Date>> getFiscalMonthEndDate(){
        if(mpFscalMnthEndDt==null || mpFscalMnthEndDt.isEmpty()){
            Date startdate = Date.newInstance(System.today().year(), 1, 1);
            mpFscalMnthEndDt = new map<Integer,map<integer,Date>>();
            List<Period> AllPeriods = [SELECT EndDate,Id,Number,StartDate FROM Period 
                                       WHERE Type = 'month' AND StartDate >= : startdate ];
            for(Period objPeriod : AllPeriods){
                Integer endDate_Year = objPeriod.EndDate.year();
                if(!mpFscalMnthEndDt.containskey(endDate_Year)){
                    map<integer,Date> monthEndDate = new  map<integer,Date>();
                    monthEndDate.put(objPeriod.Number,objPeriod.EndDate);
                    mpFscalMnthEndDt.put(endDate_Year,monthEndDate);
                }else{
                    map<integer,Date> monthEndDate = new  map<integer,Date>();
                    monthEndDate = mpFscalMnthEndDt.get(endDate_Year);
                    monthEndDate.put(objPeriod.Number,objPeriod.EndDate);
                    mpFscalMnthEndDt.put(endDate_Year,monthEndDate);                    
                }
            }  
        }
        return mpFscalMnthEndDt;
    }
    /****************************************************************************************************************
* Author        :   Ajay Dixit

* Return        :   Set<id>
* Description   :   return set of system users
****************************************************************************************************************/
    
    public Set<Id> getSystemUsers() {
        if(systemUsers.isEmpty()){ 
            Map<id,User> sysUser=new Map<ID, User>([Select id from User where Access_type__c='System']);
            systemUsers.addAll(sysUser.keySet());          
        }
        return systemUsers; //return the set
    }
    
    
    public String prsSaveRslt(List<Database.SaveResult> rslt, List<PermissionSetAssignment> psaLst) {
        String msg = ''; 
        integer i=0;
        
        for(Database.SaveResult sr: rslt)  {
            if(!sr.isSuccess()) {
                Database.Error e = sr.getErrors().get(0); 
                msg += psaLst[i].AssigneeId + '-Error:' + e.getMessage() + '\n';
            }
            i++;
        } return msg; 
    } 
    
    public String prsDelRslt(List<Database.DeleteResult> rslt, List<PermissionSetAssignment> psaLst) {
        String msg = ''; 
        integer i=0;
        
        for(Database.DeleteResult dr: rslt)  {
            if(!dr.isSuccess()) {
                Database.Error e = dr.getErrors().get(0); 
                msg += psaLst[i].AssigneeId + '-Error:' + e.getMessage() + '\n';
            }
            i++;
        } return msg; 
    } 
    //Returns RecordTypeId when name and RecordType name is passed, if incorrect name then null.
    public Id getRecordTypeId(String Obj, String rtName) {
        List<Schema.DescribeSObjectResult> s=schema.describeSObjects(new List<String>{Obj});       
        return s[0]?.getRecordTypeInfosByName().get(rtName)?.getRecordTypeId(); 
        
    }
     //Returns Id of Custom Metadata Type record related to Developer Name passed, If not found then return NULL.
    public static Id getIdOf(String devName) {
       ID_Config__mdt iDs = ID_Config__mdt.getInstance(devName);
		return iDs?.IDs__c;        
    } 
	//Returns SET OF IdS of Custom Metadata Type record related to Developer Name passed, If not found then return NULL.
    public Static Set<Id> getIdSetOf(String devName) {
        ID_Config__mdt iDs = ID_Config__mdt.getInstance(devName); 
        List<Id> idL=iDs?.IDs__c?.replaceAll(', ',',').split(',');
        return idL==null?null:new Set<Id>(idL);         
    } 
    
    public static Map<String,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField) {
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
         
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
         
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey((String) controllerValue)){
                        dependentPicklistValues.put((String) controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controllerValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
    
}