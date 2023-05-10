@istest 

Public class CalcMonthlyGrossProfitTEST{
    static testmethod void test1() {
        
        Opportunity Opp = new Opportunity();                              
        Opp.Name='TestOpsads';
        Opp.StageName='Prospecting';
        Opp.CloseDate=System.today();
        insert Opp;
        zqu__Quote__c zq = new zqu__Quote__c(zqu__Opportunity__c=opp.id);
        insert zq;
        Test.startTest();
        CalcMonthlyGrossProfit a = new CalcMonthlyGrossProfit();
        a.execute(null);
        Test.stopTest();
        zqu__Quote__c zqObj = [select Monthly_Gross_Profit__c from zqu__Quote__c where id=:zq.id ];
        Opportunity oppObj = [select Monthly_Gross_Profit__c from Opportunity where id =:opp.id];
        System.assert(oppObj.Monthly_Gross_Profit__c==zqObj.Monthly_Gross_Profit__c);
    }
    
}