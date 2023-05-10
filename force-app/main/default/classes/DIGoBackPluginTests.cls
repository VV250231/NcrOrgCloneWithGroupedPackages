// ===========================================================================
// Object: DIGoBackPluginTests
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage of DIGoBackPlugin for DI story 1475
// ===========================================================================
// Changes: 2016-12-06 Reid Beckett
//           Class created
// ===========================================================================
@isTest(SeeAllData=false)
public class DIGoBackPluginTests {

    @isTest
    public static void test1()
    {
        Account acct = new Account(Name = 'Test Account');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
            insert acct;
        }
        
        system.assertNotEquals(acct.Name, 'Testing');        
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        Test.setCurrentPage(Page.zqu__CreateQuote);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.currentPage().getParameters().put('id', qt.Id);
        ApexPages.currentPage().getParameters().put('crmAccountId', ZuoraTestUtil.generateGUID());
        ApexPages.currentPage().getParameters().put('billingAccountId', ZuoraTestUtil.generateGUID());
        ApexPages.currentPage().getParameters().put('retUrl', '/');
        new DIGoBackPlugin().goBack(qt, new zqu.PropertyComponentController.ParentController());
    }
}