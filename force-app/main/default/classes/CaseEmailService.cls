global class CaseEmailService implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        Savepoint sp = Database.setSavepoint();
        
        try {           
            String valStr =  validateEmailSubject(email.Subject);
            String emailBody= email.plainTextBody;
            system.debug('emailBody>>>>>>' + emailBody);
            if(String.isBlank(valStr)) { // no error
                
                String emailSubject = EncodingUtil.urlDecode(email.Subject, 'UTF-8'); 
                List<String> fieldValueList = emailSubject.trim().Split('\\|');
                System.debug('fieldValueList >>'  + fieldValueList.size());
                String MCN = fieldValueList.get(0).trim().split(':').get(1).trim();   
                String ctryCode = fieldValueList.get(1).trim().split(':').get(1).trim(); 
                system.debug('MCN>>>>>>>' + MCN);
                system.debug('ctryCode>>>>>>>' + ctryCode);
                List<Account> matchAcctList = [SELECT Id, Master_Customer_Number__c FROM Account 
                                                    WHERE Master_Customer_Number__c = :MCN AND 
                                                    Account_Country_Code__c = :ctryCode LIMIT 1]; 
                                                    
                if(!matchAcctList.isEmpty()) {
                    Group Entitlement_Queue = [Select Id,name from Group where DeveloperName='Entitlement_Queue' and Type = 'Queue' LIMIT 1];
                    
                    //Fetching the assignment rules on case
                    AssignmentRule AR = new AssignmentRule();
                    AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                    
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                    
                    Case c = new Case();
                    c.AccountId = matchAcctList.get(0).Id;
                    c.Subject =  'Compile Case for Customer Number: ' + MCN;
                    c.Queue__c = 'Entitlement Queue'; 
                    c.Priority = 'Medium';
                    c.RecordTypeId = NSCCommonInfoUtil.getIdOf('CasePOReviewRTId'); //'012700000009spY'
                    c.Case_Creation_Source__c = 'CaseEmailService';
                    c.setOptions(dmlOpts);
                    //Added By Ravi to Populate Pipeline Values
                    CaseWrapper caseWrap = setPipelineValues(emailBody,c);
                    if(caseWrap.sucess){
                        c= caseWrap.caserecord;
                    }
                    insert c; 
                    
                    List<Attachment> attLst = new List<Attachment>();                    
                    if(email.textAttachments != null && email.textAttachments.size() > 0) {
                        for (Messaging.Inboundemail.TextAttachment tAttch : email.textAttachments) {                          
                          attLst.add(new Attachment(Name = tAttch.fileName, Body = Blob.valueOf(tAttch.body), ParentId = c.Id));                          
                        }
                    }
                    
                    if(email.binaryAttachments != null &&  email.binaryAttachments.size() > 0) {
                        for (Messaging.Inboundemail.BinaryAttachment bAttch : email.binaryAttachments) {                                                
                          attLst.add(new Attachment(Name = bAttch.fileName, Body = bAttch.body, ParentId = c.Id));  
                        }
                    }     
                    if(!attLst.isEmpty()) insert attLst;
                    result.success = true;
                } else {
                     result.success = false;
                     result.message = 'Error: No matching Account found for Master Customer Numnber:' + MCN  + ' and Country Code:' + ctryCode + ' provided';
                }
            } else {
                result.success = false;
                result.message = valStr;
            }
           
        }  catch(Exception e) {
            Database.rollback(sp);
            result.success = false;
            result.message = 'Error ::' + e.getMessage();            
        }
        System.debug('Email handler Result ::' + result);
        return result;
    }
    
    public Messaging.InboundEmailResult getInboundEmailResult(String msg) {
         Messaging.InboundEmailResult result = new Messaging.InboundEmailResult(); 
         result.success = false;
         result.message = msg;
         
         return result;
    }
    
    private String validateEmailSubject(String emailSubject) {
        String valString = null;
        
        
        if(String.isBlank(emailSubject)) {
            valString  = 'Error: Incorrect format for email Subject.'; 
              
        } else { //check MCN and Country Codse in MCN: 9748791|Country Code:US
            emailSubject =  EncodingUtil.urlDecode(emailSubject, 'UTF-8');
             System.debug(emailSubject);
            List<String> fieldValueList = emailSubject.trim().Split('\\|');
            
            System.debug('fieldValueList' + fieldValueList.size());
            if (fieldValueList.size() < 2) { 
               valString  = 'Error: Incorrect format for email Subject.'; 
                     
            } else { 
                List<String> mcnValuePair = fieldValueList.get(0).trim().split(':');
                List<String> ctryCodeValuePair = fieldValueList.get(1).trim().split(':'); 
                
                System.debug( 'mcnValuePair ' + mcnValuePair );
                 System.debug( 'ctryCodeValuePair ' + ctryCodeValuePair );
                
                if((mcnValuePair == null) || (mcnValuePair.size() < 2) || (ctryCodeValuePair == null) || (ctryCodeValuePair.size() < 2))  {
                    valString  = 'Error: Incorrect format for email Subject.'; 
                }  else {
                    String mcnStr, mcnValue, ctryCodeStr, ctryCodeValue;
                    
                    mcnStr = mcnValuePair.get(0).trim();
                    mcnValue = mcnValuePair.get(1).trim();
                    ctryCodeStr = ctryCodeValuePair.get(0).trim();
                    ctryCodeValue = ctryCodeValuePair.get(1).trim();
                    
                    if (String.isBlank(mcnStr) || String.isBlank(mcnValue) || String.isBlank(ctryCodeStr) || String.isBlank(ctryCodeValue)) {
                        valString  = 'Error: Customer Master Customer Number or Country Code not provided in email Subject.';      
                    }
                }
                  
            } 
        } 
        return valString;
    }
    
    public static CaseWrapper setPipelineValues(String emailBody, Case caseRecord){
            CaseWrapper caseWrap = new CaseWrapper();
            caseWrap.caserecord = caseRecord;
        try{
            system.debug('emailBody>>>>>' + emailBody);
            List<String> fieldValueList = emailBody.trim().Split('\n');
            System.debug('fieldValueList >>'  + fieldValueList.size());
            System.debug('fieldValueList >>'  + fieldValueList);
            String PipelineSource = fieldValueList.get(0).trim().split(':').get(1).trim();   
            String PipelineSourceExplanation = fieldValueList.get(1).trim().split(':').get(1).trim();
            System.debug('PipelineSource >>'  + PipelineSource);
            System.debug('PipelineSourceExplanation >>'  + PipelineSourceExplanation);
            caseRecord.Pipeline_Source__c = PipelineSource;
            caseRecord.Pipeline_Source_Explanation__c = PipelineSourceExplanation;
            caseWrap.sucess = true;
        }catch(exception ex){
            caseWrap.sucess = false;
        }
        system.debug('caseWrap>>>>>' + caseWrap);
        return caseWrap;
        
    }
    
    public class CaseWrapper{
        public Case caserecord;
        public Boolean sucess;
    }

}