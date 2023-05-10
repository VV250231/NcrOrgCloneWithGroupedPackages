//This class updates the opportunities which are not in All Quby quotes but are attched to order in an Anaplan
global class UpdateNonQubyQuoteOpp
{
    @future
    public static void updateOpp(Map<String,String> quoteOppMap )
    {   
        system.debug('QuoteOppMap@@@ = '+quoteOppMap);
        List<QuBy_Detail__c> allQubyOppList = new List<QuBy_Detail__c>();
        if(quoteOppMap.size()>0){
            allQubyOppList = [select Id,Opportunity_No__c  from QuBy_Detail__c where Opportunity_No__c  IN :quoteOppMap.values() and Opportunity_No__c!=null];
        }
        
        if(allQubyOppList != null && allQubyOppList.size()>0){
            for(QuBy_Detail__c qb : allQubyOppList ){
                quoteOppMap.remove(qb.Opportunity_No__c);
            }
           }
        system.debug('QuoteOppMap### = '+quoteOppMap);
        List<Opportunity> OppList= new List<Opportunity>();
        if(quoteOppMap != null && quoteOppMap.size()>0){
            for(Opportunity Opp : [select Id,Opportunity_Number__c,IsQuoteCreatedInOtherSystem__c from Opportunity where Opportunity_Number__c IN :quoteOppMap.values() AND IsQuoteCreatedInOtherSystem__c != 'YES']){
                Opp.IsQuoteCreatedInOtherSystem__c = 'YES';
                OppList.add(Opp);
            }
        }
        if(OppList != null && OppList.size()>0){
        system.debug('OppList### = '+OppList);
            update OppList;
        }
    }
}