public class EDBI_Order_Trigger_Handler {
 public static void PopulateQuBYQuote(List<EDBI_Order__c> newQuBYQuote, Map<ID,EDBI_Order__c> oldMapQuBYQuote)
 {
     
     Map<String, String> qubyQuoteNbrAndIdMap = new Map<String, String>();
    Map<String, String> salesOrgCodeAndIdMap = new Map<String, String>();
    
    Map<String, String> orderId_SalesOrgMap = new Map<String, String>();
    Map<String, String> orderId_QuoteNumberMap = new Map<String, String>();
    Set<String> OppNumSet = new Set<String>();
    Set<String> MCNWithCountyCodeSet= new Set<String>();
    Map<String,Id> MCNCountryCodeWithAccountIdMap = new Map<String,Id>();
    
    if (Trigger.isBefore)  {
        
        if (Trigger.isInsert) {
            for(EDBI_Order__c order : newQuBYQuote) {
                if(String.isNotBlank(order.Quote_Number__c)) orderId_QuoteNumberMap.put(order.Id, order.Quote_Number__c);          
                if(String.isNotBlank(order.Sales_Org_Code__c)) orderId_SalesOrgMap.put(order.Id, order.Sales_Org_Code__c);  
                if(String.isNotBlank(order.NSC_Opportunity_Number__c)) OppNumSet.add(order.NSC_Opportunity_Number__c);    
                if(String.isNotBlank(order.Country_Code_With_Master_Customer_Nbr__c)) MCNWithCountyCodeSet.add(order.Country_Code_With_Master_Customer_Nbr__c); 
            }    
        }
        
        if (Trigger.isUpdate) {
            for(EDBI_Order__c order : newQuBYQuote) {
                EDBI_Order__c oldOrder = oldMapQuBYQuote.get(order.Id);
                
                if(String.isNotBlank(order.Quote_Number__c)) {
                    orderId_QuoteNumberMap.put(order.Id, order.Quote_Number__c);  
                } else {
                    order.All_QuBy_Quote__c  = null;
                }
                
                if(String.isNotBlank(order.Sales_Org_Code__c)) {
                    orderId_SalesOrgMap.put(order.Id, order.Sales_Org_Code__c);    
                } else {
                    order.Sales_Org__c = null;
                }
                
                if(String.isNotBlank(order.NSC_Opportunity_Number__c)) OppNumSet.add(order.NSC_Opportunity_Number__c); 
                if(String.isNotBlank(order.Country_Code_With_Master_Customer_Nbr__c)) MCNWithCountyCodeSet.add(order.Country_Code_With_Master_Customer_Nbr__c); 
            }
        }
        
        if (!orderId_QuoteNumberMap.isEmpty()) { 
            for(QuBy_Detail__c quote : [SELECT Id, Quote_Number__c FROM QuBy_Detail__c WHERE Quote_Number__c IN :orderId_QuoteNumberMap.values()]) {
                qubyQuoteNbrAndIdMap.put(quote.Quote_Number__c , quote.Id);       
            }
        }
        
        if (!orderId_SalesOrgMap.isEmpty()) {
            for(Sales_Org_Temp__c temp: [SELECT Id, Sales_Org_Code__c FROM Sales_Org_Temp__c WHERE Sales_Org_Code__c IN :orderId_SalesOrgMap.values()]) {
                salesOrgCodeAndIdMap.put(temp.Sales_Org_Code__c, temp.Id);
            }
        }
         for(Account accOb:[select Country_with_Master_customer_Number__c,Id from account where Country_with_Master_customer_Number__c in:MCNWithCountyCodeSet ]){
        MCNCountryCodeWithAccountIdMap.put(accOb.Country_with_Master_customer_Number__c,accOb.Id);  
        }
        
        for (EDBI_Order__c order : newQuBYQuote) {  
            if (orderId_QuoteNumberMap.containsKey(order.Id)) {
                order.All_QuBy_Quote__c = qubyQuoteNbrAndIdMap.containsKey(order.Quote_Number__c) ? qubyQuoteNbrAndIdMap.get(order.Quote_Number__c) : null; 
                
                String NSCOppNum = ((order.All_QuBy_Quote__c != null) && (order.All_QuBy_Quote__r.Opportunity__c != null)) ? order.All_QuBy_Quote__r.Opportunity__r.Opportunity_Number__c : order.Anaplan_Opportunity_Number__c;
                
                if(String.isNotBlank(NSCOppNum)) OppNumSet.add(NSCOppNum);
            } 
            
            if (orderId_SalesOrgMap.containsKey(order.Id)) {
                order.Sales_Org__c =  salesOrgCodeAndIdMap.containsKey(order.Sales_Org_Code__c) ? salesOrgCodeAndIdMap.get(order.Sales_Org_Code__c) : null;      
            }
            if (MCNCountryCodeWithAccountIdMap.containsKey(order.Country_Code_With_Master_Customer_Nbr__c)) {
                order.Account_Lookup__c =  MCNCountryCodeWithAccountIdMap.containsKey(order.Country_Code_With_Master_Customer_Nbr__c) ? MCNCountryCodeWithAccountIdMap.get(order.Country_Code_With_Master_Customer_Nbr__c) : null;      
            }
        }  
        
        if(!OppNumSet.isEmpty()) {
            Map<String, String> oppNumIdMap = new Map<String, String>();
            for(opportunity opp : [SELECT id,Opportunity_number__C FROM opportunity WHERE Opportunity_number__C IN :OppNumSet]) {
                oppNumIdMap.put(opp.opportunity_Number__c , opp.Id);
            }
            
            for (EDBI_Order__c order : newQuBYQuote) {
                String NSCOppNum = ((order.All_QuBy_Quote__c != null) && (order.All_QuBy_Quote__r.Opportunity__c != null)) ? order.All_QuBy_Quote__r.Opportunity__r.Opportunity_Number__c : order.Anaplan_Opportunity_Number__c;
                
                if(String.isNotBlank(NSCOppNum) && oppNumIdMap.containsKey(NSCOppNum)) {
                    order.Opportunity__c = oppNumIdMap.get(NSCOppNum);
                }
            }
        }  
    }
     
 }
 public static void PopulateAllQBOppNo(List<EDBI_Order__c> newQBOppNo,Map<ID,EDBI_Order__c> oldMapQBOppNo)
 {
     if (Trigger.isBefore && Trigger.isUpdate)  
     {
          Map<string,string>quoteOppMap = new Map<string,string>();
    Set<String> NonQbOpp = new Set<String>();

    for(EDBI_Order__c  edbiO :newQBOppNo){
        if( edbiO.Anaplan_Opportunity_Number__c != null && oldMapQBOppNo.get( edbiO.id ).Anaplan_Opportunity_Number__c != edbiO.Anaplan_Opportunity_Number__c ){
            quoteOppMap.put( edbiO.Quote_Number__c,edbiO.Anaplan_Opportunity_Number__c );
        }
    }
    
    List<QuBy_Detail__c> AllQubyQuotesList = new List<QuBy_Detail__c>();
    if(quoteOppMap != null && quoteOppMap.size()>0){   
        for(QuBy_Detail__c QbDetail : [select Id,Opportunity_No__c,Quote_Number__c from QuBy_Detail__c where Quote_Number__c IN :quoteOppMap.keySet()]  ){
            QbDetail.Opportunity_No__c = quoteOppMap.get( QbDetail.Quote_Number__c );
            AllQubyQuotesList.add( QbDetail );
        }
     }
    
    if(AllQubyQuotesList != null && AllQubyQuotesList.size()>0){
        update AllQubyQuotesList;
    }  
    
    //Call the future class method
    if(quoteOppMap != null && quoteOppMap.size()>0){
        UpdateNonQubyQuoteOpp.updateOpp(quoteOppMap);
        }
    
 }
}
    
