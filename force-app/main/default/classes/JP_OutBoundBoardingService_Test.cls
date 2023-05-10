/*************************************************************************************************
*   Author      : Monika
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-2024		9-9-2022		Monika	   Payment Processing: Option to Withdraw Payments Application (Non-CPQ) 
*************************************************************************************************/
@isTest
public class JP_OutBoundBoardingService_Test {
    @isTest
    public static void testControllerNegative(){        
        
        List<Product2> products = new List<Product2>();
        Product2 paymentsProduct = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        
        
        products.add(paymentsProduct);
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        PaymentFeeDefaultValueObj.Name='test';
        insert PaymentFeeDefaultValueObj;
        
        insert products;  
         
        Account act=createAccount('Test456');
        Test.startTest(); 
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(act);
        
        opp.Total_Annual_Volume__c=100000;
        opp.Total_Annual_Transactions__c=1000000;
        update opp;
        
        Contact c=TestRecordsFactory.createContact(act);
        c.phone='11111111111';
        update c;
            
        opp.Payments_Application_Signee__c=c.id;
        update opp;
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(paymentsProduct);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=paymentsProduct.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        insert oli;
        
        //Add billing site
        Account site=TestRecordsFactory.createBillToAccount('TestSite', act.Id);
        
        //adding address to acc and site
        act.BillingStreet='Account';
        act.BillingCity='Atlanta';
        act.BillingCountry='US';
        act.BillingState='GA';
        act.BillingPostalCode='30306';
        
        site.BillingStreet='Account';
        site.BillingCity='Atlanta';
        site.BillingCountry='US';
        site.BillingState='GA';
        site.BillingPostalCode='30306';
        List <account> aL=new List <account>();
        aL.add(act);
        aL.add(site);
        System.runAs(TestRecordsFactory.getUser()){
        update aL;
        }
        
        List<NCR_Payments_Site__c> psL=new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        PaySite.Opportunity__c = opp.Id;

        //insert PaySite;
        psL.add(PaySite);
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';        
        PaySite1.Merchant_Application_Id__c = '123';
        PaySite1.Cobrand__c = 'ncralohapfintegration';
        PaySite1.Opportunity__c = opp.Id;
       
        //insert PaySite1;
        psL.add(PaySite1);
        
        NCR_Payments_Site__c PaySite2 = new NCR_Payments_Site__c();
        PaySite2.InfiniceptApplicationId__c='123';  
        psL.add(PaySite2);
        
        insert psL;
        
        
        
        Opportunity Opp1 = [Select Id, Opportunity_Number__c from Opportunity where id=:opp.Id LIMIT 1];
        String response = '[{"merchantClaimURL":"https://merchantapp.io:443/ncralohapfintegration/Merchant/Claim/758cb569-aeb0-4370-ba03-a48ca9a62043","administratorURL":"https://merchantapp.io:443/ncralohapfintegration/CoBrands/MerchantUW?applicationId=136396","merchantApplicationId":"136396","externalMerchantApplicationId":"e2d83032f3ea4250841c521d7e18a070/790ce820ea974c308caefbcb4bf2f4e5","infiniceptApplicationId":"c40f4dbf-ba35-4237-a8c2-1dd8de4af385","status":30,"statusMessage":"Submission successful.","organizationId":"e2d83032-f3ea-4250-841c-521d7e18a070","siteId":"790ce820-ea97-4c30-8cae-fbcb4bf2f4e5","externalMerchantId":"ATL864","externalStoreId":"1234","cobrand":"ncralohapfintegration"}]';
        JPLogs__c jplog = new JPLogs__c(name=opp1.Opportunity_Number__c + '-OutBound',Type__c ='OutBound', Status__c='Success', Response__c = response);
        insert jplog;
       
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
        
        JP_EndPoint__c JPEnd3 = new JP_EndPoint__c();
        JPEnd3.Name='JPOnBoarding';
        JPEnd3.EndPoint_URL__c='https://ncrstag-stag.apigee.net/payos/api/v1.0/application/{mrchntAppId}/status?board=true';
        lstJPEnd.add(JPEnd3);
        
        JP_EndPoint__c JPEnd4 = new JP_EndPoint__c();
        JPEnd4.Name='WithdrawApplication';
        JPEnd4.EndPoint_URL__c='https://ncrstag-stag.apigee.net/payos/api/v1.0/application/{mrchntAppId}/withdrawn';
        lstJPEnd.add(JPEnd4);
        
        
        
        insert lstJPEnd;
        List<GeneratePaymentsApplicationController.BillingSitesWrapper> bswL= new  List<GeneratePaymentsApplicationController.BillingSitesWrapper>();
        GeneratePaymentsApplicationController.BillingSitesWrapper bsw= new  GeneratePaymentsApplicationController.BillingSitesWrapper(Site,true);
        bswL.add(bsw);
        String str = JSON.serialize(bswL);
        NSC_Support_Error_Notification__c objNSC = new NSC_Support_Error_Notification__c();
        objNSC.Name ='NSC Job Failure';
        objNSC.ToEmailAddresses__c='test@test.com';
        insert objNSC; 
        string response1 = JP_OutBoundOnBoardingService.initiateMerchantOnboarding(opp.id, str);
        String opId = opp.id;
        Set<Id> psS=new Set<Id>();
        psS.add(PaySite1.id);
        string response3 = JP_OutBoundOnBoardingService.initiateAppWithdrawn(opId,psS, 'testing');
        psS.add(PaySite.id);
        string response2 = JP_OutBoundOnBoardingService.initiateAppWithdrawn(opId,psS, 'testing');
        
        System.assert(response1!=null);
       // JP_OutBoundOnBoardingService.onBoardPymntSite(opp.id, new Set<ID>{psL[0].id});
       // JP_OutBoundOnBoardingService.onBoardPymntSite(opp.id, new Set<ID>{psL[1].id});
       // JP_OutBoundOnBoardingService.onBoardPymntSite(opp.id, new Set<ID>{psL[2].id});
      //  JP_OutBoundOnBoardingService.sendOnboardingRequest(opp,psL[0],'test.com','Test','Test',new List<JPLogs__c>{null});
        Test.stopTest(); 
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
     @isTest
    public static void runtest1(){
        
    	Account act=createAccount('Test456');       
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(act);  
        
        List<NCR_Payments_Site__c> psL=new List<NCR_Payments_Site__c>();
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        PaySite.Merchant_Application_Id__c = '123';
        PaySite.Opportunity__c = opp.Id;
        
        //insert PaySite;
        psL.add(PaySite);
        NCR_Payments_Site__c PaySite1= new NCR_Payments_Site__c();
        PaySite1.InfiniceptApplicationId__c='123';        
        PaySite1.Merchant_Application_Id__c = '234';
        PaySite1.Cobrand__c = 'ncralohapfintegration';
        PaySite1.Opportunity__c = opp.Id;
       
        //insert PaySite1;
        psL.add(PaySite1);         
        insert psL;
        
        NSC_Support_Error_Notification__c confg = new NSC_Support_Error_Notification__c(name='NSC Job Failure', ToEmailAddresses__c='test@ncr.com');
        insert confg;
        
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
        
        JP_EndPoint__c JPEnd3 = new JP_EndPoint__c();
        JPEnd3.Name='JPOnBoarding';
        JPEnd3.EndPoint_URL__c='https://ncrstag-stag.apigee.net/payos/api/v1.0/application/{mrchntAppId}/status?board=true';
        lstJPEnd.add(JPEnd3);
        
        insert lstJPEnd;
         
        
        Test.setMock(HttpCalloutMock.class, new JP_OutBoundCalloutMock()); 
       
       // JP_OutBoundOnBoardingService.onBoardPymntSite(opp.id, new Set<ID>{psL[0].id});
       // JP_OutBoundOnBoardingService.onBoardPymntSite(opp.id, new Set<ID>{psL[1].id});
        JP_OutBoundOnBoardingService.customFieldWrapper fieldwrap = new JP_OutBoundOnBoardingService.customFieldWrapper();
        fieldwrap.Id = 540;
        fieldwrap.UserDefinedId = 'annual.volume';
        JSONGenerator submitAppJSON = JSON.createGenerator(true);
        JP_OutBoundOnBoardingService.normalFeeJSONFormatted(submitAppJSON, 1000, fieldwrap);
        System.assert(submitAppJSON.getAsString()!=null);
    }
}