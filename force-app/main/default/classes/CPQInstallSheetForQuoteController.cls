/************************************** 
  Author ...............: Suraj Parihar
  Created Date..........: 13-APR-2021
  Modified Date.........: 13-APR-2021
  Description...........: Controller for vf "InstallSheetForOrders" which includes the productId and Quantity for the related Quote in the form of excel sheet. 
***************************************/
public class CPQInstallSheetForQuoteController {
   
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
        public String quantity {get;set;}
        public string Name{get;set;}
        public string ProductID{get;set;}
        public string ProductFamily{get;set;}
        public String PriorQuantity{get;set;}
        public String EffectiveQuantity{get;set;}
        public String NewAlohaKey{get;set;}
        public String ExistingAlohaKey{get;set;}
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
    public CPQInstallSheetForQuoteController() {        
        //Get All querystring parameters
        QuoteId = ApexPages.currentPage().getParameters().get('id');
        List<SBQQ__QuoteLine__c> lstQli; 

        //Get product details
        if(QuoteId != null){
            Map<string, SBQQ__QuoteLine__c> lstQLIMap = new Map<string, SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c obj : [SELECT  Id, SBQQ__Quantity__c, SBQQ__Product__r.Family, SBQQ__Description__c, SBQQ__Product__r.Productcode, SBQQ__EffectiveQuantity__c, SBQQ__PriorQuantity__c, SBQQ__Quote__r.qtc_New_Aloha_Key_Number__c,  SBQQ__Quote__r.qtc_Existing_Aloha_Key_Number__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.id =:QuoteId AND SBQQ__Product__r.product_type__c in ('PID')
                                          AND  Revenue_Type__c != 'TS']){
                                         if(!lstQLIMap.containsKey(obj.SBQQ__Product__r.Productcode)){
                                             lstQLIMap.put(obj.SBQQ__Product__r.Productcode,obj);                                             
                                         }else{
                                             SBQQ__QuoteLine__c qliObj = lstQLIMap.get(obj.SBQQ__Product__r.Productcode);
                                             qliObj.SBQQ__Quantity__c += obj.SBQQ__Quantity__c;
                                             lstQLIMap.put(obj.SBQQ__Product__r.Productcode, qliObj);                                             
                                         } 
                                     }
            lstQli = lstQLIMap.values(); 
        }
    
        if(lstQli != null){ 
            addDynamicRows(lstQli);
        }        
        
    }
    public void addDynamicRows(List<SBQQ__QuoteLine__c> lstQli) {
        ProductDetailsClass clsObject;
        
        for(SBQQ__QuoteLine__c ql : lstQli){
            clsObject = new ProductDetailsClass();            
            clsObject.ProductID = String.valueOf(ql.SBQQ__Product__r.Productcode);            
            clsObject.Name = String.valueOf(ql.SBQQ__Description__c);
            clsObject.quantity = String.valueOf(ql.SBQQ__Quantity__c);
            clsObject.ProductFamily = String.valueOf(ql.SBQQ__Product__r.Family);
            clsObject.EffectiveQuantity = String.valueOf(ql.SBQQ__EffectiveQuantity__c);
            clsObject.PriorQuantity = String.valueOf(ql.SBQQ__PriorQuantity__c);
            clsObject.NewAlohaKey = String.valueOf(ql.SBQQ__Quote__r.qtc_New_Aloha_Key_Number__c);
            clsObject.ExistingAlohaKey = String.valueOf(ql.SBQQ__Quote__r.qtc_Existing_Aloha_Key_Number__c);
            productDetails.add(clsObject);
        } 
    }
}