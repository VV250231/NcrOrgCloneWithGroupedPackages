public class SolutionProviderContactTriggerHandler
{
 	public static void HandleAfterInsert(List<Solution_Provider_Contact__c> contacts)
	{
         List<String> jsonList=new List<String>();
		for(Solution_Provider_Contact__c contact : contacts)
		{
			try
			{
                jsonList.add(JSON.serializePretty(contact));
					}
			catch(Exception e)
			{
		    	System.debug('Failed to send Solution Provider Contact to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
			}
		}
        DIServiceNowInterface.SendToSOUP(jsonList, 'SolutionProviderContact', 'POST');
		
	}
	public static void HandleAfterUpdate(List<Solution_Provider_Contact__c> contacts)
	{
        List<String> jsonList=new List<String>();
		for(Solution_Provider_Contact__c contact : contacts)
		{
			try
			{
                  jsonList.add(JSON.serializePretty(contact));
				
			}
			catch(Exception e)
			{
		    	System.debug('Failed to send Solution Provider Contact to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
			}
		}
        DIServiceNowInterface.SendToSOUP(jsonList, 'SolutionProviderContact', 'POST');
	}
    /*
	public static void HandleAfterDelete(List<Solution_Provider_Contact__c> contacts)
	{
		for(Solution_Provider_Contact__c contact : contacts)
		{
			try
			{
				//DIServiceNowInterface.SendToSOUP(JSON.serializePretty(contact), 'SolutionProviderContact', 'POST');
			}
			catch(Exception e)
			{
		    	System.debug('Failed to send Solution Provider Contact to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
			}
		}
	}*/
}