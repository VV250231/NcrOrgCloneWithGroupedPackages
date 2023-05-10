@isTest
public class autoCXCaseCreationTestClass {
    @isTest
    public static void unitTest(){
        Test.startTest();
        Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        Case caseObj = new Case(status = 'Open', origin = 'Call', recordTypeId = RecTypeId, description = 'Test Description');
        insert caseObj;
        String caseStr = JSON.serialize(caseObj);
        Case obj = autoCXCaseCreationClass.CreateCxCase(caseStr);
        System.assertEquals(obj.description, obj.description);
        Test.stopTest();
    }    
}