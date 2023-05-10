@isTest
private class DIServiceNowInterfaceTest
{
    @TestSetup
    static void Setup()
    {
        Automation_Setting__c setting = new Automation_Setting__c(
                Skip_Trigger__c = true,
                Skip_Validation_Rule__c = true,
                Skip_Flow__c = true,
                Skip_Outbound_Integration__c = true
        );
        insert setting;

        DIServiceNowInterface_Mock successMock = new DIServiceNowInterface_Mock(200, 'Complete', '[{"Status: "Success"}]', null);
        DIServiceNowInterface_Mock failureMock = new DIServiceNowInterface_Mock(500, 'Complete', '[{"Status: "Failed!"}]', null);
        Test.setMock(HttpCalloutMock.class, successMock);

        SOUP_Endpoint__c endpoint = new SOUP_Endpoint__c();
        endpoint.Endpoint_URL__c = 'https://www.fakeendpoint.com';
        endpoint.Name = 'REST';

        insert endpoint;

        System.assert(endpoint.id!=null);
    }

    @isTest
    static void TestContactSync()
    {
        DIServiceNowInterface_Mock successMock = new DIServiceNowInterface_Mock(200, 'Complete', '[{"Status: "Success"}]', null);
        Test.setMock(HttpCalloutMock.class, successMock);

    }

    @isTest
    static void TestAccountSync()
    {

        DIServiceNowInterface_Mock successMock = new DIServiceNowInterface_Mock(200, 'Complete', '[{"Status: "Success"}]', null);
        DIServiceNowInterface_Mock failureMock = new DIServiceNowInterface_Mock(500, 'Complete', '[{"Status: "Fail!"}]', null);
        Test.setMock(HttpCalloutMock.class, successMock);
        Account a = new Account();
        a.Name = 'Digital Insight';
        a.Master_Customer_Number__c = '4423DI';
        a.FI_Type__c = 'Bank';
        a.FDIC__c = '4423fdic';
        a.DI_Customer__c = '4423';
        /* TODO: Create Vendors, Vendor Products, etc
        a.DPV_Provider__c;
        a.DPV_Software__c;
        a.Service_Bureau__c;
        */
        a.Tier__c = '5';
        a.Website = 'www.lmgtfy.com?q=agile';
        a.Phone = '818-867-5309';
        a.Fax = '818-597-5310';
        a.BillingStreet = '5601 N Lindero Canyon Rd';
        a.BillingCity = 'Westlake Village';
        a.BillingState = 'CA';
        a.BillingPostalCode = '91362';
        a.BillingCountry = 'US';
        a.Subscription_Group__c = 'Digital Insight';
        //insert a;
        Test.startTest();
        //update a;
        List<String> sendToSoupList = new List<String>();
        sendToSoupList.add(JSON.serialize(a));
        DIServiceNowINterface.SendToSOUP(sendToSoupList, 'Account', 'POST');

        Test.setMock(HttpCalloutMock.class, failureMock);
        DIServiceNowINterface.SendToSOUP(sendToSoupList, 'Account', 'POST');


        Contact contact = new Contact();
        contact.FirstName = 'Joe';
        contact.LastName = 'Contact';
        contact.Email = 'joe.contact@gmil.com';
        contact.Title = 'Master of Nothing';
        contact.MailingStreet = '5601 N Lindero Canyon Rd';
        contact.MailingCity = 'Westlake Village';
        contact.MailingState = 'CA';
        contact.MailingPostalCode = '91362';
        contact.MailingCountry = 'US';
        contact.Phone = '818-867-5309';
        contact.MobilePhone = '818-597-5310';
        contact.HomePhone = '818-597-5311';
        contact.OtherPhone = '818-597-5312';
        //contact.AccountId = a.Id;
        contact.Additional_Relationships__c = 'Test';
        contact.Active_Contact__c = true;
        insert contact;
        System.assert(contact.id!=null);
        system.assertEquals(contact.Active_Contact__c,True);
        Contact con = new Contact();
        con.Active_Contact__c = true;
        con.Email = null;
        con.Primary_Language__c = null;
        con.SuspendProcessing_Contact__c = true;
        // update con;
        //  update con;

        delete contact;
        //delete a;
        Test.stopTest();
    }

    @isTest
    static void TestSolutionProviderProductAndInterfaceSync()
    {

        Test.startTest();
        Solution_Provider__c sp = new Solution_Provider__c();
        sp.Category__c = 'Interface';
        //sp.Parent_Solution_Provider_Id__c;
        sp.Name = 'MSI';
        sp.Solution_Provider_Number__c = 'v1000';
        sp.Website__c = 'www.lmgtfy.com/?q=agile';
        sp.Address_1__c = '5601 N Lindero Canyon Rd';
        sp.Address_2__c = 'Suite 220';
        sp.City__c = 'Westlake Village';
        sp.State__c = 'CA';
        sp.Zip__c = '93021';
        sp.Country__c = 'US';
        sp.Phone__c = '818-867-5309';
        sp.Fax__c = '818-867-5310';
        insert sp;
        System.assert(sp.id!=null);
        system.assertEquals(sp.Country__c, 'US');
        update sp;

        Solution_Provider_Product__c spp = new Solution_Provider_Product__c();
        spp.Hosting_Type__c = 'Internal';
        spp.Name = 'Some Product';
        spp.Software_Support_Type__c = 'Internal';
        spp.Product_Type__c = 'Core Processing Vendor';
        spp.Product_Manager__c = 'Product Manager';
        spp.Internal_Status__c = 'Available';
        spp.Solution_Provider_Product_Category__c = 'Category';
        spp.Solution_Provider_Id__c = sp.Id;
        insert spp;
        System.assert(spp.id!=null);
        system.assertNotEquals(spp.Product_Type__c, 'Aloha Essential');
        update spp;

        Solution_Provider_Product_Interface__c sppi = new Solution_Provider_Product_Interface__c();
        sppi.Solution_Provider_Product__c = spp.id;
        sppi.Interface_Name__c = 'Batch';
        sppi.Available__c = true;
        sppi.Middleware__c = 'Mortar';
        sppi.Solution_Provider_Product__c = spp.id;
        insert sppi;
        System.assert(sppi.id!=null);
        system.assertNotEquals(sppi.Available__c, false);
        update sppi;

        delete sppi;
        delete spp;
        delete sp;
        Test.stopTest();
    }


    @isTest
    static void TestSolutionProviderContactSync()
    {
        Test.startTest();
        Solution_Provider_Contact__c spc = new Solution_Provider_Contact__c();
        spc.First_Name__c = 'Brick';
        spc.Last_Name__c = 'Rickard';
        spc.Email__c = 'br185076@ncr.com';
        spc.Key_Contact__c = 'CS;TS';
        spc.Inactive__c = true;
        spc.Job_Title__c = 'Master of Nothing';
        spc.Address_1__c = '8601 N Lindero Canyon Rd';
        spc.Address_2__c = 'Suite 220';
        spc.City__c = 'Westlake Village';
        spc.State__c = 'CA';
        spc.Zip__c = '91362';
        spc.Country__c = 'US';
        spc.Phone__c = '818-292-7777';
        spc.Fax__c = '818-292-8888';
        insert spc;
        System.assert(spc.id!=null);
        system.assertEquals(spc.Country__c, 'US');

        update spc;
        delete spc;
        Test.stopTest();
    }

    @isTest
    static void TestWriteHeadersToDebug()
    {
        HTTPResponse response = new HttpResponse();
        response.setHeader('test', 'test');
        DIServiceNowInterface.WriteHeadersToDebug(response);
        System.assert(response !=null);
    }
}