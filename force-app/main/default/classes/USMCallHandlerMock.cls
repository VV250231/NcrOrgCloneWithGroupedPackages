global class USMCallHandlerMock implements HttpCalloutMock {
    
    global static HttpResponse respond(HttpRequest hreq) {
        HttpResponse hresp  = new HttpResponse() ;
        hresp.setStatusCode(200) ;
        hresp.setStatus('SUCCESS') ;
        hresp.setBody('<ns:RequestHeader>'+
                      '<ns:TransactionID>'+'Test'+'</ns:TransactionID>'+
                      //'<ns:TransactionID>'+getUUID()+'</ns:TransactionID>'+
                      '<ns:SourceSystem>NSC</ns:SourceSystem>'+
                      '<ns:Timestamp>'+System.now()+'</ns:Timestamp>'+
                      '<ns:TargetSystem>Salesforce</ns:TargetSystem>'+
                      '<Status>SUCCESS</Status>' +
                      '</ns:RequestHeader>' ) ;
        
        return hresp ;
        
        
    }
    
    
}