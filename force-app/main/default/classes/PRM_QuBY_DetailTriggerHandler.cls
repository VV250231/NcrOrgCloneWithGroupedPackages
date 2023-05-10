public class PRM_QuBY_DetailTriggerHandler {
    public static void updateQuoteNumOnPartnerOpp (List<QuBy_Detail__c> QuByDetailList ) {
        Set<Id> oppIds = new Set<Id>();
        
        for (QuBy_Detail__c qbDetail : QuByDetailList) {
            oppIds.add(qbDetail.Opportunity__c);
        }
        
        Map<Id,String> partnerOppIdToQuoterNumMap = new Map<Id,String>();
        
        if (oppIds.size() > 0) {
            
            for (Opportunity op : [SELECT Id,Linked_Partner_Opportunity__c, (SELECT Id,Quote_Number__c FROM All_QuBy_Quotes__r)  FROM Opportunity WHERE Id IN: oppIds AND Linked_Partner_Opportunity__c != null]) {
                String quoteNumbers = '';
                for (QuBy_Detail__c qd : op.All_QuBy_Quotes__r) {
                    quoteNumbers = (quoteNumbers != '') ? quoteNumbers +'; ' + qd.Quote_Number__c : qd.Quote_Number__c;
                }
                if (quoteNumbers != '') {
                    partnerOppIdToQuoterNumMap.put(op.Linked_Partner_Opportunity__c,quoteNumbers);
                }
                
            }
            
        }
        
        if (partnerOppIdToQuoterNumMap.keySet().size() > 0) {
            List<Partner_Opportunity__c> partnerOpportunity = [SELECT Id, Quote_Number__c FROM Partner_Opportunity__c WHERE Id IN: partnerOppIdToQuoterNumMap.keySet()];
            for (Partner_Opportunity__c po : partnerOpportunity ) {
                po.Quote_Number__c = partnerOppIdToQuoterNumMap.get(po.Id);
            }
            update partnerOpportunity ;
        }
    }
}