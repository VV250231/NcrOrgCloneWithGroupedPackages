/**************************************
  Author ...............: Dharmendra Kumar Pandey
  Modified Date.........: 17-DEC-2020
  Description...........: Integration to QB for uploading order info. 
***************************************/
global class CPQEmailSalesOrder  {
    private Order ord;
    public CPQEmailSalesOrder (ApexPages.StandardController stdController){
        this.ord = (Order)stdController.getRecord();
        this.ord = [Select Name, AccountId from Order where id=:this.ord.Id];
    }
    
    public void sendQBOrder() {
        //string recordId, 
        string accountName = [Select name from Account where Id=:this.ord.AccountId].Name;
        
        String recordId = this.ord.Id;
        PageReference pgRef = new PageReference('/apex/CPQSalesOrderMultiSheet?id='+recordId);
        
        //pick the Id of Integraton User from custom settings
        NCR_CPQBLG_Email__c user = NCR_CPQBLG_Email__c.getValues('Order Management');
         
        String strToEmail = NCR_CPQBLG_Email__c.getValues('Order Management').Email__c;
        String strFromEmail = NCR_CPQBLG_Email__c.getValues('Default Workflow Email').Email__c;
        
        List<Messaging.SingleEmailMessage> singleMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('Subscription POS Admin');
        message.setReplyTo(strFromEmail);
        message.setToAddresses(new List<string>{strToEmail});
        message.setSubject('QB SalesOrder Information');
        
        String strEmail = 'Please enter the Subscription order for the customer ('+ accountName +'). The order is attached in a QB upload format.<br><br><br>' +
        'A link to the order is provided here - '+ system.url.getsalesforcebaseurl().toexternalform() + '/' + recordId +'. Please add the ERP Order Number to Salesforce.com when complete.<br><br>Thanks.';

        message.setHtmlBody(strEmail);
        List<Messaging.Emailfileattachment> attachmentList = new  List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
        if(Test.isRunningTest()) {
            Blob myBlob = Blob.valueof('Testing');
            attachment.setBody(myBlob);
        }
        else {
            attachment.setBody(pgRef.getContent());
        }
        attachment.ContentType ='application/vnd.ms-excel';
        //attachment.ContentType ='text/csv';
        attachment.setFileName('QBSalesOrder.xls');        
        attachmentList.add(attachment);
        message.setFileAttachments(attachmentList);

        singleMessages.add(message);
        Messaging.sendEmail(singleMessages);
        
		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Message Sent'));
      	
        //PageReference pgRefReturn = new PageReference('/'+recordId);
        //return pgRefReturn;  
    }
}