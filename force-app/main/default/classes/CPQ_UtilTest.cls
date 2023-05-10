@isTest
public with sharing class CPQ_UtilTest {
   
    @testSetup
    static void setup() {
        Account customerAccount;
        List<Account> sites;
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            customerAccount = CPQ_TestDataFactory.createAccount('1', null);
            customerAccount.Master_Customer_Number__c = '91661111';
            insert customerAccount;

            // site linked to customer account.
            Account site = CPQ_TestDataFactory.createSite(customerAccount, '1', null);
            site.Site_Number__c='1231';
            site.Primary_Bill_To__c = true;
            site.Primary_Deliver_To__c = true;
            site.Primary_Ship_To__c = true;
            insert site;
        }
    }

    @isTest public static void testGetAccount() {
        Account customerAccount = CPQ_Util.getAccount('91661111');
        System.assertEquals('91661111', customerAccount.Master_Customer_Number__c, 'Customer account not found.');
    }

    @isTest public static void testGetSite() {
        Account site = CPQ_Util.getSite('1231');
        System.assertEquals('1231', site.Site_Number__c, 'Customer site not found');
    }

    @isTest public static void testSafeString() {
        String s;
        System.assertNotEquals(CPQ_Util.safeString(s), null, 'String should not be null');
    }
    
    @isTest 
    public static void testDateString(){
        Datetime dt1 = Date.valueOf('2022-01-01 00:00:00');
        Datetime dt2 = Date.valueOf('2022-02-10 00:00:00');
        Datetime dt3 = Date.valueOf('2022-03-10 00:00:00');
        Datetime dt4 = Date.valueOf('2022-04-10 00:00:00');
        Datetime dt5 = Date.valueOf('2022-05-10 00:00:00');
        Datetime dt6 = Date.valueOf('2022-06-10 00:00:00');
        Datetime dt7 = Date.valueOf('2022-07-10 00:00:00');
        Datetime dt8 = Date.valueOf('2022-08-10 00:00:00');
        Datetime dt9 = Date.valueOf('2022-09-10 00:00:00');
        Datetime dt10 = Date.valueOf('2022-10-10 00:00:00');
        Datetime dt11 = Date.valueOf('2022-11-10 00:00:00');
        Datetime dt12 = Date.valueOf('2022-12-10 00:00:00');
        
        CPQ_Util util = new CPQ_Util();
        
        Test.startTest();
        util.dateString(dt1);
        util.dateString(dt2);
        util.dateString(dt3);
        util.dateString(dt4);
        util.dateString(dt5);
        util.dateString(dt6);
        util.dateString(dt7);
        util.dateString(dt8);
        util.dateString(dt9);
        util.dateString(dt10);
        util.dateString(dt11);
        util.dateString(dt12);
        
        Test.stopTest();
        
    }
    
    @isTest 
    public static void testCreateLog(){
        
        String transId = 'tid1010101';
        String status = 'test status';
        String interfaceMessage = 'test interfaceMsg';
        String req = 'test request';
        String res = 'test response';
        String reqType = 'test request type';
        String interfaceType = 'outBound';
        SBQQ__Quote__c q = new SBQQ__Quote__c(qtc_Quote_Name__c='Test Name', 
                                              qtc_Channel_Local_Office_Record_Type__c='PARTNER'
                                             );
        insert q;
        qtc_FulfillmentOrder__c fo = new qtc_FulfillmentOrder__c(qtc_DeliverToSite__c='00179000006KtILAA0', 
                                                                 qtc_Bill_To_Site__c='00179000006KtILAA0', 
                                                                 qtc_CDP__c = 'CDP1', qtc_CIS__c='CIS1', 
                                                                 qtc_Conversion_Type__c='C1', 
                                                                 qtc_ERP_Quote_Type__c='E1',
                                                                 qtc_Sequence_Number__c=1,
                                                                 Retry_Attempt__c=1
                                                                );
        insert fo;
        fo.qtc_Quote__r = q;
        update fo;
        
        CPQ_util util = new CPQ_util();
        Test.startTest();
        util.createLog(transId,status,interfaceMessage,req,res,reqType,fo,q.id,null,interfaceType);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetQuotesWithCLMDoc(){
         Integer prorationDayOfMonth = 25;
		Integer setupYear = 2020;
        Integer setupMonth = 1;
        Integer setupDay = 1;

        Date startDate = Date.newInstance( setupYear, setupMonth, setupDay);
        Account testAccount = CPQ_TestDataFactory.createAccount('Test Account',Null);
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
        	insert testAccount;
        }        
        Account deliverToSite = CPQ_TestDataFactory.createSite(testAccount, '123', null);
        insert deliverToSite;
        
         SBQQ__Quote__c masterQuote = new SBQQ__Quote__c(
              SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Bill_To_Site__c =deliverToSite.Id,
            Deliver_To_Site__c =deliverToSite.Id,
            qtc_Ship_To_Account__c =deliverToSite.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Parent',
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
 		insert masterQuote;
        Customer_Document__c docMasterQuote = CPQ_UtilTest.getCLMDoc(masterQuote.Id);
        
         SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
              SBQQ__Account__c = testAccount.Id,
            SBQQ__StartDate__c = startDate,
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__EndDate__c = startDate.addDays(30),
            SBQQ__ProrationDayOfMonth__c = String.valueOf( prorationDayOfMonth ),
            QuoteBillThroughDate__c=startDate.addDays(20),
            SBQQ__Type__c = 'Quote',
            qtc_Bill_To_Site__c =deliverToSite.Id,
            Deliver_To_Site__c =deliverToSite.Id,
            qtc_Ship_To_Account__c =deliverToSite.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c = 'AE Only',
            qtc_Multi_Site_Relationship__c='Child',
            qtc_Multi_Site_Parent_Quote__c = masterQuote.id,
            SBQQ__Primary__c=true,
            SBQQ__Status__c='Approved',
            qtc_Cancelled__c=false
        );
 		insert childQuote;
        
        System.assert(childQuote.Id!=null);
        system.assertNotEquals(childQuote.qtc_Cancelled__c, True);
        Customer_Document__c docChildQuote = CPQ_UtilTest.getCLMDoc(childQuote.Id);
        
        Test.startTest();
        CPQ_Util.getQuotesWithCLMDoc(masterQuote.Id);
        CPQ_Util.getQuotesWithCLMDoc(childQuote.Id);
        Test.stopTest();
        
    }
     private static Customer_Document__c getCLMDoc(Id quoteId){
        Account testAccount = TestRecordsFactory.createAccount('Test Account',Null);
        Customer_Document__c doc = new Customer_Document__c(
            Account__c = testAccount.id,
        	Quote__c = quoteId,
        	Document_Type__c = 'AE Amendment',
        	Document_Status__c = 'Sent for Signature');
        insert doc;
        return doc;
    }
    
    @isTest 
    public static void testRequestJSONAsString() {
        HttpRequest request = new HttpRequest();
        System.assertNotEquals((new CPQ_Util()).getRequestJSONAsString(request), null, 'String should not be null');
    }
    @isTest 
    public static void testResponseJSONAsString() {
        HttpResponse response = new HttpResponse();
        System.assertNotEquals((new CPQ_Util()).getResponseJSONAsString(response), null, 'String should not be null');
    }
    @isTest 
    public static void testRestRequestJSONAsString() {
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('RequestBody');
        System.assertNotEquals((new CPQ_Util()).getRequestJSONAsString(request), null, 'String should not be null');
    }
    @isTest 
    public static void testRestResponseJSONAsString() {
        RestResponse response = new RestResponse();
        response.responseBody =  Blob.valueOf('ResponseBody');
        System.assertNotEquals((new CPQ_Util()).getResponseJSONAsString(response), null, 'String should not be null');
    }
    
}