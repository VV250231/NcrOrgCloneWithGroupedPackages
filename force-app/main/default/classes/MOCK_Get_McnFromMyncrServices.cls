global class MOCK_Get_McnFromMyncrServices  implements HttpCalloutMock 
{
    global static HttpResponse respond(HttpRequest hreq) 
    {
        HttpResponse hresp  = new HttpResponse() ;
        hresp.setStatusCode(200) ;
        hresp.setStatus('SUCCESS') ;
        hresp.setHeader('Content-Type', 'application/json');
        
        hresp.setBody('{"responseHeader":{"status":"SUCCESS","statusCode":"00","statusMessage":"User attributes returned.","timestamp":"2021-07-20T18:46:17.580+00:00","transactionId":"12335678-1234-1234-1234-1234567890AC"},"myNCRUserProfileResp":{"address":{"city":"","address1":"","address2":"","address3":"","postalCode":"","county":"","state":"","country":"AZ"},"userStatus":"ENABLED","lastLoginTime":"","federatedUser":"NO","lastname":"VOCustomerFour","myNCRUser":"YES","officePhone":"","admin":"YES","username":"TestHCVOC16","email":"harjanFour@gmail.com","login":"TestHCVOC16","firstName":"Test","memberOf":[{"accountNumber":"6891525","accountName":"NAVY FEDERAL CREDIT UNION"},{"accountNumber":"5444561","accountName":"NAVY FEDERAL CREDIT UNION"}],"userCreationDateTime":"12 Jul 2021 13:44:52 GMT","jobTitle":"Branch Manager"}}');
        
        return hresp ;
    }
}