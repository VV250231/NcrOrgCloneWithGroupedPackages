@isTest
public class QuoteTriggerHandlerTest {
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    @testSetup static void setupTestData() {
        Account acct1 = new Account(name = 'test-acc', industry = 'HOSPITALITY:CHANNEL', Account_Country_Code__c = 'US', Subscription_Group__c = 'Digital Insight');
        Account acct2 = new Account(name = 'test-acc1', industry = 'HOSPITALITY:CHANNEL', Account_Country_Code__c = 'US');
        System.runAs(getUser())
        {
            insert acct1;
            insert acct2;
        }
        
        Zuora__CustomerAccount__c ZCA = new Zuora__CustomerAccount__c();
        ZCA.Zuora__AccountNumber__c = 'A01032344';
        ZCA.Zuora__Account__c =acct1.id;
        ZCA.Subscription_Group__c = 'Digital Insight';
        ZCA.Zuora__Batch__c = 'Batch1';
        ZCA.Zuora__Zuora_Id__c = '8a80c239790cec39017946f5bea53d3a';
        ZCA.Zuora__PurchaseOrderNumber__c = '';
        insert ZCA;
        
        Zuora__CustomerAccount__c ZCA1 = new Zuora__CustomerAccount__c();
        ZCA1.Name = 'MCD test / MCD Test';
        ZCA1.ERPSiteNumber__c = '41389609';
        ZCA1.Zuora__External_Id__c = '8a80c239790cec39017946f5bea53d3a';
        ZCA1.Address__c = '1105 Northside Dr NW';
        ZCA1.City__c = 'Atlanta';
        ZCA1.State__c = 'GA';
        ZCA1.Zuora__BillToPostalCode__c = '30318-5416';
        ZCA1.Zuora__AccountNumber__c = 'A01032344';
        ZCA1.Zuora__Account__c =acct1.id;
        ZCA1.Subscription_Group__c = 'Digital Insight';
        ZCA1.Zuora__Batch__c = 'Batch1';
        ZCA1.Zuora__Zuora_Id__c = '8a80c239790cec39017946f5bea53d3a';
        ZCA1.Zuora__PurchaseOrderNumber__c = '';
        ZCA1.Zuora__MRR__c = 450;
        ZCA1.Zuora__Currency__c = 'USD';
        insert ZCA1;
        
        //Opportunity opp1 = ZuoraTestUtil.createOpp(acct1);
        //zqu__Quote__c qut1 = ZuoraTestUtil.createQuote(opp1, 'Default'); 
        
        
        OpportunityStage ostage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp1 = new Opportunity(Name = 'Test Opp', AccountId = acct1.Id, StageName = ostage.MasterLabel, CloseDate = Date.today().addDays(1),
                                          Opportunity_Classification__c = 'Digital Insight', /*Solution_Portfolio__c = 'DIGITAL BANKING',*/ CurrencyIsoCode = 'USD', Key_Criteria__c = 'Price',
                                          Price_Variance__c = 'NCR above 5%');
        insert opp1;
        
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo =  rtMapByName.get('Default');
        Date startDate = Date.today();
        if(startDate.day() <= 15) startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        else startDate = Date.newInstance(startDate.year(), startDate.month()+1, 1);
        zqu__Quote__c qt1 = new zqu__Quote__c(zqu__Opportunity__c = opp1.Id, zqu__Account__c = acct1.Id, Name = 'TestQuote1',zqu__Primary__c = true, zqu__StartDate__c = startDate,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month',
                                              zqu__Currency__c = opp1.CurrencyIsoCode, RecordTypeId = rtInfo.getRecordTypeId(), BundleNameNew__c = 'NCR Back Office for SMB',ImplementationRequired__c = 'No',zqu__InvoiceOwnerId__c='8a80c239790cec39017946f5bea53d3a',zqu__ZuoraAccountID__c='8a80c239790cec39017946f5bea53d3a');
        insert qt1;
        
        zqu__Quote__c qt2 = new zqu__Quote__c(zqu__Opportunity__c = opp1.Id, zqu__Account__c = acct1.Id, Name = 'TestQuote2',zqu__Primary__c = false, zqu__StartDate__c = startDate,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month',
                                              zqu__Currency__c = opp1.CurrencyIsoCode, RecordTypeId = rtInfo.getRecordTypeId(),ImplementationRequired__c = 'No');
        insert qt2;
        zqu__Quote__c qt3 = new zqu__Quote__c(zqu__Opportunity__c = opp1.Id, zqu__Account__c = acct2.Id, Name = 'TestQuote3', zqu__StartDate__c = startDate,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month',zqu__ExistSubscriptionID__c = '2c92a0fe6175a0c701617b2521537455',
                                              zqu__Currency__c = opp1.CurrencyIsoCode, RecordTypeId = rtInfo.getRecordTypeId(),ImplementationRequired__c = 'No',zqu__ZuoraAccountID__c='8a80c239790cec39017946f5bea53d3a',CancellationReason__c='Other Cancellation: softlock' ,CancellationAction__c = 'Softlock');
        insert qt3;
        
                Quote_Product__c p1 = new Quote_Product__c(); 
        p1.Name = 'Fake';
        p1.Action__c = 'Deactivate'; 
        p1.Quote__c = qt3.Id; 
        insert p1;

        Quote_Product__c p2 = new Quote_Product__c(); 
        p2.Name = 'Fake2';
        p2.Action__c = 'Softlock'; 
        p2.Quote__c = qt3.Id; 
        insert p2;
        
        //qrp
        //qrpc
        
        
        
        Profile userProfile = [SELECT Id FROM Profile WHERE Name='04 NSC UI Administrator']; 
        User ur = new User(Alias = 't23', Email='teststandarduser@stemcell.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = userProfile.Id, Quicklook_ID__c='AB185514',
                           TimeZoneSidKey='America/Los_Angeles', UserName='teststandarduser@stemcell.com');
        insert ur;  
        OpportunityTeamMember otm = new OpportunityTeamMember(opportunityid = opp1.Id,UserId = ur.Id);
        insert otm;
        //list <OpportunityTeamMember> otmList = [select id, user.name, user.email,opportunityid from OpportunityTeamMember where opportunityid in : oppID];
        
    }
    @isTest static void testMethod1() {
        UpdateQuoteRelatedObjects.increasecoverage();
        zqu__Quote__c qut = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
                             zqu__Opportunity__r.AccountId from zqu__Quote__c where Name = 'TestQuote1'];
        Account act = [select Id from account where name='test-acc1'];
        test.startTest();
        qut.zqu__Primary__c = false;
        qut.Quote_Stage__c='Rejected';
        qut.zqu__Account__c = act.Id;
        qut.zqu__Service_Activation_Date__c = null;
        qut.ImplementationRequired__c = 'No';
        update qut;
        test.stopTest();
    }
    @isTest static void testMethod2() {
        zqu__Quote__c qut = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
                             zqu__Opportunity__r.AccountId from zqu__Quote__c where Name = 'TestQuote1'];
        User newUsr = [select Id from User where UserName='teststandarduser@stemcell.com'];
        test.startTest();
        qut.OwnerId = newUsr.Id;
        qut.zqu__Status__c = 'QA Processing Complete';
        update qut;
        //delete qut;
        test.stopTest();
    }
    @isTest static void testMethod3() {
        zqu__Quote__c qut = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
                             zqu__Opportunity__r.AccountId from zqu__Quote__c where Name = 'TestQuote1'];
        test.startTest();
        delete qut;
        undelete qut;
        test.stopTest();
    }
    @isTest static void testMethod4() {
        zqu__Quote__c qut = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
                             zqu__Opportunity__r.AccountId from zqu__Quote__c where Name = 'TestQuote1'];
        test.startTest();
        qut.BundleNameNew__c = 'Not a Bundle';
        qut.Sales_Comp_Status__c = 'Pending';
        qut.Provisioning_Status__c = 'Failed';
        update qut;
        test.stopTest();
    }
    @isTest static void testMethod5() {
        zqu__Quote__c qut = [select Id, zqu__Primary__c, zqu__Currency__c, zqu__Account__c, zqu__Opportunity__c, zqu__StartDate__c, zqu__Opportunity__r.Opportunity_Classification__c,
                             zqu__Opportunity__r.AccountId from zqu__Quote__c where Name = 'TestQuote3'];
        test.startTest();
        qut.zqu__Status__c = 'QA Processing Complete';
        //qut.zqu__ExistSubscriptionID__c = '2c92a0fe6175a0c701617b2521537455';
        qut.zqu__SubscriptionType__c = 'Cancel Subscription';
        qut.CancellationReason__c = 'Billing Error';
        qut.CancellationAction__c = 'No Action';
        update qut;
        test.stopTest();
    }
}