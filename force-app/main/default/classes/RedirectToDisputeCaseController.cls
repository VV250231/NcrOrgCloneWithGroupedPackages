public class RedirectToDisputeCaseController {

    
    @AuraEnabled
    Public static string ParseDataToDisputeObj(String TableDataJson,String DisputeCaseId){
        
        //System.debug('TableDataJson'+TableDataJson);
        //System.debug('DisputeCaseId'+DisputeCaseId);
        return PardateTableDataToDisputeInvoice.parse(TableDataJson,DisputeCaseId);
    }
}