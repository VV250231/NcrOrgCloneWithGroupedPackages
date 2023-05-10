public class sendCaseEmail{
    @InvocableMethod(label='Case Email' description='Send email')
    public static void getAccountNames(List<Case> Cases) {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'IPT_Partner' AND SobjectType='Case' LIMIT 1 ];
        List<NCR_EmailMessage__c> mails = new List<NCR_EmailMessage__c>();
        List<EmailTemplate> emailTemp = [select id, Subject, HtmlValue from EmailTemplate where Name ='Get Help Submission Notification VF'];
        //Change by Saurav(EBA_SF-1349)----------------------
        Map<string,Get_help_Configuration__mdt> gHCMap = new Map<string,Get_help_Configuration__mdt>();
        for(Get_help_Configuration__mdt ghc :[Select id, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c,MasterLabel from Get_help_Configuration__mdt]){
           gHCMap.put(ghc.MasterLabel,ghc);
         }
        User lusr = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];        
        List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: lusr.AccountId LIMIT 1];
        //Change by Saurav(EBA_SF-1349)----------------------
        //List<String> sendTo = new List<String>();
        For(Case c : cases){
            //List<Get_help_Configuration__mdt> getHelpConfiguration =[Select id, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c from Get_help_Configuration__mdt Where MasterLabel =: c.Category__c ] ;
            //String userName = getHelpConfiguration[0].Case_Assigned_User_Name__c +'%';
            //List<User> userObj = [Select Id from User Where UserName Like : userName ];
           //Change by Saurav(EBA_SF-1349)----------------------
            List<String> sendTo = new List<String>();
             if(gHCMap.get(c.Category__c) != Null){
            sendTo = gHCMap.get(c.Category__c).Email_Send_List__c.split(',');
                   sendTo.add(UserInfo.getUserEmail());
            }    
            //Change by Saurav(EBA_SF-1349)----------------------
            //List<OrgWideEmailAddress> emailAddress = new List<OrgWideEmailAddress>();
            //emailAddress = [SELECT Id, address FROM OrgWideEmailAddress WHERE address = 'partner.resourcecenter@ncr.com']; 
            //get the data
            
           // List<String> sendTo = getHelpConfiguration[0].Email_Send_List__c.split(',');
            //sendTo.add(UserInfo.getUserEmail());
            
            //ContactEmail Added by Anupam   
            if(String.isNotBlank(c.contactEmail))
                sendTo.add(c.contactEmail);
            if (UserInfo.getUserId() != null) {
                //Change by Saurav(EBA_SF-1349)----------------------
                //List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
               // if (users.size() > 0) {
                 //   List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: users[0].AccountId LIMIT 1];
                    if (accounts.size() > 0) {
                        sendTo.add(accounts[0].Owner.Email);
                    }
                    //Change by Saurav(EBA_SF-1349)----------------------
                }
            
            
            //Locate the contact for creating mail          
            //Contact co = [select id, Email from Contact where email <> null and name='partner demo contact' limit 1];
            //List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            
            
            /*Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId( [select id from EmailTemplate where Name ='Get Help Submission Notification VF'].id );
            msg.setWhatId(c.id);
            msg.setTargetObjectId(co.id);
            msg.setToAddresses(new List<String>{'partner.resourcecenter@ncr.com'});
            if (emailAddress.size() > 0) {
                msg.setOrgWideEmailAddressId(emailAddress[0].Id);
            }
            lstMsgs.add(msg);

            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(lstMsgs);
            Database.rollback(sp);
            
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
            */
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id, null, c.Id);
            if(emailTemp.size() > 0) {
                NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                ncrEmail.Email_Type__c = 'sendCaseEmail';
                ncrEmail.HTML_Body__c = mail.gethtmlBody();
                ncrEmail.Subject__c = mail.getSubject();
                if(sendTo.size() > 0)
                    ncrEmail.Recipient1__c = sendTo[0];
                if(sendTo.size() > 1)
                    ncrEmail.Recipient2__c = sendTo[1];
                if(sendTo.size() > 2)
                    ncrEmail.Recipient3__c = sendTo[2];
                if(sendTo.size() > 3)
                    ncrEmail.Recipient4__c = sendTo[3];
                if(sendTo.size() > 4)
                    ncrEmail.Recipient5__c = sendTo[4];
                ncrEmail.Case_Category__c = c.Category__c;
                mails.add(ncrEmail);
            }
            
            /*for (Messaging.SingleEmailMessage email : lstMsgs) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(sendTo);
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                if (emailAddress.size() > 0 && c.Category__c != 'MDF') {
                    emailToSend.setOrgWideEmailAddressId(emailAddress[0].Id);
                }
                lstMsgsToSend.add(emailToSend);
            }
            Messaging.sendEmail(lstMsgsToSend);
            */
        }
        
        if(mails.size() > 0)
            Insert mails;
    }

}