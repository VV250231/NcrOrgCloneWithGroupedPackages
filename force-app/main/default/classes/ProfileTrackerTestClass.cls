@isTest
public class ProfileTrackerTestClass {
    @isTest
    private static void UnitTestMethod(){
        List<Profile> proList = [Select Id,Name,PermissionsCustomizeApplication,PermissionsModifyAllData from profile where PermissionsCustomizeApplication=true];
       	profiletracker__c proTrackerObj = new profiletracker__c();
        proTrackerObj.IsCustomizeAppSelected__c = false;
        proTrackerObj.ProfileId__c =proList[0].id;
        Test.startTest();
        insert proTrackerObj;
        profileTrackerBatchClass uca = new profileTrackerBatchClass();
        Id batchId = Database.executeBatch(uca);
        System.assertNotEquals(batchId, null,'Batch is Null');
        Test.stopTest();
    }
}