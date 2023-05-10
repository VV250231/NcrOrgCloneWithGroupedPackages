// ===========================================================================
// Object: IZuoraClient
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Interface for client to Zuora API
// ===========================================================================
// Changes: 2016-04-29 Reid Beckett
//           Class created
// ===========================================================================
public interface IZuoraClient 
{
    List<Zuora.ZObject> zquery(string zoql);
    List<Zuora.zApi.SaveResult> zupdate(List<Zuora.ZObject> zobjects);
    ZuoraSubscription findZuoraSubscription(String zuoraSubscriptionId);
}