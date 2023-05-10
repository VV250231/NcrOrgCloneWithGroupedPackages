public class CommonUtility {
  public Static void sendEmail(string strEmailSubject,string strEmailHeader,string strEmailSubHeader,string strEmailBodytoReplaced,string EmailBody, list<string> address) 
    {
        

       	EmailBody = EmailBody.replace('#Body', strEmailBodytoReplaced);
        
        If (strEmailSubject.contains('Failed'))
        {
        EmailBody=EmailBody.replace('id = "HeaderID" bgcolor="#54b948"', 'id = "HeaderID" bgcolor="Red"');
        }
       

        EmailBody=EmailBody.replace('#Header', strEmailHeader);
        EmailBody=EmailBody.replace('#HeadLine', strEmailSubHeader);
        
        
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.addAll(address);
        message.setToAddresses(sendTo);
        message.subject = strEmailSubject;
        message.setHtmlBody(EmailBody); 
        System.debug( EmailBody);
        
        Messaging.SingleEmailMessage[] messages =
            new List < Messaging.SingleEmailMessage > {
                message
                    };
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +
                         results[0].errors[0].message);
        }
    }}