/*
*********************************************************
Apex Class Name    : CPQ_QuoteInfoService
@description       : This class is used for a web serivice which is consumed by My-NCR to get quotes
                     for given MCN and Bill to Site.
@author            : Shiv Mahla
Modification Log:
Ver   Date         Author                               Modification
1.0   CreatedDate  Shiv Mahla                      Initial Version
*********************************************************
*/
@RestResource(urlMapping='/cpq/v1/site-quotes')
global with sharing class CPQ_QuoteInfoService {
    static String transactionID = '';
    static String masterCustomerNumber = '';
    static String billToSiteNumber = '';

    static final String STATUS_SUCESS = 'SUCESS';
    static final String STATUS_FAILURE = 'FAILURE';
    static final String QUOTE_STATUS_APPROVED = 'Approved';
    static final String MS_RELATIONSHIP_PARENT = 'Parent';
    static final String MS_RELATIONSHIP_CHILD = 'Child';
    static final String MS_TYPE_AE_ONLY =  'AE Only';
    static final String ERROR_MCN_MISSING = System.label.ERROR_MCN_MISSING;
    static final String ERROR_SITE_NUMBER_MISSING = System.label.ERROR_SITE_NUMBER_MISSING;
    static final String ERROR_MCN_NOT_FOUND = System.label.ERROR_MCN_NOT_FOUND;
    static final String ERROR_SITE_NOT_FOUND = System.label.ERROR_SITE_NOT_FOUND;
    static final String ERROR_WRAPPER_GENERATION = System.label.ERROR_WRAPPER_GENERATION;
    static final String ERROR_JSON_GENERATION = System.label.ERROR_JSON_GENERATION;
    static final String ERROR_WRONG_SITE = System.label.ERROR_WRONG_SITE;
    static final String SERVICE_OFFERING_CATEGORY_PAYMENT_PROCESSING = 'Payments Processing';
       
    
    @HttpGet
    global static void getQuotes() {      
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        response.addHeader('Content-Type', 'application/json');
        response.addHeader('charset', 'UTF-8');

        masterCustomerNumber = CPQ_Util.safeString(request.params.get('mcn'));
        billToSiteNumber = CPQ_Util.safeString(request.params.get('billToSiteNumber')); 
        transactionID = CPQ_Util.safeString(request.headers.get('x-transaction-id'));

        try {

            validateInputParameters();
            response.responseBody = Blob.valueOf(getResponseBody());

        } catch (MissingParameterException ex) {

            handleMissingParameterException(ex, response);

        } catch (InvalidParameterException ex){

            handleInvalidParameterException(ex, response);

        } catch (InternalServerException internalServerEx) {

            handleInternalServerException(internalServerEx, response);

        } catch (Exception ex) {

            handleException(ex, response);

        }
    }

    // validate required input paramenters.
    private static void validateInputParameters() {
        if (String.isBlank(masterCustomerNumber)) {
            throw new MissingParameterException(ERROR_MCN_MISSING);
        }

        if (String.isBlank(billToSiteNumber)) {
            throw new MissingParameterException(ERROR_SITE_NUMBER_MISSING);
        }
    }

    // JSON response for the GET request.
    private static String getResponseBody() {
        List<Cpq_QuoteUtil.QuoteDetail> quoteLst;
        JSONGenerator gen = JSON.createGenerator(true);
        String response;

        Account account = CPQ_Util.getAccount(masterCustomerNumber);
        if (account == null) {
            throw new InvalidParameterException(ERROR_MCN_NOT_FOUND);
        }

        Account billToSite = CPQ_Util.getSite(billToSiteNumber);
        if (billToSite == null) {
            throw new InvalidParameterException(ERROR_SITE_NOT_FOUND);
        }

        if (billToSite.ParentId != account.Id) {
            throw new InvalidParameterException(ERROR_WRONG_SITE);
        }

        quoteLst = Cpq_QuoteUtil.getQuotes(masterCustomerNumber, billToSiteNumber);

        try {
            gen.writeStartObject();
            gen.writeFieldName('cpqQuoteReadRespABM');
            gen.writeStartObject();
            gen.writeFieldName('responseHeader');
            gen.writeStartObject();
            gen.writeStringField('transactionID', transactionID);
            gen.writeStringField('timestamp', String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
            gen.writeStringField('status',STATUS_SUCESS);
            gen.writeEndObject();
            gen.writeFieldName('cpqQuoteReadResp');
            gen.writeStartObject();
            gen.writeFieldName('account');
            gen.writeStartObject();
            gen.writeStringField('mcn', account.Master_Customer_Number__c);
            gen.writeStringField('name', account.Name);
            gen.writeFieldName('billToSite');
            gen.writeStartObject();
            gen.writeStringField('siteNumber', billToSite.Site_Number__c);
            gen.writeStringField('name', billToSite.Name);
            gen.writeFieldName('quotes');
            gen.writeObject(quoteLst);
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            response = gen.getAsString();
        } catch (Exception ex) {

            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex, 'CPQ_QuoteInfoService');
            throw new InternalServerException(ERROR_JSON_GENERATION);
            
        }

        return response;
    }



    // handle required paramenter missing into the request.
    private static void handleMissingParameterException(MissingParameterException ex, RestResponse response) {
        setErrorResponse(400, ex.getMessage(), response);
    }

    // handle invalid data 
    private static void handleInvalidParameterException(InvalidParameterException ex, RestResponse response) {
        setErrorResponse(404, ex.getMessage(), response);
    }

    //hanld If any error occured while generating wrapper list or JSON
    private static void handleInternalServerException(InternalServerException ex, 
            RestResponse response) 
    {
        setErrorResponse(500, ex.getMessage(), response);
    }

    // handle any other type of exception occures.
    private static void handleException(Exception ex, RestResponse response) {
        setErrorResponse(500, 'Internal seriver error', response);
        NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex,'CPQ_QuoteInfoService');
    }

    // set response values in case of exception.
    private static void setErrorResponse(Integer statusCode,String message, RestResponse response) {
        response.statuscode = statusCode;
        response.headers.put('status', STATUS_FAILURE);
        response.responseBody = Blob.valueOf(getErrorResponse(message));
    }

    // Error response body
    private static String getErrorResponse(String errorMessage) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('cpqQuoteReadRespABM');
        gen.writeStartObject();
        gen.writeFieldName('responseHeader');
        gen.writeStartObject();
        gen.writeStringField('transactionID', transactionID);
        gen.writeStringField('timestamp', String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
        gen.writeStringField('status',STATUS_FAILURE);
        gen.writeEndObject();
        gen.writeStringField('message', errorMessage);
        gen.writeStringField('cpqQuoteReadResp','');
        gen.writeEndObject();
        String response = gen.getAsString();
        return response;
    }

    public class InternalServerException extends Exception {}
    public class MissingParameterException extends Exception {}
    public class InvalidParameterException extends Exception {}


}