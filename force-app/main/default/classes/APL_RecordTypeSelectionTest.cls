@isTest
private class APL_RecordTypeSelectionTest{
    
    static testMethod void myTest() {
        List<RecordType> rc = APL_RecordTypeSelection.getRecordType();
        System.assert(rc!=null);
    }
    
}