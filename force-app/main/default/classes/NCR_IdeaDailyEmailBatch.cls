global class NCR_IdeaDailyEmailBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    Set<String> userIds = new Set<String>();
    
    global List<User> start(Database.BatchableContext bc) {
        List<User> subscribers = new List<User>();
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        
        if (netWorks.size() > 0) {
            List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
            if(zones.size() > 0) {
                // Fetching user record to send mail
                List<DI_Idea_Exchange_Daily_Digest__c> registeredUser = [SELECT Id, Name, DI_User__c, DI_Subscribe_for_daily_digest__c FROM DI_Idea_Exchange_Daily_Digest__c WHERE DI_Subscribe_for_daily_digest__c =: true];
                Set<Id> userIds = new Set<Id>();
                for(DI_Idea_Exchange_Daily_Digest__c rec : registeredUser) {
                    userIds.add(rec.DI_User__c);
                }
                subscribers = [SELECT Id, Name, DI_Fi_Domain__c, DI_Fi_Name__c FROM User WHERE Id IN : userIds];
                return subscribers;
            } else {
                return null;
            }
        }
        
        // If there is no Idea created for the community/Network then return null
        return null;

    }
    
    global void execute(Database.BatchableContext BC, list<User> subscribers){
        if (subscribers != null) {
            system.debug('****'+subscribers);
            // Find from address
            List<OrgWideEmailAddress> orgWideEmails = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Idea Exchange' LIMIT 1] ;
            // Fetching Visualforce Email template
            List<EmailTemplate> emailTemplate = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'NCR_Daily_Summary_Email_Template' LIMIT 1];
            // If Email Template found than send the mail else do not send the mail.
            if (emailTemplate.size() > 0) {
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                if (subscribers.size() > 0) {
                    for (User userRec : subscribers) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(userRec.Id);
                        mail.setTemplateId(emailTemplate[0].Id);
                        mail.saveAsActivity = false;
                        if (orgWideEmails.size() > 0)
                            mail.setOrgWideEmailAddressId(orgWideEmails[0].Id);
                        mails.add(mail);
                    }
                                       
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                                      
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
}