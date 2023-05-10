trigger WarrantyLaborCommentsUpdate on Warranty_Labor_Request__c (before update) {


  Map<Id, Warranty_Labor_Request__c> wlrStatusUpdated
             = new Map<Id, Warranty_Labor_Request__c>{};

  for(Warranty_Labor_Request__c wlr: trigger.new)
  {
    /* 
      approval status field has been updated to rejected OR Approved. If so, put it in a map.
    */
    
    Warranty_Labor_Request__c oldWlr = System.Trigger.oldMap.get(wlr.Id);
	
    if ((oldWlr.Status__c != 'Rejected' &&  oldWlr.Status__c != 'Approved')
     && (wlr.Status__c == 'Rejected' ||  wlr.Status__c == 'Approved'))
    { 
    	wlr.Approval_Rejection_Date__c=System.Today();		
      wlrStatusUpdated.put(wlr.Id, wlr); 
      
    }
  }
   
  if (!wlrStatusUpdated.isEmpty())  
  {
    /* 
      Get the last approval process for the rejcted approvals, 
      and check the comments.
    */
    
    for (ProcessInstance pi : [SELECT TargetObjectId, 
                              (  
                                 SELECT Id, StepStatus, Comments 
                                 FROM Steps
                                 WHERE StepStatus = 'Rejected'
                                 OR StepStatus = 'Approved'
                                 ORDER BY CreatedDate DESC
                                 LIMIT 1 
                              )
                               FROM ProcessInstance
                               WHERE TargetObjectId In 
                                 :wlrStatusUpdated.keySet()
                               ORDER BY CreatedDate DESC
                              ])
    {   if ((pi.Steps[0].Comments != null && pi.Steps[0].Comments.trim().length() != 0))  { wlrStatusUpdated.get(pi.TargetObjectId).Approval_Rejection_Comments__c=pi.Steps[0].Comments;
        
      }
    }  
  }
}