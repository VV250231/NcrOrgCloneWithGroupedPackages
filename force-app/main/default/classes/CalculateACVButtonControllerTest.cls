@isTest(SeeAllData=true)
public class CalculateACVButtonControllerTest
{
    private static zqu__Quote__c qt;
    public static testMethod void calculateACV()
    {
        
        User u = TestRecordsFactory.getUser();
        System.runAs(u){
            Account acct = new Account(Name = 'Test Account', Subscription_Group__c = 'Test');
            insert acct;
            Opportunity opp = ZuoraTestUtil.createOpp(acct);
            
            //ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
            qt = ZuoraTestUtil.createQuote(opp, 'Default');
        }
        CalculateACVButtonController c = new CalculateACVButtonController(new ApexPages.StandardController(qt));
        test.startTest();
        c.calculateACV();
        PageReference pgRef =c.redirect();
        test.stoptest();  
        System.assert(pgRef!=null);
    }
}