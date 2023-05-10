/****************************************************************************************************************
*   ClassName :   MetadataWrapper
Created By : Puneet/Monika
*   Description :  Automate process to provide access of all the fields to Admin 04, Data Backup and Recovery
and 10 Read Only Advance
Test class - PermissionReaderTest
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-2357     11 NOV 2022         Monika            Automate process to provide access of all the fields to Admin 04
                                                     and 10 Read Only Advance
****************************************************************************************************************/
public class MetadataWrapper {
     public Integer Index;
     public String EntityName;        
     public String ParentEntityName;
     public string EntityType;
     public Boolean IsEntityAccess; // modify all for object/modify for field
     public Boolean IsSelfProcess; 
     public Boolean IsProcessed; 
     public String errMsg;
     public String ProfileName;        
     public List<metadataWrapper> childItems; 
    
    Public MetadataWrapper(){}
    
    public MetadataWrapper(Integer Index, String EntityName, string EntityType, Boolean IsSelfProcess,  Boolean IsProcessed) {
            this.Index = Index;
            this.EntityName = EntityName;
            this.EntityType = EntityType;
            this.IsSelfProcess = IsSelfProcess;
            this.IsProcessed = IsProcessed;
        }
 }