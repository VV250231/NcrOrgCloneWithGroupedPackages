@isTest(SeeAllData=true)
public class CloneOpportunityWithLinkTest {
    
    public static testMethod void testCloneOpportunityWithLink(){
        
        Opportunity o = new Opportunity();
        o = [select id, createdbyid from Opportunity limit 1];
        System.assertNotEquals(o.id, null,'Opportunity is Null');  
        PageReference pageRef = Page.CloneOpportunityWithLink;
        Test.setCurrentPage(pageRef);
        if(o != Null)
        {
            ApexPages.currentPage().getParameters().put('id', o.id);
            ApexPages.StandardController opp = new ApexPages.StandardController(o);
            CloneOpportunityWithLink controller = new CloneOpportunityWithLink(opp);
            controller.autoRun();
        }
    
    }
}