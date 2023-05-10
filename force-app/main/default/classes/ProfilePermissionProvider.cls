/****************************************************************************************************************
*   ClassName :   ProfilePermissionProvider
Created By : Puneet/Monika
*   Description :  Automate process to provide access of all the fields to Admin 04, Data Backup and Recovery
and 10 Read Only Advance
Test class - PermissionReaderTest
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-2357     11 NOV 2022         Monika            Automate process to provide access of all the fields to Admin 04
                                                     and 10 Read Only Advance
****************************************************************************************************************/
public class ProfilePermissionProvider implements Database.Batchable<MetadataWrapper>, Database.Stateful,Database.AllowsCallouts {
    List<MetadataWrapper> mtdItemLst; 
    Map<Integer, MetadataWrapper> mtdItemByIndex;
    integer batchSize = 0;
    Boolean retryBatchRun = false; 
    integer retryBatchSize = 1; 
    Boolean splitPermission = false;
    
    public ProfilePermissionProvider() {}
    
    public ProfilePermissionProvider(List<MetadataWrapper> mtdItemLst, Boolean splitPermission) {
    	this.mtdItemLst = mtdItemLst;
        this.splitPermission = (splitPermission != null ? splitPermission : false);
        this.mtdItemByIndex = new Map<Integer, MetadataWrapper>();       
        
        for(MetadataWrapper item : mtdItemLst) {
            this.mtdItemByIndex.put(item.Index, item);  
        }     
    }
    
    public Iterable<MetadataWrapper> start(Database.BatchableContext info) {
        return new MetadataIterable(mtdItemLst);      
    } 
    
