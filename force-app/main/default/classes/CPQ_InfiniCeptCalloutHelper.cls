public with sharing class CPQ_InfiniCeptCalloutHelper {
    final static String REJECT = 'Reject',
                        WITHDRAWN = 'Withdrawn';
    
    public static List <CPQ_InfiniCeptCallouts.CustomFieldWrapper> getTemplate(String accessToken) {
        try{
            CPQ_InfiniCeptCallouts.TemplateWrapper templateFields = new CPQ_InfiniCeptCallouts.TemplateWrapper();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = null; 
     System.debug('CPQ_InfiniCeptCalloutHelper > getTemplate > ' + accessToken);
            string endpointURL = getEndPointURL('JPTemplate');           
                      
            req.setEndpoint(endpointURL);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('payos-application-key', '123');
            req.setHeader('x-app-name', 'pos-payos');
            req.setTimeout(120000);
            req.setMethod('GET');
            resp = http.send(req);
            System.debug('CPQ_InfiniCeptCalloutHelper > getTemplate > API Response ' + resp.getBody());
            if (resp.getStatusCode() != 200) {
                throw new CPQ_InfiniCeptCallouts.TemplateException('Template Called failed to retrieve fields');
            } else {
                templateFields = (CPQ_InfiniCeptCallouts.TemplateWrapper) JSON.deserialize(resp.getBody(), CPQ_InfiniCeptCallouts.TemplateWrapper.class);
            }
            return templateFields.CustomFields;
        }catch(Exception e){System.debug('CPQ_InfiniCeptCalloutHelper > getTemplate > catch > ' + e.getMessage());
            throw new CPQ_InfiniCeptCallouts.TemplateException(e);
        }
    }

    public static String getAccessToken() {
        String accessToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:JetPay'+System.label.PayOs_oauth_relative_URL);
        req.setMethod('POST');
        Http h = new Http();
        HttpResponse res = h.send(req);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String)m.get('access_token');
        return accessToken;
    }
    
    public static String getAccessTokenUsingJPAuthService() {
        String accessToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:JPAuthService');
        req.setMethod('POST');
        Http h = new Http();
        HttpResponse res = h.send(req);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String)m.get('access_token');
        return accessToken;
    }
    

    public static String getEndPointURL(String serviceName) {
        JP_EndPoint__c endpoint = null;
        endpoint = JP_EndPoint__c.getValues(serviceName);
        if (endpoint != null) {
            return endpoint.EndPoint_URL__c;
        } else {
            return '';
        }      
    }


    public static List<NCR_Payments_Site__c> getPaymentSites(String qteId) {
        return [ 
                SELECT Id, Quote__c, InfiniceptApplicationId__c, Account_Sites__c, Account_Sites__r.Site_Number__c,
                       Account_Sites__r.Name
                FROM NCR_Payments_Site__c
                WHERE Quote__c =: qteId AND (InfiniceptApplicationId__c = null
                    OR NCR_Payments_Application_Status__c = ''
                    OR NCR_Payments_Application_Status__c =: REJECT 
                    OR  NCR_Payments_Application_Status__c =: WITHDRAWN)
        ];
    }

    public static List<Account> getDeliverSites(Set<String> actIds) {
        return [
                SELECT 
                    Id, Name, Site_Number__c, BillingStreet, BillingCity, BillingState,BillingCountry,
                    BillingPostalCode, cdm_Store_Branch_Number__c
                FROM Account
                WHERE Id IN : actIds
        ];
    }  
    
    public static boolean checkDuplicateSites( List<NCR_Payments_Site__c> MultiQuotePaymentSites) {
        Set<String> sites=new Set<String>();
        for(NCR_Payments_Site__c site : MultiQuotePaymentSites){
            if(!(sites.add(site.Account_Sites__r.Site_Number__c))) {
                return true;
            }
        }
        return false;   
    }

    public static String getPaymentsFeature(String quoteId) {
        String paymentFeatures;
        
        List<SBQQ__QuoteLine__c> quoteLineItems = [ 
                SELECT qtc_Payments_Features__c 
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c =: quoteId 
                    AND SBQQ__ProductCode__c in ('SP1000000417', 'SP373060217965','SP1000000104','SP1000000105') 
                    AND SBQQ__Quantity__c = 1 LIMIT 1];
        
        if (! quoteLineItems.isEmpty()) {
            paymentFeatures = quoteLineItems[0].qtc_Payments_Features__c;
        }     
        return paymentFeatures;
    } 

}