global class ScheduleCSVReport implements Schedulable {
   global void execute(SchedulableContext ctx) {
      ReportObj__c r = [SELECT Id, Name, Report2_Trigger__c FROM ReportObj__c WHERE Report_ID__c = '00O70000004Pxf4' LIMIT 1];
      r.Report2_Trigger__c += 1;
      System.debug('updating trigger to: ' + r.Report2_Trigger__c);
      update r;
   }   
}