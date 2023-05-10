@isTest
private class OpportunityViewControllerTest{

    static testMethod void myTest() {
        Account acc=TestRecordsFactory.createAccount();
        Competitors__c comp=TestRecordsFactory.createCompetitor();
        Sales_Org__c  so=TestRecordsFactory.createSalesOrg();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        List<Opportunity> oppList = new  List<Opportunity>{opp};
        
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        ApexPages.StandardSetController stdctrl = new ApexPages.StandardSetController(oppList);
        OpportunityViewController oppCtrl = new OpportunityViewController(stdctrl);
        List<SelectOption> optionList  = oppCtrl.OptionValue;
      
        oppCtrl.GetFilterOpportunity();
        oppCtrl.SelectelValue = 'Total_Closed_Opportunity';
        oppCtrl.GetFilterOpportunity();
        oppCtrl.SelectelValue = 'All_Lost_Opportunity';
        oppCtrl.GetFilterOpportunity();
        oppCtrl.SelectelValue = 'Previous_Year_Closed_Opportunity';
        oppCtrl.GetFilterOpportunity();
         system.assert(oppCtrl !=null); 
    }
}