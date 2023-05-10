/****************************************************************************************************************
*   ClassName :   PSFR_ApprovalRequestCommentsController
*   Description :   
*   Author      :   
*   Version     :   Initial
*  testClass : PSFR_Approved_Comments_Test
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1669       8th Dec 2021    Varsha Pal             Remove the testcoverage function
****************************************************************************************************************/
public class PSFR_ApprovalRequestCommentsController {
    public String PSFRID{get;set;}
    public List<ProcessInstanceHistory> getApprovalSteps() {
      if (PSFRID!= null) {
       Presales_Funding_Request__c quote = [Select Id, (Select TargetObjectId, SystemModstamp, StepStatus, RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, CreatedDate, CreatedById, Comments, ActorId From ProcessSteps order by SystemModstamp desc limit 1 ) from Presales_Funding_Request__c where Id = :PSFRID];
        
        return quote.ProcessSteps;
      }
      return new List<ProcessInstanceHistory> ();
    }
}