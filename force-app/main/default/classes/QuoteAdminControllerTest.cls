@isTest
public class QuoteAdminControllerTest {
    static testmethod void RunTests()
    {
        zqu__Quote__c quote = new zqu__Quote__c(); 
        insert quote; 
        System.assert(Quote.Id!=null);
        
        // No Params
        QuoteAdminController qac = new QuoteAdminController(); 
        
        // Bad params
        ApexPages.currentPage().getParameters().put('Id', '111');
        qac = new QuoteAdminController();
        
        ApexPages.currentPage().getParameters().put('AutoSubmit', 'true');
        ApexPages.currentPage().getParameters().put('Id', quote.Id);
        
        // With Params
        qac = new QuoteAdminController(); 
        qac.init();
        qac.refreshJobs();
        qac.getQuote();
        
    }

}