public class DailyNonERPOrderTriggerHandler{ 
     
   // Get USD exchange rate from multicurrency table
   public Map<String,Decimal> CurrencyConversionRateMap = NSCCommonInfoUtil.getInstance().CollectLocaleConversionRate();
    
    
   List<Period> periodList = [Select Number, type, FullyQualifiedLabel, StartDate, EndDate From Period Where StartDate =  THIS_FISCAL_YEAR AND (TYPE='Week' OR TYPE='Month')];
           
   
   public void ConvertLocaleAmoutToUsd(List<Daily_Non_ERP_Order__c> ListOrderObj){
        Set<String> uniqueOrgCodes = new Set<String>();
        Map<String, String> salesOrgCodeAndIdMap = new Map<String, String>();
         
        for(Daily_Non_ERP_Order__c OrderObj : ListOrderObj) {
            
            if(String.isNotBlank(OrderObj.Input_Currency__c)) {
                OrderObj.CurrencyISOCode = OrderObj.Input_Currency__c;
                 
                if(String.isNotBlank(OrderObj.Input_Total_Order_Amount__c)) {
                    OrderObj.Total_Order_Amount_Local__c = Decimal.valueOf(OrderObj.Input_Total_Order_Amount__c.replaceAll(',',''));
                    OrderObj.Total_Order_Amount_USD__c = OrderObj.Total_Order_Amount_Local__c/CurrencyConversionRateMap.get(OrderObj.Input_Currency__c);
                }
                
                if(String.isNotBlank(OrderObj.Input_HW_Amount__c)) {
                    OrderObj.HW_Amount_Local__c = Decimal.valueOf(OrderObj.Input_HW_Amount__c.replaceAll(',',''));
                    OrderObj.HW_Amount_USD__c = OrderObj.HW_Amount_Local__c /CurrencyConversionRateMap.get(OrderObj.Input_Currency__c);
                }
                
                if(String.isNotBlank(OrderObj.Input_SW_Amount__c)) {
                    OrderObj.SW_Amount_in_Local__c = Decimal.valueOf(OrderObj.Input_SW_Amount__c.replaceAll(',',''));
                    OrderObj.SW_Amount_in_USD__c = OrderObj.SW_Amount_in_Local__c/CurrencyConversionRateMap.get(OrderObj.Input_Currency__c);
                }
                
                 
                if(String.isNotBlank(OrderObj.Input_PS_Amount__c)) {
                    OrderObj.PS_Amount_Local__c = Decimal.valueOf(OrderObj.Input_PS_Amount__c.replaceAll(',',''));
                    OrderObj.PS_Amount_USD__c = OrderObj.PS_Amount_Local__c/CurrencyConversionRateMap.get(OrderObj.Input_Currency__c);
                }
                
                if(String.isNotBlank(OrderObj.Input_TS_Amount__c)) {
                    OrderObj.TS_Amount_in_Local__c = Decimal.valueOf(OrderObj.Input_TS_Amount__c.replaceAll(',',''));
                    OrderObj.TS_Amount_in_USD__c = OrderObj.TS_Amount_in_Local__c/CurrencyConversionRateMap.get(OrderObj.Input_Currency__c);
                }

            }
            
            if(String.isNotBlank(OrderObj.Input_Sales_Org_Code__c)) uniqueOrgCodes.add(OrderObj.Input_Sales_Org_Code__c); 
            
            if (OrderObj.Order_Date__c != NULL) {
                for(Period prd : periodList) {
                    if(prd.TYPE == 'Week' && prd.StartDate <= OrderObj.Order_Date__c && prd.EndDate >= OrderObj.Order_Date__c) {
                        OrderObj.Week_Start_Date__c = prd.StartDate;   
                        OrderObj.Week_End_Date__c = prd.EndDate;   
                    }
                    
                    if(prd.TYPE == 'Month' && prd.StartDate <= OrderObj.Order_Date__c && prd.EndDate >= OrderObj.Order_Date__c) {
                        OrderObj.Month_Start_Date__c = prd.StartDate;   
                        OrderObj.Month_End_Date__c = prd.EndDate;  
                    }
                }
            }
           
        }
        
        if (!uniqueOrgCodes.isEmpty()) {
            for(Sales_Org_Temp__c temp: [SELECT Id, Sales_Org_Code__c FROM Sales_Org_Temp__c WHERE Sales_Org_Code__c IN :uniqueOrgCodes]) {
                salesOrgCodeAndIdMap.put(temp.Sales_Org_Code__c, temp.Id);
            }
        }
        
        for(Daily_Non_ERP_Order__c OrderObj : ListOrderObj){
            
            OrderObj.Sales_Org_Lookup__c =  salesOrgCodeAndIdMap.containsKey(OrderObj.Input_Sales_Org_Code__c) ? salesOrgCodeAndIdMap.get(OrderObj.Input_Sales_Org_Code__c) : null;      
        }
    
   }

    
}