@isTest
public class CaseControllerTest {
    @isTest
    public static void unitTest(){
        Test.startTest();
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CX Case').getRecordTypeId();  
        System.assertNotEquals(CaseRecordTypeId, null,'Case RecordType Id should not be null');
        Case caseObj = new Case(status = 'Open', origin = 'Call', recordTypeId = CaseRecordTypeId, description = 'Test Description');
        insert caseObj;
        
        Case obj = CaseController.getCaseRecord(caseObj.Id);
        Test.stopTest();
    }
}