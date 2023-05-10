/************************************** 
Author ...............: Suraj Parihar
Created Date..........: 22-JULY-2021
Modified Date.........: 22-JULY-2021
Description...........: Email class to send the excel sheet which includes the MULTI-SITE LOCATION information for the related Quote. 
***************************************/
global class CPQEmailPaymentApplicationRequest  {
    
    @InvocableMethod
    public static void sendPaymentApplicationEmail(List<ID> ids){  
        String  recordId = ids[0];
        PageReference pgRef = new PageReference('/apex/CPQMultiSiteLocationSheet?id='+recordId);
        SBQQ__Quote__c quote= new SBQQ__Quote__c();
        List<String> lstToAdd = new List<String>();
        List<String> lstCCAdd = new List<String>();
        
        // Only for testing, remove once emails available at account.
        String paymentSupport= System.Label.CPQ_JP_SupportMail;
        quote=  [SELECT Id,Name,qtc_new_aloha_key_number__c,Payments_Application_Signee__r.Email, SBQQ__Opportunity2__r.Channel_Office__r.Name, SBQQ__Opportunity2__r.Owner.Email, SBQQ__Opportunity2__r.Channel_Office__r.Master_Customer_Number__c,SBQQ__Account__r.id,SBQQ__Account__r.Name,SBQQ__SalesRep__r.email FROM SBQQ__Quote__c where Id =:recordId];
        
        if(quote.Payments_Application_Signee__r.Email!= null && quote.Payments_Application_Signee__r.Email != ''){
            lstToAdd.add(quote.Payments_Application_Signee__r.Email);
        }
        if(quote.SBQQ__Opportunity2__r.Owner.Email != null && quote.SBQQ__Opportunity2__r.Owner.Email != ''){
            lstCCAdd.add(quote.SBQQ__Opportunity2__r.Owner.Email);      
        }
        lstCCAdd.add(paymentSupport);
        
        String strFromEmail = NCR_CPQBLG_Email__c.getValues('Default Workflow Email').Email__c;        
        List<Messaging.SingleEmailMessage> singleMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('Multi-Site location information Sheet');  
        message.setReplyTo(strFromEmail);
        
        if(lstToAdd != null && lstToAdd.size() > 0){
            message.setToAddresses(lstToAdd);  
        }
        if(lstCCAdd != null && lstCCAdd.size() > 0){
            message.setCcAddresses(lstCCAdd);  
        }
        List<Messaging.Emailfileattachment> attachmentList = new  List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
        if (Test.isRunningTest()) {
            Blob myBlob = Blob.valueof('Testing');
            attachment.setBody(myBlob);
        }
        else {
            attachment.setBody(pgRef.getContent());
        }
        
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name ='MultiSiteLocationEmailTemplate'];
        Messaging.SingleEmailMessage rslt = Messaging.renderStoredEmailTemplate(et.Id,null,recordId);
        String htmlBody = rslt.getHtmlBody();
        message.setHtmlBody(htmlBody);
        message.setSubject(rslt.getSubject());
        attachment.ContentType ='application/vnd.ms-excel';
        attachment.setFileName('Multi Location spreadsheet'+'.xls');
        attachmentList.add(attachment);
        message.setFileAttachments(attachmentList);
        singleMessages.add(message);
        Messaging.sendEmail(singleMessages);
    }
}