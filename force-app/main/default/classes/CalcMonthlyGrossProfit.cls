Public Class CalcMonthlyGrossProfit implements schedulable{
        
    public void execute ( schedulablecontext sc)
    {    
    Set<ID> oppIdSet = new Set<ID>();
    Map<String, Decimal> OppTotalMthGP = new Map<String, Decimal>(); 
    List<Opportunity> updateOppList = new List<Opportunity>();
    
    if(!Test.isRunningTest())
    {
    for(zqu__Quote__c zq : [SELECT zqu__Opportunity__c  FROM zqu__Quote__c WHERE LastModifiedDate = LAST_N_DAYS:30])
    {
        oppIdSet.add(zq.zqu__Opportunity__c);
    }
    }
    else
    {
    for(zqu__Quote__c zq : [SELECT zqu__Opportunity__c  FROM zqu__Quote__c WHERE Monthly_Gross_Profit__c != null OR Monthly_Gross_Profit__c !=0.00 limit 100])
    {
        oppIdSet.add(zq.zqu__Opportunity__c);
    }
    }
    
    if (!oppIdSet.isEmpty()) {
       List<AggregateResult> aggResults = [SELECT Sum(Monthly_Gross_Profit__c) totalMthGP,zqu__Opportunity__c 
                                                FROM zqu__Quote__c where zqu__Opportunity__c IN :oppIdSet
                                                AND Monthly_Gross_Profit__c <> null GROUP BY zqu__Opportunity__c];
                                            
                                                 
       for (AggregateResult ar : aggResults) { 
           OppTotalMthGP.put((String)ar.get('zqu__Opportunity__c'), (Decimal)ar.get('totalMthGP'));
       }
       
       for(Opportunity opp :[SELECT Id, Monthly_Gross_Profit__c FROM Opportunity WHERE Id IN :oppIdSet]) {
            if(OppTotalMthGP.containsKey(opp.Id)) {
                opp.Monthly_Gross_Profit__c  = OppTotalMthGP.get(opp.Id); 
            } else {
                opp.Monthly_Gross_Profit__c = 0.00;    
            }
            updateOppList.add(opp);
        }  
    }
    
    if(!updateOppList.isEmpty()) {
        try {
            update updateOppList;
        } catch(Exception e) {e.getMessage(); }
    }
    
                                     
    
    
}
}