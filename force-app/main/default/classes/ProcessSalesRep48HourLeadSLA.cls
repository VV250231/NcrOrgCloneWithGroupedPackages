/*##################################################################################################
# Project Name..........: NSC CRM 2017                                                                    
# File..................: ProcessSalesRep48HourLeadSLA.cls                                                        
# Version...............: 39.0 
# Created by............: IDC, NSC
# Created Date..........: 27-02-2017                                                                              
# Last Modified by......: IDC, NSC
# Last Modified Date....: 27-02-2017  
# Description...........: NC_AGILE-211 - Check If sales rep either changed lead status within 48hrs or converted lead, 
                                         else send email notification to sales rep and his manager. 
################################################################################################*/
global class ProcessSalesRep48HourLeadSLA implements Database.Batchable<sObject> {
    
        
     global Database.QueryLocator start(Database.BatchableContext BC) {  
         Datetime last48Hours = Datetime.now().addHours(-48);
         
         return Database.getQueryLocator([SELECT Id, AssignToSalesRep__c, AssignToSalesRepDate__c, NotificationForSalesRep__c  
                                             FROM Lead WHERE AssignToSalesRep__c = true and IsConverted = false
                                             and NotificationForSalesRep__c = false and Status !='Return to Nurture' 
                                             and Status !='Suspect' and Status !='Disqualified' and Status !='Miss-assigned/Needs Research'
                                             and AssignToSalesRepDate__c != null and AssignToSalesRepDate__c <= :last48Hours]);
     }
     
     global void execute(Database.BatchableContext BC, List<Lead> leadList) {
         List<Lead> leadUpdateList = new List<Lead>();
         
         for (Lead lead : leadList) {
             lead.NotificationForSalesRep__c = true;  
             leadUpdateList.add(lead);
         }
         
         try { update leadUpdateList;
         } catch(Exception e) { sendErrorNotification('Error in SalesRep 48Hour Lead SLA Update' + e.getMessage()); }
     }
        
        
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));
    }
    
    global void sendErrorNotification(String emailBody) {
         if(emailBody != null && emailBody.trim().length() > 0) {
            emailBody = 'Hi NSC Support<br/><br/>NSC Admin is unable to send Lead 48 hour SLA alerts to Sales Reps due to error mentioned below: <br/>' + emailBody;
            emailBody += '<br/><br/>Thanks,<br/>NSC Administration';
            
            NSC_Support_Error_Notification__c supportNotf = NSC_Support_Error_Notification__c.getInstance('NSC Job Failure');
            String toEmailAddress = supportNotf.ToEmailAddresses__c, ccEmailAddress = supportNotf.CcEmailAddresses__c;
            
            if (String.isNotBlank(toEmailAddress)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toEmailAddress.split(',')); 
                if(String.isNotBlank(ccEmailAddress)) mail.setCcAddresses(ccEmailAddress.split(','));
                mail.setSenderDisplayName('NSC Administration');
                mail.setReplyTo('no-reply@salesforce.com');
                mail.setSubject('Need Action: Unable to send Lead 48 hour SLA alerts');
                mail.setHtmlBody(emailBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }
    }
}