@isTest
public class TestNSCProvisioning {
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    static testmethod void TestGetDetails() { 
        // Vendor
        Solution_Provider__c vendor = CreateVendorData(); 
        insert vendor; 

        // TPV Vendor Product
        Solution_Provider_Product__c tpvProduct = CreateVendorProductData(vendor.Id, false); 
        insert tpvProduct;

        // DPV Product
        Solution_Provider_Product__c dpvProduct = CreateVendorProductData(vendor.Id, true); 
        insert dpvProduct; 

        // Vendor Product Interface
        Solution_Provider_Product_Interface__c vendorProductInterface = CreateVendorProductInterfaceData(dpvProduct.Id); 
        insert vendorProductInterface;
        
        // Vendor Contact
        Solution_Provider_Contact__c vendorContact = CreateVendorContactData(vendor.Id); 
        insert vendorContact;

        // Account
        Account account = CreateAccountData(); 
        account.DPV_Provider__c = vendor.Id; 
        account.DPV_Software__c = dpvProduct.Id;
        account.DPV_Interface__c = vendorProductInterface.Id;
        
        System.runAs(getUser()){
            insert account;
        }

        // Billing Account
        Zuora__CustomerAccount__c ca = CreateBillingAccountData(account.Id); 
        insert ca; 

        // Contract
        Contract contract = CreateContractData(account); 
        insert contract; 

        // Opp
        Opportunity opp = CreateOpportunityData(account); 
        insert opp; 

        // Contact
        Contact con = CreateContactData(account); 
        insert con; 

        // Provisioning
        Provisioning__c prov = CreateProvisioningData(opp.Id, con.Id, con.Id); 
        insert prov; 
        
        // ZProduct
        zqu__ZProduct__c zProduct = CreateZProductData(); 
        insert zProduct; 
        
        // ZFeature
        zqu__ZFeature__c zFeature = CreateZFeatureData(); 
        insert zFeature;
        
        // Quote
        zqu__Quote__c quote = CreateQuoteData(account.Id, opp.Id); 
        insert quote; 
        
        // Quote Product
        Quote_Product__c quoteProduct = CreateQuoteProductData(quote.Id, zProduct.Id, tpvProduct.Id);
        insert quoteProduct;

        // Quote Feature
        zqu__QuoteProductFeature__c quoteProductFeature = CreateQuoteFeatureData(quote.Id, zFeature.Id);
        insert quoteProductFeature; 

        // Build the Detail object for SOUP callout
        NSCProvisioningUtil.GetDetailFromQuote(quote.Id);
        
        // Remove this to use only the shipping address
        account.BillingStreet = null; 
        user soupUser = testrecordsfactory.getUser();
         System.runAs(soupUser){
             update account; }

        // Build the detail again with the modified account
        NSCProvisioning.Detail_element details = NSCProvisioningUtil.GetDetailFromQuote(quote.Id);
         System.assertNotEquals(details, null,'details should not be null');

        // Might as well throw this in to see what happens...
        Test.setMock(WebServiceMock.class, new NSCProvisioning_Mocks.execute_pttBindingQSPort_Success());
        NSCProvisioningUtil.AsyncSendToProvisioning(quote.Id);

    }

    static testmethod void MockCallout() { 
        // Build an empty header for the request -- it's not going to hit the server,
        // so why not? 
        NSCProvisioning.Header_element header = new NSCProvisioning.Header_element(); 
        NSCProvisioning.Detail_element details = new NSCProvisioning.Detail_element(); 
        
        // Prep to do a full mocked web service call. See NSCProvisioning_Mocks class for implementation.
        Test.setMock(WebServiceMock.class, new NSCProvisioning_Mocks.execute_pttBindingQSPort_Success());
        
        // Create the port class
        NSCProvisioning.execute_pttBindingQSPort port = new NSCProvisioning.execute_pttBindingQSPort(); 

        // Make the call
        NSCProvisioning.OpportunityResponseType resp = port.execute(header, details); 
        //System.assertNotEquals(resp, null,'response should not be null');

        // Confirm we got a response from the mock
        system.assertEquals('Successful mock test. Congrats!', resp.Message); 
    }
    static testmethod void MockAsyncCallout() { 
        // Build an empty header for the request -- it's not going to hit the server,
        // so why not? 
        NSCProvisioning.Header_element header = new NSCProvisioning.Header_element(); 
        NSCProvisioning.Detail_element details = new NSCProvisioning.Detail_element(); 
        
        // Prep to do a full mocked web service call. See NSCProvisioning_Mocks class for implementation.
        Test.setMock(WebServiceMock.class, new NSCProvisioning_Mocks.execute_pttBindingQSPort_Success());
        
        // Create the port class
        AsyncNSCProvisioning.Asyncexecute_pttBindingQSPort port = new AsyncNSCProvisioning.Asyncexecute_pttBindingQSPort(); 
        Continuation continuation = new Continuation(40); 

        // Make the call (for coverage purposes only)
        AsyncNSCProvisioning.OpportunityResponseTypeFuture resp = port.beginExecute(continuation, header, details); 
        System.assertNotEquals(resp, null,'response should not be null');

    }

