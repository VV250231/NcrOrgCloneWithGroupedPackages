public class CpqOMOrderRequest implements Schedulable {
    static HttpRequest req;
    static HttpResponse res;
    static List<qtc_FulfillmentOrder__c> fOp;
    static String trId;
    static string ErrorMsg;//errormessage from response
    static string sts;//status from response
    
    public class OrderHeader {
        public String OrderSource;
        public String SourceOrderNumber;
        public String OrderType;
        public String CustomerNumber;
        public String ShipToSiteID;
        public String BillToSiteID;
        public String SalesRepNumber;
        public String ShippingInstructions;
        public String OrderedDate;
        public String RequestDate;
        public String CustomerPONumber;
        public String DeliveryToSiteID;
        public String CountryCode;
        public String ShipToContactNumber;
        public String BillToContactNumber;
        public String CustomerDeliveryPartner;
        public String ConversionType;
        public String CustomerPODate;
        public String TaxExempt;
        public String TaxExemptReason;
        public String InvoiceTrigger;
        public String InvoiceLineRollup;
        public String InvoiceNarrative;
        public String CustomerContactName;
        public String PrimarySalesOrg;
        public String CustomerImplementationSpecialist;
        public String FlowName;
        public String AmountPaid;
        public String PrepayAmount;
        public String EPXAuthGuid;
        public String EPXPMTType;
        public String NSN;
        public String EPXLastDigits;
        public String Attrbute1;
        public String SourceSystemHeaderID;
        public String DemandClassCode;
        public String TermsOfDelivery;
        public String RecommendedDate;
        public String RequestDateExplanation;
        public String QuoteName;
        public String PackingInstructions;
        public String ShipmentPriorityCode;
        public String CustomerEmailAddress;
        public String MerchNumber;
        public String DBANbr;
        public String TerminalNumber;
        public String TranType;
        public String TrxnCreationDate;
        public String TrxnLastUpdateDate;
        public String Amount;
        public String CurrencyCode;
        public String ZipCode;
        public String TrxnGuid;
        public String AchTransferDate;
        public String SequenceNumber;
        public String AccountNumberLastFourDigits;
        public String RoutingNumberLastFourDigits;
        public String AccountHolderFirstName;
        public String AccountHolderLastName;
        public String CaptureDate;
        public String CCLastFourDigits;
        public String CCExpirationDate;
        public String PaymentTerms;
        public String CCSurcharge;
        public String LinkedOrder;
        public String Cust_Nbr;
        public String OrigAuthGuid;
        public String CardType;
        public String CardHolderName;
        public String RequestedInstallationDate;
        public List<Attachment> Attachment;
    }
    
    public OrderRequestABM OrderRequestABM;
    
    public class OrderLines {
        public String LineNumber;
        //  public String LineNumber;
        public String ItemNumber;
        public String OrderedQuantity;
        public String UnitListPrice;
        public String UnitSellingPrice;
        public String UOM;
        public String SoftwareKeyNumber;
        public String SoftwareKeyStartDate;
        public String SoftwareKeyEndDate;
        public String ProductGrouping;
        public String CustProductDescription;
        public String ServiceAgreementID;
        public String ServiceName;
        public String PPMFlag;
        public String PPMPID;
        public String CustomerPrefFlag;
        public String SorderID;
        public String AnnualNetPrice;
        public String IntmedShipToSiteID;
        public String SSCLineNumber;
        public String FeatureOfLine;
        public String LineNumberReference;
        public String Core;
        public String HWRole;
        public String LineAttrbute1;
        public String SourceSystemLineID;
        public String MDMProduct;
        public String PackageID;
        public String SubPackageID;
        public String IPPShipQuantity;
        public String IPPNotShipQuantity;
        public String IPPSWMediaSet;
        public String IPPRelease;
        public String SystemName;
        public List<Attachment> Attachment;
    }
    
    public class OrderRequest {
        public OrderHeader OrderHeader;
        public List<OrderLines> OrderLines;
    }
    
    public class OrderRequestABM {
        public RequestHeader RequestHeader;
        public OrderRequest OrderRequest;
    }
    
    public class RequestHeader {
        public String TransactionID;
        public String TransactionType;
        public String SourceSystem;
        public String Timestamp;
        public String TargetSystem;
    }
    
    public class Attachment {
        public String LineNo;
        public String NoteType;
        public String NoteCode;
        public String NoteDesc;
    }
    
    public static void orderUpdate()
    {
        /*List<qtc_FulfillmentOrder__c> fo=[Select id , Retry_Attempt__c,qtc_Sequence_Number__c,Order_Interface_Status__c from qtc_FulfillmentOrder__c where (Order_Interface_Status__c='ERP Ready' OR ((Order_Interface_Status__c='Technical Issue(SOUP)' OR Order_Interface_Status__c='Technical Issue(ERP)') AND Retry_Attempt__c<=5)) AND qtc_Quote__r.qtc_EligibleForERP__c IN ('TRUE','TRUE MANUAL') ];*/
        Integer rowCount = Integer.valueof(System.Label.CPQ_ERP_INTERFACE_COUNT.trim());
        List<qtc_FulfillmentOrder__c> fo=[Select id , Retry_Attempt__c,qtc_Sequence_Number__c,Order_Interface_Status__c from qtc_FulfillmentOrder__c where (Order_Interface_Status__c='ERP Ready' OR ((Order_Interface_Status__c='Technical Issue(SOUP)' OR Order_Interface_Status__c='Technical Issue(ERP)') AND Retry_Attempt__c<=5)) AND qtc_Quote__r.qtc_EligibleForERP__c IN ('TRUE','TRUE MANUAL') 
                                         ORDER BY LastModifiedDate
										 LIMIT :rowCount];
        List<qtc_FulfillmentOrder__c> fOUpdate=new List<qtc_FulfillmentOrder__c>();
        for(qtc_FulfillmentOrder__c f:fo){
            if(f.Order_Interface_Status__c=='ERP Ready'){
                f.Retry_Attempt__c=f.Retry_Attempt__c+1;
                f.qtc_Sequence_Number__c= f.qtc_Sequence_Number__c+1;
                fOUpdate.add(f);
            }else if(f.Order_Interface_Status__c=='Technical Issue(SOUP)' || f.Order_Interface_Status__c=='Technical Issue(ERP)'){
                f.Retry_Attempt__c=f.Retry_Attempt__c+1; 
                fOUpdate.add(f);                
            }
        }
        if(!fOUpdate.isEmpty()){
            update fOUpdate;
        }
        for(qtc_FulfillmentOrder__c f:fo)
        {
            if(f.Retry_Attempt__c<=5){
                orderRequest(f.Id);  
            }else if(f.Retry_Attempt__c==6){
                emailOnSystemFail(f.Id);
            }
        }
    }
    
    public void execute(SchedulableContext SC) {
        try{
            
            orderUpdate();
            
        }catch(Exception ex){
            
        }         
    }
    
    
    @future (callout=true)
    public static void orderRequest(Id fId){
        try{
            fOp= [Select id,qtc_Quote__r.SBQQ__SalesRep__r.Name,qtc_Shipping_Instructions__c,qtc_Transactional_Currency_Code__c,qtc_Quote__r.Name, qtc_Quote_Name__c,qtc_Quote__r.qtc_Quote_Name__c, qtc_MCN__c,
                  qtc_Country_Code__c, qtc_Quote__r.SBQQ__Account__r.Name, qtc_Bill_To_Site__c,qtc_Quote__r.SBQQ__Opportunity2__c, 
                  qtc_Ship_To_Account__c,qtc_DeliverToSite__c, qtc_Salesperson_Global_ID__c ,
                  qtc_Invoice_Trigger__c, qtc_PO_Number__c, qtc_Order_Type__c, qtc_Quote__r.SBQQ__SalesRep__r.Email, qtc_Quote__r.qtc_TCV__c, 
                  qtc_Sequence_Number__c, qtc_PaymentTerms__c,Order_Interface_Status__c,Retry_Attempt__c,
                  qtc_Order_Source__c, qtc_New_Aloha_Key_Number__c, qtc_ERP_Estimated_Ship_Date__c, qtc_Quote__r.CurrencyIsoCode, qtc_Conversion_Type__c, qtc_CIS__c, qtc_CDP__c, qtc_Requested_Delivery_Date__c, qtc_Customer_PO_Date__c, qtc_ERP_Order_Status__c, qtc_Quote__r.SBQQ__Partner__c, 
                  qtc_Quote__r.SBQQ__Partner__r.Master_Customer_Number__c, qtc_Quote__r.qtc_Channel_Local_Office_Record_Type__c,
                  (Select id,qtc_LineNumber__c,qtc_Hardware_Role__c, qtc_MDM_Product_ID__c, qtc_SW_Key_Start_Date__c, qtc_SW_Key_End_Date__c, Name, qtc_Product__c, qtc_Qty_to_Ship__c,qtc_Software_Media_Set__c, qtc_Software_Release_Number__c,qtc_Package_ID__c, qtc_Software_System_Name__c,
                   qtc_Delivery_ID__c, qtc_Completion_Date_Shipment_Date__c,qtc_Sub_Package_ID__c,
                   qtc_Scheduled_Ship_Date__c,qtc_Software_NOT_Ship_Qty__c,qtc_Quantity__c,qtc_Unit_List_Price__c,qtc_Product__r.productcode from Fulfillment_Order_Products__r where qtc_Quantity__c>0 AND qtc_Product__r.qtc_Exclude_from_ERP__c =false)from qtc_FulfillmentOrder__c where id =:fId ];
            
            CpqOMOrderRequest reqBody = new CpqOMOrderRequest();
            CpqOMOrderRequest.OrderRequestABM reqObj = new CpqOMOrderRequest.OrderRequestABM();
            CpqOMOrderRequest.RequestHeader hdrReq = new CpqOMOrderRequest.RequestHeader(); 
            trId = new Uuid().getValue();
            hdrReq.TransactionID = trId; 
            hdrReq.SourceSystem='CPQ';
            hdrReq.Timestamp=String.valueOf(DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss'));
            hdrReq.TargetSystem='ERP';
            hdrReq.TransactionType= 'Create';
            
            reqObj.RequestHeader=hdrReq; 
            CpqOMOrderRequest.OrderRequest ordReq = new CpqOMOrderRequest.OrderRequest();
            
            CpqOMOrderRequest.OrderHeader od = new CpqOMOrderRequest.OrderHeader();
            List<CpqOMOrderRequest.OrderLines> ol = new List<CpqOMOrderRequest.OrderLines>();
            if(fOp!=null && fOp.size()>0){
                od.OrderSource=fOp[0].qtc_Order_Source__c;
                od.SourceOrderNumber=fOp[0].qtc_Quote__r.name;
                od.SalesRepNumber=fOp[0].qtc_Salesperson_Global_ID__c;  
                od.QuoteName=fOp[0].qtc_Quote__r.name;
                od.SequenceNumber=String.ValueOf(fOp[0].qtc_Sequence_Number__c);
                od.OrderType=fOp[0].qtc_Order_Type__c;
                od.CustomerNumber=fOp[0].qtc_MCN__c;
                od.OrderedDate='';
                od.ShipToSiteID=fOp[0].qtc_Ship_To_Account__c;
                od.BillToSiteID=fOp[0].qtc_Bill_To_Site__c;
                od.DeliveryToSiteID=fOp[0].qtc_DeliverToSite__c;
                od.SourceSystemHeaderId=fOp[0].id;
                od.CustomerDeliveryPartner=fOp[0].qtc_CDP__c;
                od.CurrencyCode=fOp[0].qtc_Transactional_Currency_Code__c;
                od.ConversionType=fOp[0].qtc_Conversion_Type__c;
                od.ShippingInstructions=fOp[0].qtc_Shipping_Instructions__c;
                od.CustomerContactName='';
                od.CustomerImplementationSpecialist=fOp[0].qtc_CIS__c;
                od.FlowName='HSR';
                od.CountryCode=fOp[0].qtc_Country_Code__c;
                od.CustomerPONumber='Essentials';
                od.CustomerPODate=String.ValueOf(fOp[0].qtc_Customer_PO_Date__c);
                od.InvoiceTrigger=fOp[0].qtc_Invoice_Trigger__c;
                od.PaymentTerms=fOp[0].qtc_PaymentTerms__c;// Added by shiv
                od.TaxExempt='S'; //test value
                od.RequestDate=(new CPQ_Util()).dateString(fOp[0].qtc_Requested_Delivery_Date__c); 
                // fulfillment order line
                for(qtc_FulfillmentOrderProduct__c fo:fOp[0].Fulfillment_Order_Products__r) {
                    CpqOMOrderRequest.OrderLines ordl=new CpqOMOrderRequest.OrderLines();
                    ordl.LineNumber=String.ValueOf(fo.qtc_LineNumber__c);
                    ordl.OrderedQuantity=String.ValueOf(fo.qtc_Quantity__c);
                    ordl.UnitSellingPrice=String.ValueOf(fo.qtc_Unit_List_Price__c);
                    ordl.ItemNumber=fo.qtc_Product__r.productcode;
                    ordl.UOM='';
                    if(fo.qtc_Product__r.productcode.contains('H400')){
                        ordl.SoftwareKeyNumber=fOp[0].qtc_New_Aloha_Key_Number__c;}
                    else{
                        ordl.SoftwareKeyNumber='';  }
                    ordl.SoftwareKeyStartDate=(new CPQ_Util()).dateString(fo.qtc_SW_Key_Start_Date__c);
                    ordl.SoftwareKeyEndDate=(new CPQ_Util()).dateString(fo.qtc_SW_Key_End_Date__c);
                    ordl.HWRole=fo.qtc_Hardware_Role__c;
                    ordl.LineAttrbute1='';
                    ordl.ProductGrouping='';
                    ordl.CustProductDescription='';
                    ordl.SourceSystemLineID=fo.Id;
                    ordl.MDMProduct=fo.qtc_MDM_Product_ID__c;
                    ordl.PackageID=fo.qtc_Package_ID__c;
                    ordl.SubPackageID=fo.qtc_Sub_Package_ID__c;
                    ordl.IPPShipQuantity=String.ValueOf(fo.qtc_Qty_to_Ship__c);
                    ordl.IPPNotShipQuantity=String.ValueOf(fo.qtc_Software_NOT_Ship_Qty__c);
                    ordl.IPPSWMediaSet=fo.qtc_Software_Media_Set__c;
                    ordl.IPPRelease=fo.qtc_Software_Release_Number__c;
                    ordl.SystemName=fo.qtc_Software_System_Name__c;
                    ol.add(ordl);
                }
                //--start attachement on header
            if(fOp[0].qtc_Quote__r.qtc_Channel_Local_Office_Record_Type__c == 'PARTNER') {
            
            List<CpqOMOrderRequest.Attachment> attachmentList = new List<CpqOMOrderRequest.Attachment>();
            CpqOMOrderRequest.Attachment attachment = new CpqOMOrderRequest.Attachment();
            attachment.NoteType = 'HSR Invoice';
            if(fOp[0].qtc_Quote__r.SBQQ__Partner__c != null){    
                attachment.NoteDesc = 'Please assign key to Partner MCN : ' + fOp[0].qtc_Quote__r.SBQQ__Partner__r.Master_Customer_Number__c + ' and activate key ' + fOp[0].qtc_New_Aloha_Key_Number__c;
            }
            attachmentList.add(attachment);
            od.Attachment = attachmentList;
            
            }
            //--end  
            }
            ordReq.OrderHeader=od;
            ordReq.OrderLines=ol;
            reqObj.OrderRequest=ordReq;
            
            reqBody.OrderRequestABM=reqObj;
            
            Http http = new Http();
            req = new HttpRequest();
            req.setEndpoint('callout:Soup_SalesOrder');               
            req.setMethod('POST');
            req.setTimeout(12000); 
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            
            req.setBody(JSON.serialize(reqBody));
            res = http.send(req);
            JSONParser prs = JSON.createParser(res.getBody());           
            while (prs.nextToken() != null) {
                if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Status')) {
                    prs.nextToken();
                    sts = prs.getText(); 
                }
                if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Message')) {
                    prs.nextToken();
                    ErrorMsg  = prs.getText();
                }
                fOp[0].Order_Interface_Status__c='Submitted to SOUP';
                update fOp[0];   
            }   
            (new CPQ_Util()).createLog(trId,sts,ErrorMsg, (req!=null ? String.valueOf(req.getBody()) : ''), String.valueOf(res),'Outbound', fOp[0], fOp[0].qtc_Quote__c, fOp[0].qtc_Quote__r.SBQQ__Opportunity2__c, 'ERP Order Create');
        }
        catch(Exception ex){
            fOp[0].Order_Interface_Status__c='Technical Issue(SOUP)';
            update fOp[0];
            sts ='FAILURE';  
            ErrorMsg = 'some problem at SOUP end.';
            (new CPQ_Util()).createLog(trId,sts,ErrorMsg, (req!=null ? String.valueOf(req.getBody()) : ''), String.valueOf(res),'Outbound', fOp[0], fOp[0].qtc_Quote__c, fOp[0].qtc_Quote__r.SBQQ__Opportunity2__c, 'ERP Order Create');
            if(fOp[0].Retry_Attempt__c==5){
                emailOnSystemFail(fOp[0].id);}
        }
    }  
    
    
    
    public static void emailOnSystemFail(Id fId){
        List<Interface_Log__c> log=[Select id from Interface_Log__c where Fulfillment_Order__c=:fId order by CreatedDate desc limit 1];
        String recordId=log[0].id;
        List<Messaging.SingleEmailMessage> singleMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'Connection Failure'];
        CPQAdminSupportEmail__c user = CPQAdminSupportEmail__c.getValues('Admin Support');
        String strToEmail = CPQAdminSupportEmail__c.getValues('Admin Support').Email__c;
        //String strToEmail = 'sp185453@ncr.com';
        String strFromEmail = CPQAdminSupportEmail__c.getValues('Default Workflow Email').Email__c;
        Messaging.SingleEmailMessage rslt = Messaging.renderStoredEmailTemplate(template.Id,null,recordId);
        String htmlBody = rslt.getHtmlBody();
        message.setReplyTo(strToEmail);
        message.setToAddresses(new List<string>{strToEmail});
        message.setHtmlBody(htmlBody);
        message.setSubject(rslt.getSubject());
        singleMessages.add(message);
        Messaging.sendEmail(singleMessages);
        
    }
}