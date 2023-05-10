public class MetadataUpdateService {
     public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';
    
     public virtual class Metadata {
        public String fullName;
     }
    
    public class PackageTypeMembers {
        public String[] members;
        public String name;
        private String[] members_type_info = new String[]{'members',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'members','name'};
    }
    
    public class ProfileObjectPermissions {
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean modifyAllRecords;
        public String object_x; 
        public Boolean viewAllRecords;
        private String[] allowCreate_type_info = new String[]{'allowCreate',SOAP_M_URI,null,'0','1','false'};
        private String[] allowDelete_type_info = new String[]{'allowDelete',SOAP_M_URI,null,'0','1','false'};
        private String[] allowEdit_type_info = new String[]{'allowEdit',SOAP_M_URI,null,'0','1','false'};
        private String[] allowRead_type_info = new String[]{'allowRead',SOAP_M_URI,null,'0','1','false'};
        private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords',SOAP_M_URI,null,'0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
        private String[] viewAllRecords_type_info = new String[]{'viewAllRecords',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
    }
    
     public class Package_x extends Metadata {
        public String type = 'Package_x';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String apiAccessLevel;
        public String description;
        public String namespacePrefix;
        public MetadataUpdateService.ProfileObjectPermissions[] objectPermissions;
        public String packageType;
        public String postInstallClass;
        public String setupWeblink;
        public MetadataUpdateService.PackageTypeMembers[] types;
        public String uninstallClass;
        public String version;
        private String[] apiAccessLevel_type_info = new String[]{'apiAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] objectPermissions_type_info = new String[]{'objectPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] packageType_type_info = new String[]{'packageType',SOAP_M_URI,null,'0','1','false'};
        private String[] postInstallClass_type_info = new String[]{'postInstallClass',SOAP_M_URI,null,'0','1','false'};
        private String[] setupWeblink_type_info = new String[]{'setupWeblink',SOAP_M_URI,null,'0','1','false'};
        private String[] types_type_info = new String[]{'types',SOAP_M_URI,null,'0','-1','false'};
        private String[] uninstallClass_type_info = new String[]{'uninstallClass',SOAP_M_URI,null,'0','1','false'};
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'apiAccessLevel','description','namespacePrefix','objectPermissions','packageType','postInstallClass','setupWeblink','types','uninstallClass','version'};
    }
    
    public class ProfileCustomMetadataTypeAccess {
		public Boolean enabled;
		public String name;
		private transient String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,'boolean','1','1','false'};
		private transient String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
		private transient String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private transient String[] field_order_type_info = new String[]{'enabled','name'};
	}
    
     public class ProfileCustomSettingAccess { 
		public Boolean enabled;
		public String name;
		private transient String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,'boolean','1','1','false'};
		private transient String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
		private transient String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private transient String[] field_order_type_info = new String[]{'enabled','name'};
	}
    
     public class ProfileFieldLevelSecurity {
        public Boolean editable;
        public String field;
        public Boolean readable;
        private String[] editable_type_info = new String[]{'editable',SOAP_M_URI,null,'1','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] readable_type_info = new String[]{'readable',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'editable','field','readable'};
    }
    
     public class RetrieveRequest {
        public Double apiVersion;
        public String[] packageNames;
        public Boolean singlePackage;
        public String[] specificFiles;
        public MetadataUpdateService.Package_x unpackaged;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] packageNames_type_info = new String[]{'packageNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] specificFiles_type_info = new String[]{'specificFiles',SOAP_M_URI,null,'0','-1','false'};
        private String[] unpackaged_type_info = new String[]{'unpackaged',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiVersion','packageNames','singlePackage','specificFiles','unpackaged'};
    }
    
    public class AsyncResult {
        public Boolean done;
        public String id;
        public String message;
        public String state;
        public String statusCode;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'0','1','false'};
        private String[] state_type_info = new String[]{'state',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','id','message','state','statusCode'};
    }
    
    public class UpsertResult {
        public Boolean created;
        public MetadataUpdateService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'created','errors','fullName','success'};
    }
    
     public class upsertMetadataResponse_element {
        public MetadataUpdateService.UpsertResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
     public class listMetadataResponse_element {
        public MetadataUpdateService.FileProperties[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
     public class checkRetrieveStatus_element {
        public String asyncProcessId;
        public Boolean includeZip;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
        private String[] includeZip_type_info = new String[]{'includeZip',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId','includeZip'};
    }
    
     public class checkRetrieveStatusResponse_element {
        public MetadataUpdateService.RetrieveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
     public class RetrieveMessage {
        public String fileName;
        public String problem;
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fileName','problem'};
    }
    
     public class FileProperties {
        public String createdById;
        public String createdByName;
        public DateTime createdDate;
        public String fileName;
        public String fullName;
        public String id;
        public String lastModifiedById;
        public String lastModifiedByName;
        public DateTime lastModifiedDate;
        public String manageableState;
        public String namespacePrefix;
        public String type_x;
        private String[] createdById_type_info = new String[]{'createdById',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedById_type_info = new String[]{'lastModifiedById',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedByName_type_info = new String[]{'lastModifiedByName',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'1','1','false'};
        private String[] manageableState_type_info = new String[]{'manageableState',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'createdById','createdByName','createdDate','fileName','fullName','id','lastModifiedById','lastModifiedByName','lastModifiedDate','manageableState','namespacePrefix','type_x'};
    }
    
    public class checkDeployStatusResponse_element {
        public MetadataUpdateService.DeployResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class retrieveResponse_element {
        public MetadataUpdateService.AsyncResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class CancelDeployResult {
        public Boolean done;
        public String id;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','id'};
    }
    
    public class cancelDeployResponse_element {
        public MetadataUpdateService.CancelDeployResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class RetrieveResult {
        public Boolean done;
        public String errorMessage;
        public String errorStatusCode;
        public MetadataUpdateService.FileProperties[] fileProperties;
        public String id;
        public MetadataUpdateService.RetrieveMessage[] messages;
        public String status;
        public Boolean success;
        public String zipFile;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] errorStatusCode_type_info = new String[]{'errorStatusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] fileProperties_type_info = new String[]{'fileProperties',SOAP_M_URI,null,'0','-1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] messages_type_info = new String[]{'messages',SOAP_M_URI,null,'0','-1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] zipFile_type_info = new String[]{'zipFile',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','errorMessage','errorStatusCode','fileProperties','id','messages','status','success','zipFile'};
    }
    
    public class DeployMessage {
        public Boolean changed;
        public Integer columnNumber;
        public String componentType;
        public Boolean created;
        public DateTime createdDate;
        public Boolean deleted;
        public String fileName;
        public String fullName;
        public String id;
        public Integer lineNumber;
        public String problem;
        public String problemType;
        public Boolean success;
        private String[] changed_type_info = new String[]{'changed',SOAP_M_URI,null,'1','1','false'};
        private String[] columnNumber_type_info = new String[]{'columnNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'0','1','false'};
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] deleted_type_info = new String[]{'deleted',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'0','1','false'};
        private String[] lineNumber_type_info = new String[]{'lineNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'0','1','false'};
        private String[] problemType_type_info = new String[]{'problemType',SOAP_M_URI,null,'0','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'changed','columnNumber','componentType','created','createdDate','deleted','fileName','fullName','id','lineNumber','problem','problemType','success'};
    }
    
    public class DeployDetails {
        public MetadataUpdateService.DeployMessage[] componentFailures;
        public MetadataUpdateService.DeployMessage[] componentSuccesses;
        public MetadataUpdateService.RetrieveResult retrieveResult;
        private String[] componentFailures_type_info = new String[]{'componentFailures',SOAP_M_URI,null,'0','-1','false'};
        private String[] componentSuccesses_type_info = new String[]{'componentSuccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] retrieveResult_type_info = new String[]{'retrieveResult',SOAP_M_URI,null,'0','1','false'};
        private String[] runTestResult_type_info = new String[]{'runTestResult',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentFailures','componentSuccesses','retrieveResult','runTestResult'};
    }
    
    public class describeMetadata_element {
        public Double asOfVersion;
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asOfVersion'};
    }
    
    public class describeMetadataResponse_element {
        public MetadataUpdateService.DescribeMetadataResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
     public class ExtendedErrorDetails {
        public String extendedErrorCode;
        private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorCode'};
     }
    
     public class Error {
        public MetadataUpdateService.ExtendedErrorDetails[] extendedErrorDetails;
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] extendedErrorDetails_type_info = new String[]{'extendedErrorDetails',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorDetails','fields','message','statusCode'};
     }
    
     public class SaveResult {
        public MetadataUpdateService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    
     public class DeleteResult {
        public MetadataUpdateService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    
     public class deleteMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }

    public class deleteMetadataResponse_element {
        public MetadataUpdateService.DeleteResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class renameMetadata_element {
        public String type_x;
        public String oldFullName;
        public String newFullName;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] oldFullName_type_info = new String[]{'oldFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] newFullName_type_info = new String[]{'newFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','oldFullName','newFullName'};
    }
    
    public class renameMetadataResponse_element {
        public MetadataUpdateService.SaveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
      public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
      }
        
     public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] level_type_info = new String[]{'level',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    
     public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
    
     public class DebuggingHeader_element {
        public MetadataUpdateService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories',SOAP_M_URI,null,'0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
     }
    
     public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    
     public class DescribeMetadataObject {
        public String[] childXmlNames;
        public String directoryName;
        public Boolean inFolder;
        public Boolean metaFile;
        public String suffix;
        public String xmlName;
        private String[] childXmlNames_type_info = new String[]{'childXmlNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] directoryName_type_info = new String[]{'directoryName',SOAP_M_URI,null,'1','1','false'};
        private String[] inFolder_type_info = new String[]{'inFolder',SOAP_M_URI,null,'1','1','false'};
        private String[] metaFile_type_info = new String[]{'metaFile',SOAP_M_URI,null,'1','1','false'};
        private String[] suffix_type_info = new String[]{'suffix',SOAP_M_URI,null,'0','1','false'};
        private String[] xmlName_type_info = new String[]{'xmlName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'childXmlNames','directoryName','inFolder','metaFile','suffix','xmlName'};
    }
    
    public class DescribeMetadataResult {
        public MetadataUpdateService.DescribeMetadataObject[] metadataObjects;
        public String organizationNamespace;
        public Boolean partialSaveAllowed;
        public Boolean testRequired;
        private String[] metadataObjects_type_info = new String[]{'metadataObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] organizationNamespace_type_info = new String[]{'organizationNamespace',SOAP_M_URI,null,'1','1','false'};
        private String[] partialSaveAllowed_type_info = new String[]{'partialSaveAllowed',SOAP_M_URI,null,'1','1','false'};
        private String[] testRequired_type_info = new String[]{'testRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadataObjects','organizationNamespace','partialSaveAllowed','testRequired'};
    }
    
    public class updateMetadataResponse_element {
        public MetadataUpdateService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class updateMetadata_element {
        public MetadataUpdateService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    
     public class DeployResult {
        public String canceledBy;
        public String canceledByName;
        public Boolean checkOnly;
        public DateTime completedDate;
        public String createdBy;
        public String createdByName;
        public DateTime createdDate;
        public MetadataUpdateService.DeployDetails details;
        public Boolean done;
        public String errorMessage;
        public String errorStatusCode;
        public String id;
        public Boolean ignoreWarnings;
        public DateTime lastModifiedDate;
        public Integer numberComponentErrors;
        public Integer numberComponentsDeployed;
        public Integer numberComponentsTotal;
        public Integer numberTestErrors;
        public Integer numberTestsCompleted;
        public Integer numberTestsTotal;
        public Boolean rollbackOnError;
        public Boolean runTestsEnabled;
        public DateTime startDate;
        public String stateDetail;
        public String status;
        public Boolean success;
        private String[] canceledBy_type_info = new String[]{'canceledBy',SOAP_M_URI,null,'0','1','false'};
        private String[] canceledByName_type_info = new String[]{'canceledByName',SOAP_M_URI,null,'0','1','false'};
        private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] completedDate_type_info = new String[]{'completedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] createdBy_type_info = new String[]{'createdBy',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] details_type_info = new String[]{'details',SOAP_M_URI,null,'1','1','false'};
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] errorStatusCode_type_info = new String[]{'errorStatusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] numberComponentErrors_type_info = new String[]{'numberComponentErrors',SOAP_M_URI,null,'1','1','false'};
        private String[] numberComponentsDeployed_type_info = new String[]{'numberComponentsDeployed',SOAP_M_URI,null,'1','1','false'};
        private String[] numberComponentsTotal_type_info = new String[]{'numberComponentsTotal',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestErrors_type_info = new String[]{'numberTestErrors',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestsCompleted_type_info = new String[]{'numberTestsCompleted',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestsTotal_type_info = new String[]{'numberTestsTotal',SOAP_M_URI,null,'1','1','false'};
        private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
        private String[] runTestsEnabled_type_info = new String[]{'runTestsEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] startDate_type_info = new String[]{'startDate',SOAP_M_URI,null,'0','1','false'};
        private String[] stateDetail_type_info = new String[]{'stateDetail',SOAP_M_URI,null,'0','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'canceledBy','canceledByName','checkOnly','completedDate','createdBy','createdByName','createdDate','details','done','errorMessage','errorStatusCode','id','ignoreWarnings','lastModifiedDate','numberComponentErrors','numberComponentsDeployed','numberComponentsTotal','numberTestErrors','numberTestsCompleted','numberTestsTotal','rollbackOnError','runTestsEnabled','startDate','stateDetail','status','success'};
    }
    
     public class retrieve_element {
        public MetadataUpdateService.RetrieveRequest retrieveRequest;
        private String[] retrieveRequest_type_info = new String[]{'retrieveRequest',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'retrieveRequest'};
    }
    
     public class cancelDeploy_element {
        public String String_x;
        private String[] String_x_type_info = new String[]{'String',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'String_x'};
    }
    
     public class checkDeployStatus_element {
        public String asyncProcessId;
        public Boolean includeDetails;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
        private String[] includeDetails_type_info = new String[]{'includeDetails',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId','includeDetails'};
    }
    
     public class deployRecentValidation_element {
        public String validationId;
        private String[] validationId_type_info = new String[]{'validationId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'validationId'};
    }
    
    public class deployRecentValidationResponse_element {
        public String result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
     public class ListMetadataQuery {
        public String folder;
        public String type_x;
        private String[] folder_type_info = new String[]{'folder',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'folder','type_x'};
    }
    
     public class listMetadata_element {
        public MetadataUpdateService.ListMetadataQuery[] queries;
        public Double asOfVersion;
        private String[] queries_type_info = new String[]{'queries',SOAP_M_URI,null,'0','-1','false'};
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'queries','asOfVersion'};
    }
    
    public class createMetadataResponse_element {
        public MetadataUpdateService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class deployResponse_element {
        public MetadataUpdateService.AsyncResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class DeployOptions {
        public Boolean allowMissingFiles;
        public Boolean autoUpdatePackage;
        public Boolean checkOnly;
        public Boolean ignoreWarnings;
        public Boolean performRetrieve;
        public Boolean purgeOnDelete;
        public Boolean rollbackOnError;
        public String[] runTests;
        public Boolean singlePackage;
        public String testLevel;
        private String[] allowMissingFiles_type_info = new String[]{'allowMissingFiles',SOAP_M_URI,null,'1','1','false'};
        private String[] autoUpdatePackage_type_info = new String[]{'autoUpdatePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
        private String[] performRetrieve_type_info = new String[]{'performRetrieve',SOAP_M_URI,null,'1','1','false'};
        private String[] purgeOnDelete_type_info = new String[]{'purgeOnDelete',SOAP_M_URI,null,'1','1','false'};
        private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
        private String[] runTests_type_info = new String[]{'runTests',SOAP_M_URI,null,'0','-1','false'};
        private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] testLevel_type_info = new String[]{'testLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowMissingFiles','autoUpdatePackage','checkOnly','ignoreWarnings','performRetrieve','purgeOnDelete','rollbackOnError','runTests','singlePackage','testLevel'};
    }
    
    public class deploy_element {
        public String ZipFile;
        public MetadataUpdateService.DeployOptions DeployOptions;
        private String[] ZipFile_type_info = new String[]{'ZipFile',SOAP_M_URI,null,'1','1','false'};
        private String[] DeployOptions_type_info = new String[]{'DeployOptions',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'ZipFile','DeployOptions'};
    }
    
     public class PicklistEntry {
        public Boolean active;
        public Boolean defaultValue;
        public String label;
        public String validFor;
        public String value;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] validFor_type_info = new String[]{'validFor',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','defaultValue','label','validFor','value'};
    }
    
      public class ValueTypeField {
        public MetadataUpdateService.ValueTypeField[] fields;
        public String[] foreignKeyDomain;
        public Boolean isForeignKey;
        public Boolean isNameField;
        public Integer minOccurs;
        public String name;
        public MetadataUpdateService.PicklistEntry[] picklistValues;
        public String soapType;
        public Boolean valueRequired;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] foreignKeyDomain_type_info = new String[]{'foreignKeyDomain',SOAP_M_URI,null,'0','-1','false'};
        private String[] isForeignKey_type_info = new String[]{'isForeignKey',SOAP_M_URI,null,'1','1','false'};
        private String[] isNameField_type_info = new String[]{'isNameField',SOAP_M_URI,null,'1','1','false'};
        private String[] minOccurs_type_info = new String[]{'minOccurs',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] soapType_type_info = new String[]{'soapType',SOAP_M_URI,null,'1','1','false'};
        private String[] valueRequired_type_info = new String[]{'valueRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','foreignKeyDomain','isForeignKey','isNameField','minOccurs','name','picklistValues','soapType','valueRequired'};
    }
    
     public class DescribeValueTypeResult {
        public Boolean apiCreatable;
        public Boolean apiDeletable;
        public Boolean apiReadable;
        public Boolean apiUpdatable;
        public MetadataUpdateService.ValueTypeField parentField;
        public MetadataUpdateService.ValueTypeField[] valueTypeFields;
        private String[] apiCreatable_type_info = new String[]{'apiCreatable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiDeletable_type_info = new String[]{'apiDeletable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiReadable_type_info = new String[]{'apiReadable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiUpdatable_type_info = new String[]{'apiUpdatable',SOAP_M_URI,null,'1','1','false'};
        private String[] parentField_type_info = new String[]{'parentField',SOAP_M_URI,null,'0','1','false'};
        private String[] valueTypeFields_type_info = new String[]{'valueTypeFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiCreatable','apiDeletable','apiReadable','apiUpdatable','parentField','valueTypeFields'};
    }
    
    public class describeValueType_element {
        public String type_x;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x'};
    }
    
    public class describeValueTypeResponse_element {
        public MetadataUpdateService.DescribeValueTypeResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    
    public class createMetadata_element {
        public MetadataUpdateService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    
    public class upsertMetadata_element {
        public MetadataUpdateService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }

     public class ProfileApplicationVisibility {
        public String application;
        public Boolean default_x;
        public Boolean visible;
        private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'application','default_x','visible'};
    }

     public class ProfileCategoryGroupVisibility {
        public String[] dataCategories;
        public String dataCategoryGroup;
        public String visibility;
        private String[] dataCategories_type_info = new String[]{'dataCategories',SOAP_M_URI,null,'0','-1','false'};
        private String[] dataCategoryGroup_type_info = new String[]{'dataCategoryGroup',SOAP_M_URI,null,'1','1','false'};
        private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dataCategories','dataCategoryGroup','visibility'};
    }
    
     public class ProfileApexClassAccess {
        public String apexClass;
        public Boolean enabled;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexClass','enabled'};
    }
    
     public class ProfileCustomPermissions {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','name'};
    }
    
     public class ProfileExternalDataSourceAccess {
        public Boolean enabled;
        public String externalDataSource;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','externalDataSource'};
    }
    
     public class ProfileLoginIpRange {
        public String description;
        public String endAddress;
        public String startAddress;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] endAddress_type_info = new String[]{'endAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] startAddress_type_info = new String[]{'startAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','endAddress','startAddress'};
    }
    
      public class ProfileLoginHours {
        public String fridayEnd;
        public String fridayStart;
        public String mondayEnd;
        public String mondayStart;
        public String saturdayEnd;
        public String saturdayStart;
        public String sundayEnd;
        public String sundayStart;
        public String thursdayEnd;
        public String thursdayStart;
        public String tuesdayEnd;
        public String tuesdayStart;
        public String wednesdayEnd;
        public String wednesdayStart;
        private String[] fridayEnd_type_info = new String[]{'fridayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] fridayStart_type_info = new String[]{'fridayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] mondayEnd_type_info = new String[]{'mondayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] mondayStart_type_info = new String[]{'mondayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] saturdayEnd_type_info = new String[]{'saturdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] saturdayStart_type_info = new String[]{'saturdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] sundayEnd_type_info = new String[]{'sundayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] sundayStart_type_info = new String[]{'sundayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] thursdayEnd_type_info = new String[]{'thursdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] thursdayStart_type_info = new String[]{'thursdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] tuesdayEnd_type_info = new String[]{'tuesdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] tuesdayStart_type_info = new String[]{'tuesdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] wednesdayEnd_type_info = new String[]{'wednesdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] wednesdayStart_type_info = new String[]{'wednesdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fridayEnd','fridayStart','mondayEnd','mondayStart','saturdayEnd','saturdayStart','sundayEnd','sundayStart','thursdayEnd','thursdayStart','tuesdayEnd','tuesdayStart','wednesdayEnd','wednesdayStart'};
    }
    
      public class ProfileApexPageAccess {
        public String apexPage;
        public Boolean enabled;
        private String[] apexPage_type_info = new String[]{'apexPage',SOAP_M_URI,null,'1','1','false'};
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexPage','enabled'};
    }
    
     public class ProfileUserPermission {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','name'};
    }
    
     public class ProfileTabVisibility {
        public String tab;
        public String visibility;
        private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
        private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'tab','visibility'};
    }
    
     public class ProfileRecordTypeVisibility {
        public Boolean default_x;
        public Boolean personAccountDefault;
        public String recordType;
        public Boolean visible;
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] personAccountDefault_type_info = new String[]{'personAccountDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'default_x','personAccountDefault','recordType','visible'};
    }
    
     public class ProfileLayoutAssignment {
        public String layout;
        public String recordType;
        private String[] layout_type_info = new String[]{'layout',SOAP_M_URI,null,'1','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layout','recordType'};
    }
    
     public class ProfileActionOverride {
        public String actionName;
        public String content;
        public String formFactor;
        public String pageOrSobjectType;
        public String recordType;
        public String type_x;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'1','1','false'};
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        private String[] formFactor_type_info = new String[]{'formFactor',SOAP_M_URI,null,'1','1','false'};
        private String[] pageOrSobjectType_type_info = new String[]{'pageOrSobjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionName','content','formFactor','pageOrSobjectType','recordType','type_x'};
    }
    
    public class PermissionSetFlowAccess {
		public Boolean enabled;
		public String flow;
		private transient String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,'boolean','1','1','false'};
		private transient String[] flow_type_info = new String[]{'flow',SOAP_M_URI,'string','1','1','false'};
		private transient String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private transient String[] field_order_type_info = new String[]{'enabled','flow'};
	}
    
     public class Profile extends Metadata {
        public String type = 'Profile';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataUpdateService.ProfileApplicationVisibility[] applicationVisibilities;
        public MetadataUpdateService.ProfileCategoryGroupVisibility[] categoryGroupVisibilities;
        public MetadataUpdateService.ProfileApexClassAccess[] classAccesses;
        public Boolean custom;
        public MetadataUpdateService.ProfileCustomMetadataTypeAccess[] customMetadataTypeAccesses;
        public MetadataUpdateService.ProfileCustomPermissions[] customPermissions;
        public String description;
        public MetadataUpdateService.ProfileExternalDataSourceAccess[] externalDataSourceAccesses;
        public MetadataUpdateService.ProfileFieldLevelSecurity[] fieldPermissions;
        public MetadataUpdateService.PermissionSetFlowAccess[] flowAccesses;
        public MetadataUpdateService.ProfileLayoutAssignment[] layoutAssignments;
        public MetadataUpdateService.ProfileLoginHours loginHours;
        public MetadataUpdateService.ProfileLoginIpRange[] loginIpRanges;
        public MetadataUpdateService.ProfileObjectPermissions[] objectPermissions;
        public MetadataUpdateService.ProfileApexPageAccess[] pageAccesses;
        public MetadataUpdateService.ProfileActionOverride[] profileActionOverrides;
        public MetadataUpdateService.ProfileRecordTypeVisibility[] recordTypeVisibilities;
        public MetadataUpdateService.ProfileTabVisibility[] tabVisibilities;
        public String userLicense;
        public MetadataUpdateService.ProfileUserPermission[] userPermissions;
        public MetadataUpdateService.ProfileCustomSettingAccess[] customSettingAccesses;         
        private String[] applicationVisibilities_type_info = new String[]{'applicationVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] categoryGroupVisibilities_type_info = new String[]{'categoryGroupVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] classAccesses_type_info = new String[]{'classAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] custom_type_info = new String[]{'custom',SOAP_M_URI,null,'0','1','false'};
        private String[] customMetadataTypeAccesses_type_info = new String[]{'customMetadataTypeAccesses',SOAP_M_URI,'ProfileCustomMetadataTypeAccess','0','-1','false'};         
        private String[] customPermissions_type_info = new String[]{'customPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDataSourceAccesses_type_info = new String[]{'externalDataSourceAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] fieldPermissions_type_info = new String[]{'fieldPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] flowAccesses_type_info = new String[]{'flowAccesses',SOAP_M_URI,'ProfileFlowAccess','0','-1','false'};
        private String[] layoutAssignments_type_info = new String[]{'layoutAssignments',SOAP_M_URI,null,'0','-1','false'};
        private String[] loginHours_type_info = new String[]{'loginHours',SOAP_M_URI,null,'0','1','false'};
        private String[] loginIpRanges_type_info = new String[]{'loginIpRanges',SOAP_M_URI,null,'0','-1','false'};
        private String[] objectPermissions_type_info = new String[]{'objectPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] pageAccesses_type_info = new String[]{'pageAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] profileActionOverrides_type_info = new String[]{'profileActionOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] recordTypeVisibilities_type_info = new String[]{'recordTypeVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] tabVisibilities_type_info = new String[]{'tabVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] userLicense_type_info = new String[]{'userLicense',SOAP_M_URI,null,'0','1','false'};
        private String[] userPermissions_type_info = new String[]{'userPermissions',SOAP_M_URI,null,'0','-1','false'};
		private  String[] customSettingAccesses_type_info = new String[]{'customSettingAccesses',SOAP_M_URI,'ProfileCustomSettingAccess','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'applicationVisibilities','categoryGroupVisibilities','classAccesses','custom','customMetadataTypeAccesses','customPermissions','description','externalDataSourceAccesses','fieldPermissions','flowAccesses', 'layoutAssignments','loginHours','loginIpRanges','objectPermissions','pageAccesses','profileActionOverrides','recordTypeVisibilities','tabVisibilities','userLicense','userPermissions', 'customSettingAccesses'};
    }
    
     public interface IReadResult {
        MetadataUpdateService.Metadata[] getRecords();
     }
     public interface IReadResponseElement {
        IReadResult getResult();
     }
    
     public class readMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    
  
    public class readProfileResponse_element implements IReadResponseElement {
        public MetadataUpdateService.ReadProfileResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
  
   public class ReadProfileResult implements IReadResult {
        public MetadataUpdateService.Profile[] records;
        public MetadataUpdateService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    
    
      public class MetadataPort {
        public String endpoint_x = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/56.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public MetadataUpdateService.SessionHeader_element SessionHeader;
        public MetadataUpdateService.DebuggingInfo_element DebuggingInfo;
        public MetadataUpdateService.DebuggingHeader_element DebuggingHeader;
        public MetadataUpdateService.CallOptions_element CallOptions;
        public MetadataUpdateService.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'MetadataService'};
        public MetadataUpdateService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
            MetadataUpdateService.deleteMetadata_element request_x = new MetadataUpdateService.deleteMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataUpdateService.deleteMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.deleteMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.deleteMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deleteMetadata',
              SOAP_M_URI,
              'deleteMetadataResponse',
              'MetadataUpdateService.deleteMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.SaveResult renameMetadata(String type_x,String oldFullName,String newFullName) {
            MetadataUpdateService.renameMetadata_element request_x = new MetadataUpdateService.renameMetadata_element();
            request_x.type_x = type_x;
            request_x.oldFullName = oldFullName;
            request_x.newFullName = newFullName;
            MetadataUpdateService.renameMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.renameMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.renameMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'renameMetadata',
              SOAP_M_URI,
              'renameMetadataResponse',
              'MetadataUpdateService.renameMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.SaveResult[] updateMetadata(MetadataUpdateService.Metadata[] metadata) {
            MetadataUpdateService.updateMetadata_element request_x = new MetadataUpdateService.updateMetadata_element();
            request_x.metadata = metadata;
            MetadataUpdateService.updateMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.updateMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.updateMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'updateMetadata',
              SOAP_M_URI,
              'updateMetadataResponse',
              'MetadataUpdateService.updateMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
            MetadataUpdateService.describeMetadata_element request_x = new MetadataUpdateService.describeMetadata_element();
            request_x.asOfVersion = asOfVersion;
            MetadataUpdateService.describeMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.describeMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.describeMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeMetadata',
              SOAP_M_URI,
              'describeMetadataResponse',
              'MetadataUpdateService.describeMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.DeployResult checkDeployStatus(String asyncProcessId,Boolean includeDetails) {
            MetadataUpdateService.checkDeployStatus_element request_x = new MetadataUpdateService.checkDeployStatus_element();
            request_x.asyncProcessId = asyncProcessId;
            request_x.includeDetails = includeDetails;
            MetadataUpdateService.checkDeployStatusResponse_element response_x;
            Map<String, MetadataUpdateService.checkDeployStatusResponse_element> response_map_x = new Map<String, MetadataUpdateService.checkDeployStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'checkDeployStatus',
              SOAP_M_URI,
              'checkDeployStatusResponse',
              'MetadataUpdateService.checkDeployStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.RetrieveResult checkRetrieveStatus(String asyncProcessId,Boolean includeZip) {
            MetadataUpdateService.checkRetrieveStatus_element request_x = new MetadataUpdateService.checkRetrieveStatus_element();
            request_x.asyncProcessId = asyncProcessId;
            request_x.includeZip = includeZip;
            MetadataUpdateService.checkRetrieveStatusResponse_element response_x;
            Map<String, MetadataUpdateService.checkRetrieveStatusResponse_element> response_map_x = new Map<String, MetadataUpdateService.checkRetrieveStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'checkRetrieveStatus',
              SOAP_M_URI,
              'checkRetrieveStatusResponse',
              'MetadataUpdateService.checkRetrieveStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.AsyncResult retrieve(MetadataUpdateService.RetrieveRequest retrieveRequest) {
            MetadataUpdateService.retrieve_element request_x = new MetadataUpdateService.retrieve_element();
            request_x.retrieveRequest = retrieveRequest;
            MetadataUpdateService.retrieveResponse_element response_x;
            Map<String, MetadataUpdateService.retrieveResponse_element> response_map_x = new Map<String, MetadataUpdateService.retrieveResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'retrieve',
              SOAP_M_URI,
              'retrieveResponse',
              'MetadataUpdateService.retrieveResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.CancelDeployResult cancelDeploy(String String_x) {
            MetadataUpdateService.cancelDeploy_element request_x = new MetadataUpdateService.cancelDeploy_element();
            request_x.String_x = String_x;
            MetadataUpdateService.cancelDeployResponse_element response_x;
            Map<String, MetadataUpdateService.cancelDeployResponse_element> response_map_x = new Map<String, MetadataUpdateService.cancelDeployResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'cancelDeploy',
              SOAP_M_URI,
              'cancelDeployResponse',
              'MetadataUpdateService.cancelDeployResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public String deployRecentValidation(String validationId) {
            MetadataUpdateService.deployRecentValidation_element request_x = new MetadataUpdateService.deployRecentValidation_element();
            request_x.validationId = validationId;
            MetadataUpdateService.deployRecentValidationResponse_element response_x;
            Map<String, MetadataUpdateService.deployRecentValidationResponse_element> response_map_x = new Map<String, MetadataUpdateService.deployRecentValidationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deployRecentValidation',
              SOAP_M_URI,
              'deployRecentValidationResponse',
              'MetadataUpdateService.deployRecentValidationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.DescribeValueTypeResult describeValueType(String type_x) {
            MetadataUpdateService.describeValueType_element request_x = new MetadataUpdateService.describeValueType_element();
            request_x.type_x = type_x;
            MetadataUpdateService.describeValueTypeResponse_element response_x;
            Map<String, MetadataUpdateService.describeValueTypeResponse_element> response_map_x = new Map<String, MetadataUpdateService.describeValueTypeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeValueType',
              SOAP_M_URI,
              'describeValueTypeResponse',
              'MetadataUpdateService.describeValueTypeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.SaveResult[] createMetadata(MetadataUpdateService.Metadata[] metadata) {
            MetadataUpdateService.createMetadata_element request_x = new MetadataUpdateService.createMetadata_element();
            request_x.metadata = metadata;
            MetadataUpdateService.createMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.createMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.createMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'createMetadata',
              SOAP_M_URI,
              'createMetadataResponse',
              'MetadataUpdateService.createMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.AsyncResult deploy(String ZipFile,MetadataUpdateService.DeployOptions DeployOptions) {
            MetadataUpdateService.deploy_element request_x = new MetadataUpdateService.deploy_element();
            request_x.ZipFile = ZipFile;
            request_x.DeployOptions = DeployOptions;
            MetadataUpdateService.deployResponse_element response_x;
            Map<String, MetadataUpdateService.deployResponse_element> response_map_x = new Map<String, MetadataUpdateService.deployResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deploy',
              SOAP_M_URI,
              'deployResponse',
              'MetadataUpdateService.deployResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.IReadResult readMetadata(String type_x,String[] fullNames) {
            MetadataUpdateService.readMetadata_element request_x = new MetadataUpdateService.readMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataUpdateService.IReadResponseElement response_x;
            Map<String, MetadataUpdateService.IReadResponseElement> response_map_x = new Map<String, MetadataUpdateService.IReadResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'readMetadata',
              SOAP_M_URI,
              'readMetadataResponse',
              'MetadataUpdateService.read' + type_x + 'Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.getResult();
        }
        public MetadataUpdateService.UpsertResult[] upsertMetadata(MetadataUpdateService.Metadata[] metadata) {
            MetadataUpdateService.upsertMetadata_element request_x = new MetadataUpdateService.upsertMetadata_element();
            request_x.metadata = metadata;
            MetadataUpdateService.upsertMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.upsertMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.upsertMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'upsertMetadata',
              SOAP_M_URI,
              'upsertMetadataResponse',
              'MetadataUpdateService.upsertMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataUpdateService.FileProperties[] listMetadata(MetadataUpdateService.ListMetadataQuery[] queries,Double asOfVersion) {
            MetadataUpdateService.listMetadata_element request_x = new MetadataUpdateService.listMetadata_element();
            request_x.queries = queries;
            request_x.asOfVersion = asOfVersion;
            MetadataUpdateService.listMetadataResponse_element response_x;
            Map<String, MetadataUpdateService.listMetadataResponse_element> response_map_x = new Map<String, MetadataUpdateService.listMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'listMetadata',
              SOAP_M_URI,
              'listMetadataResponse',
              'MetadataUpdateService.listMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
}