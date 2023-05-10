@isTest
public class TestReportScheduleController {
    @isTest(SeeAllData='true')
    public static void TestReportSchedule(){ 
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Case_Test_Report_1_9Nd'];
        String reportId = (String)reportList.get(0).get('Id');
        List<Id> contactIdList = new List<Id>();
        List<Id> emailRecipientIdList = new List<Id>();
        List<Id> scheduleExRptIdList = new List<Id>();
        //Creating test account record
        Account acc =  TestRecordsFactory.createAccount('1234320','HOSPITALITY:TSR','NAMER SMB');
        Account acc2 =  TestRecordsFactory.createAccount('1234329','HOSPITALITY:TSR','NAMER SMB');
        // Creating test contact record
        Contact con = TestRecordsFactory.createContact(acc);
        contactIdList.add(con.Id);
        
        //Creating accountcontact relationship  
        AccountContactRelation acctcr = new AccountContactRelation(AccountId = acc2.id, ContactId = con.id);
        insert acctcr;
        
        // Creating test record on Schedule external report object
        Schedule_External_Report__c scheduleExtRepObj = new Schedule_External_Report__c();
        scheduleExtRepObj.Schedule_external_report_name__c = 'Test';
        scheduleExtRepObj.Frequency__c = 'Daily';
        insert scheduleExtRepObj; 
        scheduleExRptIdList.add(scheduleExtRepObj.id);
        // Creating test record on Email Recipient object
        Email_Recipient__c emailRecipientObj = new Email_Recipient__c();
        emailRecipientObj.Schedule_External_Report__c = scheduleExtRepObj.Id;
        emailRecipientObj.Direct_MCN__c = 'nullA';
        emailRecipientObj.Indirect_MCN__c = '';
        emailRecipientObj.updatedByBatch__c = false;
        emailRecipientObj.Email__c = 'test@gmail.com';
        insert emailRecipientObj;
        emailRecipientIdList.add(emailRecipientObj.id);
        
        Test.startTest();
        ReportScheduleController.getScheduleReportDetail(scheduleExtRepObj.Id);
        ReportScheduleController.getReportDetails(reportId);
        ReportScheduleController.getRelatedContactData(contactIdList);
        ReportScheduleController.updateScheduleExternalReport(scheduleExRptIdList);
        ReportScheduleController.getEmailRecipientRecord(scheduleExtRepObj.Id);
        ReportScheduleController.retrieveRecords('Account', 'Name','Name', 'tes', acc.Id);
        ReportScheduleController.retrieveRecords('Account', 'Name','Name', '*', acc.Id);
        ReportScheduleController.retrieveRecords('Contact', 'Id,Email,Name','Name', 'tes', con.Id);
        ReportScheduleController.retrieveRecords('Report', 'Id','Name', 'Test', reportId);
        ReportScheduleController.getAllReports();
        ReportScheduleController.search('CF', 'Report','');
        ReportScheduleController.search('', 'Report','');
        ReportScheduleController.search('CF', 'Report','name=\'CF\'');
        ReportScheduleController.search('Name', 'Account','');
        ReportScheduleController.search('', 'Account','');
        ReportScheduleController.search('Name', 'Account','name=\'CF\'');
        ReportScheduleController.search('Test', 'User','');
        ReportScheduleController.search('', 'User','');
        ReportScheduleController.search('Test', 'User','name=\'CF\'');
        ReportScheduleController.validateReport(reportId);
        Test.stopTest();
        Schedule_External_Report__c scheduleExtRepObj2 = [select Last_Email_Sent_Successfully__c from Schedule_External_Report__c where id=:scheduleExtRepObj.id] ;
        System.assert(scheduleExtRepObj2.Last_Email_Sent_Successfully__c!=null);
    }
}