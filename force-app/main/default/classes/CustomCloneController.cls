/****************************************************************************************************************
* ClassName     :   CustomCloneController
* Author        :   Mudit Saxena / Ajay Dixit
* Version       :   Initial
* Description   :   This Class is used by CustomCloneComponent for cloning opportunity. 
* Change Date     Chnaged By       Change Description
* 23-Feb-2021     Puneet Bhatia    Added check for CPQ Source Oppty
*********************************************************************************************
* Change Date     Chnaged By       Change Description
* 18-mar-2021     Monika            EBA_SF-1167-Custom seting Custom Clone Opportunity should be able to handle field API having more than 40 characters for clone functionalities. 
*1/18/2022   Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
****************************************************************************************************************/
public class CustomCloneController {
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   recordId                :   Opportunity Record id,
isCloneWithProduct      :   flag to identify that user hit cloning with product,
isCloneWithLink         :   flag to identify that user hit cloning with Link,
isCloneWithoutProduct   :   flag to identify that user hit cloning without Product
* Return        :   paramWrapper  
* Description   :   This Method return wrapper which is used by createRecord Method on Component.
This Wrapper Contains ObjectName and field Values.
****************************************************************************************************************/
    final static String CPQ_FLD = 'CPQ__c';
    
    @AuraEnabled
    public static paramWrapper getData(Id recordId, boolean isCloneWithProduct, boolean isCloneWithLink, boolean isCloneWithoutProduct) {
        
        paramWrapper PW = new paramWrapper();
        PW.objectApiName = 'Opportunity'; 
        PW.lstFieldsDetail = new List<dataWrapper>();
        sObject targetRecord = null;
        
        Schema.DescribeSObjectResult dscOppRslt = Schema.SObjectType.Opportunity; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = dscOppRslt.getRecordTypeInfosById();  
        
        if(isCloneWithProduct) {
            targetRecord = CustomCloneController.getTargetRecord(recordId, CPQ_FLD, PW); 
            if (PW.srcOppType == 'CPQ') {
                isCloneWithProduct = false;
                isCloneWithoutProduct = true;
            }            
        } else { targetRecord = CustomCloneController.getTargetRecord(recordId, null, null); } 

        // NC_AGILE-1906 - Cloning from a Prospecting Opportunity is not allowed
        if((String.valueOf(targetRecord.get('StageName'))).toUpperCase() == 'PROSPECTING') {
            throw new AuraHandledException('Error: Cloning from a Prospecting Opportunity is not allowed');
        }
        
        //getting Clear field info from custom setting.
        Set<String>clearfields = new Set<String>();
        clearfields.addAll( CustomCloneController.clearFieldSet( isCloneWithProduct, isCloneWithLink, isCloneWithoutProduct) );
        
        //Getting Channel record type Identifer
        /*List<Channel_RecordType_Clone_Setting__c>ChannelRecordTypeCloneSetting = new List<Channel_RecordType_Clone_Setting__c>();
ChannelRecordTypeCloneSetting = [ SELECT Name , Value_Must_Be__c FROM Channel_RecordType_Clone_Setting__c ];

if( ChannelRecordTypeCloneSetting != null && ChannelRecordTypeCloneSetting.size() > 0 ){
for( Channel_RecordType_Clone_Setting__c CRCS : ChannelRecordTypeCloneSetting ){
if( CRCS.Value_Must_Be__c == string.valueOf( targetRecord.get( CRCS.Name ) ) ){
PW.recordTypeId = 'Channel';
}
}
}else{
PW.recordTypeId = string.valueOf( targetRecord.get( 'RecordTypeId' ) );
}*/
        
        //Getting Default Value Map
        Map<string,string>defaultValueMap = new Map<string,string>();
        defaultValueMap.putAll( CustomCloneController.defaultValueMap() );
        
        /************* WORKING CODE
for( String fieldApiName : CustomCloneController.getFields( recordId ) ){
dataWrapper DW = new dataWrapper();
DW.fieldApiName = fieldApiName;
DW.fieldValue = defaultValueMap.ContainsKey( fieldApiName ) ? defaultValueMap.get( fieldApiName ) : clearfields.Contains( fieldApiName ) ? '' : string.valueOf( targetRecord.get( fieldApiName ) );         
PW.lstFieldsDetail.add( DW );
}
*************  WORKING CODE *  a0R7000000c4QxPEAU*/
        String trgtRtId = string.valueOf(targetRecord.get('RecordTypeId'));
        if(rtMapById.get(trgtRtId).isAvailable()) {
          PW.recordTypeId = trgtRtId;    
        }
        
        for( String fieldApiName : CustomCloneController.getFields( recordId ) ){
            dataWrapper DW = new dataWrapper();
            
            if( fieldApiName == 'Service_Sales_Consultant__c' ){
                DW.fieldApiName = fieldApiName;
                DW.fieldValue = null;
            }else
                if( fieldApiName == 'OwnerId' ){
                    DW.fieldApiName = fieldApiName;
                    DW.fieldValue = string.valueOf( UserInfo.getUserId() );
                } else if( fieldApiName == 'StageName' ){
                    //Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity; 
                    String rtName = rtMapById.get(String.valueOf(targetRecord.get('RecordTypeId'))).getDeveloperName();
                    String fieldValue = defaultValueMap.ContainsKey( fieldApiName ) ? defaultValueMap.get( fieldApiName ) : clearfields.Contains( fieldApiName ) ? '' : string.valueOf( targetRecord.get( fieldApiName ) ); 
                    fieldValue = ((rtName == 'ExcludefromFunnel' || rtName == 'Indirect_Exclude_from_Funnel') && String.isNotBlank(fieldValue)) ?  (fieldValue + ' - NonFunnel') : fieldValue; 
                    
                    DW.fieldApiName = fieldApiName;
                    DW.fieldValue = fieldValue;
                } else if( fieldApiName == 'IsClone__c' ){
                    DW.fieldApiName = fieldApiName;
                    DW.fieldValue = string.valueOf( targetRecord.get( 'id' ) );
                }else if(fieldApiName == 'isCloneWithProduct__c'){
                    if(isCloneWithProduct){
                        DW.fieldApiName = fieldApiName;
                        DW.fieldValue = 'true';
                        DW.fieldType='Boolean';   
                    }else{
                        DW.fieldApiName = fieldApiName;
                        DW.fieldValue = 'false';
                        DW.fieldType='Boolean'; 
                    }
                    
                }
            
            else if(fieldApiName == 'ClonedFromOpportunity__c'){
                if(isCloneWithLink){
                    if(string.valueOf( targetRecord.get( 'ClonedFromOpportunity__c' ) ) == null){
                        DW.fieldApiName = fieldApiName;
                        DW.fieldValue = string.valueOf( targetRecord.get( 'id' ) );    
                    }else{
                        DW.fieldApiName = fieldApiName;
                        DW.fieldValue = string.valueOf( targetRecord.get( 'ClonedFromOpportunity__c' ));
                    }
                    
                }else{
                    DW.fieldApiName = fieldApiName;
                    DW.fieldValue = null; 
                }
                
            }
            //handling Sales Org Code Cloned. If original Opportunity from wher clone initiated has Cloned as Sales Org then blank out the value.
            //else if( fieldApiName == 'Sales_Org__c' && string.valueOf( targetRecord.get( 'Sales_Org__c' ) ) == 'a0R7000000c4QxPEAU' ){
            else if( fieldApiName == 'Sales_Org__c'){
                DW.fieldApiName = fieldApiName;
                DW.fieldValue = null;
            }else if (CustomCloneController.fieldType( fieldApiName ) =='DATETIME'){
            //else if(fieldApiName == 'User_Modified_Date__c'){
                DW.fieldApiName = fieldApiName;
                if(targetRecord.get( fieldApiName  )!=Null){
                Datetime dt = DateTime.valueOf(targetRecord.get( fieldApiName ));                 
                String dtime = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                DW.fieldValue = dtime; 
                }
            }
            
            else{
                if( CustomCloneController.fieldType( fieldApiName ) == 'BOOLEAN'){
                    DW.fieldApiName = fieldApiName;
                    //DW.fieldValue = string.valueOf( targetRecord.get( fieldApiName ) );
                    DW.fieldValue = defaultValueMap.ContainsKey(fieldApiName ) ? defaultValueMap.get(fieldApiName)  : clearfields.Contains(fieldApiName) ? 'false' : string.valueOf(targetRecord.get(fieldApiName)); 
                    DW.fieldType='Boolean';                    
                }else{
                    DW.fieldApiName = fieldApiName;                   
                    String clearVal='';
                    if(CustomCloneController.fieldType( fieldApiName )=='REFERENCE'){
                        system.debug('@@'+fieldApiName);
                        clearVal=null ;
                    }
                    
                    DW.fieldValue = defaultValueMap.ContainsKey( fieldApiName ) ? defaultValueMap.get( fieldApiName ) : clearfields.Contains( fieldApiName ) ? clearVal : string.valueOf( targetRecord.get( fieldApiName ) );         
                }
            }
            PW.lstFieldsDetail.add( DW );
        }
        return PW;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   recordId    :   Opportunity Record id
* Return        :   sObject  
* Description   :   This Method return the queried result with all the fields.                      
****************************************************************************************************************/
    public static sObject getTargetRecord( Id recordId, String acsChkFld, paramWrapper PW) { 
        List<string>Fields = CustomCloneController.getFields( recordId );
       
        System.debug(String.join( Fields,',' ));
        if (String.isNotBlank(acsChkFld)) {
           if (!new Set<String>(Fields).contains(acsChkFld)) { 
              Fields.add(acsChkFld);    
              PW.hasFieldAccess = false; 
           } else 
              PW.hasFieldAccess = true;
        }
        string query = ' Select '+String.join( Fields,',' )+' FROM Opportunity WHERE id = \''+ recordId+'\'';   
        sObject srcRcrd  = database.query( query );
        
        if(String.isNotBlank(acsChkFld)) {
            PW.srcOppType = (Boolean) srcRcrd.get(acsChkFld) == true ? 'CPQ' : 'Non-CPQ';   
        }
        
        return srcRcrd;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   recordId    :   Opportunity Record id
* Return        :   List<string>  
* Description   :   This Method return List of All field from Opportunity.                      
****************************************************************************************************************/
    public static List<string>getFields( Id recordId){
        List<string>returnFieldList = new List<string>();
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get( 'Opportunity' ).getDescribe().fields.getMap();
        
        for( string fieldApiName : fieldsMap.keySet() ){            
            Schema.DescribeFieldResult fieldResult = fieldsMap.get( fieldApiName ).getDescribe();
            if( fieldResult.isCreateable() && fieldResult.isUpdateable() ){ 
                returnFieldList.add( fieldResult.getName() );
            }
        }
        return returnFieldList;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   isCloneWithProduct      :   flag to identify that user hit cloning with product,
isCloneWithLink         :   flag to identify that user hit cloning with Link,
isCloneWithoutProduct   :   flag to identify that user hit cloning without Product,
* Return        :   set<string> 
* Description   :   This Method return Set of fields which we want to clear while cloning opportunity.                      
Set contains fields on the basis of flag. i.e. which button is pressed by user
****************************************************************************************************************/
    public static set<string>clearFieldSet( boolean isCloneWithProduct, boolean isCloneWithLink, boolean isCloneWithoutProduct) {
        set<string>returnSet = new set<string>();
        string query = ' SELECT id,Field_API_Name__c FROM Custom_Clone_Opportunity__c WHERE ';
        string WhereCondition = isCloneWithProduct ? 'isClear_With_Product__c = true' : isCloneWithLink ? 'isClear_Link__c = true' : isCloneWithoutProduct ? 'isClear_Without_Product__c = true' : '';
        for( Custom_Clone_Opportunity__c COF : database.query(String.escapeSingleQuotes(query + WhereCondition)) ){
            returnSet.add( COF.Field_API_Name__c);
        }
        return returnSet;
    }
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Param         :   
* Return        :   Map<string,string>
* Description   :   This Method return Map of fields API Name as KEY and Dafault value of that field as VALUE.
****************************************************************************************************************/
    public static Map<string,string>defaultValueMap(){
        Map<string,string> returnMap = new Map<string,string>();
        for( Custom_Clone_Opportunity__c CCO : [ SELECT Field_API_Name__c, Default_Value__c FROM Custom_Clone_Opportunity__c ] ){
            if( CCO.Default_Value__c != null && CCO.Default_Value__c.trim().length() > 0 )
                returnMap.put( CCO.Field_API_Name__c,CCO.Default_Value__c );            
        }
        return returnMap;
    }
    
    public static string fieldType( string fieldApiName ){
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();        
        Schema.SObjectField field = M.get( fieldApiName );
        Schema.DisplayType FldType = field.getDescribe().getType(); 
        return string.valueof( FldType );
    }
    
    
    
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Description   :   Wrapper
****************************************************************************************************************/
    public class paramWrapper {
        @AuraEnabled
        public String srcOppType{get;set;}
        @AuraEnabled
        public Boolean hasFieldAccess{get;set;}
        @AuraEnabled
        public String objectApiName{get;set;}
        @AuraEnabled
        public String recordTypeId{get;set;}
        @AuraEnabled
        public List<dataWrapper> lstFieldsDetail{get;set;}
    }
    /****************************************************************************************************************
* Author        :   Mudit Saxena
* Description   :   Wrapper
****************************************************************************************************************/
    public class dataWrapper{                        
        @AuraEnabled
        public String fieldApiName{get;set;}        
        @AuraEnabled
        public String fieldValue{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
    }
}