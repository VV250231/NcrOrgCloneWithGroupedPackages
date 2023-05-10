/****************************************************************************************************************
*   ClassName :   PermissionReader
Created By : Puneet/Monika
*   Description :  Automate process to provide access of all the fields to Admin 04, Data Backup and Recovery
and 10 Read Only Advance
Test class - PermissionReaderTest
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-2357     11 NOV 2022         Monika            Automate process to provide access of all the fields to Admin 04
                                                     and 10 Read Only Advance
****************************************************************************************************************/
public class PermissionReader implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts { 
    
     List<MetadataWrapper> wrList = new List<MetadataWrapper>();
     Map<String, Schema.SObjectType> objectMap = new Map<String, Schema.SObjectType>();
     integer index = 0;    
    
     public Database.queryLocator start(Database.BatchableContext bc) {
         if(!Test.isRunningTest()){
             //Set<Id> adminIds = NSCCommonInfoUtil.getIdSetOf('fls_per');
        Set<Id> adminIds = new Set<Id>();        
        List<Grant_Permission__mdt> mcs = Grant_Permission__mdt.getAll().values();
         for(Grant_Permission__mdt mdt : mcs){             
             adminIds.add(mdt.IDs__c);            
         }
         this.objectMap.putAll(schema.getGlobalDescribe());
        return Database.getqueryLocator([Select id,name from profile where Id IN :adminIds]); 
         /*if(Test.isRunningTest()) {
             MetadataWrapper item = new PermissionReader.MetadataWrapper(0, 'Account', 'CustomObject', false, false);
             this.mtdItemLst = new List<MetadataItem>{item}; 
         }*/
        //return Database.getqueryLocator([Select id,name from profile where Name = '10 Read Only Advanced']);
             
         }
         else{
             objectMap.put('Account', null);
             return Database.getqueryLocator([Select id,name from profile where Name = 'System Administrator']);
             
         }
         
     }
    
     public void execute(Database.BatchableContext bc, List<Profile> objLst) {
         
         Profile p = objLst[0];
         MetadataUpdateService.MetadataPort service = createService();
         service.timeout_x = 120000; 
         MetadataUpdateService.ReadProfileResult readResult = (MetadataUpdateService.ReadProfileResult)service.readMetadata('Profile', new String[] {p.Name});
         MetadataUpdateService.Profile[] prfRslt = (MetadataUpdateService.Profile[]) readResult.getRecords();
         
             
         Map<String, MetadataWrapper> mdtWrapMap = new Map<String, MetadataWrapper>();
         
         for(MetadataUpdateService.Profile pr : prfRslt) {
             for(MetadataUpdateService.ProfileObjectPermissions objPrm : pr.objectPermissions) {
             	System.debug('obj name>>>>>>>>>>' + objPrm.object_x);  
                 
                 //if(objPrm.object_x.equalsIgnoreCase(objPrm.object_x)) {
                     if(objPrm.modifyAllRecords == false) {
                         MetadataWrapper ntdWrapper = new MetadataWrapper();
                         ntdWrapper.EntityType = 'CustomObject';  
                         ntdWrapper.EntityName = objPrm.object_x;
                         ntdWrapper.IsSelfProcess = false; 
                         ntdWrapper.IsProcessed = false;
                         ntdWrapper.Index = index; 
                         ntdWrapper.ProfileName = p.Name;
                         ntdWrapper.isEntityAccess = false;
                         ntdWrapper.childItems = new List<metadataWrapper>();                        
                         this.wrList.add(ntdWrapper);
                         mdtWrapMap.put(objPrm.object_x, ntdWrapper); 
                         index++;  
                     }
                 //}
             }
             
             for(String objName : this.objectMap.keySet()) {
                 if (!objName.endsWithIgnoreCase('changeevent') && !objName.endsWithIgnoreCase('tag') && !objName.endsWithIgnoreCase('share') 
                     && !objName.endsWithIgnoreCase('history') && !objName.endsWithIgnoreCase('feed') && !objName.endsWithIgnoreCase('localization')) {
             	 MetadataWrapper objWrap = mdtWrapMap.get(objName); 
                 System.debug('describe object Name >>>>>' + objName);
                 //if(objName.equalsIgnoreCase('OpportunityAndCECObject__c')) {
                     if(objWrap == NULL) {
                         
                         MetadataWrapper mw = new MetadataWrapper();
                         mw.EntityType = 'CustomObject';  
                         mw.EntityName = objName;
                         mw.IsSelfProcess = false; 
                         mw.IsProcessed = false;
                         mw.Index = index; 
                         mw.ProfileName = p.Name;
                         mw.isEntityAccess = false;                   
                         mw.childItems = new List<metadataWrapper>();
                         this.wrList.add(mw);
                         mdtWrapMap.put(objName, mw); 
                         index++;      
                     }
                 //}
                 }
             }
                  
             for(MetadataUpdateService.ProfileFieldLevelSecurity fieldPrm : pr.fieldPermissions) {
             	System.debug('field Name >>>>>' + fieldPrm.field);
                
                if(!fieldPrm.editable) { // if customfield not editable for profile  
                    String objName = fieldPrm.field.split('\\.')[0];               
                    if(objName.equalsIgnoreCase(objName)) {
                    //if(objName.equalsIgnoreCase('account')) {
                        MetadataWrapper objWrap = mdtWrapMap.get(objName);
                         
                        if (objWrap == null) {
                             objWrap = new MetadataWrapper();
                             objWrap.EntityType = 'CustomObject';  
                             objWrap.EntityName = objName;
                             objWrap.IsSelfProcess = false; 
                             objWrap.IsProcessed = false;
                             objWrap.Index = index; 
                             objWrap.ProfileName = p.Name;
                             objWrap.isEntityAccess = false;
                             objWrap.childItems = new List<metadataWrapper>();
                             this.wrList.add(objWrap);
                             mdtWrapMap.put(objName, objWrap); 
                             index++;  
                         }                 
                                    
                         MetadataWrapper fieldWrap = new MetadataWrapper();                 	
                         fieldWrap.EntityType = 'CustomField';  
                         fieldWrap.EntityName = fieldPrm.field;
                         fieldWrap.IsSelfProcess = false; 
                         fieldWrap.IsProcessed = false; 
                         fieldWrap.isEntityAccess = false;
                         fieldWrap.ParentEntityName = objName;
                         fieldWrap.ProfileName = p.Name;
                         objWrap.childItems.add(fieldWrap); 
                	}                    
                 } 
                 
             } 
         } 
     }
    
     public void finish(Database.BatchableContext bc) {
         if(!this.wrList.isEmpty()) {
            System.debug(this.wrList.size());
         	Database.executeBatch(new ProfilePermissionProvider(this.wrList, false), 70);    
         }
     }
    
     public  MetadataUpdateService.MetadataPort createService() {
        MetadataUpdateService.MetadataPort service = new MetadataUpdateService.MetadataPort();
        service.SessionHeader = new MetadataUpdateService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
   

}