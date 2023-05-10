@isTest
private class PermissionCheckerTest {
    static testMethod void runTest1() {
        User ownBkupUsr = [Select Id from User Where Profile.Name = :Label.OwnBackup_Profile limit 1];
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
        
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataUpdateServiceTest.WebServiceMockImpl());
        
        System.runas(ownBkupUsr) {  
            PermissionChecker prmChkr = new PermissionChecker();
            Database.executeBatch(prmChkr, 1);              
       
        	MetadataUpdateService.Error errorObj = new MetadataUpdateService.Error();
            errorObj.message = 'Test';
            errorObj.statusCode = 'Test';
            errorObj.fields = new List<String>{'Test field'};                
                
            MetadataUpdateService.SaveResult saveResult = new MetadataUpdateService.SaveResult();           
            saveResult.fullName = Label.OwnBackup_Profile;
            saveResult.success = false;
            saveResult.errors = new List<MetadataUpdateService.Error>();        
            saveResult.errors.add(errorObj);
            prmChkr.handleSaveResults(saveResult);
        }
        Test.stopTest();
        
    }
    
    static testMethod void runTest2() {
        User ownBkupUsr = [Select Id from User Where Profile.Name = :Label.OwnBackup_Profile limit 1];
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
        
        Map<String, Schema.SObjectType> objectMap = new Map<String, Schema.SObjectType>();
        objectMap.put('Account', schema.getGlobalDescribe().get('Account'));        
        PermissionChecker.MetadataItem item = new PermissionChecker.MetadataItem(0, 'Account', (Object)objectMap.get('Account'), false, false);
        List<PermissionChecker.MetadataItem> mtdItemLst = new List<PermissionChecker.MetadataItem>{item};
       
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataUpdateServiceTest.WebServiceMockImpl());
        System.runas(ownBkupUsr) { 
            Database.executeBatch(new PermissionChecker(mtdItemLst), 1);  
        }
        Test.stopTest();
    }
    
      static testMethod void runTest3() {
        User ownBkupUsr = [Select Id from User Where Profile.Name = :Label.OwnBackup_Profile limit 1];
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
        
         System.runas(ownBkupUsr) {
            Test.startTest();
            System.Test.setMock(WebServiceMock.class, new MetadataUpdateServiceTest.WebServiceMockImpl());
                String cron_exp = '20 30 8 10 2 ?';
                system.schedule('PermissionService Schedule', cron_exp, new ScheduleDatabackupPermission());
            Test.stopTest(); 
         }
        
    }
    
}