@isTest
public class VisitDataOppTest {
    private static testMethod void testAutoRun() {
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
   		VisitDataOpp  controller = new VisitDataOpp(sc);
        controller.requestBriefing();
        system.assert(controller.requestBriefing() !=null);
        
    }

}