    public void execute(Database.batchableContext info, List<MetadataWrapper> scope) {
        if(batchSize == 0) {
            batchSize = scope.size();
            System.debug('batchSize::' + batchSize);
        } 
        
        /* fetch the metadata for profile permission**/        
        Map<String, Grant_Permission__mdt> mdtMap = new Map<String, Grant_Permission__mdt>();        
        List<Grant_Permission__mdt> mcs = Grant_Permission__mdt.getAll().values();
         for(Grant_Permission__mdt mdt : mcs){
             mdtMap.put(mdt.Label, mdt);            
         }
         if(Test.isRunningTest()){
            Grant_Permission__mdt grd = new Grant_Permission__mdt();
            grd.Modify_All__c = true;
            grd.View_All__c = true;
            grd.Delete__c = true;
            grd.Create__c = true;
            grd.Read__c = true;
            grd.Edit_Object__c = true;
            grd.Edit_Field__c = true;
            grd.label = 'System Administrator';
            
            mdtMap.put('System Administrator', grd); 
        }
       
        System.debug(scope);
        
        Map<String, List<MetadataWrapper>> prflMdtMap = new  Map<String, List<MetadataWrapper>>();
        List<MetadataUpdateService.Profile> updatePrfLst = new List<MetadataUpdateService.Profile>();
        List<MetadataWrapper> prcsdMtdLst = new List<MetadataWrapper>();  

        for(MetadataWrapper mtd : scope) {
        	MetadataWrapper mtdItem = mtdItemByIndex.get(mtd.Index);            
            List<MetadataWrapper> mdtWrapList = prflMdtMap.get(mtdItem.ProfileName);
            
            if(mdtWrapList == null) {
            	mdtWrapList = new List<MetadataWrapper>(); 
                prflMdtMap.put(mtdItem.ProfileName, mdtWrapList);
            }
            mdtWrapList.add(mtdItem);      
        }
        
        for(String prfName : prflMdtMap.keySet()) {
            MetadataUpdateService.Profile updatePrfl = new MetadataUpdateService.Profile();
            updatePrfl.fullName = prfName;
            updatePrfl.custom = true;
            updatePrfl.fieldPermissions = new List<MetadataUpdateService.ProfileFieldLevelSecurity>(); 
            updatePrfl.objectPermissions = new List<MetadataUpdateService.ProfileObjectPermissions>();
            
            List<MetadataWrapper> mdtWrapList = prflMdtMap.get(prfName);
            Boolean isMetadataUpdate = false;  
            
            //Boolean isEditable = false;
            Boolean ModifyAll = false;
            Boolean ViewAll = false;
            Boolean DeletePer = false;
            Boolean Create = false;
            Boolean ReadPer = false;
            Boolean EditPer = false;
            Boolean FieldEditable = false; //edit/read for field

            
            
            for(MetadataWrapper mtdItem : mdtWrapList) {
                System.debug('mtdItem::' + mtdItem);
                //isEditable = false;
                
                ModifyAll = false;
                ViewAll = false;
                DeletePer = false;
                Create = false;
                ReadPer = false;
                EditPer = false;
                FieldEditable = false;
                /*if(mdtMap.get(mtdItem.ProfileName). == 'Edit'){ //checking metadata
                    isEditable = True;
                }*/
                if(mdtMap.get(mtdItem.ProfileName).Modify_All__c == True){ //checking metadata
                    ModifyAll = True;
                }
                if(mdtMap.get(mtdItem.ProfileName).View_All__c == True){ //checking metadata
                    ViewAll = True;
                }
                if(mdtMap.get(mtdItem.ProfileName).Delete__c == True){ //checking metadata
                    DeletePer = True;
                }
                if(mdtMap.get(mtdItem.ProfileName).Create__c == True){ //checking metadata
                    Create = True;
                }
                if(mdtMap.get(mtdItem.ProfileName).Read__c == True){ //checking metadata
                    ReadPer = True;
                }
                if(mdtMap.get(mtdItem.ProfileName).Edit_Object__c == True){ //checking metadata
                    EditPer = True;
                }
                if(mdtMap.get(mtdItem.ProfileName).Edit_Field__c == True){ //checking metadata
                    FieldEditable = True;
                }
                
                
                

                if (String.isNotBlank(mtdItem.EntityType) && mtdItem.IsProcessed == false) {                
                    if (mtdItem.EntityType.equalsIgnoreCase('CustomObject')) {                 
                        String objectName = mtdItem.EntityName;              
                       
                        if(String.isNotBlank(objectName)) {                       
                            if(mtdItem.IsEntityAccess == false) {
                                updatePrfl.objectPermissions.add(updateObjectPermission(objectName,ModifyAll,ViewAll,DeletePer,Create,ReadPer,EditPer));
                                //updatePrfl.objectPermissions.add(updateObjectPermission(objectName,isEditable));  
                                isMetadataUpdate = true;
                            }
                            
                            if(!mtdItem.IsSelfProcess && mtdItem.childItems != null && mtdItem.childItems.size() > 0) {
                                for(MetadataWrapper childWrap : mtdItem.childItems) {                                   
                                     updatePrfl.fieldPermissions.add(updateFieldPermission(objectName, childWrap.EntityName, true , FieldEditable));  
                                     isMetadataUpdate = true;
                                }  
                            }    
                        } 
    
                        if(isMetadataUpdate) {
                            prcsdMtdLst.add(mtdItem); // update isProcessed = true
                            //updatePrfMdtLst.add(prf);
                        }
                        else 
                            mtdItem.isProcessed = true;                            
                        
                    } else if(mtdItem.EntityType.equalsIgnoreCase('CustomField')) {
                        System.debug('fieldName>>>' + mtdItem.EntityName);                   
                        String objectName = mtdItem.ParentEntityName;
                        updatePrfl.fieldPermissions.add(updateFieldPermission(objectName, mtdItem.EntityName, true,FieldEditable)); 
                        prcsdMtdLst.add(mtdItem);
                        isMetadataUpdate = true;
                        //updatePrfMdtLst.add(prf);
                    }
                } 
                
            }  
            
            if(isMetadataUpdate) {
                updatePrfLst.add(updatePrfl); // update isProcessed = true
            }
        }
        
        
        if(updatePrfLst != null && updatePrfLst.size() > 0) { 
           
            for(MetadataUpdateService.Profile p : updatePrfLst) {
                System.debug('PPPPPPPPPPPPPPPPP' + p.fullName);
                System.debug('OOOOOOOOOOOOOOOOOOOO' + p);
            }
            processMetadata(updatePrfLst, prcsdMtdLst);
        }
      
    }
    
