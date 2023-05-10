@isTest(SeeAllData=false)
public class DisableSendToZBillingTests {

    @isTest
    public static void test4_E4()
    {
        Account acct = new Account(Name = 'Test Account');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
        	insert acct;
        }
       // Account acct = new Account(Name = 'Test Account');
        //insert acct;
        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        
        insert new ZuoraOptions__c(Send_To_Z_Billing_Enabled__c = false);
        System.assert(ZuoraOptions__c.id!=null); 
        
        Test.startTest();
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        NCRQuoteSubmit2Controller cont = new NCRQuoteSubmit2Controller(new ApexPages.StandardController(qt));
        cont.init();
        Test.stopTest();
    }
}