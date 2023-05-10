@isTest
public class TriggerReportFlowBatchClassTestClass {
    @isTest static void data_setup(){
        //creating Account record
        Account acc =  TestRecordsFactory.createAccount('1234320','HOSPITALITY:TSR','NAMER SMB');
        //creating Contact record
        Contact con = TestRecordsFactory.createContact(acc);
        //conversion of time zones
        DateTime dtTime=DateTime.now();
        TimeZone tz = UserInfo.getTimeZone();
        Integer offset=tz.getOffset(dtTime);
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone('America/New_York');
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
        integer correction = offsetTotargetTZ- offset;
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        Time currentTime = Time.newInstance(targetDT.hour(), targetDT.minute(), targetDT.second(), targetDT.millisecond());
        //Creating Schedule External Report
        Schedule_External_Report__c ser = new Schedule_External_Report__c();
        ser.Schedule_external_report_name__c = 'Test';
        ser.Frequency__c = 'Daily';
        ser.Start_Date__c = Date.today();
        ser.End_Date__c = Date.today().addDays(6);
        ser.NextBatchDate__c = Date.today();
        ser.Schedule_Time__c = currentTime;
        insert ser;
        Schedule_External_Report__c ser1 = new Schedule_External_Report__c();
        ser1.Schedule_external_report_name__c = 'Test';
        ser1.Frequency__c = 'Weekly';
        ser1.Start_Date__c = Date.today();
        ser1.End_Date__c = Date.today().addDays(11);
        ser1.NextBatchDate__c = Date.today();
        ser1.Schedule_Time__c = currentTime;
        insert ser1;
        Schedule_External_Report__c ser2 = new Schedule_External_Report__c();
        ser2.Schedule_external_report_name__c = 'Test';
        ser2.Frequency__c = 'Monthly';
        ser2.Start_Date__c = Date.today();
        ser2.End_Date__c = Date.today().addMonths(2);
        ser2.NextBatchDate__c = Date.today();
        ser2.Schedule_Time__c = currentTime;
        insert ser2;
        Schedule_External_Report__c ser3 = new Schedule_External_Report__c();
        ser3.Schedule_external_report_name__c = 'Test';
        ser3.Frequency__c = 'Quarterly';
        ser3.Start_Date__c = Date.today();
        ser3.End_Date__c = Date.today().addMonths(4);
        ser3.NextBatchDate__c = Date.today();
        ser3.Schedule_Time__c = currentTime;
        insert ser3;
        Schedule_External_Report__c ser4 = new Schedule_External_Report__c();
        ser4.Schedule_external_report_name__c = 'Test';
        ser4.Frequency__c = 'Yearly';
        ser4.Start_Date__c = Date.today();
        ser4.End_Date__c = Date.today().addYears(1);
        ser4.NextBatchDate__c = Date.today();
        ser4.Schedule_Time__c = currentTime;
        insert ser4;
        //Creating Email Recipient
        Email_Recipient__c er = new Email_Recipient__c();
        er.Contact__c = con.Id;
        er.Schedule_External_Report__c = ser.Id;
        er.Direct_MCN__c = 'nullA';
        er.Indirect_MCN__c = '';
        er.updatedByBatch__c = false;
        er.Email__c = 'moraz@gmail.com';
        insert er;
        Email_Recipient__c er1 = new Email_Recipient__c();
        er1.Contact__c = con.Id;
        er1.Schedule_External_Report__c = ser1.Id;
        er1.Direct_MCN__c = 'nullA';
        er1.Indirect_MCN__c = '';
        er1.updatedByBatch__c = false;
        er1.Email__c = 'moraz@gmail.com';
        insert er1;
        Email_Recipient__c er2 = new Email_Recipient__c();
        er2.Contact__c = con.Id;
        er2.Schedule_External_Report__c = ser2.Id;
        er2.Direct_MCN__c = 'nullA';
        er2.Indirect_MCN__c = '';
        er2.updatedByBatch__c = false;
        er2.Email__c = 'moraz@gmail.com';
        insert er2;
        Email_Recipient__c er3 = new Email_Recipient__c();
        er3.Contact__c = con.Id;
        er3.Schedule_External_Report__c = ser3.Id;
        er3.Direct_MCN__c = 'nullA';
        er3.Indirect_MCN__c = '';
        er3.updatedByBatch__c = false;
        er3.Email__c = 'moraz@gmail.com';
        insert er3;
        Email_Recipient__c er4 = new Email_Recipient__c();
        er4.Contact__c = con.Id;
        er4.Schedule_External_Report__c = ser4.Id;
        er4.Direct_MCN__c = 'nullA';
        er4.Indirect_MCN__c = '';
        er4.updatedByBatch__c = true;
        er4.Email__c = 'moraz@gmail.com';
        insert er4;
        //test.startTest();
        TriggerReportFlowBatchClass tbc = new TriggerReportFlowBatchClass();
        Database.executeBatch(tbc);
        //test.stopTest();
        Email_Recipient__c emailRec = [Select Id,updatedByBatch__c from Email_Recipient__c Where Id =: er4.Id];
        System.assertEquals(emailRec.updatedByBatch__c == true, emailRec.updatedByBatch__c);
    }
}