      public void finish(Database.batchableContext info) {
        if(this.retryBatchRun && !this.splitPermission) {
            if(this.batchSize == 1) {
                this.splitPermission = true;                
            }
            Database.executeBatch(new ProfilePermissionProvider(this.mtdItemLst, this.splitPermission), retryBatchSize);
        }  else {
            
            List<String> toAddresses = new List<String>();  
            //toAddresses.add('mm185627@ncr.com');
			toAddresses.addAll(NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(','));  
            String mailBdy = '', mailSub = '', mailHeader = '', mailSubHdr = '';
                      
            
            for(MetadataWrapper mdt : this.mtdItemLst) {
                if(String.isNotBlank(mdt.errMsg)) {
                    if(mdt.EntityType.equalsIgnoreCase('CustomObject')) {
                        mailBdy += mdt.EntityName + ' CustomObject :' + mdt.errMsg + '\n';          
                    }  else {
                        mailBdy +=  mdt.EntityName + ' CustomField :' + mdt.errMsg + '\n';      
                    }  
                }    
            }
            
            if(String.isNotBlank(mailBdy)) {
                  mailHeader = 'Permission Reader Batch Process completed';
                  mailSub = mailHeader;
                  mailSubHdr = 'Permission Reader Batch Process completed with below error/warning for below CustomObjects and fields';
    
            } else {
                  mailHeader = 'Permission Reader Batch Process completed Successfully';
                  mailSub = mailHeader;
                  mailSubHdr = 'Permission Reader Batch Process completed Successfully for ' + this.mtdItemLst.size() + ' CustomObjects and fields';     
            }
            
            if(mailBdy.length()> 9000) {
                mailBdy = mailBdy.substring(0, 9000);   
            }
            EmailUtility.sendEmail(mailSub,mailHeader,mailSubHdr,mailBdy,toAddresses); 
            
        
        }
		
    } 
    
    
    
    
    
    /********************************** helper classes *************************************/
        public void processMetadata(List<MetadataUpdateService.Profile> prflLst, List<MetadataWrapper> updateMdtLst) {
         String saveError = '';
         Boolean hasError = false;
         try {
                 MetadataUpdateService.MetadataPort service = createService();
                 List<MetadataUpdateService.Metadata> prfMtdLst = new List<MetadataUpdateService.Metadata>();
             	 prfMtdLst.addAll(prflLst);
             
                 service.timeout_x = 120000;   
                 
                 List<MetadataUpdateService.SaveResult> results = service.updateMetadata(prfMtdLst);
                 System.debug('saveresult size' + results.size()); 
                 Map<String, String> saveResults = handleAllSaveResults(results);
               
                 if(saveResults != null && !saveResults.isEmpty()) {
                     // update isProcessed for updateMdtLst based on matching profile
                     // 
                     for(MetadataWrapper mw : updateMdtLst) {                      
                     	String errMsg = saveResults.get(mw.ProfileName);
                         
                        if(String.isBlank(errMsg)) 
                            mw.IsProcessed = true;
                        else {
                       		saveError += errMsg;
                            if(this.batchSize > 1) hasError = true; 
                            else mw.errMsg = errMsg;
                        }
                     }
                     //saveError = (saveResult.size() > 1) ? String.join(saveResult, ',') : saveResult.get(0);                     
                 } 
                
            } catch(CalloutException e) {
                saveError = e.getMessage();
                if(this.batchSize > 1) hasError = true;  
                
            } catch(Exception e) {
                saveError = e.getMessage();
                if(this.batchSize > 1) hasError = true; 
            }    
            
         
            if(this.batchSize == 1 && !prflLst.isEmpty() && !this.splitPermission  
                    && (saveError.containsIgnoreCase('read time out') || saveError.containsIgnoreCase('read timed out') || saveError.containsIgnoreCase('INVALID_CROSS_REFERENCE_KEY'))) {
                        
                hasError = true;                
                //this.splitPermission = true;
                /*for(MetadataWrapper Item : updateMdtLst) { // update object self run                  
                    Item.IsSelfProcess = true;  
                    
                    for(MetadataUpdateService.ProfileFieldLevelSecurity fieldprm : prflLst) {
                        this.mtdItemLst.add(new MetadataWrapper(this.mtdItemLst.size(), fieldprm.field, null, false, false));                        
                    }
                } */
                        for(MetadataWrapper Item : updateMdtLst) { // update object self run and add field as MetadataWrapper                   
                            Item.IsSelfProcess = true;                             
                            for(MetadataUpdateService.Profile pr : prflLst){                                
                                for(MetadataUpdateService.ProfileFieldLevelSecurity fieldprm : pr.fieldPermissions) {
                                    this.mtdItemLst.add(new MetadataWrapper(this.mtdItemLst.size(), fieldprm.field, null, false, false));                       
                                }  
                            }                          
                        }

                
            }
             
            if(hasError) { 
                if(!this.retryBatchRun) 
                    this.retryBatchRun = true;
                
                if (this.retryBatchRun) {
                    if(this.batchSize >= 100) {
                        this.retryBatchSize = 50;       
                    } else if(this.batchSize >= 50)  {
                        this.retryBatchSize = 20;       
                    }  else {
                        this.retryBatchSize = 1;        
                    }    
                } 
            } else {
                
                
                for(MetadataWrapper Item : updateMdtLst) {
                	if(Item.IsProcessed == false)                    
                    Item.IsProcessed = true;
                    /*if(String.isNotBlank(saveError)) {  
                        Item.errMsg = saveError;
                        //throw new PermissionCheckerException(saveError);
                    }*/
                }    
             }
    }
    
