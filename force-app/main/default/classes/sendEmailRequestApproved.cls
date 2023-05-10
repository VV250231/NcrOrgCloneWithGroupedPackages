/*
##################################################################################################
# Project Name && Request Num..........: Ticket Request
# File............................: sendEmailRequestApproved.cls                                                        
# Created by................: Mohammad Ahad                                                                   
# Created Date...........: 19/10/2017                                                                              
# Last Modified by......:  Mohammad Ahad
# Last Modified Date..: 19/10/2017
# Description...............: This class is used in SendEmail Component for Ticket Request Project.
################################################################################################
*/

public class sendEmailRequestApproved {
    @AuraEnabled 
    public static void sendMailMethod(list<string> mMail ,String mSubject ,String mbody, String replyTo){
        system.debug('In Apex'+mMail);
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
       // sendTo.add(mMail);
        mail.setToAddresses(mMail);
        mail.setReplyTo(replyTo); 
        mail.setSenderDisplayName('Event Invitation from NCR Corporation');
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        mails.add(mail);
        //Messaging.sendEmail(mails);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }    
    @AuraEnabled
    public static list<Ticket_Request__c> getApprovalStats(String RdId) {
        list<Ticket_Request__c> aprvlStatus = [ SELECT Id,  Approval_Status__c, Name, Event_Name_Date__c, 
                                               Contact_Name__r.Name,  Contact_Name__r.Email
                                               FROM Ticket_Request__c 
                                               WHERE Id =:RdId ]; 
        system.debug('*******'+ aprvlStatus);
        return aprvlStatus;
        
    } 
    
    @AuraEnabled
    public static list<User> getUserEmail() {
        Id userId = UserInfo.getUserId();
        return [SELECT Name, Email FROM User WHERE Id = :userId];
    }
    
}