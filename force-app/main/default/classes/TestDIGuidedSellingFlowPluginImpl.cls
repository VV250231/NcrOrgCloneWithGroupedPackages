@isTest
public class TestDIGuidedSellingFlowPluginImpl {

    @isTest(SeeAllData=False)
    public static void test1() 
    {
        Account acct = new Account(Name = 'Test Account');
        
         System.runAs(TestRecordsFactory.getUser()){
             insert acct;
         }
        
        Contact cont = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acct.Id);
        insert cont;

        Opportunity opp = ZuoraTestUtil.createOpp(acct);
        ZuoraTestUtil.ProductCatalog pcatalog = ZuoraTestUtil.createProductCatalog();
        zqu__Quote__c qt = ZuoraTestUtil.createQuote(opp, 'New Renewal');
        zqu__Quote__c qt1 = ZuoraTestUtil.createQuoteWithAcc(acct, 'New Renewal');
    
        DIGuidedSellingFlowPluginImpl impl = new DIGuidedSellingFlowPluginImpl();
        impl.getFlows(qt.Id);
        List<id> LSTID= impl.getFlows(qt1.Id);
        System.assert(LSTID.size()>=0);
        zqu__GuidedSellingFlow__c ZQFLOW= new zqu__GuidedSellingFlow__c();
        ZQFLOW.name= 'Add DI Product';
        
        ZQFLOW.zqu__IncludeInProductSelector__c=true;
        insert ZQFLOW;
         zqu__GuidedSellingFlow__c ZQFLOW1= new zqu__GuidedSellingFlow__c();
        ZQFLOW1.name= 'Add Product';
        ZQFLOW1.zqu__IncludeInProductSelector__c=true;
        insert ZQFLOW1;
        List<id> LSTID1= impl.getFlows(qt1.Id);
        System.assert(LSTID1.size()>=1);
        
           
    }
}