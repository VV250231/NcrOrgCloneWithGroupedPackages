public class PermissionChecker implements Database.Batchable<MetadataItem>, Database.Stateful,Database.AllowsCallouts {
    List<MetadataItem> mtdItemLst; 
    Map<Integer, MetadataItem> mtdItemByIndex;
    Profile p;
    integer batchSize = 0;
    Boolean retryBatchRun = false; 
    integer retryBatchSize = 1; 
    Boolean splitPermission = false;
    //Map<String,Schema.SObjectField> objTypeFields;
    //List<String> items;
    public PermissionChecker(List<MetadataItem> mtdItemLst) {
        this(mtdItemLst, false);  
    }
    
    public PermissionChecker(List<MetadataItem> mtdItemLst, Boolean splitPermission) {
        p = [Select Id, Name,PermissionsModifyAllData,PermissionsViewAllData from Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        
        if(p.Name != Label.OwnBackup_Profile) {        
            throw new PermissionCheckerException('This batch class is only applicable to run from user of '  + Label.OwnBackup_Profile + ' profile');    
        } else if(!p.PermissionsModifyAllData) {
            throw new PermissionCheckerException('Modify all data permission should be enabled first for ' + p.Name + ' profile');         
        }
        
        this.mtdItemLst = mtdItemLst;
        this.splitPermission = (splitPermission != null ? splitPermission : false);
        this.mtdItemByIndex = new Map<Integer, MetadataItem>();
        integer index = 0;
        
        for(MetadataItem item : mtdItemLst) {
            item.Index = index;
            this.mtdItemByIndex.put(item.Index, item);  
            index++;
        }
    }
    public PermissionChecker() {       
        p = [Select Id, Name,PermissionsModifyAllData,PermissionsViewAllData from Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        
        if(p.Name != Label.OwnBackup_Profile) {        
            throw new PermissionCheckerException('This batch class is only applicable to run from user of '  + Label.OwnBackup_Profile + ' profile');    
        } else if(!p.PermissionsModifyAllData) {
            throw new PermissionCheckerException('Modify all data permission should be enabled first for ' + p.Name + ' profile');         
        }
       
        this.mtdItemLst = new List<MetadataItem>();  
        this.mtdItemByIndex = new Map<Integer, MetadataItem>();
        integer index = 0;
        Map<String, Schema.SObjectType> objectMap = schema.getGlobalDescribe();
        
        for(String objName : objectMap.keySet()) {
            MetadataItem item = new MetadataItem(index, objName, (Object)objectMap.get(objName), false, false);
            this.mtdItemLst.add(item); 
            this.mtdItemByIndex.put(item.Index, item);
            index++;
        } 
        
         if(Test.isRunningTest()) {
             MetadataItem item = new PermissionChecker.MetadataItem(0, 'Account', (Object)objectMap.get('Account'), false, false);
             this.mtdItemLst = new List<MetadataItem>{item}; 
         }
    }
    
    public Iterable<MetadataItem> start(Database.BatchableContext info) {
        return new MetadataIterable(mtdItemLst);      
    }   
    
    
    public void execute(Database.batchableContext info, List<MetadataItem> scope) {
        if(batchSize == 0) {
            batchSize = scope.size();
            System.debug('batchSize>>' + batchSize);
        }       
        
        MetadataUpdateService.Profile prfl = new MetadataUpdateService.Profile();
        prfl.fullName = p.Name;
        prfl.custom = true;
        prfl.fieldPermissions = new List<MetadataUpdateService.ProfileFieldLevelSecurity>(); 
        prfl.objectPermissions = new List<MetadataUpdateService.ProfileObjectPermissions>(); 
        
        List<MetadataItem> updateMdtLst = new List<MetadataItem>();
            
        for (MetadataItem mtd : scope) {
             MetadataItem mtdItem = mtdItemByIndex.get(mtd.Index);
        
            if(mtdItem.entityMetaData != null && mtdItem.entityMetaData instanceof Schema.SObjectType) {
                String objectName = mtdItem.EntityName;
                Schema.SObjectType objectType = (Schema.SObjectType) mtdItem.EntityMetaData; 
               
                if(mtdItem != null && !objectName.endsWithIgnoreCase('changeevent') && !objectName.endsWithIgnoreCase('tag') && !objectName.endsWithIgnoreCase('share') 
                    && !objectName.endsWithIgnoreCase('history')) {
                            
                        Schema.DescribeSObjectResult dsor = objectType.getDescribe();
                        System.debug('objectName>> ' + dsor.getLabel());  
                        Boolean isMetadataUpdate = false;
                        
                         if(!dsor.isAccessible() || !dsor.isUpdateable()) { // provide object permission
                            prfl.objectPermissions.add(updateObjectPermission(objectName));   
                            isMetadataUpdate = true;
                         } 
                            
                         if(!mtdItem.IsSelfProcess) { // process objects and fields permission                        
                                Map<String, Schema.SObjectField> objFieldsMap = dsor.fields.getMap();                
                                
                                for (String fieldName : objFieldsMap.keySet()) {  
                                    System.debug('fieldName>>' + fieldName);
                                    Schema.DescribeFieldResult dfr = objFieldsMap.get(fieldName).getDescribe(); 
                                    
                                    if(!dfr.isAccessible() && dfr.isPermissionable() && !fieldName.endsWithIgnoreCase('__s')) {                                
                                        prfl.fieldPermissions.add(updateFieldPermission(p.Id, objectName, fieldName, false)); 
                                        isMetadataUpdate  = true;
                                    }
                                }
                         }
                        
                        if(isMetadataUpdate) 
                            updateMdtLst.add(mtdItem);   
                        else 
                            mtdItem.isProcessed = true;    
                        
                    } else {
                        mtdItem.isProcessed = true;    
                    }
            } else {
                String fieldName = mtdItem.EntityName;
                String objectName = mtdItem.ParentEntityName;
                prfl.fieldPermissions.add(updateFieldPermission(p.Id, objectName, fieldName, true)); 
                updateMdtLst.add(mtdItem);   
             
            }
    
        }    
        
        if(prfl != null && (!prfl.objectPermissions.isEmpty() || !prfl.fieldPermissions.isEmpty())) {
            processMetadata(prfl, updateMdtLst);
        }
      
    }
    
     public void processMetadata(MetadataUpdateService.Profile prfl, List<MetadataItem> updateMdtLst) {
         String saveError = '';
         Boolean hasError = false;
         try {
                 MetadataUpdateService.MetadataPort service = createService();
                 service.timeout_x = 120000;   
                 
                 List<MetadataUpdateService.SaveResult> results = service.updateMetadata(new MetadataUpdateService.Metadata[] {prfl});
                 System.debug('saveresult size' + results.size()); 
                 List<String> saveResult = handleSaveResults(results[0]);
               
                 if(saveResult != null && !saveResult.isEmpty()) {
                     saveError = (saveResult.size() > 1) ? String.join(saveResult, ',') : saveResult.get(0);
                     if(this.batchSize > 1) hasError = true;      
                 } 
                
            } catch(CalloutException e) {
                saveError = e.getMessage();
                if(this.batchSize > 1) hasError = true;  
                
            } catch(Exception e) {
                saveError = e.getMessage();
                if(this.batchSize > 1) hasError = true; 
            }    
            
            if(this.batchSize == 1 && !prfl.fieldPermissions.isEmpty() && !this.splitPermission 
                    && (saveError.containsIgnoreCase('read time out') || saveError.containsIgnoreCase('read timed out') || saveError.containsIgnoreCase('INVALID_CROSS_REFERENCE_KEY'))) {
                        
                hasError = true;                
                //this.splitPermission = true;
                for(MetadataItem Item : updateMdtLst) { // update object self run                  
                    Item.IsSelfProcess = true;  
                    
                    for(MetadataUpdateService.ProfileFieldLevelSecurity fieldprm : prfl.fieldPermissions) {
                        this.mtdItemLst.add(new MetadataItem(this.mtdItemLst.size(), fieldprm.field, null, false, false));                        
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
                for(MetadataItem Item : updateMdtLst) {                    
                    Item.IsProcessed = true;
                    if(String.isNotBlank(saveError)) {  
                        Item.errMsg = saveError;
                        //throw new PermissionCheckerException(saveError);
                    }
                }    
             }
    }
    
    
    public List<String> handleSaveResults(MetadataUpdateService.SaveResult saveResult)
    {
        List<String> messages = new List<String>();
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return null;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
        
            for(MetadataUpdateService.Error error : saveResult.errors)
                //if(error.statusCode != 'INVALID_CROSS_REFERENCE_KEY') {
                    messages.add(
                        error.message + ' (' + error.statusCode + ').'  +
                       ( error.fields!=null && error.fields.size()>0 ?
                            ' Fields ' + String.join(error.fields, ',') + '.' : '' ) ); 
                //}
            /*if(messages.size()>0)
                throw new PermissionCheckerException(String.join(messages, ' '));*/
        }
        else if(!saveResult.success) {
            messages.add('Request failed with no specified error.');
            //throw new PermissionCheckerException('Request failed with no specified error.');
        }
        System.debug(messages);
        return messages;
    }
    
    
    public void finish(Database.batchableContext info) {
        if(this.retryBatchRun && !this.splitPermission) {
            if(this.batchSize == 1) {
                this.splitPermission = true;                
            }
            Database.executeBatch(new PermissionChecker(this.mtdItemLst, this.splitPermission), retryBatchSize);
        }  else {
            
            List<String> toAddresses = new List<String>();  
			toAddresses.addAll(NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(','));  
            String mailBdy = '', mailSub = '', mailHeader = '', mailSubHdr = '';
                      
            
            for(MetadataItem mdt : this.mtdItemLst) {
                if(String.isNotBlank(mdt.errMsg)) {
                    if(mdt.entityMetaData != null && mdt.entityMetaData instanceof Schema.SObjectType) {
                        mailBdy += mdt.EntityName + ' CustomObject :' + mdt.errMsg + '\n';          
                    }  else {
                        mailBdy +=  mdt.EntityName + ' CustomField :' + mdt.errMsg + '\n';      
                    }  
                }    
            }
            
            if(String.isNotBlank(mailBdy)) {
                  mailHeader = 'Permission Checker Batch Process completed';
                  mailSub = mailHeader;
                  mailSubHdr = 'Permission Checker Batch Process completed with below error/warning for below CustomObjects and fields';
    
            } else {
                  mailHeader = 'Permission Checker Batch Process completed Successfully';
                  mailSub = mailHeader;
                  mailSubHdr = 'Permission Checker Batch Process completed Successfully for ' + this.mtdItemLst.size() + ' CustomObjects and fields';     
            }
            
            if(mailBdy.length()> 9000) {
                mailBdy = mailBdy.substring(0, 9000);   
            }
            EmailUtility.sendEmail(mailSub,mailHeader,mailSubHdr,mailBdy,toAddresses); 
            
        
        }
    } 
    
     
    public MetadataUpdateService.ProfileObjectPermissions updateObjectPermission(String objName) {
        MetadataUpdateService.ProfileObjectPermissions objPrm  = new MetadataUpdateService.ProfileObjectPermissions();
        objPrm.object_x = objName;
        objPrm.allowCreate = true;
        objPrm.allowRead = true;
        objPrm.allowEdit = true; 
        objPrm.viewAllRecords = true;
        objPrm.modifyAllRecords = true;
        return objPrm; 
    }
    
     public  MetadataUpdateService.ProfileFieldLevelSecurity updateFieldPermission(String prfId, String objName, String fieldName, Boolean isContainObjName) {
        MetadataUpdateService.ProfileFieldLevelSecurity fieldSec = new MetadataUpdateService.ProfileFieldLevelSecurity();
        //fieldSec.field='SFLight__MasterList__c.SFLight__Deal_Type__c';
        
        fieldSec.field= (isContainObjName ? fieldName : objName + '.' + fieldName);
        fieldSec.editable=true;
        fieldSec.readable = true;         
        return fieldSec;
    }
    
   
      public  MetadataUpdateService.MetadataPort createService()
    {
        MetadataUpdateService.MetadataPort service = new MetadataUpdateService.MetadataPort();
        service.SessionHeader = new MetadataUpdateService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    
    public class PermissionCheckerException extends Exception { }
    
    private class MetadataIterator implements Iterator<MetadataItem> {
        private List<MetadataItem> items;
        private Integer nextIdx;
        
        public MetadataIterator(List<MetadataItem> items)
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
        
        public MetadataItem next()
        { System.debug('JobIterator next CALL #######################');
            return items[nextIdx++];
        }
    }
    
    
    private class MetadataIterable implements Iterable<MetadataItem> {
        private List<MetadataItem> iteratorItems;
        
        public MetadataIterable(List<MetadataItem> items)
        {
            // Only iterate over items that have not been completed
            iteratorItems = new List<MetadataItem>();
            for(MetadataItem item : items) {
                if (!item.IsProcessed) {
                    iteratorItems.add(item);    
                }                   
            }
        }
        
        public Iterator<MetadataItem> Iterator()
        {
            return new MetadataIterator(iteratorItems);
        }       
    }
    
    
    public class MetadataItem {
        public Integer Index;
        public String EntityName;
        public String ParentEntityName;
        public Object EntityMetaData;
        public Boolean IsSelfProcess;
        public Boolean IsProcessed;
        public String errMsg;
        
        public MetadataItem(Integer Index, String EntityName, Object EntityMetaData, Boolean IsSelfProcess,  Boolean IsProcessed) {
            this.Index = Index;
            this.EntityName = EntityName;
            this.EntityMetaData = EntityMetaData;
            this.IsSelfProcess = IsSelfProcess;
            this.IsProcessed = IsProcessed;
        }
    }
}