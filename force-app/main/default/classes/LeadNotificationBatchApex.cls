/*
####################################################################################################################                                                        
# Created by................: Yogesh Singh                                                                      
# Created Date...........: 27-10-2021                                                                                  
# Last Modified by......: Ashish                                                                          
# Last Modified Date..: 7-11-2022  // LeadTriggerTest                                                                              
# Description...............: Combined test class for all Lead Triggers
####################################################################################################################
*/

global class LeadNotificationBatchApex implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select id, isConverted, Status,LastModifiedDate,Owner.Email,LeadOwnerManage__c,Lead_Qualified_DateTime__c from 
                                         Lead where Status ='Qualified' and Industry__c ='Hospitality' 
                                         and IsConverted =false and Lead_Qualified_DateTime__c!=null]);
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> donotReplyAddress=[select Id,DisplayName from OrgWideEmailAddress WHERE DisplayName='NCR Global Do Not Reply'];
        EmailTemplate eTmpForTFourHour = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Notification to the Lead Owner + Manager after 24 hours'];
        EmailTemplate eTForOWeek = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Notification to the qualified Lead Owner + Manager'];
        for (Lead l : scope) {
            GenericTimeDifferenceApexClass.StringIntegerWrapper stw = GenericTimeDifferenceApexClass.duration_between_two_date_times(l.Lead_Qualified_DateTime__c,l.LastModifiedDate);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(Integer.valueof(stw.sumoOfMinuteHourInSecond)<=60 && Integer.valueof(stw.sumoOfMinuteHourInSecond)>=0){
                if(l.LastModifiedDate <= System.Now().addHours(-24) && l.LastModifiedDate>System.Now().addHours(-36)){
                    message.setToAddresses(new String[] {l.Owner.Email,l.LeadOwnerManage__c});
                    message.setTargetObjectId(l.id); message.setTemplateID(eTmpForTFourHour.Id);
                    message.setOrgWideEmailAddressId(donotReplyAddress[0].Id);  
                    message.setUseSignature(false); 
                    message.setTreatTargetObjectAsRecipient(false); message.setSaveAsActivity(false);
                    if(l.Owner.Email!=null)
                        mail.add(message);
                }
            }
            if(l.Lead_Qualified_DateTime__c<=System.Now().addHours(-168) && l.Lead_Qualified_DateTime__c>System.Now().addHours(-180)){
                message.setToAddresses(new String[] {l.Owner.Email,l.LeadOwnerManage__c});
                message.setTargetObjectId(l.id); 
                message.setTemplateID(eTForOWeek.Id);
                message.setOrgWideEmailAddressId(donotReplyAddress[0].Id); 
                message.setUseSignature(false); 
                message.setBccSender(false);
                message.setBccAddresses(new String[]{'ys250288@ncr.com'});
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(false);
                if(l.Owner.Email!=null)
                    mail.add(message);
            }
        }
        if(!mail.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mail);
        }
        
    }
    /*public void execute(SchedulableContext SC) {
LeadNotificationBatchApex schLead = new LeadNotificationBatchApex();
//String sch = '0 0 0,12,0 ? * * ';
//  String CRON_EXP = '0 0 * * * ?';
//  System.schedule('Lead Owner Notifcation', CRON_EXP, schLead);
//  Database.executeBatch(schLead);
} */
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        // call some utility to send email
    }
}