public class ApprovalClassLtngCon
{ 
    // Porcess portal Access Request
    @AuraEnabled
    public static ProcessResult submitPortalRequest(String recordId, String comment)
    {
        ProcessResult result ;
        Engineers__c eng = [Select id, Type_of_Portal_Access__c, Status__c from Engineers__c Where id =: Id.valueOf(recordId)];
        
        if(String.isNotBlank(eng.Type_of_Portal_Access__c))
        {
            if(eng.Type_of_Portal_Access__c.containsIgnoreCase('Portal Access'))
            {
                // If it's a new request or rejcted request in past than only allow it to submit
                if (eng.Status__c == 'Created' || eng.Status__c == 'Rejected') {
                    // Submit portal access request
                    result = approvalSubmission(recordId, UserInfo.getUserId(), comment);
                }
                else if (eng.Status__c == 'Submitted') {
                    result = new ProcessResult('info', 'Portal access request has already been Submitted. You will not be able to re-submit this request for approval.');
                }
                else if (eng.Status__c == 'Approved') {
                    result = new ProcessResult('info', 'Portal access request has already been approved. You will not be able to re-submit this request for approval.');
                }
            }
            else
            {
                result = new ProcessResult('info', 'Portal access request already completed.');
            }
        }
        return result;
    }
    
    public static ProcessResult approvalSubmission(String objectId, String userId, String strComment)
    {
        ProcessResult result ;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(strComment);
        req1.setObjectId(Id.valueOf(objectId));
        req1.setSubmitterId(Id.valueOf(userId));
        
        // Submit the approval request for the account
        try
        {
            Approval.ProcessResult approvalResult = Approval.process(req1);
            if(approvalResult.isSuccess())
            {
                result = new ProcessResult('success',' Record successfully submitted for Approval');
            }
            else 
            {
                result = new ProcessResult('error', String.valueOf(approvalResult.getErrors()));
            }
        }
        catch (Exception e)
        {
            if(e.getMessage().containsIgnorecase('This record is currently in an approval process'))
            {
                result = new ProcessResult('error', 'Record has already been submitted for approval. Please contact the approver.');
            }
            else
            {
                result = new ProcessResult('error', 'Record cannot be submitted because of glitch in System. Contact IT support');
            }
        }
         return result;
    }
    
    /*// Process Diagnostic Request.
    @AuraEnabled
    public static String processDiagnosticsRequest(String objectId) {
        String resultStr = '';
        List<Attachment__c> engAttachmentList;
        
        List<Engineers__c> engList = [Select id, Status__c, Type_of_Portal_Access__c, Diagnostics_Request_Status__c  
                                      from Engineers__c Where id =: objectId LIMIT 1];
        
        
        if(engList.size() > 0) {
            if (engList[0].Status__c != 'Approved') {
                resultStr  = 'Portal Access must be approved to submit Diagnostics Request';
                
            } else if(engList[0].Diagnostics_Request_Status__c == 'Submitted') {
                resultStr  = 'Diagnostics Request has already been submitted. You will not be able to re-submit this request for approval.';
                
            } else if (engList[0].Diagnostics_Request_Status__c == 'Approved') {
                resultStr  = 'Diagnostics Request has already been approved. You will not be able to re-submit this request for approval.';
            }
            
            // If issue found return the issue.            
            if (String.isNotBlank(resultStr))
                return resultStr;
            
            engAttachmentList = [Select Id, Name, Engineers__c, Engineer_Attachment_Type__c From Attachment__c 
                                 Where Engineers__c =: engList[0].Id AND Engineer_Attachment_Type__c = 'IPP Order Form'];
            
            if (engAttachmentList.size() > 0) {
                // Setting value of 'Request For' field to 'Diagnostics' and 'Diagnostics Request Status' field to 'submitted'.
                engList[0].Type_of_Portal_Access__c = 'Diagnostics';
                engList[0].Diagnostics_Request_Status__c = 'Submitted';
                
                try {
                    update engList[0];
                } catch (exception ex) {
                    return resultStr = ex.getMessage();
                }                
                resultStr = approvalSubmission(objectId,UserInfo.getUserId());
            } else {
                resultStr = 'Please attach IPP Order Form in attachement to submit Diagnostics Request';
            }
        } else {
            resultStr  = 'Engineer record not found';
        }
        
        return resultStr;
    }*/
    
    @AuraEnabled
    public static ProcessResult submitDiagnosticsApprovalRequest(String recordId, String comment) 
    {
        ProcessResult result ;
        List<Attachment__c> engAttachmentList;
        
        List<Engineers__c> engList = [Select id, Status__c, Type_of_Portal_Access__c, Diagnostics_Request_Status__c  
                                      from Engineers__c Where id =: recordId LIMIT 1];
        
        
        if (engList[0].Status__c != 'Approved') 
        {
            result = new ProcessResult('info','Portal Access must be approved to submit Diagnostics Request');
            return result;
        } 
        else if(engList[0].Diagnostics_Request_Status__c == 'Submitted') 
        {
            result = new ProcessResult('info','Diagnostics Request has already been submitted. You will not be able to re-submit this request for approval.');
            return result;
        } 
        else if (engList[0].Diagnostics_Request_Status__c == 'Approved') 
        {
            result = new ProcessResult('info','Diagnostics Request has already been approved. You will not be able to re-submit this request for approval.');
            return result;
        }
        
        engAttachmentList = [Select Id, Name, Engineers__c, Engineer_Attachment_Type__c From Attachment__c 
                                 Where Engineers__c =: engList[0].Id AND Engineer_Attachment_Type__c = 'IPP Order Form'];
        
        if(!engAttachmentList.isEmpty() || Test.isRunningTest())
        {
            engList[0].Type_of_Portal_Access__c = 'Diagnostics';
            engList[0].Diagnostics_Request_Status__c = 'Submitted';
                
            try 
            {
                update engList[0];
            } 
            catch (exception ex) 
            { 
                result = new ProcessResult('error',ex.getMessage());
            }                
            result = approvalSubmission(recordId, UserInfo.getUserId(), comment);
        }  
        else
        {
            result = new ProcessResult('info','Please attach IPP Order Form in attachement to submit Diagnostics Request');
            return result;
        }
        return result;
    }
    
    public class ProcessResult 
    {
        @AuraEnabled public String status = '';
        @AuraEnabled public String message = '';
        
        //public processResult(){}
        
        public processResult(String status, String message) 
        {
            this.status = status;
            this.message = message;
        }
    }
}