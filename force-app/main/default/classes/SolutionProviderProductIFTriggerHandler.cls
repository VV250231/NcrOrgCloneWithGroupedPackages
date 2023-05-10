public class SolutionProviderProductIFTriggerHandler
{
    public static void HandleAfterInsert(List<Solution_Provider_Product_Interface__c> interfaces)
        
    {
        List<string> spJsonList=new List<String>();
        
        for(Solution_Provider_Product_Interface__c i : interfaces)
        {
            try
            {
                spJsonList.add(JSON.serializePretty(i));
                //DIServiceNowInterface.SendToSOUP(JSON.serializePretty(i), 'SolutionProviderProductInterface', 'POST');
            }
            catch(Exception e)
            {
                System.debug('Failed to send Solution Provider Product Interface to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
        DIServiceNowInterface.SendToSOUP(spJsonList, 'SolutionProviderProductInterface', 'POST');
    }
    public static void HandleAfterUpdate(List<Solution_Provider_Product_Interface__c> interfaces)
    {
        List<string> spJsonList=new List<String>();
        
        for(Solution_Provider_Product_Interface__c i : interfaces)
        {
            try
            {
                spJsonList.add(JSON.serializePretty(i));
                
                //DIServiceNowInterface.SendToSOUP(JSON.serializePretty(i), 'SolutionProviderProductInterface', 'POST');
            }
            catch(Exception e)
            {
                System.debug('Failed to send Solution Provider Product Interface to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
        DIServiceNowInterface.SendToSOUP(spJsonList, 'SolutionProviderProductInterface', 'POST');
        
    }
    /*
public static void HandleAfterDelete(List<Solution_Provider_Product_Interface__c> interfaces)
{
for(Solution_Provider_Product_Interface__c i : interfaces)
{
try
{
DIServiceNowInterface.SendToSOUP(JSON.serializePretty(i), 'SolutionProviderProductInterface', 'POST');
}
catch(Exception e)
{
System.debug('Failed to send Solution Provider Product Interface to SOUP for Service Now. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
}
}
}
*/
}