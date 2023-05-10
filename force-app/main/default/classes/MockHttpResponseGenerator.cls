@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        String resBody = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing">' + 
                                       '<env:Header>' + 
                                    '<wsa:MessageID>test</wsa:MessageID>' + 
                                    '</env:Header>' + 
                                    '<env:Body>' + 
                                    '<CDMUpdateOrganizationRespABMMsg xmlns:ns2="http://xmlns.ncr.com/SOUP/Common/1.0" xmlns="http://xmlns.ncr.com/SOUP/Service/CDM/Organization/V1">' + 
                                    '<UpdateOrganizationRespABM>' +
                                    '<ns2:ResponseHeader>' + 
                                    '<ns2:TransactionID>81d52e7b-e48f-48c8-8505-342e7afbf4bf</ns2:TransactionID>' +
                                    '<ns2:Timestamp>2020-04-17T15:37:55.928+00:00</ns2:Timestamp>' +
                                    '<ns2:Status>SUCCESS</ns2:Status>' + 
                                    '</ns2:ResponseHeader>' +
                                    '<UpdateOrganizationResponse>' +
                                    '<OrganizationPartyResult>' +
                                    '<Value>' +
                                    '<PartyNumber>10536781</PartyNumber>' +
                                    '<PartyId>300000075863492</PartyId>' +
                                    '<PartyType>ORGANIZATION</PartyType>  ' +
                                    '</Value>' +
                                    '</OrganizationPartyResult>' +
                                    '</UpdateOrganizationResponse>' +
                                    '</UpdateOrganizationRespABM>' +
                                    '</CDMUpdateOrganizationRespABMMsg>' +
                                    '</env:Body>' +
                                    '</env:Envelope>';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(resBody);
        return res;
    }
}