@isTest
public class TestQuoteOnSubmitTriggerHandler { 
    static testMethod void testOnSubmit() { 
        Test.startTest();
        DICustomerNumberSequence__c seq = DICustomerNumberSequence__c.getOrgDefaults();
        seq.Next__c = 1002;
        insert seq;

        Test.setMock(WebServiceMock.class, new NSCProvisioning_Mocks.execute_pttBindingQSPort_Success());

        Solution_Provider__c sp = TestNSCProvisioning.CreateVendorData(); 
        insert sp; 

        Solution_Provider_Product__c spp = TestNSCProvisioning.CreateVendorProductData(sp.Id, true);
        insert spp;

        Account a = TestNSCProvisioning.CreateAccountData();
        a.DPV_Provider__c = sp.Id; 
        a.DPV_Software__c = spp.Id; 
        System.runas(TestRecordsFactory.getUser()){
        insert a;
		}
        
        // Billing Account
        Zuora__CustomerAccount__c ca = TestNSCProvisioning.CreateBillingAccountData(a.Id); 
        insert ca; 


        // Some dummy acounts to test the DI Number choice
        System.runas(TestRecordsFactory.getUser()){
        Account a2 = TestNSCProvisioning.CreateAccountData(); 
        a2.DI_Customer__c = '1000'; 
        insert a2; 
        Account a3 = TestNSCProvisioning.CreateAccountData(); 
        a3.DI_Customer__c = '1001'; 
        insert a3; 
        Account a4 = TestNSCProvisioning.CreateAccountData(); 
        a4.DI_Customer__c = '1005'; 
        insert a4; 
        
        }

        Opportunity o = ZuoraTestUtil.createOpp(a);
        system.debug('****Opp: ' + o);

        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact'); 
        insert c; 
        
        Provisioning__c prov = TestNSCProvisioning.CreateProvisioningData(o.Id, c.Id, c.Id); 
        insert prov;


        Contract con = TestNSCProvisioning.CreateContractData(a); 
        insert con;
        
        zqu__Quote__c q = ZuoraTestUtil.createQuote(o, 'Default');
        q.zqu__ZuoraAccountID__c = '1234';
        update q;
        
        zqu__ZProduct__c zProduct = TestNSCProvisioning.CreateZProductData(); 
        insert zProduct; 
        
        Quote_Product__c qp = TestNSCProvisioning.CreateQuoteProductData(q.Id, zProduct.Id, spp.Id);
        insert qp;
        
        Test.stopTest();
        q.zqu__Status__c = 'Sent to Z-Billing';
        update q;
        
        
        // Requery the account to get the most recent info
        Account updatedAcc = [select DI_Customer__c from Account where Id = :a.Id];
        System.debug('>>>>>>>>>>>>>>' + updatedAcc.DI_Customer__c );

        system.assertEquals('1002', updatedAcc.DI_Customer__c);
    }
}