@isTest
public class CPQERPAckServiceTest {
    static String transactionID = 'txnId12345';
    static final String STATUS_SUCCESS = 'SUCCESS';
	
    @isTest
    public static void testDoERPAcknowledgement(){
        RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
    	req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/cpq/v1/erpacknowledgement';
    	req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
      /*  JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        	gen.writeFieldName('OrderResponseABM');
            gen.writeStartObject();
             	gen.writeFieldName('ResponseHeader');
             	gen.writeStartObject();
              		gen.writeStringField('TransactionID', 'tID10101010');
              		gen.writeStringField('Timestamp', String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
              		gen.writeStringField('Status','SUCCESS');
            	gen.writeEndObject();
        		gen.writeFieldName('OrderResponse');
        		gen.writeStartObject();
        			gen.writeStringField('SourceOrderNumber', 'Q-111111');
        			gen.writeStringField('SourceSystemHeaderID', 'sshid');
                    gen.writeStringField('OMOrderNumber', '111111');
        			gen.writeStringField('OMHeaderID', '111111');
        			gen.writeStringField('Status', 'Processed');
        			gen.writeStringField('OMOrderNumber', '111111');
                        
            	gen.writeEndObject();
            gen.writeEndObject();
          gen.writeEndObject();*/
		//req.requestBody = Blob.valueOf(gen.getAsString());
        
       /*  SBQQ__Quote__c q = new SBQQ__Quote__c(qtc_Quote_Name__c='Test Name', 
                                              qtc_Channel_Local_Office_Record_Type__c='PARTNER'
                                             );
        insert q;
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        fo.qtc_Quote__r = q;
        update fo;
        */
        
        String str = '{ "OrderResponseABM" : { "ResponseHeader" : { "TransactionID" : "tID1111111", "TransactionType" : "UPD", "Timestamp" : "2022-03-04T02:39:10.107230+00:00", "Status" : "SUCCESS" }, "OrderResponse" : { "SourceOrderNumber" : "Q-test", "SourceSystemHeaderID" : "sshid", "OMOrderNumber" : "omno121212", "OMHeaderID" : "omhid121137295", "Status" : "BOOKED",  "TimeStamp" : { "AxnStartTimestamp" : "2022-03-04T02:30:06.388542+00:00", "AxnEndTimestamp" : "2022-03-04T02:39:10.107272+00:00" }, "Fault" : { "FaultCode" : null, "FaultDescription" : null } } } }';
        req.requestBody = Blob.valueOf(str);
       // System.debug(System.JSON.deserializeUntyped(req.requestBody.toString()));
        System.debug(req);
    	RestContext.request = req;
    	RestContext.response= res;
        CPQERPAcknowledgementService.doERPAcknowledgement();
    }
    
    @isTest
    public static void testUpdateFailureFulfillmentOrder(){
         qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        String erpOrderStatus = 'Processed';
        String interfaceStatus = 'Order Booked';
        CPQERPAcknowledgementService ackService = new CPQERPAcknowledgementService();
        Test.startTest();
        ackService.updateFailureFulfillmentOrder(fo.id,erpOrderStatus,interfaceStatus);
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateSuccessFulfillmentOrder(){
         qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        String erpOrderStatus = 'Success';
        String interfaceStatus = 'Order Booked';
        String omOrderNo = '123456789';
        CPQERPAcknowledgementService ackService = new CPQERPAcknowledgementService();
        Test.startTest();
        ackService.updateSuccessFulfillmentOrder(fo.id,omOrderNo,erpOrderStatus,interfaceStatus);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetSuccessResponseBody(){
        CPQERPAcknowledgementService ackService = new CPQERPAcknowledgementService();
        Test.startTest();
        ackService.getSuccessResponseBody();
        Test.stopTest();
    }
    
    @isTest
    public static void testGetErrorMessages(){
        String errorMsgs = 'testErrorMsg1 ## testErrorMsg2';
        CPQERPAcknowledgementService ackService = new CPQERPAcknowledgementService();
        Test.startTest();
        ackService.getErrorMessages(errorMsgs);
        Test.stopTest();
    }
    
    @isTest
    public static void testvalidate(){
               qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
        String str = '{ "OrderResponseABM" : { "ResponseHeader" : { "TransactionID" : "tID1111111", "TransactionType" : "UPD", "Timestamp" : "2022-03-04T02:39:10.107230+00:00", "Status" : "SUCCESS" }, "OrderResponse" : { "SourceOrderNumber" : "Q-test", "SourceSystemHeaderID" : "sshid", "OMOrderNumber" : "omno121212", "OMHeaderID" : "omhid121137295", "Status" : "BOOKED",  "TimeStamp" : { "AxnStartTimestamp" : "2022-03-04T02:30:06.388542+00:00", "AxnEndTimestamp" : "2022-03-04T02:39:10.107272+00:00" }, "Fault" : { "FaultCode" : null, "FaultDescription" : null } } } }';
        str = str.replace('sshid', fo.Id);
        req.requestBody = Blob.valueOf(str);
        CPQERPAcknowledgementService ackService = new CPQERPAcknowledgementService();
        Test.startTest();
        ackService.processRequest(req, res);
        Test.stopTest();
    }
    
}