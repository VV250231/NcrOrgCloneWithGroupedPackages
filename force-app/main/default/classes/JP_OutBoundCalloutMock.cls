@isTest
global class JP_OutBoundCalloutMock  implements HttpCalloutMock  {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        System.debug(req.getEndpoint());
        if(req.getEndpoint().contains('application/123')) {
        	 res.setStatusCode(200);
        	 res.setStatus('OK');    
        }
        
        if(req.getEndpoint().contains('application/234')) {
        	 res.setStatusCode(400);
             res.setStatus('Bad Request');    
        }
        res.setBody('{"example":"test"}');
       
        return res;
    }

}