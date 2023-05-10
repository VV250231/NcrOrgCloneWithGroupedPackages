@isTest
private class CaseApexUtilityTest{

    private static testMethod void testAssigmentRuleOn(){
        // Build my new case
        Case c = new Case(Type = 'Other');
        
        // Run the test
        Test.startTest();
        insert c;
        Test.stopTest();
		
        List<Id> CaseIds =new List<Id>();
        CaseIds.add(c.Id);
        CaseApexUtility.assignCases(CaseIds);
        // Get the case that we just inserted
        Case caCheck = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];

        // The owner should *NOT* be me
        System.assertNotEquals(Userinfo.getUserId(), caCheck.OwnerId, 'Should be the queue not the user');

    }

}