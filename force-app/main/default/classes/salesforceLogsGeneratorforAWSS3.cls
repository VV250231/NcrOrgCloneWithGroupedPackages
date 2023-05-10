public class salesforceLogsGeneratorforAWSS3 {
   @future(callout=true)
    public static void uploadToAmazonS3() {

        DateTime dt= null;
        SObjectType accountType = Schema.getGlobalDescribe().get('LoginHistory');
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        Last_SIEM_Logs_Sent__c ssl = Last_SIEM_Logs_Sent__c.getInstance('SIEM Logs');	
        
        if(ssl!=null) dt=  ssl.Timestamp__c;
         system.debug('@@@: '+ssl.Timestamp__c);
       
      List<LoginHistory> lgnObj =[Select id,ApiType,LoginType,LoginHistory.NetworkId,AuthenticationServiceId, ApiVersion, LoginHistory.AuthMethodReference, Application, Browser, CipherSuite, ClientVersion, CountryIso, LoginGeo.City, LoginGeo.Country, LoginGeoId,
                                 LoginTime, LoginUrl, OptionsIsGet, OptionsIsPost, Platform, SourceIp, Status, TlsProtocol, UserId from LoginHistory
                                where LoginTime >= :dt];
                                    
        String jsonStringxmlRes =JSON.serialize(lgnObj);
        jsonStringxmlRes=jsonStringxmlRes.replace('}},','}}\n');
        System.debug(jsonStringxmlRes);
        Blob jsonContentBlob = Blob.valueOf(jsonStringxmlRes);
        System.debug(jsonContentBlob);
        String attachmentBody = EncodingUtil.base64Encode(jsonContentBlob);
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String fileNameTime = ((String.ValueOf(Datetime.now())).replace(' ','_')).replace(':','_');
        String bucketname = 'ncr-salesforce'; //AWS bucket name
        String host = 's3.us-east-1.amazonaws.com';
        String method = 'PUT';
        String filename = 'Salesforce_Main_LoginEvent_'+fileNameTime;
        system.debug('@@@: '+filename);
        
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('callout:AWS_S3_SIEM_Integration' + '/' + filename); 
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read-write');
        Blob xmlBlob = EncodingUtil.base64Decode(attachmentBody);
        req.setBodyAsBlob(xmlBlob);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('>>>> The response');
        System.debug(res);
        System.debug('>>>> The body');
        System.debug(res.getBody());
        System.debug('>>>> Status code');
        System.debug(res.getStatusCode());
        System.debug('>>>> Finished method');
        
        If(res.getStatusCode()==200){ Last_SIEM_Logs_Sent__c ls = Last_SIEM_Logs_Sent__c.getInstance('SIEM Logs');	
            if(ls!=null){ ls.Timestamp__c= Datetime.now(); update ls; }
        }
        
    }   
}