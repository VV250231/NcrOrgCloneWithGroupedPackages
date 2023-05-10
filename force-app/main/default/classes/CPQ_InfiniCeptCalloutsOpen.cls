public with sharing class CPQ_InfiniCeptCalloutsOpen {
    
    static JSONGenerator gen;
    static SBQQ__Quote__c qte;
    public static List<CPQ_InfiniCeptCallouts.CustomFieldWrapper> custFieldLst = new List <CPQ_InfiniCeptCallouts.CustomFieldWrapper>();
    public static Map<String,CPQ_InfiniCeptCallouts.CustomFieldWrapper> fIdToField = new Map<String,CPQ_InfiniCeptCallouts.CustomFieldWrapper>();
    public static String accessToken,
                  paymentFeatures;
    public final static String STATUS_SUCCESS = 'Success',
                        STATUS_FAILURE = 'Failure';
    public static List<JPLogs__c> logs = new List <JPLogs__c> ();
      
/*
*********************************************************
@Method Name    : submitAppRequest
@author         : Shiv Mahla
@description    : Submits underwriting request to Infinicept
@param          : QuoteId
@return         : List of result object in JSON format
********************************************************
*/
    @AuraEnabled
    public static String submitAppRequest(String qteId) {
        List<NCR_Payments_Site__c> npsList = new List<NCR_Payments_Site__c>();
        Map<String,NCR_Payments_Site__c> actIdToNcrPS = new Map<String,NCR_Payments_Site__c>();
        List<Account> deliverToSites = new List<Account>();
        String msResponseJSON;
        MultiSiteResult msResponse = new MultiSiteResult();
        List<SiteResult> siteResLst = new List<SiteResult>();
        
        try {
            qte = getQuoteDetail(qteId);
            if (qte == null) {
                throw new CustomException('Quote Record not found');
            }  
            // If any payment package added in quote find pament feature value.     
            paymentFeatures = CPQ_InfiniCeptCalloutHelper.getPaymentsFeature(qte.Id);
            
            accessToken  = CPQ_InfiniCeptCalloutHelper.getAccessToken();
            if (String.isBlank(accessToken)) {
                throw new CustomException('Access issue. Please contact to Admin');
            }
            
            custFieldLst = CPQ_InfiniCeptCalloutHelper.getTemplate(accessToken);
            if (custFieldLst == null || custFieldLst.size() == 0) {
                throw new CustomException('Template not found');
            } else {
                for (CPQ_InfiniCeptCallouts.CustomFieldWrapper obj: custFieldLst) {
                    fIdToField.put(obj.UserDefinedId.toLowerCase(),obj); 
                }
            }
            
            // finding ncr payments & deliver to site details           
            if (qte.qtc_Multi_Site__c) {
                npsList = CPQ_InfiniCeptCalloutHelper.getPaymentSites(qteId);
                if (npsList.size() == 0) {
                    throw new CustomException('None of NCR Payment Sites meet the criteria.');
                } 
                for (NCR_Payments_Site__c np : npsList) {
                    actIdToNcrPS.put(String.valueOf(np.Account_Sites__c),np);
                }
                
                deliverToSites = CPQ_InfiniCeptCalloutHelper.getDeliverSites(actIdToNcrPS.keySet());
            } else {
                deliverToSites = CPQ_InfiniCeptCalloutHelper.getDeliverSites(new Set<String>{qte.Deliver_To_Site__c});
            }
            
            if (deliverToSites.size() == 0) {
                throw new CustomException('No Sites found for payment underwriting');
            }
            
            // sending site undrwriting request to infinicept and collecting responses.
            siteResLst = getAppResponses(deliverToSites,qte);
            
            // updating infinicept id to ncr sites.
            if (qte.qtc_Multi_Site__c) {
                updateAppIdOnNPS(siteResLst, npsList);
            } else {
                upsertNPS(siteResLst, qte);
            }
            
        } catch (CustomException e) {
            throw new AuraHandledException(e.getMessage());
            
        } catch (Exception e) {
            JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=qte.Name+'- Outbound',
                                          status__c = ('Failure-Exception :' +e).left(250));
            logs.add(log);
            msResponse.exceptionFlag = true;
            msResponse.exceptionMessage = 'Technical issue occured. Please contact system admin.';
        }
        
        // save logs
        createLogs();
        
        // If everything goes well.
        msResponse.exceptionFlag = false;
        msResponse.exceptionMessage = '';
        msResponse.siteResultLst = siteResLst;
        
        msResponseJSON = jSON.serialize(msResponse);
        return msResponseJSON;
    }
    
