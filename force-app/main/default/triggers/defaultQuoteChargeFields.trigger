trigger defaultQuoteChargeFields on zqu__QuoteCharge__c (before insert, before update) {
   
   if(Trigger.isBefore) {
       if (Trigger.isInsert) {
            Set<ID> zQuoteIDSet = new Set<ID>();
            Map<ID, ID> zQoteIDChOffNameMap = new Map<ID, ID>();
            Map<ID, ID> zQoteIDSalesPersonMap = new Map<ID, ID>(); 
            
            for (zqu__QuoteCharge__c z :trigger.new ) {
                zQuoteIDSet.add(z.zqu__Quote__c);   
            }
            
           for(zqu__Quote__c zq :[SELECT Id, zqu__Opportunity__c, zqu__Opportunity__r.OwnerId,
                                   zqu__Opportunity__r.Owner.Name, zqu__Opportunity__r.Channel_Office__c, 
                                   zqu__Opportunity__r.Channel_Office__r.Name 
                                   FROM zqu__Quote__c WHERE Id IN :zQuoteIDSet]) {
                                   
               if(zq.zqu__Opportunity__c != NULL &&  zq.zqu__Opportunity__r.OwnerId != NULL) {
                    zQoteIDSalesPersonMap.put(zq.Id, zq.zqu__Opportunity__r.OwnerId);    
               }                          
               
               if(zq.zqu__Opportunity__c != NULL && zq.zqu__Opportunity__r.Channel_Office__c != NULL) {
                   zQoteIDChOffNameMap.put(zq.Id, zq.zqu__Opportunity__r.Channel_Office__c); 
               }
           }
           
           for (zqu__QuoteCharge__c qc :trigger.new ) {
               if(zQoteIDSalesPersonMap.containsKey(qc.zqu__Quote__c)) {
                   qc.Salesperson_Lkp__c = zQoteIDSalesPersonMap.get(qc.zqu__Quote__c);
               } 
               
               if(zQoteIDChOffNameMap.containsKey(qc.zqu__Quote__c)) {
                   qc.ChannelPartner_Lkp__c = zQoteIDChOffNameMap.get(qc.zqu__Quote__c);    
               }
           }
       }
       
       if(Trigger.isUpdate) {
           for (zqu__QuoteCharge__c zcharge :trigger.new ) {
               if(String.isNotEmpty(zcharge.PartnerCommission__c)) {
                   zcharge.Partner_Commission_currency__c = Decimal.valueOf(zcharge.PartnerCommission__c);
               }
                
               if(String.isNotEmpty(zcharge.Cost__c)) {
                   zcharge.Cost_currency__c = Decimal.valueOf(zcharge.Cost__c);
               }
               zcharge.Gross_Profit_currency__c = zcharge.Gross_Profit_Calculation__c;
               zcharge.GrossProfit__c = String.valueOf(zcharge.Gross_Profit_Calculation__c); 
               zcharge.PartnerCost__c  = String.valueOf(zcharge.Partner_Cost__c);    
           }
       }
   }
    

}