// ===========================================================================
// Object: NCRZuoraCustomizationPluginFactory
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: This works with the ZuoraCustomizationPlugin__c custom setting to load an implementation of a registred customization plugin
// ===========================================================================
// Changes: 2016-03-18 Reid Beckett
//           Class created
// ===========================================================================
global class NCRZuoraCustomizationPluginFactory 
{
    global static Object getImpl(String pluginType, String ncrDivision) 
    {
        for(ZuoraCustomizationPlugin__c zcp : ZuoraCustomizationPlugin__c.getAll().values())
        {
            if(zcp.Plugin_Type__c == pluginType && zcp.NCR_Division__c == ncrDivision)
            {
                try {
                    Type apexType = Type.forName(zcp.Implementation_Class__c);
                    return apexType.newInstance();
                }catch(Exception e) {
                    system.debug('inside catch'+e.getMessage());
                }
            }
        }   
        return null;
    }
}