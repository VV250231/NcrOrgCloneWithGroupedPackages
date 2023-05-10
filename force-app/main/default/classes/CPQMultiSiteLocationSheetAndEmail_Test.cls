/**************************************
Author ...............: Suraj Parihar
Date Created .........: 05-AUG-2021
Last Modified By .....:
Last Modified Date ...: 
Description ..........: Test Class for Multi-Site Location Sheet sent to Payment Application Assignee 
i.e. CPQMultiSiteLocationSheetController AND CPQEmailPaymentApplicationRequest
***************************************/
@isTest
public class CPQMultiSiteLocationSheetAndEmail_Test {
    static Account a;
    static Opportunity opp;
    static SBQQ__Quote__c quote;
    static Order ord;
    static Order ord1;
    static Contact cont;
    
    Public Static User getUser()
    {
        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    @isTest
    public static void testMultiSiteSheet() {
        
        a = new Account(name = 'Test Acc',
                        LOB__c = 'FINANCIAL',
                        Master_Customer_Number__c = 'TESTMCN00001X',
                        Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                        Active_Account__c = true,
                        BillingStreet = 'Spring Street', 
                        BillingCity ='ATLANTA', 
                        BillingState='GA', 
                        BillingPostalCode='30309', 
                        Phone='6788608261',
                        Fax='123456'
                       );
        System.runAs(getUser()){
            insert a;
        }
        opp  = TestRecordsFactory.createSimpleOpportunity(a);
        opp.closeDate = System.TODAY()- 200;
        opp.CPQ__c = TRUE;
        update opp;
        
        cont = TestRecordsFactory.createContact(a);
        cont.Email='sp185453@ncr.com';
        update cont;
        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            qtc_Average_Check__c=400,
            qtc_Annual_Volume__c=10000, 
            SBQQ__Account__c = a.Id,
            SBQQ__Opportunity2__c = opp.Id,
            qtc_Multi_Site__c=true,
            qtc_Multi_Site_Type__c='AE+PP',
            qtc_Multi_Site_Relationship__c='Parent',
            qtc_Number_of_Sites_with_Payments__c=1,
            Payments_Application_Signee__c=cont.id,
            SBQQ__Primary__c=true);
        insert quote;     
        
        NCR_Payments_Site__c nps =new NCR_Payments_Site__c(
            Account_Sites__c=a.Id,
            Quote__c=quote.Id
        );
        insert nps;
        
        List<CPQMultiSiteLocationSheetController.LocationDetailsClass> details = new List<CPQMultiSiteLocationSheetController.LocationDetailsClass>(); 
        CPQMultiSiteLocationSheetController.LocationDetailsClass ld = new CPQMultiSiteLocationSheetController.LocationDetailsClass();
        ld.Location_Type ='Additional Location';
        ld.DBA_NAME = 'Suraj';
        ld.DBA_ADDRESS_1 = 'Address';
        ld.DBA_CITY ='Atlanta';
        ld.DBA_STATE ='GA';
        ld.DBA_ZIP ='12344';
        ld.DBA_PHONE ='9999999999';
        ld.DBA_FAX ='3456';
        ld.DBA_EMAIL_ADDRESS ='tEST@NCR.COM';
        ld.DBA_CONTACT_NAME ='test';
        ld.DBA_CONTACT_EMAIL ='tEST@NCR.COM';
        ld.CUST_SERV_EMAIL = 'tEST@NCR.COM';
        ld.TAX_ID = '66666';
        ld.LEGAL_NAME = a.name;
        ld.CORP_TYPE ='tEST';
        ld.CORP_ADDRESS1= a.BillingStreet;
        ld.CITY=a.BillingCity;
        ld.STATE =a.BillingState;
        ld.ZIP =a.BillingPostalCode;
        ld.CORP_PHONE =a.Phone;
        ld.CORP_FAX =a.Fax;
        ld.TOTAL_MONTHLY_VOLUME = String.valueOf(quote.qtc_Annual_Volume__c);
        ld.TOTAL_ANNUAL_VOLUME = String.valueOf(quote.qtc_Annual_Volume__c);
        ld.AVERAGE_TICKET = String.valueOf(quote.qtc_Average_Check__c);
        ld.MCN = a.Master_Customer_Number__c;
        ld.SiteID = '123445';
        ld.MCC_CODE= ' ';
        ld.GOODS_SERVICES_DESCRIPTION='';
        ld.WEBSITE_URL_ADDRESS= ' ';
        ld.OWNER_1_FIRST_NAME= ' ';
        ld.OWNER_1_LAST_NAME= ' ';
        ld.OWNERSHIP_PERCENTAGE= ' ';
        ld.OWNER_1_SOCIAL_SEC_NUM= ' ';
        ld.OWNER_1_DATE_OF_BIRTH= ' ';
        ld.OWNER_1_HOME_ADDRESS_1= ' ';
        ld.OWNER_1_HOME_ADDRESS_2= ' ';
        ld.OWNER_1_CITY= ' ';
        ld.OWNER_1_STATE= ' ';
        ld.OWNER_1_ZIP= ' ';
        ld.OWNER_1_PHONE= ' ';
        ld.OWNER_1_EMAIL= ' ';
        ld.BILLING_CONTACT_NAME= ' ';
        ld.BILLING_CONTACT_PHONE= ' ';
        ld.BILLING_CONTACT_EMAIL= ' ';
        ld.REPORTING_CONTACT_NAME= ' ';
        ld.REPORTING_CONTACT_PHONE= ' ';
        ld.REPORTING_CONTACT_EMAIL= ' ';
        ld.PCI_CONTACT_NAME= ' ';
        ld.PCI_CONTACT_PHONE= ' ';
        ld.PCI_CONTACT_EMAIL= ' ';
        ld.CHARGEBACKS_CONTACT_NAME= ' ';
        ld.CHARGEBACKS_CONTACT_PHONE= ' ';
        ld.CHARGEBACKS_CONTACT_EMAIL= ' ';
        ld.BANK_ABA= ' ';
        ld.BANK_DDA= ' ';
        ld.NUM_DAILY_TRANSACTIONS= ' ';
        ld.HIGHEST_DAILY_SALES_VOLUME= ' ';
        ld.CARD_PRESENT= ' ';
        ld.CARD_NOT_PRESENT= ' ';
        ld.PIN_DEBIT_USED= ' ';
        ld.AMEX_SE= ' ';
        ld.CORP_ADDRESS2= ' ';
        ld.DBA_ADDRESS_2 = ' '; 
        ld.QuoteID = quote.name;
        details.add(ld);    
        
        Test.startTest();
        insert new NCR_CPQBLG_Email__c(Name='Default Workflow Email',Email__c='sp185453@ncr.com');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setHtmlBody('strEmail');
        String testId = quote.Id;
        List<ID> ids =new List<ID>();
        ids.add(testId);
        CPQEmailPaymentApplicationRequest.sendPaymentApplicationEmail(ids);  
        string QuoteId = quote.Id;
        
        PageReference pageRef = Page.CPQMultiSiteLocationSheet;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',QuoteId);
        CPQMultiSiteLocationSheetController Obj1 = new CPQMultiSiteLocationSheetController();
        obj1.AddDynamicRows(quote);
        obj1.getlocationDetails();
        obj1.setlocationDetails(details); 
        Test.stopTest();
        
    }
    
}