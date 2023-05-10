public class NonERPOrderTriggerHandler{ 
     
   // Get USD exchange rate from multicurrency table
   public Map<String,Decimal> CurrencyConversionRateMap = NSCCommonInfoUtil.getInstance().CollectLocaleConversionRate();
   
   
   public void ConvertLocaleAmoutToUsd(List<Non_ERP_Order__c> ListOrderObj){

       Map<Id,String> AllOrderMap = new Map<Id,String>();
       Map<Id,String> OrderMaptoUpdate = new Map<Id,String>();
       List<Non_ERP_Order__c> SetOfNonERPOrdertoDelete = new List<Non_ERP_Order__c>();
       Set<String> SetOfNonERPOrder = new Set<String>();
       Map<String,Master_Non_ERP__c> MapForMasterNonErp =  new Map<String,Master_Non_ERP__c>();
       List<Master_Non_ERP__c> UpsertListforMaster = new list<Master_Non_ERP__c>();
       set<String> MasterFoundInsystem = new Set<String>();
       for(Non_ERP_Order__c OrderObj : ListOrderObj){
       

              String CustomExceptionMessage='';
              
              try
              {
                  boolean triggerException = false;
                  
                  if(String.isBlank(OrderObj.Currency__c) || String.isEmpty(OrderObj.Currency__c)){
                       System.debug('>>>>'+OrderObj.Currency__c);
                       triggerException = true;
                       CustomExceptionMessage=CustomExceptionMessage+'CURRENCY, ';
                  }
                  
                  if(String.isBlank(OrderObj.Customer_Name__c) || String.IsEmpty(OrderObj.Customer_Name__c))
                  {
                      triggerException = true;
                      CustomExceptionMessage=CustomExceptionMessage +'CUSTOMER NAME, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if(OrderObj.Date__c == null){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'MM/DD/YYYY, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
              
              
                  if(String.isBlank( OrderObj.Customer_Country_Code__c) || String.IsEmpty(OrderObj.Customer_Country_Code__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'CUSTOMER COUNTRY CODE, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if(String.isBlank( OrderObj.Master_Customer_Number__c) || String.IsEmpty(OrderObj.Master_Customer_Number__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'MASTER CUSTOMER NUMBER, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(String.isBlank( OrderObj.Order_Number__c) || String.IsEmpty(OrderObj.Order_Number__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'ORDER NUMBER, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(String.isBlank( OrderObj.Salesperson_Global_ID__c) || String.IsEmpty(OrderObj.Salesperson_Global_ID__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'SALESPERSON GLOBAL ID, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(String.isBlank( OrderObj.Transaction_Source__c) || String.IsEmpty(OrderObj.Transaction_Source__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'TRANSACTION SOURCE,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if((String.isBlank( OrderObj.HW_Amount__c) || String.IsEmpty(OrderObj.HW_Amount__c))  && (OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY')){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'HW Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if((String.isBlank( OrderObj.SW_Amount__c) || String.IsEmpty(OrderObj.SW_Amount__c))  && (OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY')){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'SW Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if((String.isBlank( OrderObj.PS_Amount__c) || String.IsEmpty(OrderObj.PS_Amount__c))  && (OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY')){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'PS Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if((String.isBlank( OrderObj.TS_Amount__c) || String.IsEmpty(OrderObj.TS_Amount__c))  && (OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY')){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'TS Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if((String.isBlank( OrderObj.Total_Order_Amount__c) || String.IsEmpty(OrderObj.Total_Order_Amount__c))  && (OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY')){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'Total Order Amount';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  
                  
                  if(triggerException){
                      throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  
                  String UniqueMaster = OrderObj.Customer_Country_Code__c+OrderObj.Order_Number__c;
                  
                  MasterFoundInsystem.add(UniqueMaster);
                  
                  if((!MapForMasterNonErp.ContainsKey(UniqueMaster)) && (OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY')){
                  
                      Master_Non_ERP__c masterObj = new Master_Non_ERP__c();
                      masterObj.name=UniqueMaster;
                      masterObj.Order_Number__c=OrderObj.Order_Number__c;
                      masterObj.Customer_Country_Code__c=OrderObj.Customer_Country_Code__c;
                      masterObj.Master_Customer_Number__c=OrderObj.Master_Customer_Number__c;
                      masterObj.Enterprise_ID__c=OrderObj.Enterprise_ID__c;
                      masterObj.Order_Number__c =OrderObj.Order_Number__c;
                      masterObj.Transaction_Source__c=OrderObj.Transaction_Source__c;
                      masterObj.Customer_Name__c=OrderObj.Customer_Name__c;
                      masterObj.Customer_Country_Code__c=OrderObj.Customer_Country_Code__c;
                      masterObj.HW_Order_Local_Amount__c= Decimal.valueOf(OrderObj.HW_Amount__c.replaceAll(',',''));
                      masterObj.HW_Order_Amount__c = masterObj.HW_Order_Local_Amount__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                      
                      masterObj.Total_Order_Local_Amount__c= Decimal.valueOf(OrderObj.Total_Order_Amount__c.replaceAll(',',''));
                      masterObj.Total_Order_Amount__c= masterObj.Total_Order_Local_Amount__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                       
                      masterObj.TS_Order_Local_Amount__c= Decimal.valueOf(OrderObj.TS_Amount__c.replaceAll(',',''));
                      masterObj.TS_Order_Amount__c= masterObj.TS_Order_Local_Amount__c/CurrencyConversionRateMap.get(OrderObj.Currency__c); 
                      
                      masterObj.PS_Order_Local_Amount__c= Decimal.valueOf(OrderObj.PS_Amount__c.replaceAll(',',''));
                      masterObj.PS_Order_Amount__c= masterObj.PS_Order_Local_Amount__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                      
                      masterObj.SW_Order_Local_Amount__c= Decimal.valueOf(OrderObj.SW_Amount__c.replaceAll(',',''));
                      masterObj.SW_Order_Amount__c= masterObj.SW_Order_Local_Amount__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                      
                      MapForMasterNonErp.put(UniqueMaster,masterObj);
                  }
                    
                  
                  /*OrderObj.Amount_in_Local_Currency__c= Decimal.valueOf(OrderObj.Amount_in_Local__c.replaceAll(',',''));
                  OrderObj.Amount_in_USD__c = OrderObj.Amount_in_Local_Currency__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                  OrderObj.CurrencyISOCode = OrderObj.Currency__c;*/
                  
                  
                  
              }
             
              catch (NonERPBlankFieldException e)
              {
                  OrderObj.addError(string.format(system.label.NonERPTrHd2 , new list<string>{CustomExceptionMessage})) ; //CustomExceptionMessage+' '+': Fields can\'t be blank 
              }
              
               catch (Exception e)
              {
                OrderObj.addError(system.label.NonERPTrHd1);  //INVALID ENTITLED AMOUNT
              }
              
       }
       
       for(Master_Non_ERP__c  NewObj : [Select id,name from Master_Non_ERP__c  where Name IN : MapForMasterNonErp.KeySet()]){
       
           MapForMasterNonErp.get(NewObj.Name).Id = NewObj.id;
           
       }
       
       
       if(MapForMasterNonErp.values().size() > 0){
           upsert  MapForMasterNonErp.values();
       }
       
       
       for(Non_ERP_Order__c OrderObj : ListOrderObj ){
           String CustomExceptionMessage='';
           String s = '';
           String UniqueMaster = OrderObj.Customer_Country_Code__c+OrderObj.Order_Number__c;
           
           if(OrderObj.Date__c != null){
                      s = OrderObj.Salesperson_Global_ID__c+String.Valueof(OrderObj.Date__c.Month())+String.Valueof(OrderObj.Date__c.Day())+String.Valueof(OrderObj.Date__c.Year())+OrderObj.Customer_Country_Code__c+OrderObj.Order_Number__c;
           }
           
           if(s != null)
              OrderObj.UniqueExterId__c = s;
              
              
            
            if( s != null ){
                SetOfNonERPOrder.add(s);
            } 
                  
                try{
                   
                    boolean triggerException = false;
                  
                  
                  
                  if(String.isBlank(OrderObj.Currency__c) || String.isEmpty(OrderObj.Currency__c)){
                       System.debug('>>>>'+OrderObj.Currency__c);
                       triggerException = true;
                       CustomExceptionMessage=CustomExceptionMessage+'CURRENCY, ';
                  }
                  
                  if(String.isBlank(OrderObj.Customer_Name__c) || String.IsEmpty(OrderObj.Customer_Name__c))
                  {
                      triggerException = true;
                      CustomExceptionMessage=CustomExceptionMessage +'CUSTOMER NAME, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if(OrderObj.Date__c == null){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'MM/DD/YYYY, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
              
              
                  if(String.isBlank( OrderObj.Customer_Country_Code__c) || String.IsEmpty(OrderObj.Customer_Country_Code__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'CUSTOMER COUNTRY CODE, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if(String.isBlank( OrderObj.Master_Customer_Number__c) || String.IsEmpty(OrderObj.Master_Customer_Number__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'MASTER CUSTOMER NUMBER, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(String.isBlank( OrderObj.Order_Number__c) || String.IsEmpty(OrderObj.Order_Number__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'ORDER NUMBER, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(String.isBlank( OrderObj.Salesperson_Global_ID__c) || String.IsEmpty(OrderObj.Salesperson_Global_ID__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'SALESPERSON GLOBAL ID, ';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(String.isBlank( OrderObj.Transaction_Source__c) || String.IsEmpty(OrderObj.Transaction_Source__c)){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'TRANSACTION SOURCE,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if((String.isBlank( OrderObj.HW_Amount__c) || String.IsEmpty(OrderObj.HW_Amount__c)) && ((OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY'))){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'HW Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if((String.isBlank( OrderObj.SW_Amount__c) || String.IsEmpty(OrderObj.SW_Amount__c)) && ((OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY'))){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'SW Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  if((String.isBlank( OrderObj.PS_Amount__c) || String.IsEmpty(OrderObj.PS_Amount__c)) && ((OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY'))){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'PS Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if((String.isBlank( OrderObj.TS_Amount__c) || String.IsEmpty(OrderObj.TS_Amount__c)) && ((OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY'))){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'TS Amount,';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if((String.isBlank( OrderObj.Total_Order_Amount__c) || String.IsEmpty(OrderObj.Total_Order_Amount__c)) && ((OrderObj.Transaction_Source__c.toUpperCase() != 'HOSPITALITY'))){
                      triggerException = true;
                      CustomExceptionMessage = CustomExceptionMessage + 'Total Order Amount';
                      //throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                  
                  
                  if(triggerException){
                      throw new NonERPBlankFieldException ('This is my Custom Exception');
                  }
                   
                       
                  OrderObj.Amount_in_Local_Currency__c= Decimal.valueOf(OrderObj.Amount_in_Local__c.replaceAll(',',''));
                  OrderObj.Amount_in_USD__c = OrderObj.Amount_in_Local_Currency__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                  OrderObj.CurrencyISOCode = OrderObj.Currency__c;
                  
                  if(String.isNotBlank(OrderObj.HW_Credit_Amount__c)) {
                      OrderObj.HW_Credit_Amount_Local__c = Decimal.valueOf(OrderObj.HW_Credit_Amount__c.replaceAll(',',''));
                      OrderObj.HW_Credit_Amount_USD__c = OrderObj.HW_Credit_Amount_Local__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                  }
                   
                  if(String.isNotBlank(OrderObj.SW_Credit_Amount__c)) {
                      OrderObj.SW_Credit_Amount_Local__c = Decimal.valueOf(OrderObj.SW_Credit_Amount__c.replaceAll(',',''));
                      OrderObj.SW_Credit_Amount_USD__c = OrderObj.SW_Credit_Amount_Local__c /CurrencyConversionRateMap.get(OrderObj.Currency__c);
                  }
                  
                  if(String.isNotBlank(OrderObj.PS_Credit_Amount__c)) {
                      OrderObj.PS_Credit_Amount_Local__c = Decimal.valueOf(OrderObj.PS_Credit_Amount__c.replaceAll(',',''));
                      OrderObj.PS_Credit_Amount_USD__c = OrderObj.PS_Credit_Amount_Local__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                  }
                  
                  if(String.isNotBlank(OrderObj.TS_Credit_Amount__c)) {
                      OrderObj.TS_Credit_Amount_Local__c = Decimal.valueOf(OrderObj.TS_Credit_Amount__c.replaceAll(',',''));
                      OrderObj.TS_Credit_Amount_USD__c = OrderObj.TS_Credit_Amount_Local__c/CurrencyConversionRateMap.get(OrderObj.Currency__c);
                  }
                  
                  if(MapForMasterNonErp.ContainsKey(UniqueMaster))
                  OrderObj.Master_Non_ERP_Order__c = MapForMasterNonErp.get(UniqueMaster).Id;
                  }
                  
                  catch (NonERPBlankFieldException e)
              {
                  OrderObj.addError(string.format(system.label.NonERPTrHd2 , new list<string>{CustomExceptionMessage})) ; //CustomExceptionMessage+' '+': Fields can\'t be blank
              }
              
               catch (Exception e)
              {
                OrderObj.addError(system.label.NonERPTrHd1); //INVALID ENTITLED AMOUNT
              }
       }
       
       
       for(Non_ERP_Order__c obj : [select id,name,UniqueExterId__c from Non_ERP_Order__c where UniqueExterId__c IN : SetOfNonERPOrder]){
            
            SetOfNonERPOrdertoDelete.add(obj);
        } 
        
        if(SetOfNonERPOrdertoDelete.size() > 0 ){
            Delete SetOfNonERPOrdertoDelete;
        }
       
   } 
    

    
}