/*
*********************************************************
@Method Name    : createLogs
@author         : Shiv Mahla
@description    : Create logs for successful and unsuccessful attempts of site underwriting.
********************************************************
*/
    private static void createLogs() {
        // insert logs.
        try {
            if (logs.size() > 0) {
                insert logs;
            }
        } catch (Exception e) {
            system.debug('***'+e.getMessage());
        }
    }
    
    /*
*********************************************************
@Method Name    : getAppResponses
@author         : Shiv Mahla
@description    : Submits underwriting request to Infinicept and store results in result wrapper
@param          : deliverToSites - List of sites for which underwriting request needs to be send.
@param          : qte - quote record associated with NCR Payment Sites
@return         : List of result objects 
********************************************************
*/
    private static List<SiteResult> getAppResponses(List<Account> deliverToSites, SBQQ__Quote__c qte) {
        
        List<SiteResult> siteResLst = new List<SiteResult>();
        
        for (Account deliverSite : deliverToSites) {
            String status = STATUS_SUCCESS;
            String reqBodyJSON;
            HttpResponse httpAppResp;
            List<ApplicationResponse> apexAppResp;
            
            try {
                reqBodyJSON = getApplicationJSON(qte, deliverSite);
            } catch (Exception e) {
                status = STATUS_FAILURE;
                SiteResult sr = handleSiteException('Error while creating the request body',deliverSite,e);
                siteResLst.add(sr);
                gen.close();
                System.debug('reqBodyJSON: '+e.getStackTraceString());
            }
            
            if (!status.containsIgnoreCase(STATUS_FAILURE)) { 
                try {
                    httpAppResp = submitAppCallOut(reqBodyJSON, accessToken);
                    if (httpAppResp.getStatusCode() != 200) {
                        SiteResult sr = new SiteResult();
                        sr.siteNumber = deliverSite.Site_Number__c;
                        sr.exceptionFlag = true;
                        sr.status = 'Failure';
                        sr.statusMessage = httpAppResp.getStatus();
                        siteResLst.add(sr);
                        System.debug('httpAppResp:'+httpAppResp);
                        JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=qte.Name+'- Outbound',
                                                      Request__c = reqBodyJSON, Response__c = httpAppResp.getBody(),
                                                      status__c = httpAppResp.getStatus());
                        logs.add(log);
                    } else {
                        apexAppResp = (List<ApplicationResponse>) JSON.deserialize(httpAppResp.getBody(), List<ApplicationResponse>.class);
                        
                        SiteResult sr = new SiteResult();
                        sr.siteNumber = deliverSite.Site_Number__c;
                        sr.siteName = deliverSite.Name;
                        if (apexAppResp.size() > 0) {
                            sr.siteAppResp = apexAppResp[0];
                            sr.exceptionFlag = false;
                            sr.status = apexAppResp[0].statusMessage.containsIgnoreCase('Submission successful')?'Success' : 'Failure';
                            if (sr.statusMessage.containsIgnoreCase('A duplicate enterprise')){
                                sr.statusMessage = 'Duplicate Site, Site may already be Underwritten. Please remove it from NCR Payment Site';
                            } else {
                                sr.statusMessage = apexAppResp[0].statusMessage;
                            }
                        }
                        siteResLst.add(sr);
                        
                        JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=qte.Name+'- Outbound',
                                                      Request__c = reqBodyJSON, Response__c = httpAppResp.getBody(),
                                                      status__c = sr.siteAppResp.statusMessage);
                        logs.add(log);
                    }
                    
                } catch (Exception e) {
                    SiteResult sr = handleSiteException('Error while submitting the request',deliverSite,e);
                    siteResLst.add(sr);
                    System.debug('reqBodyJSON: '+e.getStackTraceString());
                    System.debug('httpAppResp:'+httpAppResp);
                }           
            }
        }
        return siteResLst;
    }
  
    
    /*
*********************************************************
@Method Name    : updateAppIdOnNPS
@author         : Shiv Mahla
@description    : updates site's application id on NCR Payment Sites record.
@param          : siteResult - response result of site's underwriting request
@param          : npsLst - NCR payment site records on which application Id needs to be updated.
********************************************************
*/
    private static void updateAppIdOnNPS(List<SiteResult> siteResult, List<NCR_Payments_Site__c> npsLst) 
    {   
        List<NCR_Payments_Site__c> npsLstToUpdate = new List<NCR_Payments_Site__c>();
        Map<String,SiteResult> siteNoToSiteRes = new Map<String,SiteResult>();
        for (SiteResult sr : siteResult) {
            if(!String.isBlank(sr.siteNumber)){
                siteNoToSiteRes.put(sr.siteNumber,sr);
            }
        }
        for (NCR_Payments_Site__c np : npsLst) {
            Account act = np.Account_Sites__r;
            if (act != null && siteNoToSiteRes.containsKey(act.Site_Number__c)) {
                SiteResult sr = siteNoToSiteRes.get(act.Site_Number__c);
                if (!sr.exceptionFlag && sr.siteAppResp != null) {
                    np.Opportunity__c = qte.SBQQ__Opportunity2__c;
                    np.NCR_Payments_Application_Status__c = sr.siteAppResp.statusMessage;
                    np.InfiniceptApplicationId__c = String.valueOf(sr.siteAppResp.infiniceptApplicationId);
                     //changed for payments onBoarding story
                    np.Cobrand__c =sr.siteAppResp.cobrand;
                    np.Cobrand_URL__c = sr.siteAppResp.merchantClaimURL;
                    np.Merchant_Application_Id__c=sr.siteAppResp.merchantApplicationId;
                    npsLstToUpdate.add(np);
                }
            }
        }
        
        if (npsLstToUpdate.size() > 0) {
            update npsLstToUpdate;
        }
        
    }
    
    /*
*********************************************************
@Method Name    : updateAppIdOnNPS
@author         : Shiv Mahla
@description    : insert of update NCR payment site record for single site quotes.
@param          : siteResult - response result of site's underwriting request
@param          : qte - quote record for which NCR payment site record needs to be insert or update.
********************************************************
*/
    private static void upsertNPS(List<SiteResult> siteResult,SBQQ__Quote__c qte) 
    {   
        
        List<NCR_Payments_Site__c> npsLstToUpsert = new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c npsObj;
        List<NCR_Payments_Site__c> npsls = [SELECT Id, Quote__c, InfiniceptApplicationId__c, Account_Sites__c, Account_Sites__r.Site_Number__c,
                                            Account_Sites__r.Name
                                            FROM NCR_Payments_Site__c
                                            WHERE Quote__c =: qte.Id
                                            AND Account_Sites__c =: qte.Deliver_To_Site__c];
        if (npsls.size() > 0) {
            npsObj = npsls[0];
        } else {
            npsObj = new NCR_Payments_Site__c();
        }
        for (SiteResult sr : siteResult) {
            if (!sr.exceptionFlag && sr.siteAppResp != null) {
                npsObj.Quote__c = qte.id;
                npsObj.Opportunity__c  = qte.SBQQ__Opportunity2__c;
                npsObj.Account_Sites__c = qte.Deliver_To_Site__c;
                npsObj.NCR_Payments_Application_Status__c = sr.siteAppResp.statusMessage;
                npsObj.InfiniceptApplicationId__c = String.valueOf(sr.siteAppResp.infiniceptApplicationId);
                 //changed for payments onBoarding story
                npsObj.Cobrand__c =sr.siteAppResp.cobrand;
                npsObj.Cobrand_URL__c = sr.siteAppResp.merchantClaimURL;
                npsObj.Merchant_Application_Id__c=sr.siteAppResp.merchantApplicationId != null ? String.valueOf(sr.siteAppResp.merchantApplicationId) : sr.siteAppResp.merchantApplicationId;
                
                npsLstToUpsert.add(npsObj);
            }
        }
        
        if (npsLstToUpsert.size() > 0) {
            upsert npsLstToUpsert;
        }
        
    }
    
    /*
*********************************************************
@Method Name    : submitAppCallOut
@author         : Shiv Mahla
@description    : insert of update NCR payment site record for single site quotes.
@param          : body - request body in JSON Format
@param          : accessToken - authentication token for authorization.
@return         : HttpResponse of the cllout
********************************************************
*/
    private static HttpResponse submitAppCallOut(String body, String accessToken) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endpointURL = CPQ_InfiniCeptCalloutHelper.getEndPointURL('SubmitApplication');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-app-name', 'pos-payos');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setEndpoint(endpointURL);
        req.setBody(body);
        return h.send(req);
    }
    
    /*
*********************************************************
@Method Name    : getQuoteDetail
@author         : Shiv Mahla
@description    : method to get the detail of quote.
@param          : quoteId
@return         : SBQQ__Quote__c - CPQ Qoute
********************************************************
*/
    public static SBQQ__Quote__c getQuoteDetail(String quoteId) {
        return [ SELECT Id, Name, SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.id,
                POS__c,SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c,
                SBQQ__Opportunity2__r.Channel_Office__r.Name,SBQQ__Opportunity2__r.Owner.Email,SBQQ__Opportunity2__r.Owner.Name, 
                SBQQ__Opportunity2__r.Contacts__r.Email, SBQQ__Opportunity2__r.Contacts__r.Name,
                SBQQ__Opportunity2__r.Contacts__r.Phone,SBQQ__Account__c, SBQQ__Account__r.Name, 
                SBQQ__Account__r.Master_Customer_Number__c,SBQQ__Account__r.BillingStreet, 
                SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingCountry,
                SBQQ__Account__r.BillingPostalCode, Deliver_To_Site__c,Deliver_To_Site__r.Name,
                Deliver_To_Site__r.BillingStreet, Deliver_To_Site__r.BillingCity,
                Deliver_To_Site__r.BillingState, Deliver_To_Site__r.BillingCountry,
                Deliver_To_Site__r.BillingPostalCode,Deliver_To_Site__r.Site_Number__c,
                Deliver_To_Site__r.cdm_Store_Branch_Number__c,qtc_Multi_Site__c, 
                Payments_Application_Signee__r.Name, Payments_Application_Signee__r.Phone, Payments_Application_Signee__r.Email,
                SBQQ__Opportunity2__r.Channel_Office__r.CDM_Account_Type__c,SBQQ__Opportunity2__r.Marketing_Program__c,
                SBQQ__Opportunity2__r.Opportunity_Number__c, qtc_Service_Type__c, qtc_Payments_Solution__c, 
                SBQQ__Opportunity2__r.Payments_Rep__r.Name, qtc_Number_of_Sites_with_Payments__c,
                //Quote Contact fields
                SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Phone,SBQQ__PrimaryContact__r.Email,SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.StageName,
                //Quote Line Fields
                (SELECT 
                 Id, SBQQ__ListPrice__c, SBQQ__ProductCode__c, SBQQ__Quantity__c,
                 qtc_Pricing_Type__c,qtc_Basis_Points__c,qtc_Basis_Points_Percent__c, 
                 qtc_Annual_Volume__c, qtc_Average_Check__c from SBQQ__LineItems__r 
                 WHERE Service_Offer_Category__c='Payments Processing'
                ),
                (SELECT Id FROM NCR_Payments_Sites__r)
                
                FROM SBQQ__Quote__c    
                WHERE Id=:quoteId
               ];
    }
    
    /*
*********************************************************
@Method Name    : getApplicationJSON
@author         : Shiv Mahla
@description    : create JSON Body of the HttpRequest.
@param          : qte - Quote record
@param          : deliverSite - NCR payment site account record.
@return         : SBQQ__Quote__c - CPQ Qoute
********************************************************
*/
    public static String getApplicationJSON(SBQQ__Quote__c qte, Account deliverSite) {
        
        Account act = qte.SBQQ__Account__r;
        Contact primaryCon = qte.SBQQ__PrimaryContact__r;
        gen = JSON.createGenerator(true);
        //start application JSON
        gen.writeStartObject(); 
        gen.writeStringField('Id', act.Master_Customer_Number__c);
        gen.writeStringField('legalName', act.Master_Customer_Number__c);
        gen.writeStringField('EmailAddress', deliverSite.Id == qte.Deliver_To_Site__c? qte.Payments_Application_Signee__r.Email :System.Label.CPQ_JP_SupportMail);
        
        gen.writeFieldName('address');
        gen.writeStartObject();
        gen.writeStringField('street', act.BillingStreet);
        gen.writeStringField('city', act.BillingCity);
        gen.writeStringField('state', act.BillingState);
        gen.writeStringField('postalCode', act.BillingPostalCode);
        gen.writeStringField('country', act.BillingCountry);
        gen.writeEndObject();
        
        // Sites
        gen.writeFieldName('sites');
        gen.writeStartArray();
        writeSitesJSON(act,deliverSite,primaryCon);
        gen.writeEndArray(); // End Sites
        
        
        gen.writeStringField('AutoRun', 'true');
        
        // Custom Field Answers
        gen.writeFieldName('CustomFieldAnswers');
        gen.writeStartArray();
        writeCustomFieldAnswersJSON(qte,deliverSite); // custom fields json
        gen.writeEndArray();
        
        gen.writeEndObject();
        //End Application JSON
        
        gen.close();
        return gen.getAsString();
    }
    
    /*
*********************************************************
@Method Name    : writeSitesJSON
@author         : Shiv Mahla
@description    : create JSON Body of site section of application request.
@param          : act - customer account record
@param          : deliverSite - NCR payment site
@param          : primaryCon - primary contact populated on quote
********************************************************
*/
    private static void writeSitesJSON(Account act, Account deliverSite, Contact primaryCon){
        
        // Start Site
        gen.writeStartObject();
        gen.writeStringField('Id',deliverSite.Site_Number__c != null ? deliverSite.Site_Number__c : '');
        gen.writeStringField('name', (deliverSite.Site_Number__c+'-'+deliverSite.Name).left(50));
        gen.writeStringField('description', 'Fill Description');
        
        gen.writeFieldName('contact');
        gen.writeStartObject();
        gen.writeStringField('contactPerson', primaryCon != null ? primaryCon.Name : '');
        if (primaryCon?.Phone != null) {
            gen.writeStringField('phoneNumber', primaryCon.Phone);
        }
        gen.writeNumberField('phoneNumberCountryCode', 1);
        gen.writeEndObject();
        
        gen.writeFieldName('address');
        gen.writeStartObject();
        gen.writeStringField('city', deliverSite.BillingCity == null 
                             ? act.BillingCity : deliverSite.BillingCity);
        gen.writeStringField('country', deliverSite.BillingCountry == null 
                             ? act.BillingCountry : deliverSite.BillingCountry);
        gen.writeStringField('postalCode', deliverSite.BillingPostalCode == null 
                             ? act.BillingPostalCode : deliverSite.BillingPostalCode);
        gen.writeStringField('state', deliverSite.BillingState == null 
                             ? act.BillingState : deliverSite.BillingState);
        gen.writeStringField('street', deliverSite.BillingStreet == null 
                             ? act.BillingStreet : deliverSite.BillingStreet);
        gen.writeEndObject();//end address
        
        if (deliverSite.cdm_Store_Branch_Number__c != null) {
            Double storeId;
            try {
                storeId = Integer.valueOf(deliverSite.cdm_Store_Branch_Number__c);  
            } catch (Exception e){
                storeId=101;
            }
            gen.writeNumberField('storeNumber', Integer.valueOf(storeId));
        } else {
            gen.writeNumberField('storeNumber', 101);
        }
        gen.writeEndObject();
        // End Site
        
    }
    
    /*
*********************************************************
@Method Name    : writeCustomFieldAnswersJSON
@author         : Shiv Mahla
@description    : create JSON Body of custom field section of application request.
@param          : qte - Quote record
@param          : deliverSite - NCR payment site record
********************************************************
*/
    private static void writeCustomFieldAnswersJSON(SBQQ__Quote__c qte, Account deliverSite){
        
        Map<String, JP_ProdCode_Price_map__mdt> produtCodeToPriceMap;
        Set<String> fieldIds = new Set<String>(); 
        fieldIds.addAll(fIdToField.keySet());
        
        // Set field values
        // Note : Always use lower case.
        if (fieldIds.contains('legal.name')) {
            writeFieldAnsJSON(fIdToField.get('legal.name'), qte.SBQQ__Account__r.Name);
        }
        
        if (fieldIds.contains('legal.address')) {
            writeAddressJSON( fIdToField.get('legal.address'), qte.SBQQ__Account__r);
        }
        
        if (fieldIds.contains('dba.name')) {
            writeFieldAnsJSON(fIdToField.get('dba.name'), deliverSite.Name.left(40));
        }
        
        if (fieldIds.contains('dba.address')) {
            writeAddressJSON(fIdToField.get('dba.address'), deliverSite);
        }
        
        if (fieldIds.contains('dba.email')) {
            writeFieldAnsJSON(fIdToField.get('dba.email'),qte.Payments_Application_Signee__r.Email);
        }
        
        if (fieldIds.contains('dba.phone') && qte.SBQQ__PrimaryContact__r.Phone != null) {
            writeFieldAnsJSON(fIdToField.get('dba.phone'), handlePhone(qte.Payments_Application_Signee__r.Phone));
        }
        
        if (fieldIds.contains('agent.name') && qte.SBQQ__Opportunity2__r.Channel_Office__r.Name != null) {
            writeFieldAnsJSON(fIdToField.get('agent.name'), qte.SBQQ__Opportunity2__r.Channel_Office__r.Name);
        }
        
        if (fieldIds.contains('agent.id') 
            && qte.SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c != null) 
        {
            writeFieldAnsJSON(fIdToField.get('agent.id'), qte.SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c);
        }
        
        if (fieldIds.contains('sf.ncrpos')) {
            //Ajay-EBA_SF-1375
            writeFieldAnsJSON(fIdToField.get('sf.ncrpos'), qte.POS__c);
        }
        //ADD Missing Field-Ajay-EBA_SF-1374
        if (fieldIds.contains('sf.salesrepname')) {
            writeFieldAnsJSON(fIdToField.get('sf.salesrepname'), qte.SBQQ__Opportunity2__r.Owner.Name);
        }
        
        if (fieldIds.contains('sf.salesrepemail')) {
            writeFieldAnsJSON(fIdToField.get('sf.salesrepemail'), qte.SBQQ__Opportunity2__r.Owner.Email);
        }
        
        if (fieldIds.contains('sf.mcn')) {
            writeFieldAnsJSON(fIdToField.get('sf.mcn'), qte.SBQQ__Account__r.Master_Customer_Number__c);
        }
        
        if (fieldIds.contains('annual.volume') && qte.SBQQ__LineItems__r.size() > 0) {
            writeFormattedFeeJSON(fIdToField.get('annual.volume'), qte.SBQQ__LineItems__r[0].qtc_Annual_Volume__c);
        }
        
        if (fieldIds.contains('annual.transactions') && qte.SBQQ__LineItems__r.size() > 0) {
            writeFormattedFeeJSON( fIdToField.get('annual.transactions'),
                                  (qte.SBQQ__LineItems__r[0].qtc_Annual_Volume__c / qte.SBQQ__LineItems__r[0].qtc_Average_Check__c)
                                  
                                 );
        }
        
        if (fieldIds.contains('number.sites')) {
            writeFeeJSON(fIdToField.get('number.sites'),1);
        }
        
        if (fieldIds.contains('pricing.pricingtype') && qte.SBQQ__LineItems__r.size() > 0) {
            writeFieldAnsJSON(fIdToField.get('pricing.pricingtype'), qte.SBQQ__LineItems__r[0].qtc_Pricing_Type__c);
        }
        
        if (fieldIds.contains('sf.siteid')) {
            writeFieldAnsJSON(fIdToField.get('sf.siteid'),deliverSite.Site_Number__c);
        }
        
        if (fieldIds.contains('sf.accounttype')) {
            writeFieldAnsJSON(fIdToField.get('sf.accounttype'),qte.SBQQ__Opportunity2__r.Channel_Office__r.CDM_Account_Type__c);
        }
        
        if (fieldIds.contains('sf.salesprogram')) {
            writeFieldAnsJSON(fIdToField.get('sf.salesprogram'),qte.SBQQ__Opportunity2__r.Marketing_Program__c);
        }
        
        if (fieldIds.contains('sf.paymentsalesrep')) {
            writeFieldAnsJSON(fIdToField.get('sf.paymentsalesrep'),qte.SBQQ__Opportunity2__r.Payments_Rep__r.Name);
        }
        
        if (fieldIds.contains('sf.opportunitynumber')) {
            writeFieldAnsJSON(fIdToField.get('sf.opportunitynumber'),qte.SBQQ__Opportunity2__r.Opportunity_Number__c);
        }
        //  added sf.opportunityURL   
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();  
        if (fieldIds.contains('sf.opportunityurl')) {
            writeFieldAnsJSON(fIdToField.get('sf.opportunityurl'),sfdcBaseURL+'/'+qte.SBQQ__Opportunity2__r.id);
        }   
        if (fieldIds.contains('sf.paymentssalesoffer')) {
            writeFieldAnsJSON(fIdToField.get('sf.paymentssalesoffer'),qte.qtc_Payments_Solution__c);
        }
        // Added new field: SFCPQBLG-818, SFCPQBLG-654 - 2 Feb 2022
        
        if (fieldIds.contains('sf.paymentsfeatures') && paymentFeatures != null) {
            writeFieldAnsJSON(fIdToField.get('sf.paymentsfeatures'),paymentFeatures);
        }
        //  ADDED New Fields: EBA_SF-1386
        if (qte.qtc_Service_Type__c!=null && fieldIds.contains('sf.restauranttype')) {   
            writeFieldAnsJSON(fIdToField.get('sf.restauranttype'),qte.qtc_Service_Type__c);  
        }
        if (fieldIds.contains('sf.opportunityname')) {   
            writeFieldAnsJSON(fIdToField.get('sf.opportunityname'),qte.SBQQ__Opportunity2__r.Name);                         
        } 
        if (fieldIds.contains('sf.opportunitysellingstage')) {   
            writeFieldAnsJSON(fIdToField.get('sf.opportunitysellingstage'),qte.SBQQ__Opportunity2__r.StageName);                         
        } 
        //List Price based values
        produtCodeToPriceMap = findProdutCodeToPriceMap();
        for (SBQQ__QuoteLine__c qli : qte.SBQQ__LineItems__r) {
            if (qli.SBQQ__Quantity__c != 0 && produtCodeToPriceMap.get(qli.SBQQ__ProductCode__c) != null) {
                JP_ProdCode_Price_map__mdt pricingMap = produtCodeToPriceMap.get(qli.SBQQ__ProductCode__c);
                if (pricingMap.Use_Basis_Point__c && fieldIds.contains(pricingMap.MasterLabel?.toLowerCase())) {
                    writeFeeJSON(fIdToField.get(pricingMap.MasterLabel.toLowerCase()), qli.qtc_Basis_Points__c);
                } else if (fieldIds.contains(pricingMap.MasterLabel?.toLowerCase())){
                    writeFeeJSON(fIdToField.get(pricingMap.MasterLabel.toLowerCase()), qli.SBQQ__ListPrice__c);
                }
            }
        } 
        
    }
    
    /*
*********************************************************
@Method Name    : writeAddressJSON
@author         : Shiv Mahla
@description    : create JSON Body of address
********************************************************
*/
    private static void writeAddressJSON(CPQ_InfiniCeptCallouts.CustomFieldWrapper fd, Account act){
        
        gen.writeStartObject();
        gen.writeNumberField('Id', fd.Id);
        gen.writeStringField('UserDefinedId', fd.userDefinedId);
        gen.writeFieldName('Value');
        gen.writeStartObject();
        
        if (!String.isBlank(act.BillingStreet)) {
            gen.writeStringField('Street1',act.BillingStreet.left(32));
            gen.writeStringField('Street2', '');
        }
        if (!String.isBlank(act.BillingCity)) {
            gen.writeStringField('City',act.BillingCity.left(20));
        }
        if (!String.isBlank(act.BillingState)) {
            gen.writeStringField('State', act.BillingState );
        }
        if (!String.isBlank(act.BillingCountry)) {
            gen.writeStringField('Country', 'US');
        }
        if (!String.isBlank(act.BillingPostalCode)) {
            gen.writeStringField('Zip',act.BillingPostalCode.left(5));
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
    }
    
    /*
*********************************************************
@Method Name    : writeAddressJSON
@author         : Shiv Mahla
@description    : create JSON Body of custom field
********************************************************
*/
    private static void writeFieldAnsJSON(CPQ_InfiniCeptCallouts.CustomFieldWrapper fd, String val) {
        if(val != null){
            gen.writeStartObject();
            gen.writeNumberField('id', fd.Id);
            gen.writeStringField('UserDefinedId', fd.userDefinedId);
            gen.writeFieldName('Value');
            gen.writeStartObject();
            gen.writeStringField('value', val);
            gen.writeEndObject();
            gen.writeEndObject();
        }
    }
    
    /*
*********************************************************
@Method Name    : writeFeeJSON
@author         : Shiv Mahla
@description    : create JSON Body of fee field
********************************************************
*/
    private static void writeFeeJSON(CPQ_InfiniCeptCallouts.CustomFieldWrapper fd, Decimal val) {
        if(val != null) {
            gen.writeStartObject();
            gen.writeNumberField('id', fd.Id);
            gen.writeStringField('userDefinedId', fd.userDefinedId);
            gen.writeFieldName('value');
            gen.writeStartObject();
            gen.WriteNumberField('value', val);
            gen.writeEndObject();
            gen.writeEndObject();
        }
    }
    
    /*
*********************************************************
@Method Name    : writeFeeJSON
@author         : Shiv Mahla
@description    : create JSON Body of formated fee field
********************************************************
*/
    private static void writeFormattedFeeJSON(CPQ_InfiniCeptCallouts.CustomFieldWrapper fd, Decimal val) {
        if(val != null) {
            gen.writeStartObject();
            gen.writeNumberField('id', fd.Id);
            gen.writeStringField('userDefinedId', fd.UserDefinedId);
            gen.writeFieldName('value');
            gen.writeStartObject();
            gen.writeStringField('value', val.format());
            gen.writeEndObject();
            gen.writeEndObject();
        }
    }
    
    /*
*********************************************************
@Method Name    : findProdCodeVsjpFieldName
@author         : Shiv Mahla
@description    : create map of prod code vs price field name
********************************************************
*/
    private static Map<String, JP_ProdCode_Price_map__mdt> findProdutCodeToPriceMap(){
        JP_ProdCode_Price_map__mdt[] prodCodeLst = [SELECT MasterLabel, QualifiedApiName, Product_Code__c, Use_Basis_Point__c 
                                                    FROM JP_ProdCode_Price_map__mdt];
        Map<String, JP_ProdCode_Price_map__mdt> prodCodeToPricingMap = 
            new Map<String, JP_ProdCode_Price_map__mdt>();
        
        for (JP_ProdCode_Price_map__mdt rec : prodCodeLst) {
            prodCodeToPricingMap.put(rec.Product_Code__c,rec);
        }
        return prodCodeToPricingMap;
    }
    
    /*
*********************************************************
@Method Name    : handlePhone
@author         : Shiv Mahla
@description    : format phone number
********************************************************
*/
    private static String handlePhone(String phone) {
        String p= (phone).replaceAll('\\D', '');
        p=p.removeStart('0'); 
        p=p.removeStart('1');
        if (p.length()>10) {p=p.left(10);}
        return p;
    }
    
    /*
*********************************************************
@Method Name    : handleSiteException
@author         : Shiv Mahla
@description    : create a log and site result if any exception occur for site application
@param          : errorMsg - custom error message
@param          : site - account site
@param          : e - exception object
@return         : site result obj with error message.
********************************************************
*/
    public static SiteResult handleSiteException(String errorMsg, Account site,Exception e){
        JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=qte.Name+'- Outbound',
                                      status__c = 'Failure-Exception : Error while creating the site request body',Request__c = e.getMessage()+'--'+e.getStackTraceString());
        logs.add(log);
        
        SiteResult sr = new SiteResult();
        sr.exceptionFlag = true;
        sr.status = STATUS_FAILURE;
        sr.siteNumber = site.Site_Number__c;
        sr.siteName = site.Name;
        sr.statusMessage = errorMsg;
        sr.exceptionMessage = e.getStackTraceString();
        return sr;
    }
 
    
    public class MultiSiteResult {
        public Boolean exceptionFlag = false;
        public String exceptionMessage = '';
        public List<SiteResult> siteResultLst = new List<siteResult>();
    }
    
    
    public class SiteResult {
        public String   siteNumber,
                        siteName,
                        exceptionMessage = '',
                        status = '',
                        statusMessage = '';
        public Boolean exceptionFlag = false;
        public ApplicationResponse siteAppResp = new ApplicationResponse();
    }
    
    
    public class TemplateWrapper {
        public List <CPQ_InfiniCeptCallouts.CustomFieldWrapper> customFields;
    }
    
    
    public class ApplicationResponse {        
        public String   type,                       
                        externalMerchantApplicationId,
                        infiniceptApplicationId,     
                        statusMessage,
                        organizationId,
                        siteId,
                        externalMerchantId,
                        externalStoreId,
                      //changed for payments onBoarding story
                        merchantClaimURL,merchantApplicationId,cobrand;
        public Integer status;
       
    }

    public class CustomFieldWrapper {
        public Integer id;
        public String   userDefinedId,
                        fieldType;
        public List<String> responseValueKeys;       
    }
      
    public class TemplateException extends Exception {}
    public class CustomException extends Exception {}
}