public class SolutionProviderProductTriggerHandler
{
 	public static void HandleAfterInsert(List<Solution_Provider_Product__c> products)
	{
         List<String> jsonList=new List<String>();
		for(Solution_Provider_Product__c product : products)
		{
			try
			{
                 jsonList.add(JSON.serializePretty(product));
				}
		    catch(Exception e)
		    {
		    	System.debug('Failed to send Solution Provider Product to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
		    }
		}
        	DIServiceNowInterface.SendToSOUP(jsonList, 'SolutionProviderProduct', 'POST');
		
	}
	public static void HandleAfterUpdate(List<Solution_Provider_Product__c> products)
	{
         List<String> jsonList=new List<String>();
		for(Solution_Provider_Product__c product : products)
		{
			try
			{
                 jsonList.add(JSON.serializePretty(product));
							}
		    catch(Exception e)
		    {
		    	System.debug('Failed to send Solution Provider Product to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
		    }
		}
        DIServiceNowInterface.SendToSOUP(jsonList, 'SolutionProviderProduct', 'POST');

	}
    /*
	public static void HandleAfterDelete(List<Solution_Provider_Product__c> products)
	{
		for(Solution_Provider_Product__c product : products)
		{
			try
			{
				//DIServiceNowInterface.SendToSOUP(JSON.serializePretty(product), 'SolutionProviderProduct', 'POST');
			}
		    catch(Exception e)
		    {
		    	System.debug('Failed to send Solution Provider Product to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
		    }
		}
	}
	*/
}