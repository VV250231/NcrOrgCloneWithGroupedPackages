global class SchedulepullApprovalProcessDetailsClass implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      PullApprvlProcssDataIntoObjProcssDtails objBatchClass = new PullApprvlProcssDataIntoObjProcssDtails(); 
      database.executebatch(objBatchClass,2000);
    }
}