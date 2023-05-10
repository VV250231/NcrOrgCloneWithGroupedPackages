public class SolutionProviderTriggerHandler
{
    public static void HandleAfterInsert(List<Solution_Provider__c> solutionProviders)
    {
        List<String> jsonList=new List<String>();
        for(Solution_Provider__c sp : solutionProviders)
        {
            try
            {
                jsonList.add(JSON.serializePretty(sp));
                
            }
            catch(Exception e)
            {
                System.debug('Failed to send Solution Provider to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
        DIServiceNowInterface.SendToSOUP(jsonList, 'SolutionProvider', 'POST');
    }
    public static void HandleAfterUpdate(List<Solution_Provider__c> solutionProviders)
    {
        List<String> jsonList=new List<String>();
        for(Solution_Provider__c sp : solutionProviders)
        {
            try
            {
                jsonList.add(JSON.serializePretty(sp));
            }
            catch(Exception e)
            {
                System.debug('Failed to send Solution Provider to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
        DIServiceNowInterface.SendToSOUP(jsonList, 'SolutionProvider', 'POST');
        
    }
}