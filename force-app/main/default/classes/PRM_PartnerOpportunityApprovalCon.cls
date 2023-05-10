public without sharing class PRM_PartnerOpportunityApprovalCon {

    @AuraEnabled
    public static ProcessResult submitPartnerOpportunityRequest(String objectId, String comment) {
        ProcessResult result ;
        
        // Check TAM is selected on the request
        List<Partner_Opportunity__c> parOppList = [SELECT Id,Status__c,Partner_Account__c, TAM__c FROM Partner_Opportunity__c WHERE Id=: objectId LIMIT 1];
        
        
           
        
        if (parOppList.size()>0) {
            List<AccountTeamMember> lstAccountTeamMember = [Select User.Name, UserId, Title, TeamMemberRole, SystemModstamp, PhotoUrl, OpportunityAccessLevel, Id, 
                                                            ContactAccessLevel, CaseAccessLevel, AccountId, AccountAccessLevel From AccountTeamMember where AccountId =: parOppList[0].Partner_Account__c];
            if (lstAccountTeamMember.size()>0 && !(parOppList[0].TAM__c != null)) {
                result = new ProcessResult('info','You will not be able to submit the record for approval without TAM selection. Please click on TAM selection button to continue.');
                return result;
            }
            if (parOppList[0].Status__c == 'Approved') {
                result = new ProcessResult('info','You cannot submit a request that is already approved.');
                return result;
            }
            if (parOppList[0].Status__c == 'Pending') {
                result = new ProcessResult('info','Record is already pending for approval.');
                return result;
            }
        }
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest ();
        req.setComments(comment);
        req.setObjectId(Id.valueOf(objectId));
        try
        {
            Approval.ProcessResult res =Approval.process(req);
            if(res.isSuccess())
            {
                result = new ProcessResult('success','Your request has been submitted');
            } else {
                
                result = new ProcessResult('error',String.valueOf(res.getErrors()));
                system.debug('***'+res.getErrors());
            }
        }
        catch (Exception e)
        {
            if(e.getMessage().containsIgnorecase('This record is currently in an approval process')){
                result = new ProcessResult('error','already has been submitted for approval. Please contact the approver.');
            }
            else{
                result = new ProcessResult('error','cannot be submitted because of glitch in System. Contact IT support');
                system.debug('***'+e.getMessage());
            }
        }
        return result  ;
        
    }
    
    public class ProcessResult {
        @AuraEnabled public String status='';
        @AuraEnabled public String message='';
        
        /*public processResult(){} commented empty block */
        
        public processResult(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}