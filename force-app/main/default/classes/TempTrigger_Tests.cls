@isTest
private class TempTrigger_Tests {

    @TestSetup
    static void makeUser(){
        User Usr = [Select Id from User Where Name = 'Soup User'];
        Id psid = [Select Id from PermissionSet Where Name='ETL_PreventOverwrite'].Id;
        insert new PermissionSetAssignment(AssigneeId=Usr.Id, PermissionSetId=psid);
    }

    @isTest
    static void leadTest(){
        User Usr = [Select Id from User Where Name = 'Soup User'];
        insert new Automation_Setting__c(SetupOwnerId=Usr.Id, Skip_Flow__c=true,
            Skip_Outbound_Integration__c=true,Skip_Trigger__c=true,Skip_Validation_Rule__c=true);
        Lead l;
        Test.startTest();
        System.runAs(Usr){
            l = new Lead(FirstName='Test',LastName='Lead',Company='Testco');
            l.Phone='14444444';
            l.MobilePhone='14444444';
            l.Fax='14444444';
            l.Email='1test@email.com';
            l.Street='123 test';
            l.City='Atl';
            l.State='GA';
            l.PostalCode='30339';
            l.salutation='Mr';
            l.Title='CEO';
            l.website='http://www.ncr.com';
            l.Lead_Marketing_Notes__c='test';
            l.CardtronicsId__c='00000222313fakeid';
            l.LeadSource='Website';
            l.SubIndustry__c='Financial Institutions';
            l.Leadtype__c='Web';
            l.Lead_Marketing_Notes__c ='orig note';
            insert l;
            l.FirstName='Test2';
            l.Phone='4444444';
            l.MobilePhone='4444444';
            l.Fax='4444444';
            l.Email='test@email.com';
            l.Street='123 test st';
            l.Lead_Marketing_Notes__c='new note';
            update l;
            l.FirstName='Test3';
            update l;
        }
        Test.stopTest();
        Lead ld  = [Select Id, Lead_Marketing_Notes__c from Lead where Id = :l.Id];
        System.assertEquals('orig note\nnew note', ld.Lead_Marketing_Notes__c);
    }

