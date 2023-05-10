/************************************** 
Author ...............: Suraj Parihar
Created Date..........: 13-APR-2021
Modified Date.........: 13-APR-2021
Description...........: Email class to send the excel sheet which includes the productId and Quantity for the related Quote. 
***************************************/
global class CPQEmailInstallSheetForQuote  {
    
    public static String recordId = ''; 
    
    public CPQEmailInstallSheetForQuote(ApexPages.StandardController stdController) {
        recordId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public static PageReference sendProducts(){  
   PageReference pgRef = new PageReference('/apex/CPQInstallSheetForQuote?id='+recordId);
        List<SBQQ__Quote__c> lstQuote= new List<SBQQ__Quote__c>();
        List<String> lstToAdd = new List<String>();
        List<String> lstCCAdd = new List<String>();
        // Only for testing, remove once emails available at account
        NCR_CPQBLG_Email__c user = NCR_CPQBLG_Email__c.getValues('Order Management');
        //  String strToEmail = NCR_CPQBLG_Email__c.getValues('Order Management').Email__c;
        //  lstToAdd.add(strToEmail);
        
        lstQuote = [SELECT Id,Name,qtc_New_Aloha_Key_Number__c, qtc_Existing_Aloha_Key_Number__c, SBQQ__Opportunity2__r.Channel_Office__r.Name, SBQQ__Opportunity2__r.Channel_Office__r.Project_Coordinator_Email__c, SBQQ__Opportunity2__r.Channel_Office__r.Master_Customer_Number__c,SBQQ__Account__r.id,SBQQ__Account__r.Name,SBQQ__SalesRep__r.email  FROM SBQQ__Quote__c where Id =:recordId];
        
        for(SBQQ__Quote__c qt : lstQuote){ 
            if(qt.SBQQ__Account__r.id != null){ 
                if(qt.SBQQ__Opportunity2__r.Channel_Office__r.Project_Coordinator_Email__c!= null && qt.SBQQ__Opportunity2__r.Channel_Office__r.Project_Coordinator_Email__c != ''){
                    lstToAdd.add(qt.SBQQ__Opportunity2__r.Channel_Office__r.Project_Coordinator_Email__c);
                }
                else{
                    ApexPages.addMessage(new apexpages.message(ApexPages.Severity.ERROR, 'Project coordinator’s email on the Channel/Local Office account '+ qt.SBQQ__Opportunity2__r.Channel_Office__r.Name +  ' having mcn = ' +qt.SBQQ__Opportunity2__r.Channel_Office__r.Master_Customer_Number__c + ' is missing.'));
                    return null;
                }
                if(qt.SBQQ__SalesRep__r.email != null && qt.SBQQ__SalesRep__r.email != ''){
                    lstCCAdd.add(qt.SBQQ__SalesRep__r.email);
                }
            }
        }
        
        String strFromEmail = NCR_CPQBLG_Email__c.getValues('Default Workflow Email').Email__c;        
        List<Messaging.SingleEmailMessage> singleMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('Subscription Install Sheet');  
        message.setReplyTo(strFromEmail);
        
        if(lstToAdd != null && lstToAdd.size() > 0){
            message.setToAddresses(lstToAdd);  
        }
        if(lstCCAdd != null && lstCCAdd.size() > 0){
            message.setCcAddresses(lstCCAdd);  
        }
        
        message.setSubject('Subscription Install Sheet');
        String strEmail = string.format(Label.InstalSheet_Email_Message, new List<String>{lstQuote[0].SBQQ__Account__r.Name, lstQuote[0].Name, lstQuote[0].qtc_New_Aloha_Key_Number__c, lstQuote[0].qtc_Existing_Aloha_Key_Number__c});
                
        message.setHtmlBody(strEmail);
        List<Messaging.Emailfileattachment> attachmentList = new  List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
        if (Test.isRunningTest()) {
            Blob myBlob = Blob.valueof('Testing');
            attachment.setBody(myBlob);
        }
        else {
            attachment.setBody(pgRef.getContent());
        }
        attachment.ContentType ='application/vnd.ms-excel';
        attachment.setFileName('ProductDetails_'+lstQuote[0].Name+'.xls');
        attachmentList.add(attachment);
        message.setFileAttachments(attachmentList);
        singleMessages.add(message);
        Messaging.sendEmail(singleMessages);
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Email Sent Successfully.'));
        return null;
        
        //PageReference quotePage = new PageReference('/'+recordId);
        //return quotePage;
    }
}