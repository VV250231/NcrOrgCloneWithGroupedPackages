@isTest
public class ContractActionCntrlTest {
    @isTest
    public static void test1(){
        PageReference myVfPage = Page.ContractActionsButtonVF;
        Test.setCurrentPage(myVfPage);
         Account a = Testrecordsfactory.createAccount();
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('obj','Opportunity');
        ApexPages.currentPage().getParameters().put('page','OpportunityPage');
        ApexPages.currentPage().getParameters().put('url','https://google.com');
         ApexPages.currentPage().getParameters().put('acid',a.id);
        ContractActionCntrl c = new ContractActionCntrl();
        c.urlRedirection();
        Tab_Access__c ta = [Select id from Tab_Access__c where name='Contract Action'];
        System.assert(ta.id!=null);
        PageReference myVfPage1 = Page.ContractActionsButtonVF;
        Test.setCurrentPage(myVfPage1);
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('obj','Opportunity');
        ApexPages.currentPage().getParameters().put('page','OpportunityPage');
        ApexPages.currentPage().getParameters().put('url','https://google.com');
       
        ApexPages.currentPage().getParameters().put('acid',a.id);
        ContractActionCntrl c1 = new ContractActionCntrl();
        c1.urlRedirection();
    }
}