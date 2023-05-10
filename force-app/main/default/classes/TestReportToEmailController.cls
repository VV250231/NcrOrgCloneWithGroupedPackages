@isTest
public class TestReportToEmailController {
   
    @isTest(SeeAllData='true')
    public static void TestMethod1(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName IN('Case_Test_Report_1_9Nd','Case_Test_Report_2_FJ6')];
        String reportId = (String)reportList.get(0).get('Id');
         // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_MCN__c = '3555062CA';
        emailRecipientObj.Indirect_MCN__c = '';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        string rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest(); 
    }
    
    
    
    @isTest(SeeAllData='true')
    public static void TestMethod2(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Case_Test_Report_1_9Nd'];
        String reportId = (String)reportList.get(0).get('Id');
        List<Id> contactIdList = new List<Id>();
        //Creating test account record
        Account acc =  TestRecordsFactory.createAccount('1234320','HOSPITALITY:TSR','NAMER SMB');
        // Creating test contact record
        Contact con = TestRecordsFactory.createContact(acc);
        contactIdList.add(con.Id);
                
        // Creating test case record
         Case case1 = new case(accountid=acc.id,status ='In Progress',Subject='Test case');
        insert case1;
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_MCN__c = '1234320';
        emailRecipientObj.Indirect_MCN__c = '';
        emailRecipientObj.Reporting_Filter__c='Direct MCN';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        string rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest();
    }
    
    
    @isTest(SeeAllData='true')
    public static void TestMethod3(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Case_Test_Report_1_9Nd'];
        String reportId = (String)reportList.get(0).get('Id');
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_MCN__c = '3555062CA';
        emailRecipientObj.Indirect_MCN__c = '55555555555555';
        emailRecipientObj.Reporting_Filter__c='Indirect MCN';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        string rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest();
    }
    
    @isTest(SeeAllData='true')
    public static void TestMethod4(){
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        String rslt = rc.getReportResult();
        Test.stopTest();
        System.assert(rslt==null);
    }
    
     @isTest(SeeAllData='true')
    public static void TestMethod5(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName IN('Case_Test_Report_1_9Nd','Case_Test_Report_2_FJ6')];
        String reportId = (String)reportList.get(1).get('Id');
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_MCN__c = '3555062CA';
        emailRecipientObj.Indirect_MCN__c = '';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        String rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest();
    }
    
    @isTest(SeeAllData='true')
    public static void TestMethod6(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Case_Test_Report_1_9Nd'];
        String reportId = (String)reportList.get(0).get('Id');
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_FUA__c = '3555062CA';
        emailRecipientObj.Indirect_MCN__c = '';
        emailRecipientObj.Reporting_Filter__c='Direct FUA';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        string rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest();
    }
    
    
     @isTest(SeeAllData='true')
    public static void TestMethod7(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Case_Test_Report_1_9Nd'];
        String reportId = (String)reportList.get(0).get('Id');
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_FUA__c = '3555062CA';
        emailRecipientObj.Indirect_FUA__c = '3555062CA,7827272';
        emailRecipientObj.Reporting_Filter__c='Indirect FUA';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        string rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest();
    }
    
    @isTest(SeeAllData='true')
    public static void TestMethod8(){
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Case_Test_Report_1_9Nd'];
        String reportId = (String)reportList.get(0).get('Id');
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj;
        
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c =scheduleExtRepObj.id;
        emailRecipientObj.Direct_FUA__c = '3555062CA';
        emailRecipientObj.Indirect_FUA__c = '3555062CA,7827272';
        emailRecipientObj.Reporting_Filter__c='All FUA';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        
        
        Test.startTest();
        ReportsToEmailController rc = new ReportsToEmailController();
        rc.rptId  = reportId;
        rc.con = emailRecipientObj.Id;
        string rslt =rc.getReportResult();
        System.assert(rslt!=null);
        Test.stopTest();
    }
}