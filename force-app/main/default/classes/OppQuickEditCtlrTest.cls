@isTest
private class OppQuickEditCtlrTest {
    static testMethod void runTest() {
        Opportunity opp1 = TestRecordsFactory.createSimpleOpportunity();
        system.assertNotEquals(opp1,null);      
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp1);
        OppQuickEditCtlr oppctrl = new OppQuickEditCtlr(stdController);
        
        oppctrl.expBookDate = date.today();
        oppctrl.expDeliveryDate = oppctrl.expBookDate.addDays(1).format();
        
        oppctrl.saveOppRecord(); 
         
    }

}