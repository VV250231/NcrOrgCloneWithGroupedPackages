@isTest(SeeAllData=true)
public class ACVEstimatedUsageControllerTest
{
    private static zqu__Quote__c qt;
    
	Public Static User getUser(){
		User Usr = [Select Id from User Where Name = 'Soup User'];
		return Usr;
	}   
    public static testMethod void testInit()
    {
        
        Account acct = new Account(Name = 'Test Account', Subscription_Group__c = 'Test',industry = 'HOSPITALITY:CHANNEL');
        
        System.runAs(getUser()){
	insert acct;
	}
        
        //Opportunity opp = ZuoraTestUtil.createOpp(acct);
        //ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
		
        Opportunity opp = new Opportunity();
        opp.accountid = acct.id;
        opp.name = 'test';
        opp.closedate = system.today();
        opp.stagename = 'Analyzing';
        opp.Channel_Office__c = acct.id;
        insert opp;
        
        qt = ZuoraTestUtil.createQuote(opp, 'Default');
    
        Test.setCurrentPage(Page.ACVEstimatedUsage);
        ApexPages.currentPage().getParameters().put('stepNumber', '4');
        ACVEstimatedUsageController c = new ACVEstimatedUsageController(new ApexPages.StandardController(qt));
        test.startTest();
        System.assertNotEquals(null,c.init());
        System.assertNotEquals(null,c.Save());
        System.assertNotEquals(null,c.Next());
        System.assertEquals(null,c.Back());
        System.assertNotEquals(null,c.Done());        
        
        ApexPages.currentPage().getParameters().put('stepNumber', null);
        System.assertNotEquals(null,c.back());
        System.assertNotEquals(null,c.Next());

        test.stopTest();    
    }    
    

}