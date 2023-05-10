/****************************************************************************************************************
*   ClassName :   PermissionReaderTest
Created By : Puneet/Monika
*   Description :  Automate process to provide access of all the fields to Admin 04, Data Backup and Recovery
and 10 Read Only Advance
Test class - PermissionReader, ProfilePermissionProvider, SchedulePermissionReader,MetadataWrapper
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-2357     11 NOV 2022          Monika            Automate process to provide access of all the fields to Admin 04
                                                     and 10 Read Only Advance
****************************************************************************************************************/
@isTest
private class PermissionReaderTest {
    static testMethod void runTest1() {
        User ownBkupUsr = [Select Id from User Where Profile.Name = :Label.OwnBackup_Profile limit 1];
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification;
        //Set<ID_Config__mdt> adminIds = ID_Config__mdt.getInstance('fls_per');
        Set<Id> adminIds = NSCCommonInfoUtil.getIdSetOf('fls_per');
        List<Profile> pr = [Select id,name from profile where Id IN :adminIds];
        
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataUpdateServiceTest.WebServiceMockImpl());
        
        System.runas(ownBkupUsr) {  
            PermissionReader prmChkr = new PermissionReader();
            Database.executeBatch(prmChkr);              
       
        	MetadataUpdateService.Error errorObj = new MetadataUpdateService.Error();
            errorObj.message = 'Test';
            errorObj.statusCode = 'Test';
            errorObj.fields = new List<String>{'Test field'};                
                
            MetadataUpdateService.SaveResult saveResult = new MetadataUpdateService.SaveResult();           
            saveResult.fullName = Label.OwnBackup_Profile;
            saveResult.success = false;
            saveResult.errors = new List<MetadataUpdateService.Error>();        
            saveResult.errors.add(errorObj);
            //prmChkr.handleSaveResults(saveResult);
            system.assertNotEquals(errorObj, null);
        }
        Test.stopTest();
        
        
    }
        static testMethod void runTest2() {
            NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name = 'NSC Job Failure', ToEmailAddresses__c = 'test@ncr.com');
            insert nscNotification;
            Test.startTest();
            ProfilePermissionProvider prfCl = new ProfilePermissionProvider();
           // MetadataUpdateService.ProfileFieldLevelSecurity md = 
            prfCl.updateObjectPermission('Account',true,true,true,true,true,true);   
            prfCl.updateFieldPermission('Account','name',true,true);
            MetadataWrapper mtd = new MetadataWrapper();
            //MetadataWrapper.
            mtd.Index = 1;
            mtd.EntityName = 'Account';
            mtd.EntityType = 'CustomObject';
            mtd.IsEntityAccess = False;
            mtd.IsProcessed = False;
            mtd.IsSelfProcess = False;
            mtd.errMsg = 'test';
            mtd.ProfileName ='System Administrator';
            MetadataWrapper mtd2 = new MetadataWrapper(1,'account','CustomObject',True,True); 
            List<MetadataWrapper> wrList = new List<MetadataWrapper>();
            wrList.add(mtd);
            //Database.executeBatch(new ProfilePermissionProvider(this.wrList, false), 50);  
            Database.executeBatch(new ProfilePermissionProvider(wrList, false), 50);           
            Test.stopTest();
            system.assertNotEquals(mtd, null);

        }
    static testMethod void runTest3() {
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
        
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataUpdateServiceTest.WebServiceMockImpl());
        //String cron_exp = '20 30 8 12 11 ?';
        String cron_exp = '0 25 * * * ?';
        SchedulePermissionReader m = new SchedulePermissionReader();
        // sys
        String jobId =  system.schedule('PermissionReader Schedule', cron_exp, new SchedulePermissionReader());
        Test.stopTest(); 
        system.assertNotEquals(jobId, null);
        
    }
    
    /*static testMethod void runTest2() {
        User ownBkupUsr = [Select Id from User Where Profile.Name = :Label.OwnBackup_Profile limit 1];
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
        
        Map<String, Schema.SObjectType> objectMap = new Map<String, Schema.SObjectType>();
        objectMap.put('Account', schema.getGlobalDescribe().get('Account'));        
        PermissionReader.MetadataItem item = new PermissionReader.MetadataItem(0, 'Account', (Object)objectMap.get('Account'), false, false);
        List<PermissionReader.MetadataItem> mtdItemLst = new List<PermissionReader.MetadataItem>{item};
       
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataUpdateServiceTest.WebServiceMockImpl());
        System.runas(ownBkupUsr) { 
            Database.executeBatch(new PermissionReader(mtdItemLst), 1);  
        }
        Test.stopTest();
    }*/
    
     
    
}