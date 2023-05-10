@isTest(seeAllData=true)
private class TestScheduleCSVReport {
   @isTest(SeeAllData='true')
    static void myTestMethod() { 
         ReportObj__c reportObj =  new ReportObj__c(Name = 'ThisReport', Report2_Trigger__c = 1, Report_ID__c = NSCCommonInfoUtil.getIdOf('OppRepServNow'));
         insert reportObj;  
        try{
         Test.startTest();
             ScheduleCSVReport csvReportObj = new ScheduleCSVReport();   
             String chron = '0 0 23 * * ?';        
             String jobID=system.schedule('Test Sched', chron, csvReportObj);
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
        	System.assertEquals(chron, ct.CronExpression);
         Test.stopTest();
        }
        catch(Exception e){
            System.debug('Error '+e.getMessage());
        }
    }
}