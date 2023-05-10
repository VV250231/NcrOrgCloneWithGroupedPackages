global class groomNcrPaymentSiteRecords implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
		
        return Database.getQueryLocator([Select id, Merchant_Application_Id__c,Cobrand__c,Cobrand_URL__c,Opportunity__c,Opportunity__r.Opportunity_Number__c,
                                         NCR_Payments_Application_Status__c,Quote__c, Quote__r.Name from NCR_Payments_Site__c]);
    }
    global void execute(Database.BatchableContext bc, List<NCR_Payments_Site__c> scope){
         String qtOrOpptyNbr= '';
         String OUTBOUND_LOG= 'OutBound', SUCCESS_STS = '%success%', ONBOARDING= '%OnBoarding%';
        
        for(NCR_Payments_Site__c ncrSite : scope) {     
            String recordName = (ncrSite.Quote__c != NULL) ? ncrSite.Quote__r.Name : (ncrSite.Opportunity__r?.Opportunity_Number__c);
              
            if(String.isNotBlank(recordName)) {
                if(String.isNotBlank(qtOrOpptyNbr))  qtOrOpptyNbr += ' OR '; 
                qtOrOpptyNbr += 'name like \'' + recordName + '%\'';    
            }
        }
         qtOrOpptyNbr = '(' + qtOrOpptyNbr + ')';
         String jpQuery='SELECT Id, Name, Response__c FROM JPLogs__c WHERE ' + qtOrOpptyNbr + ' AND (NOT name like :ONBOARDING) AND Type__c = :OUTBOUND_LOG AND Status__c like :SUCCESS_STS  order by createdDate desc';
          System.debug(jpquery);
         List<JPLogs__c> jpLogs = Database.query(jpquery);        
         List<NCR_Payments_Site__c> ncrPaymentLst = new List<NCR_Payments_Site__c>();
        
        for (NCR_Payments_Site__c nps : scope) { 
              String recordName = (nps.Quote__c != NULL) ? nps.Quote__r.Name : (nps.Opportunity__r?.Opportunity_Number__c);
              
            if(String.isNotBlank(recordName)) {
              for (JPLogs__c jpLog : jpLogs) {
                  if(jpLog.name.startsWith(recordName) && String.isNotBlank(jpLog.Response__c) && jpLog.Response__c != 'Success :Status updated successfully.'
                    	&& !(jplog.Response__c.contains('failure') || jplog.Response__c.contains('error'))) {
                      
                      NCR_Payments_Site__c ncrObj = new NCR_Payments_Site__c();                      
                      List<JSON2ApexNCRPaymentResponse> JsonField =JSON2ApexNCRPaymentResponse.parse(jpLog.Response__c);
                      
                      ncrObj.id = nps.id;
                      ncrObj.Cobrand_URL__c = JsonField[0].merchantClaimURL;
                      ncrObj.Merchant_Application_Id__c = JsonField[0].merchantApplicationId;
                      String str = JsonField[0].merchantClaimURL;
                      String delimiter = '/';
                      String firstSplit = str.substringAfter(delimiter);
                      String SecondSplit = firstSplit.substringAfter(delimiter);
                      String thirdtSplit = SecondSplit.substringAfter(delimiter);
                      String lastSplits = thirdtSplit.substringBefore(delimiter);
                      ncrObj.Cobrand__c =lastSplits;
                      ncrPaymentLst.add(ncrObj);
                      break; 
                  }     
              } 
            }
          }      
      
        if(!ncrPaymentLst.isEmpty()) {
            update ncrPaymentLst;
        }
        //JSON2ApexNCRPaymentResponse.parse
    }
    
    global void finish(Database.BatchableContext bc){
    }
}