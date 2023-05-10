@isTest
public class sendDisputesToCCAD_MockCallOut implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;
 
        public HTTPResponse respond(HTTPRequest req) {
        	HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/xml');
            response.setBody('<?xml version="1.0" encoding="UTF-8"?><Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><Header xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><wsa:ReplyTo xmlns:wsa="http://www.w3.org/2005/08/addressing"><wsa:Address>http://www.w3.org/2005/08/addressing/anonymous</wsa:Address><wsa:ReferenceParameters><instra:tracking.FlowEventId xmlns:instra="http://xmlns.oracle.com/sca/tracking/1.0">912261505</instra:tracking.FlowEventId></wsa:ReferenceParameters></wsa:ReplyTo></Header><Body xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><CreateDisputeResponse xmlns="soup.ncr.com.InvDisputeSvc" xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java" xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas" xmlns:ns0="soup.ncr.com.InvDisputeSvc"><ns0:Result>Saved</ns0:Result><ns0:Dispute_ID>223617</ns0:Dispute_ID><ns0:Invoices_Count>1</ns0:Invoices_Count><ns0:Invoice_List_Resp><ns0:Invoice><ns0:Master_Customer_Number>Saved</ns0:Master_Customer_Number><ns0:Invoice_id>1</ns0:Invoice_id><ns0:Dispute_ID>223617</ns0:Dispute_ID></ns0:Invoice><ns0:Invoice><ns0:Master_Customer_Number>1228ID</ns0:Master_Customer_Number><ns0:Invoice_id>WCS/18/042</ns0:Invoice_id><ns0:Dispute_ID>223610</ns0:Dispute_ID></ns0:Invoice></ns0:Invoice_List_Resp></CreateDisputeResponse></Body></Envelope>');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;          
        }
}