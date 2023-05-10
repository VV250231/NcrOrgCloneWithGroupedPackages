@isTest 
private class CaseEmailServiceTest {

    static testMethod void testMe() {

      // create a new email and envelope object
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      CaseEmailService emailProcess = new CaseEmailService();
      Account a = TestRecordsFactory.createAccount();
     
      emailProcess.handleInboundEmail(email, env);
        
      email.subject = 'Account MCN:TEST1234AAAAA';
      emailProcess.handleInboundEmail(email, env);
        
      email.subject = 'Account MCN-TEST1234AAAAA|Account Country Code-GG';
      emailProcess.handleInboundEmail(email, env);
        
      email.subject = 'Account MCN:TEST1234AAAAA|Account Country Code:';
      emailProcess.handleInboundEmail(email, env);
       
      email.subject = 'Account MCN:'+ a.Master_Customer_Number__c + '|Account Country Code:GB';
      emailProcess.handleInboundEmail(email, env);  
      // setup the data for the email
      email.subject = 'Account MCN:'+ a.Master_Customer_Number__c + '|Account Country Code:' + a.Account_Country_Code__c;
      email.plainTextBody = 'Case Origin:Email\n' + 'Case Description:test';
     
    
      // add an attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfile.txt';
      attachment.mimeTypeSubType = 'text/plain';
    
      email.binaryAttachments =
        new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        
     
      // add an attachment
      Messaging.InboundEmail.TextAttachment textattachment = new Messaging.InboundEmail.TextAttachment();
      textattachment.body = 'my attachment text';
      textattachment.fileName = 'textfile.txt';
      textattachment.mimeTypeSubType = 'text/plain';
    
      email.TextAttachments =
        new Messaging.inboundEmail.TextAttachment[] { textattachment };
    
      // call the email service class and test it with the data in the testMethod
      Messaging.InboundEmailResult emailResult = emailProcess.handleInboundEmail(email, env);
      System.assertEquals(emailResult.success, true);
      emailProcess.getInboundEmailResult('test');
    }
}