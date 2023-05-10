@isTest
private class OppListViewControllerTest{

    static testMethod void myTest() {
        Account acc=TestRecordsFactory.createAccount();
        Competitors__c comp=TestRecordsFactory.createCompetitor();
        Sales_Org__c  so=TestRecordsFactory.createSalesOrg();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        List<Opportunity> oppList = new  List<Opportunity>{opp};
        List<OppListViewController.FieldFilterWrapper> filterList = new List<OppListViewController.FieldFilterWrapper>();
        OppListViewController.FieldFilterWrapper fieldFilter = new  OppListViewController.FieldFilterWrapper(
                                                                'Name', 'Opportunity Name', 'STRING', 'equals', 'Test1234', new List<String>(), 'edit');
        filterList.add(fieldFilter);
        String filterStr = JSON.serialize(filterList);
        OppListViewController.getAcctOpps(acc.Id, 'THIS_QUARTER', 'Test', filterStr );
        OppListViewController.getAcctOpps(acc.Id, 'Previous_Year_Closed_Opportunity', 'Test', filterStr );
        OppListViewController.getAcctOpps(acc.Id, 'Total_Closed_Opportunity', 'Test', filterStr );
         //OppListViewController.getAcctOpps(acc.Id, 'All_Lost_Opportunity', 'Test', filterStr );
        OppListViewController.getFieldsInfo();
        OppListViewController.getAllCurrency();
        System.assertEquals(true, OppListViewController.getAllCurrency().contains('AED'));
        System.assertEquals('Test Acc', OppListViewController.getAcctOpps(acc.Id, 'THIS_QUARTER', 'Test', filterStr ).AccountName);
        System.assertEquals('Test Acc', OppListViewController.getAcctOpps(acc.Id, 'THIS_QUARTER', 'Test', filterStr ).AccountName);

    } 
}