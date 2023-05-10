@isTest
private class TestIncrementReport {
    static testMethod void myTestMethod() {   
         //ReportObj__c reportObj =  new ReportObj__c(Name = 'ThisReport', Report_Trigger__c = 1, Report_ID__c = NSCCommonInfoUtil.getIdOf('ReportId'));
         ReportObj__c reportObj =  new ReportObj__c(Name = 'ThisReport', Report_Trigger__c = 1, Report_ID__c = '00O70000003tHm5');
         insert reportObj;  
         
         Test.startTest();
             IncrementReport incrementObj = new IncrementReport();   
             String chron = '0 0 23 * * ?';        
             string job1= system.schedule('Test Sched', chron, incrementObj );
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals(chron, ct.CronExpression);
         Test.stopTest();
    }
}