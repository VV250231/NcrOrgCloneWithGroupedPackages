/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class for Hospitality Service Cloud custom integration logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-05-20
* @modified       2022-05-25
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-05-20
*
* v1.1            ba250204@ncr.com
* 2022-07-13      Add PE Database logic
*
* v1.2            ba250204@ncr.com
* 2022-05-20      Add context util methods
*
*v1.3             kb250441@ncr.com
*2022-12-07       Replace country code from account to site 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public inherited sharing class HSRUtil {
    
    // ---- INT-06 Dispatch outbound integration util ----
    public static String generateWorkOrderMessage(WorkOrder record) {
        // @formatter:off
        JSONGenerator jsonGenerator = JSON.createGenerator(true);
        jsonGenerator.writeStartObject(); //1
        jsonGenerator.writeFieldName('Header');
        jsonGenerator.writeStartObject();//2
        jsonGenerator.writeObjectField('TransactionID', getTransactionId(record.Id));
        jsonGenerator.writeObjectField('USERID', HSRConstants.HW_DISPATCH_OUTBOUND_WO_USER_ID);
        jsonGenerator.writeObjectField('SourceSystem', HSRConstants.HW_DISPATCH_OUTBOUND_WO_SOURCE_SYSTEM);
        jsonGenerator.writeEndObject();//2
        jsonGenerator.writeFieldName('CreateServiceRequest');
        jsonGenerator.writeStartObject();//3
        //   jsonGenerator.writeObjectField('CountryCode', getValue(record.Account?.Account_Country_Code__c));
        jsonGenerator.writeObjectField('CountryCode', getValue(record.Site_Id__r?.BillingCountry)); //Modified By Kapil Bhati(kb250441@ncr.com) EBA_SF-2414
        jsonGenerator.writeFieldName('ServiceRequest');
        jsonGenerator.writeStartObject();//4
        jsonGenerator.writeObjectField('CustomerTicketID', getValue(record.WorkOrderNumber));
        jsonGenerator.writeObjectField('Type', getValue(record.Request_Type_Mapping__c));
        jsonGenerator.writeObjectField('ProblemCode', getValue(record.Support_Class_Failure_Reason_Relation__r?.Failure_Reason_Id__c));
        jsonGenerator.writeObjectField('Priority', getPriority(record.Priority_Type__c));
        jsonGenerator.writeObjectField('Summary', getValue(record.Case?.Subject));
        jsonGenerator.writeObjectField('Description', getDescription(record.Description));
        jsonGenerator.writeObjectField('NCRMCN', getValue(record?.Account?.Master_Customer_Number__c));
        
        jsonGenerator.writeFieldName('Caller');
        jsonGenerator.writeStartObject();//5
        jsonGenerator.writeObjectField('Role', getValue(record.Solution_Set_HW_Role_Relation__r?.HW_Role_Id__c));
        if (record.ContactId != null) {
            jsonGenerator.writeObjectField('FirstName', getValue(record.Contact?.FirstName));
            jsonGenerator.writeObjectField('LastName', getValue(record.Contact?.LastName));
            jsonGenerator.writeObjectField('EmailAddress', getValue(record.Contact?.Email));
            jsonGenerator.writeFieldName('PhoneNumber');
            jsonGenerator.writeStartObject();//6
            jsonGenerator.writeObjectField('PhoneNumber', getValue(record.Contact?.Phone));
            jsonGenerator.writeEndObject();//6
        }
        jsonGenerator.writeEndObject();//5
        jsonGenerator.writeFieldName('Site');
        jsonGenerator.writeStartObject();//7
        jsonGenerator.writeObjectField('SiteName', getValue(record.Site_Id__r?.Name));
        jsonGenerator.writeObjectField('NCRSiteNumber', getValue(record.Site_Id__r?.Site_Number__c));
        jsonGenerator.writeObjectField('SiteShortName', HSRConstants.HW_DISPATCH_OUTBOUND_WO_DEFAULT_SITE_SHORT_NAME);
        if (record.ContactId != null) {
            jsonGenerator.writeFieldName('Contact');
            jsonGenerator.writeStartObject();//8
            jsonGenerator.writeObjectField('FirstName', getValue(record.Contact?.FirstName));
            jsonGenerator.writeObjectField('LastName', getValue(record.Contact?.LastName));
            jsonGenerator.writeFieldName('PhoneNumber');
            jsonGenerator.writeStartObject();//9
            jsonGenerator.writeObjectField('PhoneNumber', getValue(record.Contact?.Phone));
            jsonGenerator.writeEndObject();//9
            jsonGenerator.writeEndObject();//8
        }
        if (record.Alt_Work_Site_Flag__c) {
            jsonGenerator.writeFieldName('Address');
            jsonGenerator.writeStartObject();//10
            jsonGenerator.writeObjectField('Line1', getValue(record.Street));
            jsonGenerator.writeObjectField('Line2', getValue(record.Street_Line_2__c));
            jsonGenerator.writeObjectField('City', getValue(record.City));
            jsonGenerator.writeObjectField('PostalCode', getValue(record.PostalCode));
            jsonGenerator.writeObjectField('State', getValue(record.State));
            jsonGenerator.writeEndObject();//10
        }
        jsonGenerator.writeEndObject();//7
        jsonGenerator.writeFieldName('CI');
        jsonGenerator.writeStartObject();//11
        jsonGenerator.writeObjectField('AssetID', getValue(record.Asset?.PID__c));
        jsonGenerator.writeObjectField('ProductID', getProductId(record.Asset?.PID__c));
        jsonGenerator.writeObjectField('SerialNumber', getValue(record.Serial_Number__c));
        jsonGenerator.writeObjectField('Brand', getValue(HSRConstants.HW_DISPATCH_OUTBOUND_WO_DEFAULT_BRAND));
        jsonGenerator.writeObjectField('ConfigurationItem', getValue(record.Case?.CaseNumber));
        jsonGenerator.writeObjectField('DevicePhysicalLocation', getNumericValue(record.Service_Level_Id__c));
        jsonGenerator.writeEndObject();//11
        jsonGenerator.writeObjectField('attribute1', convertBoolToChar(record.SN_Override_Flag__c));
        jsonGenerator.writeObjectField('attribute2', convertBoolToChar(record.Out_of_Scope__c));
        jsonGenerator.writeObjectField('attribute3', getValue(record.Config_Details__c));
        jsonGenerator.writeObjectField('attribute4', getValue(record.Customer_Ticket_Number__c));
        jsonGenerator.writeObjectField('attribute5', getValue(record.Shipment_Method__c));
        jsonGenerator.writeEndObject();//4
        jsonGenerator.writeEndObject();//3
        jsonGenerator.writeEndObject();//1
        // @formatter:on
        
        return jsonGenerator.getAsString();
    }
    
    private static Integer getPriority(Object recordPriorityType) {
        return recordPriorityType != null ? Integer.valueOf(recordPriorityType) : HSRConstants.HW_DISPATCH_OUTBOUND_DEFAULT_PRIORITY_TYPE;
    }
    
    private static String getDescription(String fullDescription) {
        if(fullDescription!=null)
        return getValue(fullDescription.replaceAll('[^.,:;a-zA-Z0-9\\s+]', '')).left(2000); //Modified By Kapil Bhati(kb250441@ncr.com) EBA_SF-2470
        else
            return getValue(fullDescription);
    }
    
    private static String getProductId(String sourceAssetId) {
        return getValue(sourceAssetId).left(14);
    }
    
    private static String getTransactionId(String sourceRecordId) {
        return getValue(sourceRecordId).right(8);
    }
    
    private static String convertBoolToChar(Boolean booleanVal) {
        return booleanVal ? 'Y' : 'N';
    }
    
    public static String getValue(String value) {
        return String.isBlank(value) ? '' : value.trim();
    }
    
    private static Integer getNumericValue(Object numericValue) {
        return numericValue != null ? Integer.valueOf(numericValue) : -1;
    }
    // ---- End of INT-06 util ----
    
    public static Boolean isUserProvisioningCustomerProfile(String userProfile) {
        String userProvisioningProfiles = System.Label.HSR_UsrPrv_Profiles;
        if (String.isBlank(userProfile) || String.isBlank(userProvisioningProfiles)) {
            return false;
        }
        for (String profileName : userProvisioningProfiles.split(';')) {
            if (userProfile.trim().containsIgnoreCase(profileName.trim())) {
                return true;
            }
        }
        return false;
    }
    
    // ---- Error Logging ----
    public static String generateResponseErrorMessage(HttpResponse response) {
        return '\nResponse status: ' + response.getStatusCode() + ' ' + response.getStatus() +
            '\nResponse message: ' + response.getBody();
    }
    
    public static String generateExceptionMessage(Exception err) {
        return '\nA ' + err.getTypeName() + ' error has occurred:' +
            '\nError Message: ' + err.getMessage() +
            '\nLine: ' + err.getLineNumber() +
            '\nStacktrace: ' + err.getStackTraceString();
    }
    
    /**
* Log exception messages in "Dispute Integration Log" object
* @param caseNumber WorkOrder related Case Number
* @param request Http request that caused the exception
* @Param friendlyMessage stored in a system custom label (based on the destination system)
* @param errorMessage Exception message
* @return wrapper dispute integration log record
*/
    public static Dispute_Integration_Logs__c createExceptionLog(String caseNumber, HttpRequest request, String friendlyMessage, String errorMessage) {
        String transactionId = request?.getHeader('x-transaction-id');
        return new Dispute_Integration_Logs__c(
            Name = transactionId,
            Request__c = request?.getBody(),
            Status__c = friendlyMessage,
            Transaction_Id__c = transactionId,
            caseNumber__c = caseNumber,
            RequestType__c = HSRConstants.HW_DISPATCH_OUTBOUND_REQUEST_TYPE
        );
    }
    
    /**
* Log error messages in "Dispute Integration Log" object
* @param caseNumber WorkOrder related Case Number
* @param request Http request that caused the error
* @param response Http response
* @param errorMessage Exception message
* @return wrapper dispute integration log record
*/
    public static Dispute_Integration_Logs__c createResponseLog(String caseNumber, HttpRequest request, HttpResponse response, String errorMessage) {
        String friendlyMessage = String.format(System.Label.HSR_ERP_Callout_Error, new List<String>{
            errorMessage.left(200)
                });
        String transactionId = request?.getHeader('x-transaction-id');
        return new Dispute_Integration_Logs__c(
            Name = transactionId,
            Request__c = request?.getBody(),
            Response__c = response?.getBody(),
            Status__c = friendlyMessage,
            Transaction_Id__c = transactionId,
            caseNumber__c = caseNumber,
            RequestType__c = HSRConstants.HW_DISPATCH_OUTBOUND_REQUEST_TYPE
        );
    }
    
    /**
* Save system errors and callout errors as "Dispute Integration Log" records using CCADDLogsUtility class
* @param log wrapper record that contains all log details
*/
    public static void logError(Dispute_Integration_Logs__c log) {
        CCADDLogsUtility.insertDisputeLogs(
            log.Transaction_Id__c,
            log.Request__c,
            log.Response__c,
            log.Status__c,
            log.CCAD_Dispute_Nbr__c,
            log.caseNumber__c,
            log.RequestType__c
        );
    }
    // ---- End of Error Logging ----
    
    // ---- Database Operation ----
    @TestVisible
    private static Boolean skipDatabaseOperations = false;
    public static void insertList(List<SObject> recordsToInsert, Boolean allOrNone) {
        if (skipDatabaseOperations()) {
            for (Integer inx = 0; inx < recordsToInsert.size(); inx++) {
                recordsToInsert[inx].Id = HSRDataFactory.mockId(recordsToInsert[inx].getSObjectType(), inx);
            }
        } else {
            List<Database.SaveResult> srs = Database.insert(recordsToInsert, allOrNone);
            for (Database.SaveResult sr : srs) {
                System.debug('HSRUtil/insertList insert ' + recordsToInsert[0].getSObjectType().getDescribe().getName() + ' result: ' + (sr.isSuccess() ? 'Success' : 'failed'));
                if (!sr.isSuccess()) {
                    System.debug('HSRUtil/insertList error: ' + JSON.serializePretty(sr.getErrors()));
                }
            }
        }
    }
    
    public static void updateList(List<SObject> recordsToUpdate, Boolean allOrNone) {
        if (skipDatabaseOperations()) {
            for (Integer inx = 0; inx < recordsToUpdate.size(); inx++) {
                recordsToUpdate[inx].Id = recordsToUpdate[inx].Id == null ? HSRDataFactory.mockId(recordsToUpdate[inx].getSObjectType(), 0) : recordsToUpdate[inx].Id;
            }
        } else {
            List<Database.SaveResult> srs = Database.update(recordsToUpdate, allOrNone);
            for (Database.SaveResult sr : srs) {
                System.debug('HSRUtil/updateList update ' + recordsToUpdate[0].getSObjectType().getDescribe().getName() + ' result: ' + (sr.isSuccess() ? 'Success' : 'failed'));
                if (!sr.isSuccess()) {
                    System.debug('HSRUtil/updateList error: ' + JSON.serializePretty(sr.getErrors()));
                }
            }
        }
    }
    
    public static void deleteList(List<SObject> recordsToDelete, Boolean allOrNone) {
        if (skipDatabaseOperations()) {
            for (SObject record : recordsToDelete) {
                record = null;
            }
        } else {
            List<Database.DeleteResult> drs = Database.delete(recordsToDelete, allOrNone);
            for (Database.DeleteResult dr : drs) {
                System.debug('HSRUtil/deleteList delete ' + recordsToDelete[0].getSObjectType().getDescribe().getName() + ' result: ' + (dr.isSuccess() ? 'Success' : 'failed'));
                if (!dr.isSuccess()) {
                    System.debug('HSRUtil/updateList error: ' + JSON.serializePretty(dr.getErrors()));
                }
            }
        }
    }
    
    public static void publishEvent(List<SObject> eventsToPublish) {
        
        if (!skipDatabaseOperations()) {
            List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
            
            for (Database.SaveResult sr : results) {
                System.debug('HSRUtil/publishEvent publish ' + eventsToPublish[0].getSObjectType().getDescribe().getName() + ' result: ' + (sr.isSuccess() ? 'Success' : 'failed'));
                if (!sr.isSuccess()) {
                    System.debug('HSRUtil/publishEvent Error: ' + JSON.serializePretty(sr.getErrors()));
                }
            }
        }
    }
    
    private static Boolean skipDatabaseOperations(){
        return Test.isRunningTest() && skipDatabaseOperations;
    }
    
    // ---- Processing Context ----
    @TestVisible private static Boolean isRunningBatch { set; get; }
    public static Boolean isBatchExecuting(String batchClassName) {
        return Test.isRunningTest() ? isRunningBatch : !HSRSelector.getRunningBatchByClassName(batchClassName, HSRConstants.ASYNC_JOB_JOB_TYPE_BATCH).isEmpty();
    }
    
    @TestVisible private static Integer mockCurrentQueueableUsage {
        set;
        get {
            return (Test.isRunningTest() && mockCurrentQueueableUsage != null) ? mockCurrentQueueableUsage : Limits.getQueueableJobs();
        }
    }
    public static Boolean canEnqueue() {
        return Limits.getLimitQueueableJobs() > mockCurrentQueueableUsage;
    }
    
    // ---- Limits ----
    @TestVisible private static Integer mockMaxNumberOfDMLRows { get; set; }
    public static Integer getMaxNumberOfDMLRows() {
        return (Test.isRunningTest() && mockMaxNumberOfDMLRows != null) ? mockMaxNumberOfDMLRows : System.Limits.getLimitDmlRows() - System.Limits.getDmlRows();
    }
    
    // ---- Records Creation ----
    public static List<AccountContactRelation> makeAccountContactRelations(List<Account> accounts, Contact relatedContact) {
        List<AccountContactRelation> accountContactRelationsToInsert = new List<AccountContactRelation>();
        for (Account account : accounts) {
            if (account.Id != relatedContact.AccountId) {
                accountContactRelationsToInsert.add(
                    makeAccountContactRelation(account.Id, relatedContact.Id)
                );
            }
        }
        
        return accountContactRelationsToInsert;
    }
    
    public static AccountContactRelation makeAccountContactRelation(Id accountId, Id contactId) {
        return new AccountContactRelation(
            AccountId = accountId,
            ContactId = contactId,
            Hospitality_Experience_Cloud_Automation__c = true,
            Roles = HSRConstants.ACR_DEFAULT_ROLES
        );
    }
}