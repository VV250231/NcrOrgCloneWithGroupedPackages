@isTest
private class SolutionProviderContactTriggerTest {
	private static integer nameSuffix = 0; 
	
	@isTest static void testTriggerAndDispatcher() {
		Solution_Provider__c spAccount = SolutionProviderTriggerTest.createSolutionProvider();
		insert spAccount;

		Solution_Provider_Contact__c c = createSPContact(spAccount); 
		insert c; 
		update c;
		delete c;
        system.assertNotEquals(c.id, null);
	}

	public static Solution_Provider_Contact__c createSPContact(Solution_Provider__c spAccount)
	{
		Solution_Provider_Contact__c c = new Solution_Provider_Contact__c(); 
		c.Service_Provider_Id__c = spAccount.Id; 
		c.First_Name__c = 'Fake'; 
		c.Last_Name__c = 'User ' + nameSuffix++;
		return c; 
	}
	
	
}