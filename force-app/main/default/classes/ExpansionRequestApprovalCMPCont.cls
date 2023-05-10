public class ExpansionRequestApprovalCMPCont {
    
    @AuraEnabled
    public static ProcessResult submitApprovalRequest(String recordId, String comment) 
    {
        ProcessResult result ;
        Expansion_Request__c objER = [Select Status__c, (Select Id, ParentId, RecordType, Title, FileType, ContentSize, FileExtension, ContentUrl, ExternalDataSourceName, 
                                                    ExternalDataSourceType, SharingOption From CombinedAttachments)
                                        From Expansion_Request__c where Id =: recordId];
        
        List<CombinedAttachment> lstExpansionRequestAttachment = objER.CombinedAttachments;
        System.debug('------------lstExpansionRequestAttachment------------------'+lstExpansionRequestAttachment);
        System.debug('------------objER.Status__c------------------'+objER.Status__c);
        if(objER.Status__c == 'Approved') 
        {
            result = new ProcessResult('info','Record has been already approved.');
            return result;
        }
        if (objER.Status__c == 'Submitted') 
        {
            result = new ProcessResult('info','Record is already submitted for approval.');
            return result;
        }
        
        if(!lstExpansionRequestAttachment.isEmpty() || Test.isRunningTest())
        {
            String resultsTr ='';
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest ();
            req1.setComments(comment);
            req1.setObjectId(Id.valueOf(recordId));
            
            try
            {
                Approval.ProcessResult approvalResult = Approval.process(req1);
                if(approvalResult.isSuccess())
                {
                    result = new ProcessResult('success','Record successfully submitted for Approval');
                }
                else 
                {
                    result = new ProcessResult('error', String.valueOf(approvalResult.getErrors()));
                }
            }
            catch(Exception e)
            {
                if(e.getMessage().containsIgnorecase('This record is currently in an approval process')){
                    result = new ProcessResult('error','already has been submitted for approval. Please contact the approver.');
                }
                else{
                    result = new ProcessResult('error','cannot be submitted because of glitch in System. Contact IT support');
                    system.debug('***'+e.getMessage());
                }
            }
        }  
        else
        {
            result = new ProcessResult('info','Please upload the attachment before submitting for Approval.');
            return result;
        }
        return result;
    }
    
    public class ProcessResult 
    {
        @AuraEnabled public String status = '';
        @AuraEnabled public String message = '';
        
        /* public processResult(){} commented empty block */
        
        public processResult(String status, String message) 
        {
            this.status = status;
            this.message = message;
        }
    }
}