/*************************************************************************************************
* ClassName     :   ReportScheduleController
* Author        :   Kapil Bhati 
* Email Id      :   kb250441@ncr.com  
* Description   :   Contains different methods used for customReportScheduler lwc
* Version       :   Initial
* Story Number  :   EBA_SF-2153
# Modification History.: 
Story No#         Date            DevName                Description

*************************************************************************************************/

public with sharing class  ReportScheduleController {
    
    // METHOD TO FETCH SCHEDULE EXTERNAL RECORD USING RECORD ID
    @AuraEnabled(cacheable=true)
    public static List<Schedule_External_Report__c> getScheduleReportDetail(Id scheduleReportId){
        return [select Email_Body__c,Email_subject__c,Start_Date__c,End_Date__c,NextBatchDate__c,Is_Batch_Triggered_on_End_Date__c,Frequency__c,Schedule_external_report_name__c,Schedule_Time__c,Report_1_Name__c,Report_2_Name__c,Report_3_Name__c,Report_1_Id__c,Report_2_Id__c,Report_3_Id__c,Schedule_report_requested_by__c,Schedule_report_requested_by__r.Name,
                (select id,Additional_Email_1__c,Additional_Email_2__c,Additional_Email_3__c,Additional_Email_4__c,Additional_Recipient_Type__c,
                 Contact__c,Contact_Name__c,Direct_MCN__c,Email__c,Indirect_MCN__c,Reporting_Filter__c,Schedule_External_Report__c,Direct_FUA__c,Indirect_FUA__c from Email_Recipient__r) 
                from Schedule_External_Report__c where id =:scheduleReportId];
    }
    
    // METHOD TO FETCH REPORT DETAILS USING REPORT ID
    @AuraEnabled(cacheable=true)
    public static Report getReportDetails(Id reportId){
        return [select id,name from report where id=:reportId ];
    }
    
    //METHOD TO FETCH CONTACTS INDIRECT AND DIRECT MCN's
    @AuraEnabled
    public static List<contactWrapper> getRelatedContactData(List<Id> contactIdList){
        system.debug('contactIdList=='+contactIdList);
        if(contactIdList.size()>0){
            List<contact> conList = new List<contact>();
            List<contactWrapper> conWrapperList = new List<contactWrapper>();
            for(Contact conObj:[select id,name,email,account.Master_Customer_Number__c,account.Site_Number__c,AccountId,Account.owner.email,Account.owner.quicklook_id__c,Account.owner.name from contact where Id IN:contactIdList  ORDER BY Name ASC limit 1000 ]){
                conList.add(conObj);
                contactWrapper conWrapObj = new contactWrapper();
                conWrapObj.recordName = (String) conObj.name;
                conWrapObj.recordId  = (String) conObj.Id;
                conWrapObj.recordEmail = (String)  conObj.Email;
                conWrapObj.recordDirectMCN = (String) conObj.Account.Master_Customer_Number__c;
                conWrapObj.recordDirectFUA = (String) conObj.Account.Site_Number__c;
                conWrapObj.recordAccountOwnerQuickLookId = (String) conObj.Account.owner.quicklook_id__c;
                if(conObj.Account.owner.quicklook_id__c=='adminnsc'){
                    conWrapObj.recordAccountOwnerEmail =(String) ''; 
                    conWrapObj.recordAccountOwnerName =  (String) '';
                } 
                
                else {
                    conWrapObj.recordAccountOwnerEmail = (String) conObj.Account.owner.email; 
                    conWrapObj.recordAccountOwnerName =  (String) conObj.Account.owner.name;
                }
                
                conWrapperList.add(conWrapObj);
            }
            
            for(AccountContactRelation relationObj: [SELECT Account.Master_Customer_Number__c,Account.Site_number__c,Account.owner.email,Account.owner.quicklook_id__c,Account.owner.name,contactId FROM AccountContactRelation where ContactId IN:contactIdList and isDirect=false  limit 2000]) {
                //   conList.add(record);
                for(contactWrapper conWrapObj:conWrapperList){
                    if(conWrapObj.recordId==relationObj.contactId){
                        
                        // Populating Indirect MCN
                        if( conWrapObj.recordIndirectMCN!=null){
                            if(relationObj.Account.Master_Customer_Number__c!=null)
                                conWrapObj.recordIndirectMCN =  conWrapObj.recordIndirectMCN +', ' +(String) relationObj.Account.Master_Customer_Number__c;
                        }
                        else{
                            conWrapObj.recordIndirectMCN =  (String) relationObj.Account.Master_Customer_Number__c;
                        }
                        
                        // Populating Indirect FUA
                        if( conWrapObj.recordIndirectFUA!=null){
                            if(relationObj.Account.Site_number__c!=null)
                                conWrapObj.recordIndirectFUA =  conWrapObj.recordIndirectFUA +', ' +(String) relationObj.Account.Site_number__c;
                        }
                        else{
                            conWrapObj.recordIndirectFUA =  (String) relationObj.Account.Site_number__c;
                        }
                        
                        if(relationObj.Account.owner.quicklook_id__c!='adminnsc' && !conWrapObj.recordAccountOwnerEmail.contains(relationObj.Account.owner.email)){
                            if(conWrapObj.recordAccountOwnerEmail!=null && conWrapObj.recordAccountOwnerEmail!=''){
                                conWrapObj.recordAccountOwnerEmail = (String) conWrapObj.recordAccountOwnerEmail +', '+relationObj.Account.owner.email;
                                conWrapObj.recordAccountOwnerName = (String) conWrapObj.recordAccountOwnerName +', '+relationObj.Account.owner.name;
                            }
                            
                            else{
                                conWrapObj.recordAccountOwnerEmail = (String) relationObj.Account.owner.email;  
                                conWrapObj.recordAccountOwnerName =  (String) relationObj.Account.owner.name;
                            }
                            
                        }
                        
                        if(!conWrapObj.recordAccountOwnerQuickLookId.contains(relationObj.Account.owner.quicklook_id__c)){
                            if(conWrapObj.recordAccountOwnerQuickLookId!=null){
                                conWrapObj.recordAccountOwnerQuickLookId = (String) conWrapObj.recordAccountOwnerQuickLookId +', '+relationObj.Account.owner.quicklook_id__c;    
                                
                            }
                            else{
                                conWrapObj.recordAccountOwnerQuickLookId = (String) relationObj.Account.owner.quicklook_id__c;   
                            }
                        }
                    }
                    
                    
                    if(conWrapObj.recordIndirectMCN!=null){
                        conWrapObj.recordIndirectMCNSize = conWrapObj.recordIndirectMCN.length(); 
                    }
                    
                    if(conWrapObj.recordIndirectFUA!=null){
                        conWrapObj.recordIndirectFUASize = conWrapObj.recordIndirectFUA.length(); 
                    }
                }
            }
            return conWrapperList;
        }
        
        else{
            return null;
        } 
    }
    
    @AuraEnabled (cacheable=true)
    public static boolean validateReport(Id reportId){
        Boolean validity = false;
        List<String> customReportTypeList = new  List<String>();
        customReportTypeList = System.Label.Schedule_External_Report_Type.split(',');
        if(customReportTypeList.size()!=0){
            // Get the report metadata
            Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
            Reports.ReportType reportType = describe.getReportMetadata().getReportType();
            for(string customReportType:customReportTypeList){
                if(reportType.getType()==customReportType){
                    validity = true; 
                }
            }  
        }
        else{
            validity = false;    
        }
        return validity;
    }
    
    @InvocableMethod(label='updateScheduleExternalReport')  
    public static void updateScheduleExternalReport(List<Id> recordId){
        Schedule_External_Report__c scheduleExtRepObj = [select id,last_email_sent_successfully__c from schedule_external_report__c where id=:recordId[0] ];
        //conversion of time zones
        DateTime dtTime=DateTime.now();
        TimeZone tz = UserInfo.getTimeZone();
        Integer offset=tz.getOffset(dtTime);
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone('America/New_York');
        integer offsetTotargetTZ = targetTZ.getOffset(dtTime);
        integer correction = offsetTotargetTZ- offset;
        DateTime targetDT = dtTime.addMinutes(correction / (1000 * 60));
        if(scheduleExtRepObj.last_email_sent_successfully__c!=targetDT){
            scheduleExtRepObj.Last_Email_Sent_Successfully__c = targetDT;
            update scheduleExtRepObj;
        }
        
    }
    
    //METHOD TO GET EMAIL RECIPIENT RECORDS SO THAT IMMEDIATE EMAIL CAN BE TRIGGERED
    @AuraEnabled 
    public static Map<id,Boolean> getEmailRecipientRecord(Id scheduleExternalReportId){
        Map<id,Boolean> emailRecipientMap = new Map<id,Boolean>();
        for(Email_recipient__c erObj:[select id,updatedByBatch__c from Email_recipient__c where Schedule_External_Report__c=:scheduleExternalReportId]){
            emailRecipientMap.put(erObj.id,erObj.updatedByBatch__c);
        }
        return emailRecipientMap;
    } 
    
    //METHOD TO SEARCH SOBJECT RECORDS. WE ARE USING THIS METHOD IN CUSTOMMULTISELECTLOOKUP 
    @AuraEnabled (cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, String fieldAPINames,String filterFieldAPIName,String strInput,String objid){
        
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')){
            strInput = '';
        }
        String str = strInput + '%';
        String strQueryField = '';
        List<String> fieldList = fieldAPINames.split(',');
        List<String> temp =  filterFieldAPIName.split(','); 
        String strQuery ='';   
        system.debug('objid'+objid);
        
        //fieldList.add('AccountId');
        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }
        
        if(objectName =='Account'){
            strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                + ' FROM ' 
                + String.escapeSingleQuotes(objectName) 
                + ' WHERE ' + String.escapeSingleQuotes(temp.get(0)) + '  LIKE \'' + str + '%\''
                + 'AND MASTER_CUSTOMER_NUMBER__C!=NULL'
                +' ORDER BY ' + filterFieldAPIName
                + ' LIMIT 50';
        }
        else if(objectName =='Contact'){
            strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                + ' FROM ' 
                + String.escapeSingleQuotes(objectName) 
                + ' WHERE ' + String.escapeSingleQuotes(temp.get(0)) + '  LIKE \'' + str + '%\''
                + 'AND EMAIL!=NULL AND (ACCOUNT.MASTER_CUSTOMER_NUMBER__C!=NULL OR ACCOUNT.Site_Number__c!=NULL)'
                +' ORDER BY ' + filterFieldAPIName
                + ' LIMIT 50'; 
        }
        
        else{
            strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                + ' FROM ' 
                + String.escapeSingleQuotes(objectName) 
                + ' WHERE ' + String.escapeSingleQuotes(temp.get(0)) + '  LIKE \'' + str + '%\''
                +' ORDER BY ' + filterFieldAPIName
                + ' LIMIT 50';  
            system.debug('strQuery--'+strQuery);
        }
        System.debug('strQuery=' + strQuery);
        
        List<SObject> lstResult = database.query(strQuery);
        //create list of records that can be easily be parsable at js controller.
        for(String strField:fieldList){
            for(SObject sobj:lstResult){                
                
                if(strField != 'Id' && strField != 'Name' && objectName !='Opportunity'){
                    SObjectQueryResult result = new SObjectQueryResult();
                    result.recordId = (String) sobj.get('Id');
                    result.recordName = (String) sobj.get('Name');
                    result.recordEmail = (String) sobj.get(strField);
                    lstReturnResult.add(result);
                }
            }
        }
        return lstReturnResult;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Report> getAllReports() {
        List<String> folderNameList = System.Label.Schedule_External_Report_Folder.split(',');
        return [select id,name,foldername,owner.name,DeveloperName,Description from report where FolderName IN:folderNameList and  format NOT IN('MultiBlock','Matrix')  limit 1000]; 
    }
    
    // METHOD TO RETURN SEARCH RESULT USED IN CUSTOMLOOKUP LWC 
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        String myQuery = null;
        List<String> folderNameList = System.Label.Schedule_External_Report_Folder.split(',');
        if(myObject!='Report'){
            if(myObject=='User'){
                if(filter != null && filter != ''){
                    myQuery = 'Select Id, Name,Quicklook_ID__c from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
                }
                else {
                    if(searchTerm == null || searchTerm == ''){
                        myQuery = 'Select Id, Name,Quicklook_ID__c from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
                    }
                    else {
                        myQuery = 'Select Id, Name,Quicklook_ID__c from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
                    }
                }  
            }
            else{
                if(filter != null && filter != ''){
                    myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
                }
                else {
                    if(searchTerm == null || searchTerm == ''){
                        myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
                    }
                    else {
                        myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
                    }
                } 
            }
            
        }
        else{
            if(filter != null && filter != ''){
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' AND FolderName IN:folderNameList and Format NOT IN(\'MultiBlock\',\'Matrix\') LIMIT  5';
            }
            else {
                if(searchTerm == null || searchTerm == ''){
                    myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL AND FolderName IN:folderNameList ORDER BY LastViewedDate DESC LIMIT  5';
                }
                else {
                    myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND FolderName IN:folderNameList LIMIT  5';
                }
            }   
        }
        
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;
        
        @AuraEnabled
        public String recordName;
        
        @AuraEnabled
        public String recordEmail;
        
        @AuraEnabled
        public String recordOppId;
    }
    
    public class contactWrapper {
        @AuraEnabled
        public String recordId;
        
        @AuraEnabled
        public String recordName;
        
        @AuraEnabled
        public String recordEmail;
        
        @AuraEnabled
        public String recordDirectMCN;
        
        @AuraEnabled
        public String recordIndirectMCN;
        
        @AuraEnabled
        public String recordAccountOwnerEmail;
        
        @AuraEnabled
        public String recordAccountOwnerQuickLookId;
        
        @AuraEnabled
        public String recordAccountOwnerName;
        
        @AuraEnabled
        public String recordDirectFUA;
        
        @AuraEnabled
        public String recordIndirectFUA;
        
        @AuraEnabled
        public Integer recordIndirectMCNSize=0;
        
        @AuraEnabled
        public Integer recordIndirectFUASize=0;
        
    }
    
}