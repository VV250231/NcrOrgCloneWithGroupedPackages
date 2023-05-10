@isTest  
public class MetadataUpdateServiceTest
{    
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
    public class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataUpdateService.retrieve_element)
                response.put('response_x', new MetadataUpdateService.retrieveResponse_element());
            else if(request instanceof MetadataUpdateService.checkDeployStatus_element)
                response.put('response_x', new MetadataUpdateService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataUpdateService.listMetadata_element)
                response.put('response_x', new MetadataUpdateService.listMetadataResponse_element());
            else if(request instanceof MetadataUpdateService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataUpdateService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataUpdateService.describeMetadata_element)
                response.put('response_x', new MetadataUpdateService.describeMetadataResponse_element());
            else if(request instanceof MetadataUpdateService.deploy_element)
                response.put('response_x', new MetadataUpdateService.deployResponse_element());
            else if(request instanceof MetadataUpdateService.updateMetadata_element)  {
                MetadataUpdateService.updateMetadataResponse_element updateResponse = new MetadataUpdateService.updateMetadataResponse_element();
                MetadataUpdateService.SaveResult saveResult = new MetadataUpdateService.SaveResult();
                saveResult.fullName = Label.OwnBackup_Profile;
                saveResult.success = true;
                updateResponse.result = new List<MetadataUpdateService.SaveResult>();
                updateResponse.result.add(saveResult);
                response.put('response_x',updateResponse);    
            }
            
            else if(request instanceof MetadataUpdateService.readMetadata_element)  {
                MetadataUpdateService.ReadProfileResult prfRes = new MetadataUpdateService.ReadProfileResult();
                
                MetadataUpdateService.Profile pr= new MetadataUpdateService.Profile();
                pr.fullName = Label.OwnBackup_Profile;
                
                MetadataUpdateService.ProfileObjectPermissions  prfObj = new MetadataUpdateService.ProfileObjectPermissions();
                prfObj.object_x = 'Account';
                prfObj.modifyAllRecords = True;
                
                MetadataUpdateService.ProfileFieldLevelSecurity prfFls  = new MetadataUpdateService.ProfileFieldLevelSecurity();
                prfFls.field = 'Industry';
                prfFls.editable = false;
                
                
                pr.objectPermissions = new List<MetadataUpdateService.ProfileObjectPermissions>{prfObj};
                pr.fieldPermissions = new List<MetadataUpdateService.ProfileFieldLevelSecurity>{prfFls};
                    
                MetadataUpdateService.readProfileResponse_element mdt = new MetadataUpdateService.readProfileResponse_element();
                mdt.result = prfRes;
                    
                prfRes.records = new List<MetadataUpdateService.Profile>{pr};
                MetadataUpdateService.IReadResult prfResult = prfRes;
                response.put('response_x',mdt);
                
            }
            else if(request instanceof MetadataUpdateService.renameMetadata_element)
                response.put('response_x', new MetadataUpdateService.renameMetadataResponse_element());
            else if(request instanceof  MetadataUpdateService.cancelDeploy_element)
                response.put('response_x', new MetadataUpdateService.cancelDeployResponse_element());
            else if(request instanceof  MetadataUpdateService.deleteMetadata_element)
                response.put('response_x', new MetadataUpdateService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataUpdateService.upsertMetadata_element)
                response.put('response_x', new MetadataUpdateService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataUpdateService.createMetadata_element)
                response.put('response_x', new MetadataUpdateService.createMetadataResponse_element());
            else if(request instanceof  MetadataUpdateService.deployRecentValidation_element)
                response.put('response_x', new MetadataUpdateService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataUpdateService.describeValueType_element)
                response.put('response_x', new MetadataUpdateService.describeValueTypeResponse_element());
            else if(request instanceof MetadataUpdateService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataUpdateService.checkRetrieveStatusResponse_element());
            return;
        }
    }    
        
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {   
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataUpdateService metaDataService = new MetadataUpdateService();
        // Invoke operations     
        Test.startTest();    
        MetadataUpdateService.MetadataPort metaDataPort = new MetadataUpdateService.MetadataPort();
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataUpdateService metaDataService = new MetadataUpdateService();
        // Invoke operations    
        Test.startTest();     
        MetadataUpdateService.MetadataPort metaDataPort = new MetadataUpdateService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataUpdateService metaDataService = new MetadataUpdateService();
        // Invoke operations     
        Test.startTest();    
        MetadataUpdateService.MetadataPort metaDataPort = new MetadataUpdateService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
        Test.stopTest();
    }
        
    @IsTest
    private static void coverGeneratedCodeTypes()
    {              
        // Reference types
        Test.startTest();
        new MetadataUpdateService();
        new MetadataUpdateService.listMetadataResponse_element();        
        new MetadataUpdateService.checkDeployStatus_element();
        new MetadataUpdateService.DescribeMetadataResult();
      
        new MetadataUpdateService.Profile();
        
        new MetadataUpdateService.LogInfo();
       
        new MetadataUpdateService.CallOptions_element();
        
        new MetadataUpdateService.describeMetadataResponse_element();
     
        new MetadataUpdateService.DeployMessage();
      
        new MetadataUpdateService.describeMetadata_element();
       
        new MetadataUpdateService.ProfileObjectPermissions();
        new MetadataUpdateService.RetrieveResult();
       
        new MetadataUpdateService.retrieve_element();
        new MetadataUpdateService.DescribeMetadataObject();
       
        new MetadataUpdateService.deployResponse_element();
       
        new MetadataUpdateService.FileProperties();
        new MetadataUpdateService.AsyncResult();
        new MetadataUpdateService.checkRetrieveStatus_element();
        new MetadataUpdateService.ProfileLayoutAssignment();
       
        new MetadataUpdateService.RetrieveRequest();
        new MetadataUpdateService.ListMetadataQuery();
       
        new MetadataUpdateService.ProfileApexClassAccess();
        new MetadataUpdateService.DebuggingHeader_element();
      
        //new MetadataUpdateService.DomainWhitelist();
        new MetadataUpdateService.listMetadata_element();
        /*new MetadataUpdateService.ValidationRule();
        new MetadataUpdateService.WorkspaceMapping();
        new MetadataUpdateService.MetadataWithContent();
        new MetadataUpdateService.ValidationRuleTranslation();*/
        new MetadataUpdateService.Metadata();
        /*new MetadataUpdateService.ReportBucketFieldValue();
        new MetadataUpdateService.HomePageLayout();
        new MetadataUpdateService.FlowSubflow();
        new MetadataUpdateService.FlowScreenField();
        new MetadataUpdateService.SiteWebAddress();*/
        new MetadataUpdateService.RetrieveMessage();
        new MetadataUpdateService.SessionHeader_element();
        new MetadataUpdateService.DeployOptions();
        new MetadataUpdateService.ProfileApplicationVisibility();
        //new MetadataUpdateService.CustomApplicationComponents();
        new MetadataUpdateService.ProfileTabVisibility();
        //new MetadataUpdateService.WorkspaceMappings();
        /*new MetadataUpdateService.WorkflowAction();
        new MetadataUpdateService.DashboardFolder();
        new MetadataUpdateService.PermissionSetApexPageAccess();
        new MetadataUpdateService.LayoutTranslation();
        new MetadataUpdateService.CustomObject();
        new MetadataUpdateService.Translations();
        new MetadataUpdateService.ApexTrigger();
        new MetadataUpdateService.ReportTypeTranslation();
        new MetadataUpdateService.FlowAssignmentItem();
        new MetadataUpdateService.CustomApplicationTranslation();
        new MetadataUpdateService.CustomLabels();*/
        new MetadataUpdateService.PackageTypeMembers();
        new MetadataUpdateService.deploy_element();
        new MetadataUpdateService.retrieveResponse_element();
        new MetadataUpdateService.ProfileLoginIpRange();
        new MetadataUpdateService.ProfileRecordTypeVisibility();
        new MetadataUpdateService.checkRetrieveStatusResponse_element();
        new MetadataUpdateService.ProfileFieldLevelSecurity();       
        new MetadataUpdateService.ProfileLoginHours();
        new MetadataUpdateService.DebuggingInfo_element();
        new MetadataUpdateService.Package_x();
        new MetadataUpdateService.DeployResult();       
        new MetadataUpdateService.ProfileApexPageAccess();       
        new MetadataUpdateService.checkDeployStatusResponse_element();
        new MetadataUpdateService.ProfileExternalDataSourceAccess();
        new MetadataUpdateService.renameMetadata_element();       
        new MetadataUpdateService.deleteMetadataResponse_element();       
        new MetadataUpdateService.Error();      
        new MetadataUpdateService.deleteMetadata_element();       
        new MetadataUpdateService.updateMetadataResponse_element();
        new MetadataUpdateService.createMetadata_element();        
        new MetadataUpdateService.readMetadata_element();
        Test.stopTest();
    } 
}