/*************************************************************************************************
*   Author      : Monika
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-2024    9-9-2022    Monika     Payment Processing: Option to Withdraw Payments Application (Non-CPQ) 
*************************************************************************************************/
@isTest
public class TestGeneratePaymentsAppCtrl {
    private static final Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
    
    @isTest
    public static void testController1(){
        JetPay_Access__c jpAccessObj = new JetPay_Access__c();
        jpAccessObj.Name='Record1';
        jpAccessObj.Allow_All_Users__c= false;
        jpAccessObj.Specific_Users__c = 'ss185863';
        jpAccessObj.Specific_Profiles__c = 'test';
        jpAccessObj.Specific_Roles__c = 'test';
        insert jpAccessObj;
        List<Product2> products = new List<Product2>();
        Id priceBookID = Test.getStandardPricebookId();
        System.debug(priceBookID);
        Product2 HWProduct1 = new Product2( Name='Connected Payments', CurrencyIsoCode='USD', PMDM_Unique_Key__c='123456789',
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        /*Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'SW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWProduct1);
        products.add(SWProduct1);
        products.add(HWMProduct1);*/
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        insert HWProduct1;
        
        Account act = createAccounts('123').get(0);
        Account act1 = createAccounts('234').get(1);
        Opportunity opp = createSimpleOpportunityNew(act);
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(HWProduct1);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=2;
        oli.TotalPrice=20;
        oli.Revenue_Type__c='Payments Processing';
        oli.source__c = 'Package';
        oli.Sites__c = 10;
        oli.Topline_Product_Lkp__c = HWProduct1.Id;
        insert oli;
        
        Account site=createSite(act);
        
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
        
        insert lstJPEnd;
        
        AccountContactRelation acr = createRelContact(act, act1);
        Test.startTest(); 
        List<GeneratePaymentsApplicationController.BillingSitesWrapper>  wrapsiteWrapList =  GeneratePaymentsApplicationController.getSearchBillingList(sTempSearchKey,act.Id);
        for(GeneratePaymentsApplicationController.BillingSitesWrapper eer:wrapsiteWrapList){
            eer.isAdded=true;
        }
        // String a =JSON.serialize(wrapsiteWrapList);
        // String billingSitesStr = wrapsiteWrapList.toString();
        GeneratePaymentsApplicationController.executeButtonsStatusCalculation(opp.Id);
        System.debug('****opid**'+opp.Id);
        GeneratePaymentsApplicationController.getOpportunity(opp.Id); 
        GeneratePaymentsApplicationController.getBillingSites(act.Id);
        GeneratePaymentsApplicationController.AssignTasktoQueue(opp.Id);
        opp.Pricing_Type__c='Tiered';
        opp.Payment_Sales_Offer__c= 'EDC Promo';
        opp.Pricing_Review_Request_Status__c='Approve';
        update opp;
        GeneratePaymentsApplicationController.executeButtonsStatusCalculation(opp.Id);
        GeneratePaymentsApplicationController.updatePricingApprove(opp.Id);
        GeneratePaymentsApplicationController.getOppRecord(opp.Id);
        GeneratePaymentsApplicationController.getRelatedTask(opp.Id);
        GeneratePaymentsApplicationController.getRelatedTaskStatus(opp.Id);
        
        system.debug('vvvvvvvvv'+GeneratePaymentsApplicationController.sendApplication(opp.Id,JSON.serialize(wrapsiteWrapList)));
        
        GeneratePaymentsApplicationController.withdrawnApplication(opp.Id,'testing');
        GeneratePaymentsApplicationController.GetAllACHContacts(act.Id);
        GeneratePaymentsApplicationController.SavePaymtAsigneOnOpp(TestRecordsFactory.createContact(act).Id, opp.Id);
        //Account Site=createSite(act); 
        Sbqq__Quote__c Qte= createQte(act, site);
        GeneratePaymentsApplicationController.SavePaymtAsigneOnQte(TestRecordsFactory.createContact(act).Id, Qte.Id);    
        GeneratePaymentsApplicationController.QteWrapper qtwrap = new GeneratePaymentsApplicationController.QteWrapper(PaySite);
        GeneratePaymentsApplicationController.ApprovePricingResponse aprrsp = new GeneratePaymentsApplicationController.ApprovePricingResponse(opp, 'test');
        String[] s=new String[]{'12','123'};
        JP_MerchantOnBoardingStatusService.Tids tidss;// = new JP_MerchantOnBoardingStatusService.Tids;
        //tidss.eCommerce[0]='Test';
        //tidss.InStore[0]='Test';
        
        JP_MerchantOnBoardingStatusService.upsertCase('123', '123',
                                                          '123', '123','NewPend', '12', '12', '123', '123',s,tidss, '123', '123',
                                                          'Test', 'Test','Test', 'Test','Test','Test'); 
        
        
        List<Zuora__CustomerAccount__c> zList=[Select Id, Name,Address__c,City__c,State__c,Zuora__BillToState__c,Zuora__BillToPostalCode__c,Zuora__BillToCountry__c, ERPSiteNumber__c, Zuora__Status__c,StoreID__c FROM Zuora__CustomerAccount__c where Zuora__Account__c =: act.Id and Name like :sTempSearchKey];
        OpportunityLineItem oooppp= [SELECT id,OpportunityID, Opportunity.AccountId, Opportunity.Pricing_Review_Request_Status__c,Revenue_Type__c FROM OpportunityLineItem][0];
        System.debug('++++++++++'+oooppp);
        System.debug('+++size:'+zList.size());
        Test.stopTest(); 
        
        
    } 
    
    @isTest
    public static void testControllerNegative(){
        
        
        List<Product2> products = new List<Product2>();
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'SW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWProduct1);
        products.add(SWProduct1);
        products.add(HWMProduct1);
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        insert HWProduct1;
        Account act=createAccount2('456');
        Test.startTest(); 
        Opportunity opp = createSimpleOpportunityNew1(act);
        /*OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = standardPrice.id;
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='Payments Processing';
        OLI1.source__c = 'Package';
        OLI1.Sites__c = 10;
        insert OLI1;*/
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(HWProduct1);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=HWProduct1.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        insert oli;
        
        //Add billing site
        Account site=createSite(act);
        List<NCR_Payments_Site__c> psL=new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        //insert PaySite;
        psL.add(PaySite);
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';
        //
        //insert PaySite1;
        psL.add(PaySite1);
        insert psL;
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
        
        insert lstJPEnd;
        
        List<GeneratePaymentsApplicationController.BillingSitesWrapper>  wrapsiteWrapList =  GeneratePaymentsApplicationController.getSearchBillingList(sTempSearchKey,act.Id);
        for(GeneratePaymentsApplicationController.BillingSitesWrapper eer:wrapsiteWrapList){
            eer.isAdded=true;
        }
        // String a =JSON.serialize(wrapsiteWrapList);
        // String billingSitesStr = wrapsiteWrapList.toString();
        //GeneratePaymentsApplicationController.executeButtonsStatusCalculation(opp.Id);
        System.debug('****opid**'+opp.Id);
        GeneratePaymentsApplicationController.getOpportunity(opp.Id); 
        // GeneratePaymentsApplicationController.getBillingSites(act.Id);
        
        GeneratePaymentsApplicationController.getBillingSites(act.Id);
        GeneratePaymentsApplicationController.updatePricingApprove(opp.Id+'1');
        GeneratePaymentsApplicationController.getOppRecord(opp.Id);
        GeneratePaymentsApplicationController.getRelatedTask(opp.Id+'1');
        GeneratePaymentsApplicationController.getRelatedTaskStatus(opp.Id+'1');
        
        GeneratePaymentsApplicationController.sendApplication(opp.Id,JSON.serialize(wrapsiteWrapList));
        String[] s=new String[]{'12','123'};
        JP_MerchantOnBoardingStatusService.Tids tidss;// = new JP_MerchantOnBoardingStatusService.Tids;
       // tidss.eCommerce[0]='Test';
       // tidss.InStore[0]='Test';
        
        JP_MerchantOnBoardingStatusService.upsertCase('123', '123',
                                                          '123', '123','NewPend', '12', '12', '123', '123',s,tidss, '123', '123',
                                                          'Test', 'Test','Test', 'Test','Test','Test'); 
        
        List<Zuora__CustomerAccount__c> zList=[Select Id, Name,Address__c,City__c,State__c,Zuora__BillToState__c,Zuora__BillToPostalCode__c,Zuora__BillToCountry__c, ERPSiteNumber__c, Zuora__Status__c,StoreID__c FROM Zuora__CustomerAccount__c where Zuora__Account__c =: act.Id and Name like :sTempSearchKey];
        OpportunityLineItem oooppp= [SELECT id,OpportunityID, Opportunity.AccountId, Opportunity.Pricing_Review_Request_Status__c,Revenue_Type__c FROM OpportunityLineItem][0];
        System.debug('++++++++++'+oooppp);
        System.debug('+++size:'+zList.size());
        Test.stopTest(); 
        
        
    } 
    
    @isTest
    public static void testController3(){
        List<Product2> products = new List<Product2>();
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'SW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWProduct1);
        products.add(SWProduct1);
        products.add(HWMProduct1);
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        insert HWProduct1;
        
        Account act=createAccount2('456');
        Test.startTest(); 
        Opportunity opp = createSimpleOpportunityNew1(act);
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        /*OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = standardPrice.id;
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='Payments Processing';
        OLI1.source__c = 'Package';
        OLI1.Sites__c = 10;
        insert OLI1;*/
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(HWProduct1);
        //OpportunityLineItem oli = new OpportunityLineItem();
        OLI1.opportunityId =opp.Id;
        OLI1.PriceBookEntryId= pe.Id;
        OLI1.Quantity=10;
        OLI1.TotalPrice=1000;
        OLI1.Product_Category__c=HWProduct1.Product_Category__c ;
        OLI1.SW_Unattached_Code__c='Attached';
        insert OLI1;
        
        //Add billing site
        Account site=createSite(act);
        List<NCR_Payments_Site__c> psL=new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        //insert PaySite;
        psL.add(PaySite);
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';
        //
        //insert PaySite1;
        psL.add(PaySite1);
        insert psL;
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
        
        insert lstJPEnd;
        
        List<GeneratePaymentsApplicationController.BillingSitesWrapper>  wrapsiteWrapList =  GeneratePaymentsApplicationController.getSearchBillingList(sTempSearchKey,act.Id);
        for(GeneratePaymentsApplicationController.BillingSitesWrapper eer:wrapsiteWrapList){
            eer.isAdded=true;
        }
        // String a =JSON.serialize(wrapsiteWrapList);
        // String billingSitesStr = wrapsiteWrapList.toString();
        //GeneratePaymentsApplicationController.executeButtonsStatusCalculation(opp.Id);
        System.debug('****opid**'+opp.Id);
        Task task = new Task(Status='In Progress',WhatId=opp.Id, Subject = 'Pricing Review Request: More Information');
        insert task;
        GeneratePaymentsApplicationController.updateMoreInfoProvided(opp.Id);
        
        
        Test.stopTest(); 
        
        
    } 
    @isTest
    public static void testController4(){
        
        
        List<Product2> products = new List<Product2>();
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'SW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWProduct1);
        products.add(SWProduct1);
        products.add(HWMProduct1);
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        insert HWProduct1;
       
        Account act=createAccount2('456');
        Test.startTest(); 
        Opportunity opp = createSimpleOpportunityNew1(act);
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(HWProduct1);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=HWProduct1.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        insert oli;
        //Add billing site
        Account site=createSite(act);
        
        List<NCR_Payments_Site__c> psL=new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        //insert PaySite;
        psL.add(PaySite);
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';
        //
        //insert PaySite1;
        psL.add(PaySite1);
        insert psL;
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
        
        insert lstJPEnd;
        
        List<GeneratePaymentsApplicationController.BillingSitesWrapper>  wrapsiteWrapList =  GeneratePaymentsApplicationController.getSearchBillingList(sTempSearchKey,act.Id);
        for(GeneratePaymentsApplicationController.BillingSitesWrapper eer:wrapsiteWrapList){
            eer.isAdded=true;
        }
        // String a =JSON.serialize(wrapsiteWrapList);
        // String billingSitesStr = wrapsiteWrapList.toString();
        //GeneratePaymentsApplicationController.executeButtonsStatusCalculation(opp.Id);
        System.debug('****opid**'+opp.Id);
        
        GeneratePaymentsApplicationController.getTotalBillingSites(act.Id);
        GeneratePaymentsApplicationController.requestRateReviewUpdate(opp.Id);
        GeneratePaymentsApplicationController.updatePricingReject(opp.Id);
        
        Test.stopTest(); 
        
        
    } 
    @isTest
    public static void testController5(){
        
        
        List<Product2> products = new List<Product2>();
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'SW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWProduct1);
        products.add(SWProduct1);
        products.add(HWMProduct1);
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        insert HWProduct1;
        Account act=createAccount2('456');
        Test.startTest(); 
        Opportunity opp = createSimpleOpportunityNew1(act);
        /*OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityID = opp.id;
        OLI1.PricebookEntryId = standardPrice.id;
        OLI1.Quantity = 2;
        OLI1.unitprice = 20;
        OLI1.Revenue_Type__c='Payments Processing';
        OLI1.source__c = 'Package';
        OLI1.Sites__c = 10;
        insert OLI1;*/
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(HWProduct1);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=HWProduct1.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        insert oli;
        //Add billing site
        Account site=createSite(act);
        List<NCR_Payments_Site__c> psL=new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        //insert PaySite;
        psL.add(PaySite);
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';
        //
        //insert PaySite1;
        psL.add(PaySite1);
        insert psL;
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
        
        insert lstJPEnd;
        
        List<GeneratePaymentsApplicationController.BillingSitesWrapper>  wrapsiteWrapList =  GeneratePaymentsApplicationController.getSearchBillingList(sTempSearchKey,act.Id);
        for(GeneratePaymentsApplicationController.BillingSitesWrapper eer:wrapsiteWrapList){
            eer.isAdded=true;
        }
        // String a =JSON.serialize(wrapsiteWrapList);
        // String billingSitesStr = wrapsiteWrapList.toString();
        //GeneratePaymentsApplicationController.executeButtonsStatusCalculation(opp.Id);
        System.debug('****opid**'+opp.Id);
        Task task = new Task(Status='In Progress',WhatId=opp.Id, Subject = 'Pricing Review Request');
        insert task;
        GeneratePaymentsApplicationController.updatePricingWithdraw(opp.Id);
        GeneratePaymentsApplicationController.updateMoreInfo(opp.Id);
        
        Test.stopTest(); 
        
        
    } 
    
    @isTest
    public static void testControllerQte(){
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
        
        insert lstJPEnd;
        Account act=createAccount2('456');
        Account Site=createSite(act);  
        List<GeneratePaymentsApplicationController.BillingSitesWrapper>  wrapsiteWrapList =  GeneratePaymentsApplicationController.getSearchBillingList('',act.Id);
        SBQQ__Quote__c qte=createQte(act, site);   
        
        /*NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        PaySite.Quote__c = qte.Id;
        insert PaySite;*/
        
        Test.startTest();
       
        GeneratePaymentsApplicationController.valQteInfo(qte.id);
        GeneratePaymentsApplicationController.sndApplFmQte(qte.id);        
        Test.stopTest(); 
    } 
    
    @isTest
    public static void testController2(){
        
        
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        insert PaySite;
        Test.startTest(); 
        String[] s=new String[]{'12','123'};
        /*JP_MerchantOnBoardingStatusService.upsertCase('123', '123',
                                                          '123', '123','NewPend', '12', '12', '123', '123',s,'Test', '123', '123'); */
        
        Test.stopTest(); 
        
        
    } 
    public class BillingSitesWrapper {
        @AuraEnabled public Zuora__CustomerAccount__c billingSite{get;set;}
        @AuraEnabled public Boolean isAdded{get;set;}
        
        public BillingSitesWrapper(Zuora__CustomerAccount__c billingSite, Boolean isAdded) {
            this.billingSite = billingSite;
            this.isAdded = isAdded;
        }
    }
    
    
    public static Opportunity createSimpleOpportunity(Account actt) {
        // create new Opportunity object 
        Id priceBookID = Test.getStandardPricebookId();
        RecordType r = [Select id from Recordtype where name='Include in Funnel'];
        Account accnt= TestRecordsFactory.createAccount();
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = actt.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp.CURRENCYISOCODE = 'USD';
        //opp.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        //opp.recordTypeId = '012700000001PoZ';//hardcode id
        opp.recordTypeId = r.Id;
        //opp.ContactId =TestRecordsFactory.createContact(accnt).Id;
        opp.Contacts__c = TestRecordsFactory.createContact(actt).Id;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        opp.Pricing_Type__c='Tiered';
        opp.POS__c='NCR Aloha';
        opp.Pricing_Review_Request_Status__c='Approve';
        //opp.Sales_Org__c=null;
        opp.Sales_Org__c=TestRecordsFactory.createSalesOrg().Id;
        opp.Pricebook2Id = priceBookID;
        
        insert opp;
        System.debug('inserted Opp'+opp);
        return opp;
    }
    public static List<Account> createAccounts(String MCN) {
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //RecordType r = [Select id from RecordType where name='Partner'];
        List<Account> accLst = new List<Account>();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,  
            CDM_Account_Status__c = 'Active',      
            Master_Customer_Number__c = mcn + 'test1' + System.now().getTime(),
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,//hardcode id
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA',
            BillingStreet='Test',
            BillingCity='Test',
            BillingState='Test',
            BillingPostalCode='Test',
            BillingCountry='Test',
            Payments_Agent_ID__c='1099',
            CDM_Account_Type__c = 'Test'
        );
        
         Account a1 = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,
            CDM_Account_Status__c = 'Active',        
            Master_Customer_Number__c = mcn + 'test2'+ System.now().getTime(),
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,//hardcode id
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA',
            BillingStreet='Test',
            BillingCity='Test',
            BillingState='Test',
            BillingPostalCode='Test',
            BillingCountry='Test',
            Payments_Agent_ID__c='1099',
            CDM_Account_Type__c = 'Test'
        );
        accLst.add(a);
        accLst.add(a1);
        System.runAs(TestRecordsFactory.getUser()){
            insert accLst;
        }
        return accLst;
    }
    public static Account createAccount2(String MCN) {
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //RecordType r = [Select id from RecordType where name='Partner'];
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,   
            CDM_Account_Status__c = 'Active',     
            Master_Customer_Number__c = mcn + System.now().getTime(),
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,//hardcode id
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA',
            BillingStreet='Test',
            BillingCity='Test',
            BillingState='Test',
            BillingPostalCode='Test',
            BillingCountry='Test'
            //Payments_Agent_ID__c='1099'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
        return a;
    }
    
    public static Opportunity createSimpleOpportunityNew(Account actt) {
        Id r = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Id priceBookID = Test.getStandardPricebookId();
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        Account partnerAct = CPQ_TestDataFactory.createPartnerAccount('p', null);
        System.runAs(TestRecordsFactory.getUser()){
            insert partnerAct;
        }
        opp.AccountID = actt.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.Channel_Office__c=partnerAct.id;
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
        opp.recordTypeId = r;//hardcode id
        opp.Pricing_Type__c='Tiered';
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        opp.Contacts__c = createContact(actt).Id;
        opp.Pricing_Type__c='Tiered';
         opp.POS__c='NCR Aloha';
        //opp.Pricing_Review_Request_Status__c='Approve';
        opp.Pricing_Review_Request_Status__c='Withdrawn';
        //opp.Pricebook2Id = priceBookID;
        opp.EBT_Monthly_Access_Fee__c = 5000.12345;
        opp.EBT_Per_Transaction_Fee__c = 2000.12;
        
        insert opp;
        return opp;
    }
    
    public static Opportunity createSimpleOpportunityNew1(Account actt) {
        Id r = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        // RecordType r = [Select id from Recordtype where name='Include in Funnel'];
        // create new Opportunity object 
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = actt.id;
        opp.Name = 'OppQuote Linkage Opportunity';
        // opp.Channel_Office__c=actt.id;
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
        opp.recordTypeId = r;//hardcode id
        // opp.Pricing_Type__c='Tiered';
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        opp.Pricing_Review_Request_Status__c='Withdrawn';
        opp.Total_Annual_Volume__c=100;
        opp.Total_Annual_Transactions__c=100;
        opp.POS__c='NCR Aloha';
        opp.EBT_Monthly_Access_Fee__c = 2000.12;
        opp.EBT_Per_Transaction_Fee__c = 3000;
        //opp.Contacts__c = createContact(actt).Id;
        // opp.Pricing_Type__c='Tiered';
        // opp.Pricing_Review_Request_Status__c='Approve';
        insert opp;
        return opp;
    }
    
    public static Contact createContact(Account a) {
        Contact c = new Contact();
        c.Accountid = a.id;
        c.LastName = 'test1';
        c.Email = 'test1@test.com';
        c.Phone='56789789';
        if(a.Subscription_Group__c == 'Digital Insight') {
            c.Additional_Relationships__c = 'Digital Insight';
        }
        insert c;
        
        return c;
    }
    
    
    public static AccountContactRelation createRelContact(Account a, Account a1) {
        Contact c = new Contact();
        c.AccountId = a1.Id;
        c.LastName = 'test1';
        c.Email = 'test1@test.com';
        c.Phone='56789789';
        if(a.Subscription_Group__c == 'Digital Insight') {
            c.Additional_Relationships__c = 'Digital Insight';
        }
        insert c;
        
        AccountContactRelation acr = new AccountContactRelation(AccountId=a.Id, ContactId=c.Id);
        insert acr;
        return acr;
    }
    
    
    public static Account createSite(Account a) {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount=a;
        Account testAccount;
        System.runAs( Usr ){
            testAccount = new Account(
                RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123 Test Company Name1234',Site_Number__c='123',cdm_Store_Branch_Number__c='9011',
                Primary_Bill_To__c = true,
                Active_Account__c = true,
                CDM_Account_Status__c = 'Active',
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
        }
        return testAccount;
    }
    public static SBQQ__Quote__c createQte(Account a, Account site) {
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            qtc_Bill_To_Site__c =site.Id,
            Deliver_To_Site__c =site.Id,
            qtc_Ship_To_Account__c =site.Id,
            SBQQ__Account__c = a.Id
        );
        
        
        
        testQuote.SBQQ__PrimaryContact__c = createContact(a).id;
        insert testQuote;
        return testQuote;
    }
    
    
}