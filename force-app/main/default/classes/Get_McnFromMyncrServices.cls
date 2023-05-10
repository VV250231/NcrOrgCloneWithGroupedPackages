/**************************************
Author ...............: Santosh Jha
Date Created .........: 10 July 2021
Last Modified By .....:
Last Modified Date ...: 
Description ..........: This class will call MYNCR service to fetch MCN based on Customer User
***************************************/
public class Get_McnFromMyncrServices {
    static HttpRequest request;
    static HttpResponse response;
    
    static string ErrorMsg;//errormessage from response
    static string trId;// Transaction id 
    
    @future (callout=true)
    public static void makeGetCallout(String username, string email,String conId, String accId) {
         
        try{
           
            trId =new Uuid().getValue();
            SoupMyNcrResult ParsedObj= new SoupMyNcrResult();  
            //SOUP_Endpoint__c endPt = SOUP_Endpoint__c.getInstance('MYNCR');// store the endpoint
            
           // String usrnm = endPt.Username__c;
           // String pwd = endPt.Password__c;
           // String authHdr = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(usrnm + ':' + pwd));
           
            
            Http http = new Http();
            request = new HttpRequest();
            //request.setEndpoint('https://osbdev-ha.ncr.com/ext/ea/services/MyNCR/User/api/userProfile?username=gopal38MARS&email=gk185062@corp.ncr.com');
           // request.setEndpoint(endPt.Endpoint_URL__c+'?username='+username+ '&email='+email);
            request.setEndpoint('callout:SOUP_MYNCR'+'?username='+username+ '&email='+email);
           
            //System.debug(endPt.Endpoint_URL__c+'username='+username+ '&email='+email);
            
            request.setMethod('GET');
            // request.setHeader('Authorization', authHdr);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('x-transaction-id',  trId); 
            request.setHeader('SourceSystem',  'NSC'); 
            
            response = http.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                //System.debug('200 ok');
                // Deserializes the JSON string into collections of primitive data types.
                //System.debug('response body'+response.getBody());
                //System.debug('response'+response);
                ParsedObj =   SoupMyNcrResult.parseResponse(response.getBody());
                
                //System.debug('ParsedObj'+ParsedObj);
                //System.debug('ParsedObj.myNCRUser'+ParsedObj.myNCRUserProfileResp.userCreationDateTime);
                Set<String> McnSet = new Set<String>();
                for(SoupMyNcrResult.memberOf s : ParsedObj.myNCRUserProfileResp.memberOf){
                    if(s.accountNumber != NULL)  McnSet.add(String.valueOf(s.accountNumber));               
                    //System.debug(s.accountName);
                }
                VOCRelHandler.handleConAccAssoc( conId, McnSet,accId); 
                //ErrorMsg = 'no-error';
                //createLogs('success');
                
            }
            else 
            {
                ErrorMsg = 'FAILURE: Get_McnFromMyncrServices Class Some problem at SOUP end. Error Code'+ response.getStatusCode();
                createLogs(ErrorMsg);
            }
            
        }
        catch(Exception ex){
            
            ErrorMsg = 'FAILURE: Get_McnFromMyncrServices Class '+ ex.getMessage()+'at '+'line number '+ex.getLineNumber();
            createLogs(ErrorMsg);
           
        }
        //System.debug(sts);
        // createLogs();
        
    }
    
    public static void createLogs(string sts){
        
        MY_NCR_user_log__c obj = new MY_NCR_user_log__c();
        obj.Contact__c = null;
        obj.Quote__c = null;
        obj.Account_MCN__c = null;
        obj.Site_Address_Number__c = null;
        if(request!=null){
            obj.Request__c = String.valueOf(request.getEndpoint());
        }else{
            obj.Request__c = null;
        }
        if(response!=null){
            obj.Response__c = String.valueOf(response.getBody());
        }else{
            obj.Response__c = null;
        }
        //obj.Response__c = String.valueOf(response);
        obj.RequestType__c = 'Outbound';
        obj.Error_message__c = ErrorMsg;
        obj.Status__c = sts;
        obj.TransactionID__c = trId;
        
        insert obj; 
         //System.debug(obj.id);
        string body= String.format(System.Label.MyNCREmailBodyExc, new List<String>{String.valueof(sts),obj.Id,obj.Id});
        EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
        String eBody=template.HtmlValue;
        eBody = eBody.replace('#Body', body).replace('#Header', 'Service Failed').replace('#HeadLine', 'MyNCR MCN Logs - service Failed');
        
        String sub= 'Service Failed - MyNCR MCN Logs';
        NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'GLDC Log Failed', Subject__c =sub , title__c=sub, html_body__c=eBody);
        List<String> sndTo = new List<String>();
        sndTo.addAll(System.Label.BatchJobEmailNotificationList.split(','));
        if(sndTo.size()>0){
            ncrEmail.Recipient1__c = sndTo.get(0);
        }
        insert ncrEmail;
        
        
    }
    
}