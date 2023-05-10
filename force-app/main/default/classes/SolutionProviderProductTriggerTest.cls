@isTest
private class SolutionProviderProductTriggerTest {
	
	// Covers Interface as well 
	@isTest static void testTriggerAndDispatcher() {
		Solution_Provider_Product__c p = createSPProduct(); 
		insert p; 

		Solution_Provider_Product_Interface__c iface = createSPPInterface(p); 
		insert iface; 

		update p;
		update iface; 

		delete iface; 
		delete p; 
        system.assertNotEquals(iface, null);
	}

	static Solution_Provider_Product__c createSPProduct() 
	{
		Solution_Provider__c provider = SolutionProviderTriggerTest.createSolutionProvider(); 
		insert provider;
		Solution_Provider_Product__c product = new Solution_Provider_Product__c(); 
		product.Solution_Provider_Id__c = provider.Id; 
		product.Internal_Status__c = 'Available'; 
		product.Product_Type__c = 'Core Processing Vendor';  // Must use this type when associating an SP Interface
		product.Software_Support_Type__c = 'Third Party'; // Must set a Software support type and Hosting type when using an SP Interface
		product.Hosting_Type__c = 'In House';
		return product; 
	}

	static Solution_Provider_Product_Interface__c createSPPInterface(Solution_Provider_Product__c product)
	{
		Solution_Provider_Product_Interface__c iface = new Solution_Provider_Product_Interface__c(); 
		iface.Solution_Provider_Product__c = product.Id; 
		iface.Interface_Name__c = 'Online';

		return iface; 
	}
	
}