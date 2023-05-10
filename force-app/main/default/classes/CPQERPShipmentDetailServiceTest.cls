@isTest
public class CPQERPShipmentDetailServiceTest {
     static String transactionID = 'txnId12345';
     static final String STATUS_SUCCESS = 'SUCCESS';
    @isTest
    public static void testDoERPAcknowledgement(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/cpq/v1/erpshipmentdetail';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        qtc_FulfillmentOrderProduct__c fop = new qtc_FulfillmentOrderProduct__c( 
                    qtc_FulfillmentOrder__c = fo.Id,
                    qtc_Tracking_Number__c='1212433',
                    qtc_Carrier__c='BlueDart',
                    qtc_Quantity__c = 1);
        insert fop;
        qtc_FulfillmentOrderProduct__c fop2 = new qtc_FulfillmentOrderProduct__c( 
                    qtc_FulfillmentOrder__c = fo.Id,
                    qtc_Tracking_Number__c='"12123',
                    qtc_Carrier__c='BlueDart',
                    qtc_Quantity__c = 3);
        insert fop2;
        
        String str = '{"CPQShipmentReqABM" : {"SourceSystem" : "ERP","TargetSystem" : "CPQ","TransactionID" : "tid12345", "DeliveryID" : "dId1234","Timestamp" : "2022-03-03T09:03:54", "SourceSystemHeaderID" : "sshid","ShippingDetails" : [ {"QuoteNumber" : "Q-11064","LineNumber" : "6","PID" : "H400-0105-1000","OrderedQuantity" : "1","ShippedQuantity" : "1","ActualShippedDate" : "03/03/2022","CumulativeShippedQuantity" : "1","SourceSystemLineID" : "s1lid", "CarrierIdentifierCompanyName" : "ABC", "TrackingNumber" : "1212433","CarrierIdentifierSCAC" : "24234234",  "TrackingURL" : "a@abc.com"}, {"QuoteNumber" : "Q-11064","LineNumber" : "8","PID" : "H400-0119-0000","OrderedQuantity" : "3","ShippedQuantity" : "3","ActualShippedDate" : "03/03/2022","CumulativeShippedQuantity" : "3","SourceSystemLineID" : "s2lid", "CarrierIdentifierCompanyName" : "ABC", "TrackingNumber" : "12123","CarrierIdentifierSCAC" : "24234234",  "TrackingURL" : "a@abc.com"}] }}';
        str = str.replace('sshid', fo.id);
        str = str.replace('s1lid', fop.id);
        str = str.replace('s2lid', fop2.id);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        CPQERPShipmentDetailService.applyShipmentDetails();
    }
    
    @isTest
    public static void testgetSuccessResponseBody(){
        CPQERPShipmentDetailService sds = new CPQERPShipmentDetailService();
        Test.startTest();
        sds.getSuccessResponseBody();
        Test.stopTest();
        
    }
    
    @isTest
    public static void testGetFulfilmentOrder(){
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
         CPQERPShipmentDetailService sds = new CPQERPShipmentDetailService();
        Test.startTest();
        sds.getFulfillmentOrder(fo.id);
        Test.stopTest();
    }
    
    @istest
    public static void testGetFOProduct(){
         qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        qtc_FulfillmentOrderProduct__c fop = new qtc_FulfillmentOrderProduct__c( 
                    qtc_FulfillmentOrder__c = fo.Id,
                    qtc_Tracking_Number__c='12334',
                    qtc_Carrier__c='BlueDart',
                    qtc_Quantity__c = 3);
        insert fop;
        Set<Id> fopSet = new Set<Id>();
        fopSet.add(fop.Id);
         CPQERPShipmentDetailService sds = new CPQERPShipmentDetailService();
        Test.startTest();
        sds.getFulfillmentOrderProduct(fo.id, fopSet);
        Test.stopTest();
    }  
    
    @isTest
    public static void testDoERPAcknowledgementErrorGeneration(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/cpq/v1/erpshipmentdetail';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        qtc_FulfillmentOrderProduct__c fop = new qtc_FulfillmentOrderProduct__c( 
                    qtc_FulfillmentOrder__c = fo.Id,
                    qtc_Tracking_Number__c='1212433',
                    qtc_Carrier__c='BlueDart',
                    qtc_Quantity__c = 1);
        insert fop;
        qtc_FulfillmentOrderProduct__c fop2 = new qtc_FulfillmentOrderProduct__c( 
                    qtc_FulfillmentOrder__c = fo.Id,
                    qtc_Tracking_Number__c='"12123',
                    qtc_Carrier__c='BlueDart',
                    qtc_Quantity__c = 3);
        insert fop2;
        
        String str = '{"CPQShipmentReqABM" : {"SourceSystem" : "ERP","TargetSystem" : "CPQ","TransactionID" : "tid12345", "DeliveryID" : "dId1234","Timestamp" : "2022-03-03T09:03:54", "SourceSystemHeaderID" : "sshid","ShippingDetails" : [ {"QuoteNumber" : "Q-11064","LineNumber" : "6","PID" : "H400-0105-1000","OrderedQuantity" : "1","ShippedQuantity" : "1","ActualShippedDate" : "03/03/2022","CumulativeShippedQuantity" : "1","SourceSystemLineID" : "s1lid", "CarrierIdentifierCompanyName" : "ABC", "TrackingNumber" : "1212433","CarrierIdentifierSCAC" : "24234234",  "TrackingURL" : "a@abc.com"}, {"QuoteNumber" : "Q-11064","LineNumber" : "8","PID" : "H400-0119-0000","OrderedQuantity" : "3","ShippedQuantity" : "3","ActualShippedDate" : "03/03/2022","CumulativeShippedQuantity" : "3","SourceSystemLineID" : "s2lid", "CarrierIdentifierCompanyName" : "ABC", "TrackingNumber" : "12123","CarrierIdentifierSCAC" : "24234234",  "TrackingURL" : "a@abc.com"}] }}';
        str = str.replace('sshid', fo.id);
        str = str.replace('s1lid', fop.id);
        str = str.replace('s1lid', fop2.id);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        CPQERPShipmentDetailService.applyShipmentDetails();
    }
}