@isTest
public class SolutionProviderTriggerTest {
	private static integer nameSufix = 0; 
	
	@isTest static void testTriggerAndDispatcher() {
		
		Solution_Provider__c sp = createSolutionProvider(); 
		insert sp; 

		sp.Name = 'mud';
		update sp;

		delete sp;
        system.assertNotEquals(sp, null);
	}
	

	public static Solution_Provider__c createSolutionProvider() { 
		solution_provider__c sp = new solution_provider__c(); 
		sp.name = 'test ' + namesufix; 

		return sp; 
	}
	
}