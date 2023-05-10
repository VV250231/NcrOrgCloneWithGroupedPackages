public class DisputeDetailController {
     
    @AuraEnabled
    public static List<Dispute_Reason_and_Flwup_Question__mdt> getDisputeReason(){
       List<Dispute_Reason_and_Flwup_Question__mdt> FollowUpQuestion = new List<Dispute_Reason_and_Flwup_Question__mdt>();

        for(Dispute_Reason_and_Flwup_Question__mdt QuestionObj : [Select Id,Label,ReasonCode__c,Dispute_Reason__c,Detailed_Question__c,Followup_Question__c from Dispute_Reason_and_Flwup_Question__mdt order by Label]){
            If(String.isNotBlank(QuestionObj.Dispute_Reason__c)){
                FollowUpQuestion.add(QuestionObj);
            }
        }
        
        return FollowUpQuestion;
    }
    
    @AuraEnabled
    Public static List<Dispute_Flwup_Answ_and_Detailed_Ques__mdt> getFollowUpAnsAndDetailQuestion(String DisputeReasonId){
        //Dispute_Flwup_Answ_and_Detailed_Ques__mdt
        List<Dispute_Flwup_Answ_and_Detailed_Ques__mdt> FollwoUpAnsAndDetailQuesList = new List<Dispute_Flwup_Answ_and_Detailed_Ques__mdt>();
        
        if(String.isNotBlank(DisputeReasonId)){
            for(Dispute_Flwup_Answ_and_Detailed_Ques__mdt DisputeFlwQusAnsObj : [Select id,Dispute_Reason_and_Question__c,Dispute_Detail_Question__c,Dispute_Detail_Answer__c,Followup_Answer__c,Dispute_Reason_and_Question__r.Label from Dispute_Flwup_Answ_and_Detailed_Ques__mdt  where Dispute_Reason_and_Question__c =: DisputeReasonId]){
            	FollwoUpAnsAndDetailQuesList.add(DisputeFlwQusAnsObj);
       		}
        }

        return FollwoUpAnsAndDetailQuesList;
    }
}