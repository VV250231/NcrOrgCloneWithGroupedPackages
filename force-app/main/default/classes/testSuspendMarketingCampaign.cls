/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class testSuspendMarketingCampaign {

    static testMethod void myUnitTest() {
       Account acc = TestRecordsFactory.createAccount();
       Contact con = TestRecordsFactory.createContact(acc);
        system.debug('acc'+acc.Id);
        con.Suspend_Marketing_Campaigns__c = False;
        con.AccountId = acc.Id;
        update con;
       // Contact contact = [Select Id, AccountID, Suspend_Marketing_Campaigns__c from Contact where Suspend_Marketing_Campaigns__c = FALSE limit 1];
        //system.debug('contactAccid'+contact.AccountId);
        //Account account1 = [Select Id, Name from Account where id = :contact.AccountId];
         //update con;
        test.starttest();
        Test.setCurrentPage(Page.suspendAllMktgCampaigns);
        ApexPages.StandardController stc1 = new ApexPages.StandardController(acc);
        suspendMarketingCampaign SMC1 = new suspendMarketingCampaign(stc1);
        SMC1.suspendCampaigns();
        test.stoptest();
        
    }
    static testMethod void myUnitTest1() {
       Account acc = new Account();
        test.starttest();
        Test.setCurrentPage(Page.suspendAllMktgCampaigns);
        ApexPages.StandardController stc1 = new ApexPages.StandardController(acc);
        suspendMarketingCampaign SMC1 = new suspendMarketingCampaign(stc1);
        SMC1.suspendCampaigns();
        test.stoptest();
        system.assertNotEquals(stc1, null);
        
    }

}