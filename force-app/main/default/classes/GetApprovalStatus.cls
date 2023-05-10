public class GetApprovalStatus {

    @AuraEnabled
    public static boolean getStatus(String recId){
        list<ProcessInstance> obj = new list<ProcessInstance>();
        Ticket_Request__c tr =new Ticket_Request__c();
        tr= [select name ,Approval_Status__c ,Controll_Approval_Modal__c,(SELECT Status, TargetObjectId FROM ProcessInstances) from Ticket_Request__c where id =:recId];
         //obj = [SELECT Status, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: recId limit 1];
        System.debug(tr);
        if(tr.ProcessInstances.size()>0 ){
             return false;
        }else if(tr.Controll_Approval_Modal__c){
            return false;
        }else if(tr.Approval_Status__c == 'Approved'){
            return false;
        }
        else{
            return true;
        }
        
       
    }
     @AuraEnabled
    public static void setControlModal(String recId){
        Ticket_Request__c obj = new Ticket_Request__c(id = recId);
        obj.Controll_Approval_Modal__c = true;
        update obj;
    }
    @AuraEnabled
    public static void SendForApproval(String recId,String Comments){
        System.debug('Send for approval');
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(Comments);
        req1.setObjectId(recId); 
        // Submit the approval request for the Opportunity
        Approval.ProcessResult result = Approval.process(req1);
    }
    
}