    @isTest
    static void accountTest(){
        User Usr = [Select Id from User Where Name = 'Soup User'];
        insert new Automation_Setting__c(SetupOwnerId=Usr.Id, Skip_Flow__c=true,
            Skip_Outbound_Integration__c=true,Skip_Trigger__c=true,Skip_Validation_Rule__c=true);
        Opportunity o;
        Contract ct;
        Test.startTest();
        System.runAs(Usr){
            Account a = new Account(Name='Test Account');
            a.accountnumber='1';
            a.annualrevenue=100;
            a.billingcity='Atl';
            a.billingstate='GA';
            a.billingstreet='123 main';
            a.billingcountry='US';
            a.description='test';
            a.Fax='14444444';
            a.Phone='14444444';
            a.shippingcity='Atl';
            a.shippingstate='GA';
            a.shippingstreet='123 main';
            a.shippingcountry='US';
            a.tickersymbol='ABC';
            a.website='http://www.ncr.com';
            a.sic='1234';
            a.sicdesc='test';
            insert a;
            Contact c = new Contact(FirstName='Test',LastName='Contact');
            c.Phone='14444444';
            c.HomePhone='14444444';
            c.MobilePhone='14444444';
            c.Fax='14444444';
            c.Department='1Test';
            c.Email='1test@email.com';
            c.Active_Contact__c=true;
            c.assistantname='test';
            c.assistantphone='444444';
            c.description='test';
            c.MailingStreet='123 test';
            c.MailingCity='Atl';
            c.MailingState='GA';
            c.MailingPostalCode='30339';
            c.salutation='Mr';
            c.CardtronicsId__c='00000222314fakeid';
            c.accountid=a.id;
            insert c;
            a.Name='Test Account2';
            a.billingstreet='123 main st';
            a.shippingstreet='123 main st';
            update a;
            c.FirstName='Test2';
            c.Phone='4444444';
            c.HomePhone='4444444';
            c.MobilePhone='4444444';
            c.Fax='4444444';
            c.Department='Test';
            c.Email='test@email.com';
            c.MailingStreet='123 test dr';
            update c;
            o = new Opportunity(AccountId=a.id,ContactId=c.Id,Name='test',CloseDate=Date.parse('01/01/2025'),StageName='Prospecting');
            insert o;

            List<Product2> prodList = new List<Product2>();
            for(Integer i=0;i<2;i++) {
                Product2 p = new Product2();
                p.Name = 'Test Product Test Product'+i;
                p.pmdm_product_family__c ='Hardware like a GPU' +i;
                prodList.add(p);
            }
            insert prodList;
            
            List<PricebookEntry> peList = new List<PricebookEntry>();
            for(Product2 pr: prodList) {
                PricebookEntry pe = new PricebookEntry();
                pe = TestRecordsFactory.createPriceBookEntry(pr);
                peList.add(pe);
            }
            
            List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
            for(PricebookEntry pe: [select id, product2.product_category__c from PricebookEntry where pricebook2Id =: GlobalVariable.pricebookId]) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.opportunityId = o.Id;
                oli.PriceBookEntryId= pe.Id;
                oli.Quantity=10;
                oli.TotalPrice=1000;
                oli.SW_Unattached_Code__c='Attached';
                oliList1.add(oli);                  
            }
            insert oliList1; // this will cause the OpportunityUpdateTempTrigger to run 
            ct = new Contract(AccountID = a.Id, Opportunity__c=o.Id, Status = 'Draft');
            insert ct;
        }
        Test.stopTest();
        Contract ctr  = [Select Id, Products__c from Contract where Id = :ct.Id];
        System.assertEquals('Test Product Test Product0, Test Product Test Product1', ctr.Products__c);
    }

    // @isTest
    // static void bulkTest(){
    //     User Usr = [Select Id from User Where Name = 'Soup User'];
    //     insert new Automation_Setting__c(SetupOwnerId=Usr.Id, Skip_Flow__c=true,
    //         Skip_Outbound_Integration__c=true,Skip_Trigger__c=true,Skip_Validation_Rule__c=true);
    //     Test.startTest();
    //     System.runAs(Usr){
    //         Account a = new Account(Name='Test Account');
    //         a.accountnumber='1';
    //         a.annualrevenue=100;
    //         a.billingcity='Atl';
    //         a.billingstate='GA';
    //         a.billingstreet='123 main';
    //         a.billingcountry='US';
    //         a.description='test';
    //         a.Fax='14444444';
    //         a.Phone='14444444';
    //         a.shippingcity='Atl';
    //         a.shippingstate='GA';
    //         a.shippingstreet='123 main';
    //         a.shippingcountry='US';
    //         a.tickersymbol='ABC';
    //         a.website='http://www.ncr.com';
    //         a.sic='1234';
    //         a.sicdesc='test';
    //         insert a;
    //         Contact c = new Contact(FirstName='Test',LastName='Contact');
    //         c.Phone='14444444';
    //         c.HomePhone='14444444';
    //         c.MobilePhone='14444444';
    //         c.Fax='14444444';
    //         c.Department='1Test';
    //         c.Email='1test@email.com';
    //         c.Active_Contact__c=true;
    //         c.assistantname='test';
    //         c.assistantphone='444444';
    //         c.description='test';
    //         c.MailingStreet='123 test';
    //         c.MailingCity='Atl';
    //         c.MailingState='GA';
    //         c.MailingPostalCode='30339';
    //         c.salutation='Mr';
    //         c.CardtronicsId__c='00000222314fakeid';
    //         c.accountid=a.id;
    //         insert c;
    //         List<Opportunity> opps = new List<Opportunity>();
    //         for(Integer i=0;i<200;i++){
    //             opps.add(new Opportunity(AccountId=a.id,ContactId=c.Id,Name='test'+i,CloseDate=Date.parse('01/01/2025'),StageName='Prospecting'));
    //         }
    //         insert opps;

    //         List<Product2> prodList = new List<Product2>();
    //         for(Integer i=0;i<2;i++) {
    //             Product2 p = new Product2();
    //             p.Name = 'Test Product Test Product'+i;
    //             p.pmdm_product_family__c ='Hardware like a GPU' +i;
    //             prodList.add(p);
    //         }
    //         insert prodList;
            
    //         List<PricebookEntry> peList = new List<PricebookEntry>();
    //         for(Product2 pr: prodList) {
    //             PricebookEntry pe = new PricebookEntry();
    //             pe = TestRecordsFactory.createPriceBookEntry(pr);
    //             peList.add(pe);
    //         }
            
    //         List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
    //         for (Opportunity o:opps){
    //             for(PricebookEntry pe: [select id, product2.product_category__c from PricebookEntry where pricebook2Id =: GlobalVariable.pricebookId]) {
    //                 OpportunityLineItem oli = new OpportunityLineItem();
    //                 oli.opportunityId = o.Id;
    //                 oli.PriceBookEntryId= pe.Id;
    //                 oli.Quantity=10;
    //                 oli.TotalPrice=1000;
    //                 oli.SW_Unattached_Code__c='Attached';
    //                 oliList1.add(oli);                  
    //             }
    //         }
    //         insert oliList1; // this will cause the OpportunityUpdateTempTrigger to run 
    //     }
    //     Test.stopTest();
    // }

}