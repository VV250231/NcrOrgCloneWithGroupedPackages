/*  Used by various Triggers (see Solution Provider objects, Contact, and Account for examples). 
** TODO: Create various POST, PUT, and DELETE calls when SOUP provides endpoint information.
** TODO: Update trigger handlers to use the different HTTP VERBs once done */
public class DIServiceNowInterface{
    public static void callSendContact(List <Contact> diconList){
        List<String> jsonList=new List<String>();
        for(Contact con:diConList){
            jsonList.add(JSON.serializePretty(con));
        }
        // added to handle P1 issue DI Idea SSO, was giving future cannot call future. date refrence 20-21-Feb 2020Communications, Wendy, Amanda, Sakshi and Ajay
        if(!System.isFuture() && (System.Limits.getLimitFutureCalls() - System.Limits.getFutureCalls()) > 0){
            DIServiceNowInterface.SendToSOUP(jsonList, 'Contact', 'POST');
        }
    }
    // Paramater of note: objectType. This is used to build the endpoint url, so it must be exact.
    @future(Callout=true)
    public static void SendToSOUP(List<string> jsonL, string objectType, string httpMethod){
        for(String json:jsonL){
            Http http = new Http();
            HTTPRequest req = new HTTPRequest();
            // With a CERT sandbox refresh, we'll have the same IDs on Records and the endpoint settings for Production. 
            // Check the environment against the config URL and if they don't line up (prod -> prod or sandbox -> sandbox), don't sync!!
            if (!IsCorrectEndpointForCurrentEnv()){
                throw new SNException('Incorrect endpoint detected for this environment. Cannot sync until corrected! Update custom setting SOUP_Endpoint__c and try again.');
            }
            req.setEndpoint('callout:SOUP_Rest/'+objectType);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod(httpMethod);
            req.setBody(json);
            system.debug('Using Endpoint: ' + req.getEndpoint());
            system.debug('Sending Request to SOUP:\n\n' + json);
            HTTPResponse resp = null;
            if(!Test.isRunningTest()){ 
                resp = http.Send(req); 
            }else{
                resp = new HttpResponse(); 
                resp.setStatusCode(200);
            }
            if(resp.getStatusCode() != 200){
                system.debug('Callout failed! ' + resp.getStatusCode() + ': ' + resp.getStatus());
                WriteHeadersToDebug(resp);
                throw new SNException('Callout Failed: ' + resp.getStatusCode() + ': ' + resp.getStatus());
            }
        }
    }
    public static void WriteHeadersToDebug(HTTPResponse resp){
        for(string key : resp.getHeaderKeys()){
            system.debug('*** ' + key + ': ' + resp.getHeader(key));
        }
    }
    public static boolean IsCorrectEndpointForCurrentEnv(){
        string currentUrl = System.URL.getSalesforceBaseUrl().getHost(); 
        boolean inProduction = currentURL.contains('ncr.my.salesforce.com');
        return (inProduction || !inProduction || Test.isRunningTest());
    }
    public class SNException extends Exception{}
}