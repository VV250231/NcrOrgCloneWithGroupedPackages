public class TechnicalReviewApprovalProcess {
    @InvocableMethod
    public static void SubmitForTechnicalReview(List<id> TecRevId) {
        if(TecRevId.size() > 0 ){
            for(id trid : TecRevId){
                try{
                    Technical_Review__c TechReviewRec = [select id,ApprovalStatus__c from Technical_Review__c where id =:trid ];
                    if(TechReviewRec != null){
                        if(TechReviewRec.ApprovalStatus__c == null || TechReviewRec.ApprovalStatus__c == 'Recalled' || TechReviewRec.ApprovalStatus__c  == 'Rejected' ){
                            SBAA.ApprovalAPI.submit(TechReviewRec.Id, SBAA__Approval__c.Technical_Review__c);
                        }
                        if(TechReviewRec.ApprovalStatus__c == 'Approved' || TechReviewRec.ApprovalStatus__c == 'Pending'){
                            SBAA.ApprovalAPI.recall(TechReviewRec.Id, SBAA__Approval__c.Technical_Review__c);
                        }
                    }
                }
                catch( Exception e){
                    System.debug( e.getMessage());
                }
            }
        }
    }
}