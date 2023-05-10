trigger Reject_FundRequest on AssociateResourceandRequest__c (before insert) 
{ 
    /*   Created by  : Saagar Kinja
     *    Email ID    : saagar.kinja@ncr.com 
     *   QLID        : SK250817
     *    Details     : This trigger will unlock fund request and reject fund request.
     *                  Further, PSFR_update trigger will move the status to new and 
     *                  Raise objection status will be change and trigger notification to concern teams
   */        
    for (Integer i = 0; i < Trigger.new.size(); i++){ 
        if (Trigger.new[i].Raised_Objection_Status__c != null){
            rejectRecord(Trigger.new[i]);
        }      
    }       
    public Id getWorkItemId(Id targetObjectId){            
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id  From   
                                                 ProcessInstanceWorkitem p 
                                                 Where  p.ProcessInstance.TargetObjectId =: targetObjectId]){
                                                     retVal  =  workItem.Id;
                                                 }
        return retVal;                             
    }        
    public void rejectRecord(AssociateResourceandRequest__c ps){        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();    
        Id workItemId = getWorkItemId(ps.Presales_Funding_Request__c);       
        if(workItemId == null){
            ps.addError(system.label.Rj_FndReq1); //look for custom label Rj_FndReq1 
        }          
        else{   req2.setComments('Raised Objection');req2.setAction('Reject');req2.setWorkitemId(workItemId);Approval.ProcessResult result =  Approval.process(req2);                                  
            } 
    }
}