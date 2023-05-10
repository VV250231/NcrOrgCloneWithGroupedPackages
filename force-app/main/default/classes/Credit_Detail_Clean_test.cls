@isTest
public class Credit_Detail_Clean_test {
    
    public static testMethod void myTest() {
        
        Account a = TestRecordsFactory.createAccount();
        /*
        Credit_Detail__c cd = new Credit_Detail__c();
        //cd.Average_Days_Late__c= 3;
        cd.Customer_Balance__c=3;
        cd.On_Hold__c='YES';
        cd.Risk_Level__c='GREEN';
        cd.Unique_ID__c='1234567';
        cd.X1_30_Days_Late__c=10;
        cd.X361_Days_Late__c=10;
        cd.X31_60_Days_Late__c=10;
        cd.X61_90_Days_Late__c=10;
        cd.X91_180_Days_Late__c=10;
        cd.Account__c=a.id;
        
        insert cd;*/
        Account aa=[Select id, Country_with_Master_customer_Number__c from Account WHERE Id =: a.Id LIMIT 1];
        //Breakup
        Credit_Detail_Break_Up__c cdb = new Credit_Detail_Break_Up__c();
        cdb.Aging_31_60__c = 10;
        cdb.Aging_31__c = 10;
        cdb.Aging_61_90__c = 20;
        cdb.Aging_91_180__c = 10;
        cdb.Aging_181_360__c = 30;
        cdb.Aging_360__c = 10;
        cdb.Classification_Invoice_Type__c = 'Other';
        cdb.Customer_Balance__c = 100;
        cdb.Industry__c = 'Hospitality';
        cdb.Not_Due_1_360_Days__c = 10;
        cdb.Not_Due_360_Days__c = 10;
        cdb.On_Hold__c = 'NO';
        cdb.Unique_ID_Credit_Detail__c = aa.Country_with_Master_customer_Number__c;
        cdb.Unique_ID__c = aa.Country_with_Master_customer_Number__c;
        
        Insert cdb;
        
        Credit_Detail__c cdObj = Controller_CreditDetails_ltng.Loadcompletedetail(a.id);
        System.assert(cdObj.id!=null);
    }
    static testmethod void test() { 
        Profile p = [select id from profile where name ='02 NSC Administrator'];
            User us              =  new User();
            us.Profileid         = p.Id;
            us.Username          = 'testUser2011@ncr.com';
            us.Email             = 'testUser2011@ncr.com';
            us.Alias             = 'alias1';           
            us.FirstName         = 'NSC';
            us.LastName          = 'Admin';
            us.LocaleSidKey      = 'ar';
            us.LanguageLocaleKey = 'de';
            us.TimeZoneSidKey    = 'Africa/Cairo';
            us.EmailEncodingKey  = 'Big5';
            us.CurrencyIsoCode   = 'AUD';
            us.Quicklook_ID__c   = 'tm250661';
            us.FederationIdentifier = 'tm250661';
          insert us;
        Account a = TestRecordsFactory.createAccount();
        
       
        Account aa=[Select id, Country_with_Master_customer_Number__c from Account WHERE Id =: a.Id LIMIT 1];
        //Breakup
        Credit_Detail_Break_Up__c cdb = new Credit_Detail_Break_Up__c();
        cdb.Aging_31_60__c=10;
        cdb.Aging_31__c=10;
        cdb.Aging_61_90__c=20;
        cdb.Aging_91_180__c=10;
        cdb.Aging_181_360__c=30;
        cdb.Aging_360__c=10;
        cdb.Classification_Invoice_Type__c='Other';
        cdb.Customer_Balance__c=100;
        cdb.Industry__c='Hospitality';
        cdb.Not_Due_1_360_Days__c=10;
        cdb.Not_Due_360_Days__c=10;
        cdb.On_Hold__c='NO';
        cdb.Unique_ID_Credit_Detail__c=aa.Country_with_Master_customer_Number__c;
        cdb.Unique_ID__c=aa.Country_with_Master_customer_Number__c;
        
        DateTime dt1 = DateTime.Now().addDays(-2);
        
        cdb.CreatedDate = dt1;
        cdb.LastModifiedDate = dt1;
        
        Insert cdb;
        Credit_Detail_Break_Up__c cdbObj = [select id from Credit_Detail_Break_Up__c where id=:cdb.id];
        System.assert(cdbObj.id!=null);
        system.debug('&&&^^^'+cdb);
        Test.startTest();
        Credit_Detail_Clean rollup = new Credit_Detail_Clean(true);
        Database.executeBatch(rollup);
        Test.stopTest();
    }
    public static testMethod void testschedule() {
        Test.StartTest();
        Schedule_Credit_Detail_clean testsche = new Schedule_Credit_Detail_clean();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        List<AsyncApexJob>   jobObj = [select id from AsyncApexJob  where JobType in ('BatchApexWorker','ScheduledApex') limit 1];
        System.assert(jobObj.size()!=0);
        Test.stopTest();
    }
    
   
}