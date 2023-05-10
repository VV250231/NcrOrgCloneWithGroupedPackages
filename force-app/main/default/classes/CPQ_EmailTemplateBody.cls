global with sharing class CPQ_EmailTemplateBody {

    @InvocableMethod(label='get email body')
    public static List<CPQ_EmaileBody> getEmailBody(List<CPQ_InvocableRequest> requestList) {
        String templateDeveloperName;
        String emailTemplateId;
        List<CPQ_EmaileBody> emailTemplateBodyList = new List<CPQ_EmaileBody>();
        for (CPQ_InvocableRequest request : requestList) {
            if (templateDeveloperName== null || ! templateDeveloperName?.equalsIgnoreCase(request.templateDeveloperName)) {
                emailTemplateId = getTemplateId(request.templateDeveloperName);
            }
            CPQ_EmaileBody emailBody = new CPQ_EmaileBody();
            emailBody.htmlBody = getHTMLBodyOfTemplate(emailTemplateId, request.whoId, request.whatId);
            emailBody.plainBody = getPlainBodyOfTemplate(emailTemplateId, request.whoId, request.whatId);
            emailTemplateBodyList.add(emailBody);
        }      
        return emailTemplateBodyList;
    }   

    private static String getTemplateId(String templateDeveloperName) {
        String emailTemplateId;
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();

        emailTemplateList = [SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName =: templateDeveloperName ];
        if (!emailTemplateList.isEmpty()) {
            emailTemplateId= emailTemplateList[0].Id;
        }
        return emailTemplateId;
    }

    private static String getHTMLBodyOfTemplate(String templatId, String whoId, String whatID) {
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templatId, whoId, whatId);
        return message.getHtmlBody();    
    }

    private static String getPlainBodyOfTemplate(String templatId, String whoId, String whatID) {
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templatId, whoId, whatId);
        return message.getPlainTextBody();    
    }

    global class CPQ_EmaileBody {
        @InvocableVariable
        global String htmlBody;
        @InvocableVariable
        global String plainBody;
    }

    public class CPQ_InvocableRequest {
        @InvocableVariable
        public String templateDeveloperName;
     
        @InvocableVariable
        public String whoId;
    
        @InvocableVariable
        public String whatId;
    }
}