  public static void SyncEDBIWithCADDIsInsertTrigger(List<EDBI_Order__c> newEDBIOrder)  
  {
      Map<String,EDBI_Order__c> OrdNoCountryCodeWithIdMap = new Map<String,EDBI_Order__c>();
        List<Deming__c> DemingListToUpdate= new List<Deming__c>();
        
        for(EDBI_Order__c EDBIObj : newEDBIOrder){
            
            //  EDBI_Order__c oldEDBI = Trigger.oldMap.get(EDBIObj.Id);
            
            
            if(String.IsNotBlank(EDBIObj.Id) && String.isNotBlank(EDBIObj.Order_Number_with_Country_Code__c)){
                OrdNoCountryCodeWithIdMap.put(EDBIObj.Order_Number_with_Country_Code__c ,EDBIObj);
            }
            
            
            
        }
        
        
        //System.debug('!!!!'+OrdNoCountryCodeWithIdMap);
        for(Deming__c demingObj : [Select Order_Nbr_with_Country_Code__c,fua_site_name__c,fua_site_nbr__c,ship_to_site_name__c,ship_to_site_nbr__c,related_Order__C,Id from Deming__c where related_Order__C != null and Order_Nbr_with_Country_CodeExtrnal__c  IN:OrdNoCountryCodeWithIdMap.keySet()]){
            if(null == demingObj.related_Order__C ){
                if(OrdNoCountryCodeWithIdMap.ContainsKey(demingObj.Order_Nbr_with_Country_Code__c)){
                    DemingObj.Related_Order__C=OrdNoCountryCodeWithIdMap.get(demingObj.Order_Nbr_with_Country_Code__c).Id;
                    //DemingObj.Opportunity__c =OrdNoCountryCodeWithIdMap.get(demingObj.Order_Nbr_with_Country_Code__c).Opportunity__c ;
                    DemingObj.fua_site_name__c=OrdNoCountryCodeWithIdMap.get(demingObj.Order_Nbr_with_Country_Code__c).fua_site_name__c;
                    DemingObj.fua_site_nbr__c=OrdNoCountryCodeWithIdMap.get(demingObj.Order_Nbr_with_Country_Code__c).fua_site_nbr__c;
                    DemingObj.ship_to_site_name__c=OrdNoCountryCodeWithIdMap.get(demingObj.Order_Nbr_with_Country_Code__c).ship_to_site_name__c;
                    DemingObj.ship_to_site_nbr__c=OrdNoCountryCodeWithIdMap.get(demingObj.Order_Nbr_with_Country_Code__c).ship_to_site_nbr__c;
                    DemingListToUpdate.add(DemingObj);
                }
                
            }
        }
        
        
        
        if(DemingListToUpdate.size()>0)
        {
            Update DemingListToUpdate;  
        }
  }
    
