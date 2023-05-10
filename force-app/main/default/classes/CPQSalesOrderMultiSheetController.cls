/**************************************
Author ...............: Dharmendra Kumar Pandey
Modified Date.........: 17-DEC-2020
Description...........: Integration to QB and this controller builds the sheet for upload.

***************************************/
public with sharing class CPQSalesOrderMultiSheetController {
    
    //xml doctype
    public String xlsHeader 
    {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }set;
    }
    
    
    //Investment wrapper class 
    public class InvestmentDetailsClass {
        
        // header attributes
        public String QUOTE_HEADER_ID{get;set;} //
        public String SOLD_TO_CUST_ID{get;set;}//
        public String FREIGHT_METHOD{get;set;}
        public String CONTRACTED_FREIGHT_AMOUNT{get;set;}
        public String ORDER_TYPE{get;set;}
        public String MASTER_CUSTOMER_NUMBER{get;set;}
        public String SUBSCRIPTION_TYPE{get;set;}// PoNumber
        public String PO_DATE{get;set;}
        public String PAYMENT_TERM{get;set;}
        public String BILL_TO_CUST_ID{get;set;}
        public String SHIP_TO_CUST_ID{get;set;}
        public String DELIVER_TO_CUST_ID{get;set;} // available final installation
        public String REQUESTED_ARRIVAL_DATE{get;set;} // requested delivery date
        public String SHIPPING_METHOD{get;set;}
        public String SHIP_INSTRUCTIONS{get;set;} 
        public String INVOICE_TRIGGER{get;set;}
        public String OPPORTUNITY_NUMBER{get;set;}
        public String APPROVED_EXPLANATION{get;set;}
        public String AUTO_SUBMIT{get;set;}
        public String MASTER_QUOTE_NUMBER{get;set;}
         
        //Line attributes
        public String IDENTIFIER{get;set;} // prodcut id
        public String BUNDLE_NAME{get;set;}
        public String DESCR{get;set;}
        public String QTY{get;set;}
        public String UNIT_AMT{get;set;}
        public String ANNUAL_NET_PRICE{get;set;}
        public String HARDWARE_ROLE{get;set;}
        public String SW_KEY{get;set;}
        public String SW_START_DATE{get;set;}
        public String SW_END_DATE{get;set;}
        public String ENTITLE_START_DATE{get;set;}
        public String ENTITLE_END_DATE{get;set;}
        
        // Order Notes
        public String TEXT254{get;set;}
        
        // Others
        public String PO_REF{get;set;}
        public String INTFC_ID{get;set;}
        public String INTFC_LINE_NUM{get;set;}
        public String TRANS_TYPE_BI{get;set;}
        public String TRANS_TYPE_BI_SEQ{get;set;}      
        public String BUSINESS_UNIT{get;set;}
        public String SOLD_TO_ADDR_NUM{get;set;}
        public String ADDRESS_SEQ_NUM{get;set;}
        public String SHIP_TO_ADDR_NUM{get;set;}      
        public String BILL_TYPE_ID{get;set;}      
        public String REFERENCE_ORDER_NUMBER{get;set;}
        public String LINE_SEQ_NUM{get;set;}
        public String BI_CURRENCY_CD{get;set;}
        public String FROM_DT{get;set;}
        public String TO_DT{get;set;}
        public String NOTES_SEQ_NUM{get;set;}
        public String NOTE_TYPE{get;set;}
        public String INTERNAL_FLAG{get;set;}
        public String BILL_SOURCE_ID{get;set;}
        public String BILLING_FREQUENCY{get;set;}
        public String BILL_CYCLE_ID{get;set;}
        public String PYMNT_TERMS_CD{get;set;}
        public String ORDER_GRP{get;set;}
        public String BILL_BY_ID{get;set;}
        public String VANTATIVE_CASE_ID{get;set;}
        public String RMA_ID{get;set;}
        public String INTMED_SHIP_ID{get;set;}
        public String PG_GROUP_LINE_NO{get;set;}
       
    }
    
    String OrderId = '';
    public List<InvestmentDetailsClass> InvestmentDetails = new List<InvestmentDetailsClass>();
    
    public void setInvestmentDetails(List<InvestmentDetailsClass> setterList){this.InvestmentDetails.addAll(setterList);}
    public List<InvestmentDetailsClass> getInvestmentDetails(){ return this.InvestmentDetails;}
    
    //Default Constructor
    public CPQSalesOrderMultiSheetController() {
        //Get All querystring parameters
        OrderId = ApexPages.currentPage().getParameters().get('id');
        Order[] lstSalesOrder = [Select Id from Order where Id =:OrderId]; 
        
        if(OrderId != NULL) {
            //Get Order LineItem details
            List<OrderItem> lstOrderLI;
            Map<string, OrderItem> OrderlineItemMap = new Map<string, OrderItem>();
            for(OrderItem oliObj:  [SELECT Order.qtc_Quote_Header_ID__c,Order.qtc_Master_Customer_Number__c,id, SBQQ__OrderedQuantity__c, Order.qtc_Freight_Method__c,Order.qtc_Contracted_Freight_Amount__c,Order.qtc_Requested_Delivery_Date__c,Order.qtc_Shipping_Method__c,
                                    Order.qtc_Shipping_Instructions__c, Order.qtc_Invoice_Trigger__c, Order.qtc_Opportunity_Number__c, Order.qtc_Approved_Explanation__c, Order.qtc_Auto_Submit__c,Order.qtc_New_Aloha_Key_Number__c,
                                    Order.qtc_PO_Number__c,Order.PoDate,Order.qtc_order_type__c,Order.qtc_Available_Bill_To__c,Order.qtc_Available_Ship_To__c,
                                    Order.qtc_Available_Final_Installation__c, Order.qtc_Master_Quote_Number__c,Order.SBQQ__PaymentTerm__c,qtc_Product_Group_ERP_Line_No__c,Product2.productcode,
                                    qtc_Bundle_Name__c, qtc_Product_Description__c, UnitPrice, qtc_Hardware_Role__c,Order.SBQQ__Quote__r.qtc_New_Aloha_Key_Number__c,
                                    qtc_SW_Start_Date__c,qtc_SW_End_Date__c,qtc_Entitlement_Start_Date__c,qtc_Entitlement_End_Date__c,Product2.product_type__c 
                                    from OrderItem where OrderId=:OrderId AND Product2.product_type__c in ('PID') AND Product2.Family != 'Cloud' AND Product2.Family != 'Annuity'  AND (NOT Product2.productcode LIKE '9614%') AND (Product2.productcode !='RevenuePerTransaction')]){
                                        if(!OrderlineItemMap.containsKey(oliObj.Product2.productcode)){
                                            OrderlineItemMap.put(oliObj.Product2.productcode, oliObj);
                                        } Else {
                                            OrderItem olitemObj = OrderlineItemMap.get(oliObj.Product2.productcode);
                                            olitemObj.SBQQ__OrderedQuantity__c += oliObj.SBQQ__OrderedQuantity__c;
                                            OrderlineItemMap.put(oliObj.Product2.productcode, olitemObj);
                                        }
                                    }
            lstOrderLI = OrderlineItemMap.values();
            
            if(lstOrderLI != NULL) {
                AddDynamicRows(lstOrderLI);
            }
        } 
        
    }
    
    public void AddDynamicRows(OrderItem[] lstOrderLI) {
        InvestmentDetailsClass clsObject;
        for(Integer X=0; X < lstOrderLI.size(); X++) {
            clsObject = new InvestmentDetailsClass();
            clsObject.QUOTE_HEADER_ID= lstOrderLI[X].Order.qtc_Quote_Header_ID__c;
            clsObject.SUBSCRIPTION_TYPE = 'Essentials';//lstOrderLI[X].Order.qtc_PO_Number__c;
            clsObject.SOLD_TO_CUST_ID= lstOrderLI[X].Order.qtc_Master_Customer_Number__c;
            clsObject.BILL_TO_CUST_ID= lstOrderLI[X].Order.qtc_Available_Bill_To__c;
            clsObject.SHIP_TO_CUST_ID= lstOrderLI[X].Order.qtc_Available_Ship_To__c;
            clsObject.DELIVER_TO_CUST_ID= lstOrderLI[X].Order.qtc_Available_Final_Installation__c;
            clsObject.PAYMENT_TERM=lstOrderLI[X].Order.SBQQ__PaymentTerm__c; // changing from passing static value to dynamic value form order. 
            clsObject.PO_REF= '0' ;
            clsObject.Order_type= lstOrderLI[X].Order.qtc_order_type__c;
            clsObject.QTY = String.valueOf(lstOrderLI[X].SBQQ__OrderedQuantity__c); 
            
            clsObject.PG_GROUP_LINE_NO = lstOrderLI[X].qtc_Product_Group_ERP_Line_No__c;
            clsObject.BUNDLE_NAME= lstOrderLI[X].qtc_Bundle_Name__c;            
            clsObject.IDENTIFIER= lstOrderLI[X].Product2.productcode;            
            clsObject.DESCR = lstOrderLI[X].qtc_Product_Description__c;
            clsObject.HARDWARE_ROLE= lstOrderLI[X].qtc_Hardware_Role__c;
            
            
            clsObject.SW_START_DATE= dateString(lstOrderLI[X].qtc_SW_Start_Date__c);
            DateTime swEndDate = lstOrderLI[X].qtc_SW_End_Date__c;
            if(lstOrderLI[X].qtc_SW_Start_Date__c!=null && swEndDate==null){
                swEndDate = lstOrderLI[X].qtc_SW_Start_Date__c.addYears(10);
            }
            clsObject.SW_END_DATE= dateString(swEndDate);
            
            clsObject.ENTITLE_START_DATE= dateString(lstOrderLI[X].qtc_Entitlement_Start_Date__c);
            DateTime entEndDate = lstOrderLI[X].qtc_Entitlement_End_Date__c;
            if(lstOrderLI[X].qtc_Entitlement_Start_Date__c!=null && entEndDate==null){
                entEndDate = lstOrderLI[X].qtc_Entitlement_Start_Date__c.addYears(10);
            }
            clsObject.ENTITLE_END_DATE= dateString(entEndDate);
            
            clsObject.SW_KEY = lstOrderLI[X].Order.SBQQ__Quote__r.qtc_New_Aloha_Key_Number__c; 
            
            clsObject.TEXT254= 'Please assign key to Partner MCN:'+ lstOrderLI[X].Order.qtc_Master_Customer_Number__c+' and activate key '+lstOrderLI[X].Order.qtc_New_Aloha_Key_Number__c;        
            clsObject.NOTE_TYPE= 'Invoice';
            
            
            // Adding static values
            clsObject.INTFC_ID= '1';
            clsObject.INTFC_LINE_NUM= 'CONTRACT';
            clsObject.TRANS_TYPE_BI= '24';
            clsObject.TRANS_TYPE_BI_SEQ= '';
            clsObject.BUSINESS_UNIT= '';
            clsObject.SOLD_TO_ADDR_NUM= '';
            clsObject.ADDRESS_SEQ_NUM= '';
            clsObject.SHIP_TO_ADDR_NUM='';
            clsObject.BILL_TYPE_ID= '';
            clsObject.PO_DATE= String.isBlank(dateString(lstOrderLI[X].Order.PoDate))?dateString(system.now()):dateString(lstOrderLI[X].Order.PoDate);//Asked by Paula:NA_AGILE-315 
            
            clsObject.REFERENCE_ORDER_NUMBER= '';
            clsObject.LINE_SEQ_NUM= '';        
            clsObject.BI_CURRENCY_CD= '';
             
            clsObject.UNIT_AMT = '0';//String.valueOf(lstOrderLI[X].UnitPrice);//Asked by Paula:NA_AGILE-315 
            clsObject.ANNUAL_NET_PRICE='';
            
            clsObject.FROM_DT='';
            clsObject.TO_DT='';
            clsObject.NOTES_SEQ_NUM= '';        
            clsObject.INTERNAL_FLAG= '';         
            clsObject.BILL_SOURCE_ID= '';
            clsObject.BILLING_FREQUENCY= '';
            clsObject.BILL_CYCLE_ID= '';
            clsObject.PYMNT_TERMS_CD= '';
            clsObject.ORDER_GRP='';
            clsObject.BILL_BY_ID= '';
            clsObject.VANTATIVE_CASE_ID= '';
            clsObject.RMA_ID= ''; 
          
            clsObject.MASTER_QUOTE_NUMBER = lstOrderLI[X].Order.qtc_Master_Quote_Number__c;
            clsObject.FREIGHT_METHOD=lstOrderLI[X].Order.qtc_Freight_Method__c;
            clsObject.CONTRACTED_FREIGHT_AMOUNT=lstOrderLI[X].Order.qtc_Contracted_Freight_Amount__c;             
            clsObject.REQUESTED_ARRIVAL_DATE=dateString(lstOrderLI[X].Order.qtc_Requested_Delivery_Date__c);
            clsObject.SHIP_INSTRUCTIONS=String.isBlank(lstOrderLI[X].Order.qtc_Shipping_Instructions__c)?'2 Day Shipping - Essentials':lstOrderLI[X].Order.qtc_Shipping_Instructions__c;//lstOrderLI[X].Order.qtc_Shipping_Instructions__c; Asked by paula NA_AGILE-315
            clsObject.SHIPPING_METHOD	=lstOrderLI[X].Order.qtc_Shipping_Method__c;
            clsObject.INVOICE_TRIGGER = lstOrderLI[X].Order.qtc_Invoice_Trigger__c;
            clsObject.OPPORTUNITY_NUMBER = lstOrderLI[X].Order.qtc_Opportunity_Number__c;
            clsObject.APPROVED_EXPLANATION = lstOrderLI[X].Order.qtc_Approved_Explanation__c;
            clsObject.AUTO_SUBMIT = lstOrderLI[X].Order.qtc_Auto_Submit__c;
            
            clsObject.INTMED_SHIP_ID='';   
            
            
            //Add record to list
            InvestmentDetails.add(clsObject);
        }
    }
    
    private string dateString(Datetime dt) {
        if(dt!=null){
            
            String myDatetime;
            string day;
            string month;
            string year;
            integer i;
      //      myDatetime = dt;
      //      i = myDatetime.month();
myDatetime = String.valueOfGmt(dt);
string[] dttime = myDatetime.split('-');
year = dttime[0];
i = Integer.valueOf(dttime[1]);//month
day = dttime[2].split(' ')[0];
            if(i==1)
            {
                month = 'JAN';
            }
            else if(i==2)
            {
                month = 'FEB';
            }
            else if(i==3){
                month = 'MAR';
            }
            else if(i==4){
                month = 'APR';
            }
            else if(i==5){
                month = 'MAY';
            }
            else if(i==6){
                month = 'JUN';
            }
            else if(i==7){
                month = 'JUL';
            }
            else if(i==8){
                month = 'AUG';
            }
            else if(i==9){
                month = 'SEP';
            }
            else if(i==10){
                month = 'OCT';
            }
            else if(i==11){
                month = 'NOV';
            }
            else if(i==12){
                month = 'DEC';
            }
            
        //    day = string.valueOf(myDatetime.day());
            system.debug('@@@day' +day);
         //   if(day.length()==1)
          //  {
           //     day = '0' + day;
            //}
         //   year = string.valueOf(myDatetime.year());
            system.debug(day+'-'+month+'-'+year);
            return (day+'-'+month+'-'+year);
        } Else {
            return '';
        }
    }
}