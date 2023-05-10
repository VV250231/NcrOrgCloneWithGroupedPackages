/*
##################################################################################################
# Project Name..........: SpringCM Identity Validation                                                                       
# File..................: SpringCMAuthCtlr.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                   
# Created Date..........: 24-11-2014                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 24-11-2014 
# Description...........: The class is used to validation login user against SpringCM user account.
################################################################################################
*/
public with sharing class SpringCMAuthCtlr {

    public Boolean validSpringCMUser{get;set;}
    public SpringCMAuthCtlr(ApexPages.StandardController controller) {
        validSpringCMUser = validateSpringCMAccount();
    }   
    
    public boolean validateSpringCMAccount() {
        Boolean validUser = false;
        string apiURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/28.0/' + UserInfo.getOrganizationId();
        /*string oAuthUrlUAT = 'https://oauthuat.springcm.com/rest/201211/Salesforce/account/';*/
        string oAuthUrlProd = 'https://oauth.springcm.com/rest/201211/Salesforce/account/'; 
        HttpRequest req = new HttpRequest();
        req.setMethod('GET'); 
        req.setHeader('Accept', '*/*');
        string url = oAuthUrlProd + System.Userinfo.getOrganizationId();
        req.setHeader('Authorization', 'Salesforce ' + System.Userinfo.getSessionId() + '|' + 
        apiURL);
        req.setEndpoint(url);
        Http http = new Http();
        
        try {
            String authRes;
            if(!Test.isRunningTest()){
                HttpResponse response= http.send(req);
                authRes = response.getStatus();
            } else {
                authRes = 'OK';
            }
            if(authRes == 'OK') {
                validUser = true;   
            }
        } catch (Exception e) {  validUser = true;}
               
        return validUser;
    } 
}