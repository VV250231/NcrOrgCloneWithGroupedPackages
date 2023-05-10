@isTest
public class JPReasonOfNoPaymentProcessingCtrlTest {
    @isTest
    public static void unitTest(){
        JetPay_Access__c jpAccessObj = new JetPay_Access__c();
        jpAccessObj.Name='Record1';
        jpAccessObj.Allow_All_Users__c= false;
        jpAccessObj.Specific_Users__c = 'ss185863';
        insert jpAccessObj;
        
        
        List<Product2> products = new List<Product2>();
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 paymentProd = new Product2( Name='NCR Payments Processing', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWProduct1);
        products.add(paymentProd);
        
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        //insert HWProduct1;
        insert products;
        /*PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = HWProduct1.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;*/
        Account act=createAccount('123');
        
        Opportunity opp = createSimpleOpportunityNew(act);
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        OpportunityLineItem OLI1 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(HWProduct1));
        /*OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = standardPrice.id;
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='Payments Processing';
        OLI1.source__c = 'Package';
        OLI1.Sites__c = 10;
        insert OLI1;*/
        
        
        Zuora__CustomerAccount__c zcAcc = new Zuora__CustomerAccount__c();
        zcAcc.City__c='Test City';
        zcAcc.State__c='Test State';
        zcAcc.Zuora__Account__c=act.Id;
        zcAcc.Name='12345';
        zcAcc.ERPSiteNumber__c='123';
        //zcAcc.isAdded=true;
        
        insert zcAcc;
        
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        insert PaySite;
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';
        insert PaySite1;
        
        String sTempSearchKey='123';
        
        List<JP_EndPoint__c> lstJPEnd= new List<JP_EndPoint__c>();
        JP_EndPoint__c JPEnd = new JP_EndPoint__c();
        JPEnd.Name='JPAuthService';
        JPEnd.EndPoint_URL__c='https://ncrstag-stag.apigee.net/oauth/client_credential/accesstoken?grant_type=client_credentials&';
        JPEnd.User_Name__c='c900131f8abe42d39bac1cc1325c4aab';
        JPEnd.Password__c='6abf1ef743a4483791dfbffd193606db';
        lstJPEnd.add(JPEnd);
        
        List<JP_EndPoint__c> lstJPEnd1= new List<JP_EndPoint__c>();
        JP_EndPoint__c JPEnd1 = new JP_EndPoint__c();
        JPEnd1.Name='SubmitApplication';
        JPEnd1.EndPoint_URL__c='https://ncrstag-stag.apigee.net/payos/api/v1.0/application?partiatett';
        lstJPEnd.add(JPEnd1);
        
        JP_EndPoint__c JPEnd2 = new JP_EndPoint__c();
        JPEnd2.Name='JPTemplate';
        JPEnd2.EndPoint_URL__c='https://ncrstag-stag.apigee.net/payos/api/v1.0/application/template';
        lstJPEnd.add(JPEnd2);
        
        /*No_Attach_Code_Profiles__c noAttache = new No_Attach_Code_Profiles__c();
        noAttache.Name = 'Record1';
        //noAttache.Include_HWM_SWM_Profiles__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        noAttache.Included_Payments_Profile__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        insert noAttache;*/
        
        All_profie_config__c noAttache = new All_profie_config__c();
        noAttache.Name = 'No Attach Codes Profiles';
        //noAttache.Include_HWM_SWM_Profiles__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        noAttache.Profile_Name__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        insert noAttache;
        
        Prod_Reason_Required__c  rsnReq = new Prod_Reason_Required__c();
        rsnReq.Name='Payments Related';
        rsnReq.On__c=true;
        rsnReq.Prod_Included__c='Aloha POS, Mobile Pay';
        insert rsnReq;
        
        insert lstJPEnd;
        JPReasonOfNoPaymentProcessingCtrl.ReasonCodeRequiredWrapper testReasObj = JPReasonOfNoPaymentProcessingCtrl.reasonRequireOrNot(opp.Id);
        System.assert(testReasObj!=null); 
        JPReasonOfNoPaymentProcessingCtrl.isContractDateAvl(opp.id);
    }      
    public static Account createAccount(String MCN) {
        //RecordType r =[Select id from recordtype where developername ='Partner'];
		Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            CDM_Account_Status__c = 'Active',
            Active_Account__c = true,        
            Master_Customer_Number__c = mcn + System.now().getTime(),
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,//'0127000000014kqAAA',
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
          /*  CAP_Watch__c = 'CAP',*/
            //EBA_SF-688
            account_region__c='INDIA',
            BillingStreet='Test',
            BillingCity='Test',
            BillingState='Test',
            BillingPostalCode='Test',
            BillingCountry='Test',
            Payments_Agent_ID__c='1099'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
        return a;
    }
    public static Opportunity createSimpleOpportunityNew(Account actt) {
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
		Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();

        // create new Opportunity object 
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = actt.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.Channel_Office__c=actt.id;
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;//'012700000001PoZ';
        opp.Pricing_Type__c='Tiered';
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        //opp.Contacts__c = createContact(actt).Id;
        opp.Pricing_Type__c='Tiered';
        //opp.Pricing_Review_Request_Status__c='Approve';
        opp.Pricing_Review_Request_Status__c='Withdrawn';
        //opp.pricebook2Id = '01s700000002GMc';
        insert opp;
        return opp;
    }
}