      public Map<String, String> handleAllSaveResults(List<MetadataUpdateService.SaveResult> saveResults)
    {
        Map<String, String> results = new Map<String, String>();
        
        
        for(MetadataUpdateService.SaveResult saveResult:  saveResults) {
            String message = '';
            System.debug('result full name>>' + saveResult.fullName);
            // Nothing to see?
            if(saveResult==null || saveResult.success) {
                System.debug('<<<<<<<SAVE RESULT SUCCESS>>>>>' + saveResult.fullName);
                      
            }
            // Construct error message and throw an exception
            if(saveResult.errors!=null)
            {
                System.debug('SAVE RESULT ERROR>>>>>>>' + saveResult.fullName);
                 System.debug(saveResult.errors);
                for(MetadataUpdateService.Error error : saveResult.errors)
                    //if(error.statusCode != 'INVALID_CROSS_REFERENCE_KEY') {
                        message += error.message + ' (' + error.statusCode + ').'  +
                           			( error.fields!=null && error.fields.size()>0 ?
                                	' Fields ' + String.join(error.fields, ',') + '.' : '' );
                
                
                    //}
                /*if(messages.size()>0)
                    throw new PermissionCheckerException(String.join(messages, ' '));*/
            }
            else if(!saveResult.success) {
                System.debug('SAVE RESULT ERROR>>>>>>>>>>>>>>>>>>');
                message = 'Request failed with no specified error.';
                //throw new PermissionCheckerException('Request failed with no specified error.');
            }
            
            if(String.isNotBlank(saveResult.fullName)) 
                    results.put(saveResult.fullName, message);      
            
        }
        
        //return message;
        return results;
    }
    
     public MetadataUpdateService.ProfileObjectPermissions updateObjectPermission(String objName,Boolean ModifyAll,Boolean ViewAll,Boolean DeletePer,Boolean Create,Boolean ReadPer,Boolean EditPer) {
        MetadataUpdateService.ProfileObjectPermissions objPrm  = new MetadataUpdateService.ProfileObjectPermissions();
             objPrm.object_x = objName;
             objPrm.allowCreate = Create;
             objPrm.allowRead = ReadPer;
             objPrm.allowEdit = EditPer; 
             objPrm.allowDelete = DeletePer; 
             objPrm.viewAllRecords = ViewAll;
             objPrm.modifyAllRecords = ModifyAll;
             return objPrm;  
    }
    
     public  MetadataUpdateService.ProfileFieldLevelSecurity updateFieldPermission(String objName, String fieldName, Boolean isContainObjName, Boolean isEdit) {
        MetadataUpdateService.ProfileFieldLevelSecurity fieldSec = new MetadataUpdateService.ProfileFieldLevelSecurity();
        //fieldSec.field='SFLight__MasterList__c.SFLight__Deal_Type__c';
                
         fieldSec.field= (isContainObjName ? fieldName : objName + '.' + fieldName);
         fieldSec.editable=isEdit;
         fieldSec.readable = true;
                 
        return fieldSec;
    }
    
    public  MetadataUpdateService.MetadataPort createService() {
        MetadataUpdateService.MetadataPort service = new MetadataUpdateService.MetadataPort();
        service.SessionHeader = new MetadataUpdateService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    public class PermissionProviderException extends Exception { }
    
    private class MetadataIterator implements Iterator<MetadataWrapper> {
        private List<MetadataWrapper> items;
        private Integer nextIdx;
        
        public MetadataIterator(List<MetadataWrapper> items)
        {
            System.debug('JobIterator Initialization ##############');
            this.items = items;
            this.nextIdx = 0;
        }
        
        public boolean hasNext()
        {
            System.debug('JobIterator hasNext CALL ###############');
            return nextIdx >= items.size() ? false : true;
        }
        
        public MetadataWrapper next()
        { System.debug('JobIterator next CALL #######################');
            return items[nextIdx++];
        }
    }
    
    
    private class MetadataIterable implements Iterable<MetadataWrapper> {
        private List<MetadataWrapper> iteratorItems;
        
        public MetadataIterable(List<MetadataWrapper> items)
        {
            // Only iterate over items that have not been completed
            iteratorItems = new List<MetadataWrapper>();
            for(MetadataWrapper item : items) {
                if (!item.IsProcessed) {
                    iteratorItems.add(item);    
                }                   
            }
        }
        
        public Iterator<MetadataWrapper> Iterator()
        {
            return new MetadataIterator(iteratorItems);
        }       
    }
	/***** helper classes **********/
}