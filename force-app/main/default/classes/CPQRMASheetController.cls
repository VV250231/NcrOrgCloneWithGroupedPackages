/************************************** 
Author ...............: Suraj Parihar
Created Date..........: 31-DEC-2021
Modified Date.........: 31-DEC-2021
Description...........: Controller for vf "CPQGenerateRMASheet" which includes the productId and Quantity for the RMA Quote in the form of excel sheet. 
***************************************/
public class CPQRMASheetController {
    
    //xml doctype
    public String xlsHeader{
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
        set;
    } 
    
    //Product Details Wrapper class 
    public class ProductDetailsClass {        
        public String Contact {get;set;}
        public string Requester{get;set;}
        public String createDate{get;set;}
        public string Client{get;set;}
        public String mcn {get;set;}
        public String site_name {get;set;}
        public String use_at {get;set;}
        public String ERP_Order {get;set;}
        public String ERP_Invoice {get;set;}
        public String Client_PO {get;set;}
        public String Invoice_Date {get;set;}
        public String NCR_PID {get;set;}
        public String Description {get;set;}
        public String Qty {get;set;}
        public String Unit_Price {get;set;}
        public String to_Credit {get;set;}
    }    
    public List<ProductDetailsClass> productDetails = new List<ProductDetailsClass>();    
    public void setproductDetails(List<ProductDetailsClass> setterList){
        this.productDetails.addAll(setterList);
    }
    
    public List<ProductDetailsClass> getproductDetails(){ 
        return this.productDetails;
    }    
    
    string QuoteId = '';
    //Default Constructor
    public CPQRMASheetController() {        
        //Get All querystring parameters
        QuoteId = ApexPages.currentPage().getParameters().get('id');
        List<qtc_FulfillmentOrderProduct__c> lstQli; 
        
        //Get product details
        if(QuoteId != null){
            Map<string, qtc_FulfillmentOrderProduct__c> lstQLIMap = new Map<string, qtc_FulfillmentOrderProduct__c>();
            for(qtc_FulfillmentOrderProduct__c obj : [select id,qtc_Quantity__c,qtc_Product__r.Description,qtc_Product__r.ProductCode,qtc_FulfillmentOrder__r.qtc_Quote__r.qtc_Quote_Name__c,qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__SalesRep__r.name,
                                                      qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__PrimaryContact__r.name,qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__Account__r.Master_Customer_Number__c,qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__Account__r.name,qtc_FulfillmentOrder__r.qtc_Quote__r.CreatedDate,qtc_FulfillmentOrder__r.qtc_Quote__r.name, 
                                                      qtc_FulfillmentOrder__r.qtc_Quote__r.Deliver_To_Site__r.name,qtc_FulfillmentOrder__r.qtc_Quote__r.Deliver_To_Site__r.Site_Number__c,qtc_FulfillmentOrder__r.qtc_Quote__r.qtc_PO_Number__c,qtc_FulfillmentOrder__r.qtc_RMA_ORDER_NUMBER__c from qtc_FulfillmentOrderProduct__c where qtc_FulfillmentOrder__c =:QuoteId AND qtc_Quantity__c< 0 AND qtc_Product__r.qtc_Exclude_from_ERP__c =false ]){
                                                          lstQLIMap.put(obj.qtc_Product__r.ProductCode,obj); 
                                                      }
            lstQli = lstQLIMap.values(); 
        }
        
        if(lstQli != null){ 
            addDynamicRows(lstQli);
        }        
        
    }
    public void addDynamicRows(List<qtc_FulfillmentOrderProduct__c> lstQli) {
        ProductDetailsClass clsObject;
        for(qtc_FulfillmentOrderProduct__c ql : lstQli){
            clsObject = new ProductDetailsClass();            
            clsObject.Contact = ql.qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__PrimaryContact__r.name;
            clsObject.Requester= ql.qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__SalesRep__r.name;
            clsObject.createDate= String.valueOf(ql.qtc_FulfillmentOrder__r.qtc_Quote__r.CreatedDate);
            clsObject.Client= ql.qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__Account__r.name;
            clsObject.mcn = ql.qtc_FulfillmentOrder__r.qtc_Quote__r.SBQQ__Account__r.Master_Customer_Number__c;
            clsObject.site_name = ql.qtc_FulfillmentOrder__r.qtc_Quote__r.Deliver_To_Site__r.name;
            clsObject.use_at = ql.qtc_FulfillmentOrder__r.qtc_Quote__r.Deliver_To_Site__r.Site_Number__c;
            clsObject.ERP_Order = ql.qtc_FulfillmentOrder__r.qtc_RMA_ORDER_NUMBER__c;
            clsObject.ERP_Invoice ='';
            clsObject.Client_PO = ql.qtc_FulfillmentOrder__r.qtc_Quote__r.qtc_PO_Number__c;
            clsObject.Invoice_Date = '';
            if(ql.qtc_Product__r.ProductCode.contains('H400')){
                clsObject.NCR_PID = String.valueOf(ql.qtc_Product__r.ProductCode);}
            else{
                clsObject.NCR_PID = String.valueOf(ql.qtc_Product__r.ProductCode)+'-PZ';  }
            clsObject.Description = ql.qtc_Product__r.Description;
            clsObject.Qty = String.valueOf(-ql.qtc_Quantity__c);
            clsObject.Unit_Price = '';
            clsObject.to_Credit = '';
            productDetails.add(clsObject);
        } 
    }
}