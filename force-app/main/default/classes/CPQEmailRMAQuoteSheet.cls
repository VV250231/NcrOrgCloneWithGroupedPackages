/************************************** 
Author ...............: Suraj Parihar
Created Date..........: 31-DEC-2021
Modified Date.........: 31-DEC-2021
Description...........: Email class to send the excel sheet which includes the productId and Quantity for the RMA Quote. 
***************************************/
global class CPQEmailRMAQuoteSheet  {
    
    @InvocableMethod
    public static void sendRMASheet(List<ID> ids) {
        callEmailSend(ids);
    }
    @Future(callout=true)
    public static void callEmailSend(List<ID> ids) {
        //string recordId,
        String  recordId = ids[0]; 
        qtc_FulfillmentOrder__c qtRec= new qtc_FulfillmentOrder__c();
        //  String recordId = id;
        qtRec=  [SELECT Id,qtc_Quote__r.name, qtc_Quote__r.SBQQ__Account__r.name FROM qtc_FulfillmentOrder__c where Id =:recordId];
        
        PageReference pgRef = new PageReference('/apex/CPQGenerateRMASheet?id='+recordId);
        
        //pick the Id of Integraton User from custom settings
        NCR_CPQBLG_Email__c user = NCR_CPQBLG_Email__c.getValues('Order Management');
        
        String strToEmail = NCR_CPQBLG_Email__c.getValues('Order Management').Email__c;
        //  String strToEmail = 'sp185453@ncr.com';
        String strFromEmail = NCR_CPQBLG_Email__c.getValues('Default Workflow Email').Email__c;
        
        List<Messaging.SingleEmailMessage> singleMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('RMA Admin');
        message.setReplyTo(strFromEmail);
        message.setToAddresses(new List<string>{strToEmail});
        String subject = 'CPQ Quote:' + qtRec.qtc_Quote__r.name +'- RMA Template for '  + qtRec.qtc_Quote__r.SBQQ__Account__r.name+'';
        message.setSubject(subject);
        
        String strEmail = 'An Amendment has been created with reduced quantity or complete removal of product on the quote.  Please find attached, the Return Material Authorization (RMA) Template.' ;
        
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
        attachment.setFileName('RMA Request Form Used by HSR SMB.xls');        
        attachmentList.add(attachment);
        message.setFileAttachments(attachmentList);
        singleMessages.add(message);
        Messaging.sendEmail(singleMessages);
    }
}