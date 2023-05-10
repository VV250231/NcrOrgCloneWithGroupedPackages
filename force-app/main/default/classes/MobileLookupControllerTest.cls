@isTest
private class MobileLookupControllerTest {
    static testMethod void runTest() {
        TestRecordsFactory.createSimpleOpportunity();
        List<sObject> sObjList = MobileLookupController.getRecentRecords('Opportunity', 'Id,Name');
        System.assert(sObjList!=null);
        MobileLookupController.searchRecords('test', 'Opportunity', 'Id,Name');
    }

}