     public static void SyncEDBIWithCADDIsUpdateTrigger(List<EDBI_Order__c> newEDBIOrder,Map<ID,EDBI_Order__c> oldMapEDBIOrder)  
     {
         // Set<String> OrderNumberSet = new Set<String>();
        //    Map<String,Decimal> OrderNumberWithAmountMap = new Map<String,Decimal>();
        Map<String,String> OrderNumberWithFUISiteNameMap = new Map<String,String>();
        Map<String,String> OrderNumberWitFUIsiteNbrMap = new Map<String,String>();
        Map<String,String> OrderNumberWithShipToSiteNameMap = new Map<String,String>();
        Map<String,String> OrderNumberWithShipToSiteNbrMap = new Map<String,String>();
        Map<String,String> OrderNumberWithStatusMap = new Map<String,String>();
        List<Deming__c> DemingListToUpdate= new List<Deming__c>();
        Map<String,EDBI_Order__c> OrdNoCountryCodeWithIdMap = new Map<String,EDBI_Order__c>(); 
        // Set<String> MCNWithCountyCodeSet= new Set<String>();
        
        
        System.debug('Here1');
        
        for(EDBI_Order__c EDBIObj : newEDBIOrder){
            
            
            EDBI_Order__c oldEDBI = oldMapEDBIOrder.get(EDBIObj.Id);
            //String newStatus=EDBIObj.Backlog_Orders_Status__c;
            String newStatus=EDBIObj.Order_Status__c;
            String newFUISiteName =EDBIObj.fua_site_name__c;
            String newFUIsiteNbr =EDBIObj.fua_site_nbr__c;
            String newShipToSite = EDBIObj.ship_to_site_name__c;
            String newShipToSiteNbr = EDBIObj.ship_to_site_nbr__c; 
            // MCNWithCountyCodeSet.add(EDBIObj.Country_Code_With_Master_Customer_Nbr__c);
           
            
            //System.debug('####'+newStatus); 
            
            
            /* if(String.IsNotBlank(EDBIObj.Order_Number__c)  && EDBIObj.Order_Value_in_Thousand__c!=oldEDBI.Order_Value_in_Thousand__c  ){
OrderNumberWithAmountMap.put(EDBIObj.Order_Number__c,Decimal.valueOf(EDBIObj.Order_Value_in_Thousand__c)*1000);
}*/
            //System.debug('Here');
            
             if(String.IsNotBlank(EDBIObj.Id) && String.isNotBlank(EDBIObj.Order_Number_with_Country_Code__c)){
                OrdNoCountryCodeWithIdMap.put(EDBIObj.Order_Number_with_Country_Code__c ,EDBIObj);
            }
            
            if(((String.isNotBlank(newStatus)&&((newStatus.touppercase()==('CLOSED')) ||((newStatus.touppercase()=='CANCELLED'))) && String.IsNotBlank(EDBIObj.Order_Status__c)))){
                OrderNumberWithStatusMap.put(EDBIObj.Order_Number__c,'Closed');
            }
            if((String.isNotBlank(newFUISiteName) && EDBIObj.fua_site_name__c!=oldEDBI.fua_site_name__c)){
                System.debug('in FUA site name update');
                OrderNumberWithFUISiteNameMap.put(EDBIObj.Order_Number__c,newFUISiteName);
            }
            if((String.isNotBlank(newFUIsiteNbr) && EDBIObj.fua_site_name__c!=oldEDBI.fua_site_nbr__c)){
                OrderNumberWitFUIsiteNbrMap.put(EDBIObj.Order_Number__c,newFUIsiteNbr);
            }
            if((String.isNotBlank(newShipToSite) && EDBIObj.ship_to_site_name__c!=oldEDBI.ship_to_site_name__c)){
                OrderNumberWithShipToSiteNameMap.put(EDBIObj.Order_Number__c,newShipToSite);
            }
            if((String.isNotBlank(newShipToSiteNbr) && EDBIObj.ship_to_site_nbr__c!=oldEDBI.ship_to_site_nbr__c)){
                OrderNumberWithShipToSiteNbrMap.put(EDBIObj.Order_Number__c,newShipToSiteNbr);
            }
        }
        
        
        /*  for(Deming__c demingObj : [Select Order_Number__c,Order_Amount__c from Deming__c where Order_Number__c IN:OrderNumberWithAmountMap.keySet()]){
DemingObj.Order_Amount__c=OrderNumberWithAmountMap.get(demingObj.Order_Number__c);
DemingListToUpdate.add(DemingObj);
}*/
        
        /*  for(Account accOb:[select Country_with_Master_customer_Number__c,Id from account where Country_with_Master_customer_Number__c in:MCNWithCountyCodeSet ]){
MCNCountryCodeWithAccountIdMap.put(accOb.Country_with_Master_customer_Number__c,accOb.Id);  
}*/
        for(Deming__c demingObj : [Select Order_Number__c,fua_site_name__c,fua_site_nbr__c,ship_to_site_name__c,ship_to_site_nbr__c,Cadd_Status__c from Deming__c where Order_Nbr_with_Country_CodeExtrnal__c IN :OrdNoCountryCodeWithIdMap.keySet() and Cadd_Status__c != null]){
            //System.debug('Customer Apporval!!!!'+demingObj.Cadd_Status__c);
            //System.debug('____'+OrderNumberWithStatusMap.get(demingObj.Order_Number__c));
            if(null == demingObj.Cadd_Status__c ){
                if(OrderNumberWithStatusMap.get(demingObj.Order_Number__c)!=null){
                    
                    DemingObj.Cadd_Status__c=OrderNumberWithStatusMap.get(demingObj.Order_Number__c);  
                }
                if(OrderNumberWithFUISiteNameMap.get(demingObj.Order_Number__c)!=null){
                    DemingObj.fua_site_name__c=OrderNumberWithFUISiteNameMap.get(demingObj.Order_Number__c);
                }
                if(OrderNumberWitFUIsiteNbrMap.get(demingObj.Order_Number__c)!=null){
                    DemingObj.fua_site_nbr__c=OrderNumberWitFUIsiteNbrMap.get(demingObj.Order_Number__c);
                }
                if(OrderNumberWithShipToSiteNameMap.get(demingObj.Order_Number__c)!=null){
                    DemingObj.ship_to_site_name__c=OrderNumberWithShipToSiteNameMap.get(demingObj.Order_Number__c);
                }
                if(OrderNumberWithShipToSiteNbrMap.get(demingObj.Order_Number__c)!=null){
                    DemingObj.ship_to_site_nbr__c=OrderNumberWithShipToSiteNbrMap.get(demingObj.Order_Number__c);
                }
                DemingListToUpdate.add(DemingObj);
            }
        }
        
        //System.Debug('12345678'+DemingListToUpdate);
        
        if(DemingListToUpdate.size()>0)
        {
            Update DemingListToUpdate;  
        }
         
         
     }
    
}