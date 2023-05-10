/*
*********************************************************
Apex Class Name    : CPQERPAcknowledgementService
@description       : This class is used for a web serivice which is consumed by ERP to provide the Acknowledgement of quotes.
@author            : Pankaj Pandey
Modification Log:
Ver   Date         Author                          Modification
1.0   15-NOV-2021  Pankaj Pandey                   Initial Version
*********************************************************
*/
@RestResource(urlMapping='/cpq/v1/erpacknowledgement')
global with sharing class CPQERPAcknowledgementService {
    
    static String transactionID = '';
    static String omOrderNumber = '';
    static String sourceSystemHeaderId = '';
    static String omStatus = '';
    static String txnStatus = '';
    //static String txnType = '';
    static String faultCode = '';
    static String faultDescription = '';
    static String interfaceMessage = '';
    qtc_FulfillmentOrder__c  fo = null;
    RequestDetail requestDetail = null;
    
    
    static final String STATUS_SUCCESS = 'SUCCESS';
    static final String STATUS_FAILURE = 'FAILURE';
    static final String STATUS_ENTERED = 'ENTERED';
    static final String STATUS_PROCESSED = 'PROCESSED';
	static final String ORDER_UNDER_PROCESS_FAULT_CODE = 'ERP-ORDER_ALREADY_UNDER_PROCESS';
    static final String ORDER_ALREADY_CREATED_FAULT_CODE = 'ERP-ORDER_ALREADY_CREATED';
    static final String DATA_ERROR_FAULT_CODE = 'ERP-FAILURE';
	static final String INTERFACE_TYPE = 'ERP Order Acknowledgement';
    static final String STATUS_BOOKED = 'BOOKED';
    static final String ORDER_CREATED = 'Order Created';
    static final String LINE_PROCESSED = 'Line Processed';
    static final String ORDER_BOOKED = 'Order Booked';
	static final String ORDER_SHIPPED = 'Order Shipped';
    static final String DATA_ISSUE_ON_HEADER = 'Data Issue on Header';
    static final String ORDER_UNDER_PROCESS = 'Order Under Process';
	static final String DATA_ISSUE_ON_LINES = 'Data Issue on Lines';
	static final String TECHNICAL_ISSUE_ERP = 'Technical Issue(ERP)';
	static final String SUBMITTED_TO_SOUP = 'Submitted to SOUP';
    static final String INBOUND = 'Inbound';
    static final String OUTBOUND = 'OutBound';
    //static final String TXN_UPDATE = 'UPD';
    //static final String TXN_ACKNOWLEDGE = 'ACK';
    static final String ERROR_STATUS_MISSING = System.label.ERROR_STATUS_MISSING;
    static final String ERROR_FULFILLMENT_ORDER_NOT_FOUND = System.label.ERROR_FULFILLMENT_ORDER_NOT_FOUND;
    static final String ERROR_OM_ORDER_NUMBER_MISSING = System.label.ERROR_OM_ORDER_NUMBER_MISSING;
    static final String ERROR_SOURCE_SYSTEM_HEADER_ID_MISSING = System.label.ERROR_SOURCE_SYSTEM_HEADER_ID_MISSING;
    static final String ERROR_FAULT_CODE_MISSING = System.label.ERROR_FAULT_CODE_MISSING;
    static final String ERROR_FAULT_DESCRIPTION_MISSING = System.label.ERROR_FAULT_DESCRIPTION_MISSING;
    static final String ERROR_JSON_GENERATION = System.label.ERROR_JSON_GENERATION;
    
    
    @HttpPost
    global static void doERPAcknowledgement() {      
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        CPQERPAcknowledgementService execute = new CPQERPAcknowledgementService();
		        
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
		CPQ_Util util = null;
                
        requestDetail = (RequestDetail) System.JSON.deserializeStrict(request.requestBody.toString(), RequestDetail.class);
        System.debug(requestDetail);
        transactionID = safeString(requestDetail.OrderResponseABM.ResponseHeader.TransactionID);
        //txnType = safeString(requestDetail.OrderResponseABM.ResponseHeader.TransactionType);
        txnStatus = safeString(requestDetail.OrderResponseABM.ResponseHeader.Status);
        omStatus = safeString(requestDetail.OrderResponseABM.OrderResponse.Status);
        sourceSystemHeaderId = safeString(requestDetail.OrderResponseABM.OrderResponse.SourceSystemHeaderId); 
        
        if (sourceSystemHeaderId == null || sourceSystemHeaderId  == ''){
            
         throw new InvalidParameterException(ERROR_SOURCE_SYSTEM_HEADER_ID_MISSING);
        }
        
        fo = getFulfillmentOrder(sourceSystemHeaderId);
        
        if (fo == null){
            
            throw new InvalidParameterException(ERROR_FULFILLMENT_ORDER_NOT_FOUND);
        }
        
        if (String.isBlank(omStatus ) || !(STATUS_ENTERED == omStatus || STATUS_PROCESSED == omStatus || STATUS_BOOKED == omStatus || STATUS_FAILURE == omStatus )) {
            
            throw new InvalidParameterException(ERROR_STATUS_MISSING);
        }
		if (txnStatus == STATUS_FAILURE && (fo.Order_Interface_Status__c == LINE_PROCESSED || fo.Order_Interface_Status__c == ORDER_BOOKED || fo.Order_Interface_Status__c == ORDER_SHIPPED)){
			
			throw new InvalidParameterException('Bad request. Failure request should not applied once fulfillment order marked as Line Processed/Order Booked/Order Shipped.');
		}
        util = new CPQ_Util();
        if (txnStatus == STATUS_SUCCESS && (STATUS_ENTERED == omStatus || STATUS_PROCESSED == omStatus || STATUS_BOOKED == omStatus)) {
            
            omOrderNumber = safeString(requestDetail.OrderResponseABM.OrderResponse.OMOrderNumber);
           
            
            if (omOrderNumber == null || omOrderNumber  == ''){
                
                throw new InvalidParameterException(ERROR_OM_ORDER_NUMBER_MISSING);
            }
                
            
            if (STATUS_ENTERED == omStatus){
                
                updateSuccessFulfillmentOrder(sourceSystemHeaderId, omOrderNumber, omStatus, ORDER_CREATED);
                interfaceMessage = 'Order successfully entered in ERP.';
                
            }else if(STATUS_PROCESSED == omStatus){
                
                updateSuccessFulfillmentOrder(sourceSystemHeaderId, omOrderNumber, omStatus, LINE_PROCESSED);
                interfaceMessage = 'Order line successfully processed in ERP.';
                
            }else if (STATUS_BOOKED == omStatus){
                
                updateSuccessFulfillmentOrder(sourceSystemHeaderId, omOrderNumber, omStatus, ORDER_BOOKED);
                interfaceMessage = 'Order successfully booked in ERP.';
            }
            
            response.responseBody = Blob.valueOf(getSuccessResponseBody());
			
			util.createLog(transactionID,STATUS_SUCCESS,interfaceMessage, util.getRequestJSONAsString(request), util.getResponseJSONAsString(response),INBOUND, fo, fo.qtc_Quote__c, fo.qtc_Quote__r.SBQQ__Opportunity2__c, INTERFACE_TYPE);
           
            
        }else if (txnStatus == STATUS_FAILURE){
            
            faultCode = safeString(requestDetail.OrderResponseABM.OrderResponse.Fault.FaultCode);
            faultDescription = safeString(requestDetail.OrderResponseABM.OrderResponse.Fault.FaultDescription);
            /*if (faultCode == null || faultCode  == ''){
                throw new InvalidParameterException(ERROR_FAULT_CODE_MISSING);
            }*/
            if (faultDescription == null || faultDescription  == ''){
                throw new InvalidParameterException(ERROR_FAULT_DESCRIPTION_MISSING);
            }
            
            if(faultCode == DATA_ERROR_FAULT_CODE){
                
                if(fo.Order_Interface_Status__c == SUBMITTED_TO_SOUP){
					updateFailureFulfillmentOrder(sourceSystemHeaderId, omStatus, DATA_ISSUE_ON_HEADER);
				}else{
					updateFailureFulfillmentOrder(sourceSystemHeaderId, omStatus, DATA_ISSUE_ON_LINES);
				}                 
                
            }else if(faultCode == ORDER_ALREADY_CREATED_FAULT_CODE || faultCode == ORDER_UNDER_PROCESS_FAULT_CODE){
                    updateFailureFulfillmentOrder(sourceSystemHeaderId, omStatus, ORDER_UNDER_PROCESS);
                }
                else{
                updateFailureFulfillmentOrder(sourceSystemHeaderId, null, TECHNICAL_ISSUE_ERP);
                
            }
            
            List<String> errorMessages = getErrorMessages(faultDescription);
            response.responseBody = Blob.valueOf(getSuccessResponseBody());
			
						
            for (String errorMessage : errorMessages){
                 
				 util.createLog(transactionID,STATUS_FAILURE,errorMessage, util.getRequestJSONAsString(request), util.getResponseJSONAsString(response),INBOUND, fo, fo.qtc_Quote__c, fo.qtc_Quote__r.SBQQ__Opportunity2__c, INTERFACE_TYPE);
				 
            }
            
        }
    }
    
    //Split fault description seperated with ## delimeter
    @testVisible
    private List<String> getErrorMessages(String faultDescription){
        List<String> errorMessages = faultDescription.split('##');
        return errorMessages;
    }
    
    //JSON success response for the Post request.
    @testVisible
    private  String getSuccessResponseBody() {
        JSONGenerator gen = JSON.createGenerator(true);
        String response;
        
        try {
            gen.writeStartObject();
            gen.writeFieldName('OrderUpdateEventResponseABM');
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
            
            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex, 'CPQERPAcknowledgementService');
            throw new InternalServerException(ERROR_JSON_GENERATION);
            
        }
        
        return response;
    }
    
    // Get Fulfillment Order information
    private qtc_FulfillmentOrder__c getFulfillmentOrder(String fid) {
        
        qtc_FulfillmentOrder__c fo;
        fo = [SELECT Id, qtc_ERP_Order_Number__c, qtc_ERP_Order_Status__c,Order_Interface_Status__c,
              qtc_Sequence_Number__c, Retry_Attempt__c, Name,qtc_Quote__c,qtc_Quote__r.SBQQ__Opportunity2__c
              FROM qtc_FulfillmentOrder__c WHERE Id =: fid];
        return fo;
    }
    
    // Update Fulfillment Order information on success
    @testvisible
    private void updateSuccessFulfillmentOrder(String fid, String omOrderNumber, String erpOrderStatus, String interfaceStatus){
        
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c();
        fo.id = fid;
        fo.qtc_ERP_Order_Number__c = omOrderNumber;
        
        if(erpOrderStatus != null){
            fo.qtc_ERP_Order_Status__c = erpOrderStatus;
        }
        if(interfaceStatus != null){
            fo.Order_Interface_Status__c = interfaceStatus;
        }
        Update fo;
        
    }
    
    // Update Fulfillment Order information on success
    @testvisible
    private  void updateFailureFulfillmentOrder(String fid, String erpOrderStatus, String interfaceStatus){
        
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c();
        fo.id = fid;
        fo.qtc_ERP_Order_Status__c = erpOrderStatus;
        fo.Order_Interface_Status__c = interfaceStatus;
        Update fo;
        
    }
    
    // Retrun value if String variable is not null else return empty string.
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
        NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex,'CPQERPAcknowledgementService');
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
        gen.writeFieldName('OrderUpdateEventResponseABM');
        gen.writeStartObject();
        gen.writeFieldName('ResponseHeader');
        gen.writeStartObject();
        gen.writeStringField('TransactionID', transactionID);
        gen.writeStringField('Timestamp', String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
        gen.writeStringField('Status',STATUS_FAILURE);
        gen.writeEndObject();
        gen.writeFieldName('OrderUpdateEventResponse');
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
    
    public class ResponseHeader {
        public String TransactionID;
        public String TransactionType;
        public String Timestamp;
        public String Status;
    }
    
    public class Fault {
        public String FaultCode;
        public String FaultDescription;
    }
    
    public class OrderResponse {
        public String SourceOrderNumber;
        public String OMOrderNumber;
        public String OMHeaderID;
        public String SourceSystemHeaderId;
        public String Status;
        public String Description;
        public TimeStamp TimeStamp;
        public Fault Fault;
    }
    
    
    
    public class OrderResponseABM {
        public ResponseHeader ResponseHeader;
        public OrderResponse OrderResponse;
    }
    
    public class TimeStamp {
        public String AxnStartTimestamp;
        public String AxnEndTimestamp;
    }
    
    public class RequestDetail{
        public OrderResponseABM OrderResponseABM; 
    }
}