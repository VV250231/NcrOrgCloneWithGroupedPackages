/*
*********************************************************
Apex Class Name    : CPQERPShipmentDetailService
@description       : This class is used for a web serivice which is consumed by ERP to provide the shipment details of quote.
@author            : Pankaj Pandey
Modification Log:
Ver   Date         Author                          Modification
1.0   22-DEC-2021  Pankaj Pandey                   Initial Version
2.0   09-MAY-2022  Pankaj Pandey                   SFCPQBLG-954/SFCPQBLG-955
*********************************************************
*/
@RestResource(urlMapping='/cpq/v1/erpshipmentdetail')
global with sharing class CPQERPShipmentDetailService {
    
    String transactionID = '';
    String sourceSystemHeaderId = '';
    String sourceSystemLineID = '';
    String sourceSystem = '';
    String targetSystem = '';
    String actualShippedDate = '';
    String deliveryID = '';
    String interfaceMessage = '';
    qtc_FulfillmentOrder__c  fo = null;
    qtc_FulfillmentOrderProduct__c fop = null;
    RequestDetail requestDetail = null;
    List<ShippingDetails> shippingDetails = null;
    
    
    static final String STATUS_SUCCESS = 'SUCCESS';
    static final String STATUS_FAILURE = 'FAILURE';
    static final String INTERFACE_TYPE = 'ERP Shipment Details';
    static final String SOURCE_SYSTEM = 'ERP';
    static final String TARGET_SYSTEM = 'CPQ';
    static final String INBOUND = 'Inbound';
    static final String ERROR_FULFILLMENT_ORDER_NOT_FOUND = System.label.ERROR_FULFILLMENT_ORDER_NOT_FOUND;
    static final String ERROR_SOURCE_SYSTEM_HEADER_ID_MISSING = System.label.ERROR_SOURCE_SYSTEM_HEADER_ID_MISSING;
    
    static final String ERROR_SOURCE_SYSTEM_LINE_ID_MISSING = System.label.ERROR_SOURCE_SYSTEM_LINE_ID_MISSING;
    static final String ERROR_FULFILLMENT_ORDER_PRODUCT_NOT_FOUND = System.label.ERROR_FULFILLMENT_ORDER_PRODUCT_NOT_FOUND;
    static final String ERROR_SHIPMENT_DATE_MISSING = System.label.ERROR_SHIPMENT_DATE_MISSING;
    static final String ERROR_DELIVERY_ID_MISSING = System.label.ERROR_DELIVERY_ID_MISSING;
    static final String ERROR_SOURCE_SYSTEM_MISSING = System.label.ERROR_SOURCE_SYSTEM_MISSING;
    static final String ERROR_TARGET_SYSTEM_MISSING = System.label.ERROR_TARGET_SYSTEM_MISSING;
    static final String ERROR_SHIPMENT_DETAILS_MISSING = System.label.ERROR_SHIPMENT_DETAILS_MISSING;
    static final String ERROR_SHIPMENT_DETAILS_INVALID = System.label.ERROR_SHIPMENT_DETAILS_INVALID;
    static final String ERROR_JSON_GENERATION = System.label.ERROR_JSON_GENERATION;
    
    
    @HttpPost
    global static void applyShipmentDetails() {      
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        CPQERPShipmentDetailService execute = new CPQERPShipmentDetailService();
        
        response.addHeader('Content-Type', 'application/json');
        response.addHeader('charset', 'UTF-8');
        
        try {
            
            execute.processRequest(request, response);
            
        } catch (MissingParameterException ex) {//400 
            
            execute.handleMissingParameterException(ex, request, response);
            
        } catch (InvalidParameterException ex){//404
            
            execute.handleInvalidParameterException(ex, request, response);
            
        } catch (InternalServerException internalServerEx) { //500
            
            execute.handleInternalServerException(internalServerEx, request, response);
            
        } catch (Exception ex) {
            
            execute.handleException(ex, request, response);
            
        }
    }
    
    // validate request parameters.
    public  void processRequest(RestRequest request, RestResponse response) {
        
        Map<Id, ShippingDetails> mapifyShipmentDetails = new Map<Id, ShippingDetails>();
        Map<Id, qtc_FulfillmentOrderProduct__c> products = new Map<Id, qtc_FulfillmentOrderProduct__c>();
		ShippingDetails foShippingData = null;
        CPQ_Util util = null;
        requestDetail = (RequestDetail) System.JSON.deserializeStrict(request.requestBody.toString(), RequestDetail.class);
        transactionID = safeString(requestDetail.CPQShipmentReqABM.TransactionID);
        sourceSystem = safeString(requestDetail.CPQShipmentReqABM.SourceSystem);
        targetSystem = safeString(requestDetail.CPQShipmentReqABM.TargetSystem);
        deliveryID = safeString(requestDetail.CPQShipmentReqABM.DeliveryID);
        shippingDetails = requestDetail.CPQShipmentReqABM.ShippingDetails;
        sourceSystemHeaderId = safeString(requestDetail.CPQShipmentReqABM.SourceSystemHeaderId); 
        
        
        if (sourceSystem == null || sourceSystem  == '' || sourceSystem != SOURCE_SYSTEM){
            
            throw new MissingParameterException(ERROR_SOURCE_SYSTEM_MISSING);
        }
        
        if (targetSystem == null || targetSystem  == '' || targetSystem != TARGET_SYSTEM){
            
            throw new MissingParameterException(ERROR_TARGET_SYSTEM_MISSING);
        }
        
        if (deliveryID == null || deliveryID  == ''){
            
            throw new MissingParameterException(ERROR_DELIVERY_ID_MISSING);
        }
        
        if (shippingDetails == null){
            
            throw new MissingParameterException(ERROR_SHIPMENT_DETAILS_MISSING);
        }
        
        if (sourceSystemHeaderId == null || sourceSystemHeaderId  == ''){
            
            throw new MissingParameterException(ERROR_SOURCE_SYSTEM_HEADER_ID_MISSING);
        }
        
        fo = getFulfillmentOrder(sourceSystemHeaderId);
        
        if (fo == null){
            
            throw new InvalidParameterException(ERROR_FULFILLMENT_ORDER_NOT_FOUND);
        }
        
        
        
        for (ShippingDetails detail : shippingDetails){
            
            
            if(detail.SourceSystemLineID == null || detail.SourceSystemLineID == ''){
                throw new MissingParameterException(ERROR_SOURCE_SYSTEM_LINE_ID_MISSING);
            }
            
            if(detail.ActualShippedDate == null || detail.ActualShippedDate == ''){
                throw new MissingParameterException(ERROR_SHIPMENT_DATE_MISSING);
            }
            mapifyShipmentDetails.put(detail.SourceSystemLineID,detail);
        }
        List<qtc_FulfillmentOrderProduct__c> foProducts = getFulfillmentOrderProduct(sourceSystemHeaderId, 
                                                                     mapifyShipmentDetails.keySet());
       
        for(qtc_FulfillmentOrderProduct__c product : foProducts){
             products.put(product.Id, product);
        }
        
        for(String Ids : mapifyShipmentDetails.keySet()){
            
            if(!products.containsKey(Ids)){
                
                throw new InvalidParameterException(ERROR_SHIPMENT_DETAILS_INVALID);
            }
			foShippingData = mapifyShipmentDetails.get(Ids);
            products.get(Ids).qtc_Completion_Date_Shipment_Date__c = Date.parse(foShippingData.ActualShippedDate);
			products.get(Ids).qtc_Tracking_Number__c = foShippingData.TrackingNumber;
			products.get(Ids).qtc_Carrier__c = foShippingData.CarrierIdentifierCompanyName;
            products.get(Ids).qtc_Delivery_ID__c = deliveryID;
        }
        
        Update foProducts;
        interfaceMessage = 'Shipment details applied successfully.';
        response.responseBody = Blob.valueOf(getSuccessResponseBody());
        util = new CPQ_Util();
        util.createLog(transactionID,STATUS_SUCCESS,interfaceMessage, util.getRequestJSONAsString(request), util.getResponseJSONAsString(response),INBOUND, fo, fo.qtc_Quote__c, fo.qtc_Quote__r.SBQQ__Opportunity2__c, INTERFACE_TYPE);
    }
    
    //JSON success response for the Post request.
    @testVisible
    private  String getSuccessResponseBody() {
        JSONGenerator gen = JSON.createGenerator(true);
        String response;
        
        try {
            gen.writeStartObject();
            gen.writeFieldName('CPQShipmentResABM');
            gen.writeStartObject();
            gen.writeFieldName('ResponseHeader');
            gen.writeStartObject();
            gen.writeStringField('TransactionID', transactionID);
            gen.writeStringField('Timestamp', String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
            gen.writeStringField('Status',STATUS_SUCCESS);
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            response = gen.getAsString();
        } catch (Exception ex) {
            
            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex, 'CPQERPShipmentDetailService');
            throw new InternalServerException(ERROR_JSON_GENERATION);
            
        }
        
        return response;
    }
    
    // Get Fulfillment Order information
    @testVisible
    private qtc_FulfillmentOrder__c getFulfillmentOrder(String fid) {
        
        qtc_FulfillmentOrder__c fo;
        fo = [SELECT Id, qtc_Quote__c,qtc_Quote__r.SBQQ__Opportunity2__c,qtc_Sequence_Number__c, Retry_Attempt__c
              FROM qtc_FulfillmentOrder__c WHERE Id =: fid];
        return fo;
    }
    
    // Get Fulfillment Order Product information
    @testVisible
    private List<qtc_FulfillmentOrderProduct__c>  getFulfillmentOrderProduct(String foid, Set<Id> fopid ) {
        
        List<qtc_FulfillmentOrderProduct__c> foProducts;
        foProducts = [SELECT id, qtc_FulfillmentOrder__c,qtc_Completion_Date_Shipment_Date__c, qtc_Delivery_ID__c,qtc_Tracking_Number__c,qtc_Carrier__c   
                      FROM qtc_FulfillmentOrderProduct__c 
                      WHERE Id IN: fopid  AND qtc_FulfillmentOrder__c =: foid];
        return foProducts;
    }
    
    // Retrun value if String variable is not null else return empty string.
    @testVisible
    private String safeString(String val) {
        String returnVal = '';
        if (val != null){
            returnVal = val;
        }
        return returnVal;
    }
    
    // handle required paramenter missing into the request.
    private  void handleMissingParameterException(MissingParameterException ex, RestRequest request, RestResponse response) {
        setErrorResponse(400, ex.getMessage(), request, response);
    }
    
    // handle invalid data 
    private  void handleInvalidParameterException(InvalidParameterException ex, RestRequest request, RestResponse response) {
        setErrorResponse(404, ex.getMessage(), request, response);
    }
    
    //handle If any error occured while generating wrapper list or JSON
    private  void handleInternalServerException(InternalServerException ex,RestRequest request, RestResponse response){
        setErrorResponse(500, ex.getMessage(), request, response);
    }
    
    // handle any other type of exception occures.
    private void handleException(Exception ex, RestRequest request, RestResponse response) {
        setErrorResponse(500, ex.getMessage(), request, response);
        NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex,'CPQERPShipmentDetailService');
    }
    
    // set response values in case of exception.
    private void setErrorResponse(Integer statusCode,String errorMessage, RestRequest request, RestResponse response) {
        CPQ_Util util = null;
        response.statuscode = statusCode;
        response.headers.put('status', STATUS_FAILURE);
        response.responseBody = Blob.valueOf(getFailureResponseBody(errorMessage, statusCode));
        util = new CPQ_Util();
        
        if(fo != null){
          util.createLog(transactionID,STATUS_FAILURE,errorMessage, util.getRequestJSONAsString(request), util.getResponseJSONAsString(response),INBOUND, fo, fo.qtc_Quote__c, fo.qtc_Quote__r.SBQQ__Opportunity2__c, INTERFACE_TYPE);  
        }else{
            util.createLog(transactionID,STATUS_FAILURE,errorMessage, util.getRequestJSONAsString(request), util.getResponseJSONAsString(response),INBOUND, fo,null, null, INTERFACE_TYPE); 
        }
        
    }
    
    // Error response body
    private String getFailureResponseBody(String errorMessage, Integer statusCode) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('CPQShipmentResABM');
        gen.writeStartObject();
        gen.writeFieldName('ResponseHeader');
        gen.writeStartObject();
        gen.writeStringField('TransactionID', transactionID);
        gen.writeStringField('Timestamp', String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
        gen.writeStringField('Status',STATUS_FAILURE);
        gen.writeEndObject();
        gen.writeFieldName('ShipmentUpdateEventResponse');
        gen.writeStartObject();
        gen.writeFieldName('Fault');
        gen.writeStartObject();
        gen.writeStringField('FaultCode', statusCode +'');
        gen.writeStringField('FaultDescription', errorMessage);
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        String response = gen.getAsString();
        return response;
    }
    
    public class InternalServerException extends Exception {}
    public class MissingParameterException extends Exception {}
    public class InvalidParameterException extends Exception {}
    
    public class ShippingDetails {
        public String QuoteNumber;
        public String LineNumber;
        public String PID;
        public String OrderedQuantity;
        public String ShippedQuantity;
        public String ActualShippedDate;
        public String CumulativeShippedQuantity;
        public String SourceSystemLineID;
        public String CarrierIdentifierCompanyName;
        public String TrackingNumber;
        public String CarrierIdentifierSCAC;
        public String TrackingURL;
        
    }
    
    public class CPQShipmentReqABM {
        public String SourceSystem;
        public String TargetSystem;
        public String TransactionID;
        public String DeliveryID;
        public String Timestamp;
        public String SourceSystemHeaderID;
        public List<ShippingDetails> ShippingDetails;
    }
    
    public class RequestDetail{
        public CPQShipmentReqABM CPQShipmentReqABM; 
    }
    
    
}