@isTest 
public class CPQPaymentSiteHelperTest {
    
    private static ID quoteID = null;
    
    private static void dataSetup(){
         Account a =TestRecordsFactory.createAccount();
         Contact c= TestRecordsFactory.createContact(a);
         SBQQ__Quote__c quo = new SBQQ__Quote__c();
         quo.qtc_Multi_Site__c = True;
         quo.qtc_Multi_Site_Relationship__c = 'Parent';
         quo.qtc_Multi_Site_Type__c = 'PP Only';
         quo.qtc_Number_of_Sites_with_Payments__c = 2;
         quo.SBQQ__PrimaryContact__c = c.id;
         insert quo;
         quoteID = quo.id;
		 
         NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
		 PaySite.Quote__c = quoteID;
		 PaySite.NCR_Payments_Application_Status__c = 'ApprovedAndBoarded';
         insert PaySite;
    }
	
    @isTest 
    static void getPaymentSitesTest(){
        CPQPaymentSiteHelperTest.dataSetup();
		Test.startTest();
		CPQPaymentSiteHelper cpqPaymentSiteHelper = new CPQPaymentSiteHelper();
		cpqPaymentSiteHelper.quoteId = quoteID;
        
        List<NCR_Payments_Site__c> l = cpqPaymentSiteHelper.getPaymentSites();
    	System.assertEquals(1, l.size());
        System.assertEquals(quoteID, cpqPaymentSiteHelper.getQuoteId());
	    Test.stopTest();
	
	}
}