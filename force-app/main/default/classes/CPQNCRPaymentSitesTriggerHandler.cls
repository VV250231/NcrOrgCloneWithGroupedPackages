/**************************************
Author ...............: Pandey, Dharmendra Kumar
Modified Date.........: 13-July-2021
Description...........: Update quote's all payment application status field qtc_Status_of_all_Applications__c
						Called from cpq_NCRPaySitesToOppSyncTrigger.apxt
***************************************/
public class CPQNCRPaymentSitesTriggerHandler {
   
   /*
    * Update quote's all payment application status field qtc_Status_of_all_Applications__c to Pending or ApprovedAndBorded
    * Called from cpq_NCRPaySitesToOppSyncTrigger.apxt
    */
    
    public static void handleBeforeQuoteUpdate(Map<String,SBQQ__Quote__c> pQuotesMap){
         if(pQuotesMap.size()>0){ 
            List<String> qIdList = new List<String>();
            qIdList.addAll(pQuotesMap.keySet()); 
            Map<String, String> quoteIdStatusMap = CPQNCRPaymentSitesTriggerHandler.updatePaymentApplicationStatus(qIdList,pQuotesMap);
            for(String qId: qIdList){
                if(quoteIdStatusMap.containsKey(qId)){
                	pQuotesMap.get(qId).qtc_Status_of_all_Applications__c=quoteIdStatusMap.get(qId);
                } else {
                    pQuotesMap.get(qId).qtc_Status_of_all_Applications__c = null; 
                }
            }
        }
    }
    
    public static List<SBQQ__Quote__C> handleAfterPaymentUpdate(List<String> pqIds){ //Added by Sushant
        List<SBQQ__Quote__C> qListForOppCloseBook = new List<SBQQ__Quote__C>();
        if(pqIds.size()>0){         
            List<SBQQ__Quote__C> qList = new List<SBQQ__Quote__C>();
            Map<String, String> quoteIdStatusMap = CPQNCRPaymentSitesTriggerHandler.updatePaymentApplicationStatus(pqIds,null);
            for(String key:pqIds){
                SBQQ__Quote__c pQuote = new SBQQ__Quote__c();
                pQuote.Id = key;
                if(quoteIdStatusMap.containsKey(key)){
                    pQuote.qtc_Status_of_all_Applications__c=quoteIdStatusMap.get(key);
                } else {
                    pQuote.qtc_Status_of_all_Applications__c=null;
                }
                if(!qList.contains(pQuote)){
                	qList.add(pQuote);
                }
            }
            
            if(qList.size()>0){
                update qList; 
            }
            
            //Added by Sushant
            for(String key:pqIds){
                SBQQ__Quote__c pQuote = new SBQQ__Quote__c();
                pQuote.Id = key;
                if(quoteIdStatusMap.containsKey(key)){
                    if( quoteIdStatusMap.get(key)=='ApprovedAndBoarded'){
                        System.debug('payments sites are approved');
                        if(!qListForOppCloseBook.contains(pQuote)){
                            qListForOppCloseBook.add(pQuote);
                        }
                    }
                } 
            } // Ended by Sushant
        }
        
         return qListForOppCloseBook; //Added by Sushant
    }
    
    public static Map<String, String> updatePaymentApplicationStatus(List<String> quoteIDs,Map<String,SBQQ__Quote__c> pQuotesMap){
        Map<String, String> quoteIdStatusMap = new Map<String, String>();
        try {
            if(!quoteIDs.isEmpty()) {
                Map<Id,Decimal> qSitesNoMap = new Map<Id, Decimal>();
                List<NCR_Payments_Site__c> gRes = [Select Quote__c, NCR_Payments_Application_Status__c,Quote__r.qtc_Multi_Site__c,Quote__r.qtc_Number_of_Sites_with_Payments__c from NCR_Payments_Site__c where Quote__c in :quoteIDs];
                System.debug('No Of Sites:'+gRes.size());
                for (NCR_Payments_Site__c ar : gRes)  {
                    if(!qSitesNoMap.containsKey(ar.Quote__c)){ 
                        if(ar.Quote__r.qtc_Multi_Site__c){
                            if(pQuotesMap!=null && pQuotesMap.containsKey(ar.Quote__c)){
                                qSitesNoMap.put(ar.Quote__c,pQuotesMap.get(ar.Quote__c).qtc_Number_of_Sites_with_Payments__c);
                            } else {
                                qSitesNoMap.put(ar.Quote__c,ar.Quote__r.qtc_Number_of_Sites_with_Payments__c);
                            }
                        } else {
                            qSitesNoMap.put(ar.Quote__c,1);
                        }
                    }
                    if(ar.NCR_Payments_Application_Status__c!=null && ar.NCR_Payments_Application_Status__c.equals('ApprovedAndBoarded')){
                        qSitesNoMap.put(ar.Quote__c,qSitesNoMap.get(ar.Quote__c)-1);
                    }
                    
                }
                for (Id quoteId : qSitesNoMap.keySet()) {
                    Decimal notSiteBoarded = qSitesNoMap.get(quoteId);
                    String status = null;
                    if(notSiteBoarded>0){
                        status = 'Pending'; 
                    } else {
                        status = 'ApprovedAndBoarded';
                    }
                    quoteIdStatusMap.put(quoteId, status);
                }
                
            }
            
        } catch (Exception ex) {
            system.debug('Error Occured : CPQNCRPaymentSitesTriggerHandler.updatePaymentApplicationStatus: '+ex.getMessage());
        } 
        
        return quoteIdStatusMap;
    }
}