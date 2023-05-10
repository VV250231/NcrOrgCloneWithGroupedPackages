global class IncrementReport implements Schedulable {
   global void execute(SchedulableContext ctx) {
      System.debug('Entered Cron trigger');
      ReportObj__c r = [SELECT Id, Name, Report_Trigger__c FROM ReportObj__c WHERE Report_ID__c = '00O70000003tHm5' LIMIT 1];
      r.Report_Trigger__c += 1;
      System.debug('updating trigger to: ' + r.Report_Trigger__c );
      update r;
   }   
}