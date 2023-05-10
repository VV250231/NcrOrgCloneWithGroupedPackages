@isTest
public class PRM_DealRegistrationProgressBarTest 
{
    static testMethod void runUnitTest() {
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '0000001' + System.now().getTime(),
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            /* CAP_Watch__c = 'CAP',*/
            account_region__c='INDIA'
        );
        system.runAs(TestRecordsFactory.getUser()) {
            insert a;
        }
        
        System.assertNotEquals(a,NULL,'Account should not be NULL');
        
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = a.id;
        
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'Financial Self Service';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        
        insert opp;
        
        PRM_DealRegistrationProgressBar.getStageName(opp.Id);
    }
    static testMethod void StatusBarTest() {
        Test.startTest();
       list<string> strlist= PRM_DealRegistrationProgressBar.getStatusBar();
        
        System.assertNotEquals(strlist,NULL,'Account should not be NULL');
        Test.stopTest();
    }
}