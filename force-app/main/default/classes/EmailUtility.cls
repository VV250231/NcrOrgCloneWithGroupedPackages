public class EmailUtility {
    public Static void sendEmail(string strEmailSubject,string strEmailHeader,string strEmailSubHeader,string strEmailBodytoReplaced, list<string> address) 
    {
        strEmailBodytoReplaced = strEmailBodytoReplaced.replace('<br/>', '\n');
        strEmailBodytoReplaced = strEmailBodytoReplaced.replace('<p>', '\n');
        NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
        if(address.size() > 0)
            ncrEmail.Recipient1__c = address[0];
        if(address.size() > 1)
            ncrEmail.Recipient2__c = address[1];
        if(address.size() > 2)
            ncrEmail.Recipient3__c = address[2];
        if(address.size() > 3)
            ncrEmail.Recipient4__c = address[3];
        if(address.size() > 4)
            ncrEmail.Recipient5__c = address[4];
        ncrEmail.Email_Type__c = 'GenericPlainText';
        if (strEmailSubject.contains('Failed')){
            ncrEmail.Header_Background_Color__c = 'Red';
        }
        ncrEmail.Subject__c = strEmailSubject;
        ncrEmail.title__c = strEmailHeader;
        ncrEmail.Subtitle__c = strEmailSubHeader;
        ncrEmail.HTML_Body__c = strEmailBodytoReplaced; 
        
        if(!Test.isRunningTest())
            Insert ncrEmail;
        
    }
}