public class EULASubmissionsApprovalCont 
{
    @AuraEnabled
    public static ProcessResult submitApprovalRequest(String recordId, String comment) 
    {
        ProcessResult result ;
        EULA_submission__c objES = [Select Status__c, (Select Id, ParentId,RecordType, Title, FileType, ContentSize, FileExtension, ContentUrl, ExternalDataSourceName, 
                                                    ExternalDataSourceType, SharingOption From CombinedAttachments)
                                        From EULA_submission__c where Id =: recordId];
        
        List<CombinedAttachment> lstEULASubmissionAttachment = objES.CombinedAttachments;
        System.debug('------------lstEULASubmissionAttachment------------------'+lstEULASubmissionAttachment);
        
        if(objES.Status__c == 'Approved') 
        {
            result = new ProcessResult('error','Record has been already approved.');
            return result;
        }
        if (objES.Status__c == 'Pending') 
        {
            result = new ProcessResult('error','Record is already pending for approval.');
            return result;
        }
        
        if(!lstEULASubmissionAttachment.isEmpty())
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
            result = new ProcessResult('info','Please upload the EULA document before submitting for Approval.');
            return result;
        }
        return result;
    }
    
    public class ProcessResult 
    {
        @AuraEnabled public String status = '';
        @AuraEnabled public String message = '';
        
        /*public processResult(){} commented empty statement block */
        
        public processResult(String status, String message) 
        {
            this.status = status;
            this.message = message;
        }
    }
}