    static testmethod void CoverWSDLClasses() { 
        AsyncNSCProvisioning.OpportunityResponseTypeFuture f = 
            new AsyncNSCProvisioning.OpportunityResponseTypeFuture();
        
        f.getValue(); 

        AsyncNSCProvisioning.Asyncexecute_pttBindingQSPort port = 
            new AsyncNSCProvisioning.Asyncexecute_pttBindingQSPort(); 
    }
    
    
    
    
    
    

    public static Account CreateAccountData() { 
        Account a = new Account(); 
        a.Name = 'Dummy Account'; 
        a.AccountNumber = '123454';
        a.BillingStreet = '5601 N Lindero Canyon Rd';
        a.BillingCity = 'Westlake Village';
        a.BillingState = 'CA';
        a.BillingPostalCode = '91362';
        a.ShippingStreet = a.BillingStreet; 
        a.ShippingCity = a.BillingCity;
        a.ShippingState = a.BillingState;
        a.ShippingPostalCode = a.BillingPostalCode;
        a.Phone = '818-867-5309';
        a.Fax = '818-597-6310';
        //a.Master_Customer_Number__c = '123454t676r56y8700o0yu9u'; 
        a.Tier__c = '1';
        a.Interface_Type__c = 'Batch'; 
        return a;
    }
    public static Zuora__CustomerAccount__c CreateBillingAccountData(Id accountId) { 
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c(); 
        ca.Zuora__External_Id__c = '1234'; 
        ca.Zuora__AccountNumber__c = '1234';
        ca.Zuora__Account__c = accountId;
        ca.BillToFlag__c = 'Yes';
        return ca;
    }
    public static Opportunity CreateOpportunityData(Account account) { 
        Opportunity o = new Opportunity(); 
        o.name = 'Dummy Op';
        o.description = 'Dummy Op\'s Description';
        o.Proposal_Date__c = Date.today(); 
        o.Expected_Delivery_Date__c = Date.today().addDays(7); 
        o.Account = account; 
        o.AccountId = account.Id;
        o.StageName = 'Closing';
        o.CloseDate = Date.today().addDays(7);
        //o.Solution_Portfolio__c = 'DIGITAL BANKING'; - P360 Initial Change - Ahad
        o.Opportunity_Classification__c = 'Digital Insight';
        return o; 
    }
    public static zqu__Quote__c CreateQuoteData(Id accountId, Id oppId) { 
        zqu__Quote__c q = new zqu__Quote__c(); 
        q.name = 'Dummy quote'; 
        q.zqu__Account__c = accountId; 
        q.zqu__Opportunity__c = oppId;
        // This *must* match the IDs for the Billing Account (above) or an exception will be thrown and the test will fail
        q.zqu__ZuoraAccountId__c = '1234';
        q.zqu__InitialTermPeriodType__c = 'Month';
        q.zqu__RenewalTermPeriodType__c = 'Month';
        return q;
    }
    public static zqu__ZProduct__c CreateZProductData() { 
        zqu__ZProduct__c zp = new zqu__ZProduct__c(); 
        zp.Name = 'Dummy ZProduct'; 
        zp.InterfaceType__c = 'Batch'; 
        zp.ProductCategory__c = 'BillPay';
        return zp;
    }
    public static zqu__ZFeature__c CreateZFeatureData() { 
        zqu__ZFeature__c ft = new zqu__ZFeature__c(); 
        ft.Name = 'Dummy Feature'; 
        ft.zqu__ZuoraId__c = '1';
        return ft; 
    }
    public static Quote_Product__c CreateQuoteProductData(Id quoteId, Id zProductId, Id solutionProviderProductId){ 
        Quote_Product__c qp = new Quote_Product__c(); 
        qp.Quote__c = quoteId; 
        qp.ZProduct__c = zProductId; 
        qp.Notes__c = 'Note!';
        qp.Required_SPP_Interface__c = 'Integrated';
        qp.Required_SPP_Category__c = 'BillPay';
        //qp.Solution_Provider_Product__c = solutionProviderProductId; -- Fails on the SPP filter for some reason 
        qp.Action__c = 'Activate'/*'Add'*/;
        return qp; 
    }
    public static zqu__QuoteProductFeature__c CreateQuoteFeatureData(Id quoteId, Id zFeatureId) {
        zqu__QuoteProductFeature__c fp = new zqu__QuoteProductFeature__c();
        fp.zqu__Quote__c = quoteId;
        fp.zqu__ZFeature__c = zFeatureId;
        return fp;
    }
    public static Provisioning__c CreateProvisioningData(Id oppId, Id primaryContact, Id secondaryContact) { 
        Provisioning__c p = new Provisioning__c(); 
        p.Existing_Domain__c = 'http://www.lmgtfy.com'; 
        p.Primary_Contact__c = primaryContact; 
        p.Secondary_Contact__c = secondaryContact; 
        p.Project_Type__c = 'Add-on Sale'; 
        p.Opportunity__c = oppId; 
        return p; 
    }
    public static Contact CreateContactData(Account account) { 
        Contact c = new Contact(); 
        c.Account = account; 
        c.FirstName = 'Dummy';
        c.LastName = 'Contact'; 
        c.MailingStreet = '1234 Test St';
        c.MailingCity = 'Fake City';
        c.MailingState = 'CA';
        c.MailingPostalCode = '91312';
        c.OtherStreet = '1234 Other St';
        c.OtherCity = 'Fake Other City';
        c.OtherState = 'GA';
        c.OtherPostalCode = '93111';
        return c; 
    }
    public static Contract CreateContractData(Account account) { 
        Contract c = new Contract(); 
        c.CustomerSignedDate = Date.today(); 
        c.ContractTerm = 24; 
        c.Account = account; 
        c.AccountId = account.Id;
        //c.Status = 'Activated';
        return c; 
    }
    public static Solution_Provider__c CreateVendorData() { 
        Solution_Provider__c p = new Solution_Provider__c(); 
        p.Name = 'Dummy Provider'; 
        p.Solution_Provider_Number__c = '123'; 
        p.Category__c = 'DPV';
        p.Address_1__c = '123 Address'; 
        p.Address_2__c = 'Apt A'; 
        p.City__c = 'City!';
        p.State__c = 'Confusion'; 
        p.Zip__c = '99999'; 
        p.Country__c = 'USA'; 
        p.Phone__c = '818-867-5309';
        p.Fax__c = '818-867-5310';
        p.Website__c = 'http://www.lmgtfy.com/';
        return p; 
    }
    public static Solution_Provider_Contact__c CreateVendorContactData(Id vendorId) { 
        Solution_Provider_Contact__c c = new Solution_Provider_Contact__c(); 
        c.Address_1__c = '123 street st'; 
        c.Address_2__c = 'Apt A';
        c.Cell__c = '818-867-5310';
        c.Country__c = 'USA'; 
        c.City__c = 'Dummyville'; 
        c.State__c = 'Confusion'; 
        c.Contact_Notes__c = 'Always silent';
        c.Inactive__c = false; 
        c.Key_Contact__c = ''; 
        c.First_Name__c = 'Dummy'; 
        c.Last_Name__c = 'Contact';
        c.Job_Title__c = 'Stationary'; 
        c.Email__c = 'dummy@dummy4u.com'; 
        c.Phone__c = '818-867-5309';
        c.Fax__c = '818-867-5311';
        c.Service_Provider_Id__c = vendorId; 
        return c;
    }
    public static Solution_Provider_Product__c CreateVendorProductData(Id vendorId, boolean isDpv) {
        Solution_Provider_Product__c spp = new Solution_Provider_Product__c(); 
        spp.Name = 'Dummy Product'; 
        spp.Certification_Date__c = Date.today(); 
        spp.Comments__c = 'Comment!'; 
        spp.Hosting_Type__c = 'In House'; 
        spp.Interface_Type__c = 'Integrated'; 
        spp.Internal_Status__c = 'Available'; 
        spp.Product_Manager__c = 'Guy Fiere'; 
        spp.Software_Support_Type__c = isDpv ? 'DPV' : 'Digital Insight'; 
        spp.Product_Type__c = isDpv ? 'Core Processing Vendor' : 'Integrated Service Vendor'; 
        spp.Solution_Provider_Id__c = vendorId; 
        spp.Product_Manager__c = 'Dummy Manager';
        spp.Solution_Provider_Product_Category__c = 'BillPay';
        return spp;
    }
    public static Solution_Provider_Product_Interface__c CreateVendorProductInterfaceData(Id vendorProductId) { 
        Solution_Provider_Product_Interface__c  sppi = new Solution_Provider_Product_Interface__c(); 
        sppi.Interface_name__c = 'Online';
        sppi.Available__c = true;
        sppi.Middleware__c = 'Dummy Middleware';
        sppi.Solution_Provider_Product__c = vendorProductId;
        return sppi;
    }

}