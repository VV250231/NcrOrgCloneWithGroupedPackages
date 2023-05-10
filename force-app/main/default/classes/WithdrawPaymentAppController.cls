/**************************************
Author ...............: Devendra Kumar Tiwari
Modified Date.........: 29-Jun-2022
Description...........: SFCPQBLG-946 

***************************************/
public class WithdrawPaymentAppController {
    
  
    final static String STATUS_SUCCESS = 'Success',
                        STATUS_FAILURE = 'Failure';
    
    @auraEnabled    
    public static List<NCR_Payments_Site__c> validatePaymentAppWithdrawal(Id quoteID){
        List<NCR_Payments_Site__c> paymentSites = [Select id, NCR_Payments_Application_Status__c,  Quote__r.Name, Quote__r.qtc_Multi_Site__c, Quote__c from NCR_Payments_Site__c where Quote__c =:quoteID];
        System.debug('paymentSites : ' + paymentSites);
        return paymentSites;
    }    
	@auraEnabled
    public static String notifyToWithdrawApplication(Id quoteID, String withdrawalComments){
        String status = STATUS_SUCCESS;
            String reqBodyJSON;
            HttpResponse httpAppResp;
        String response = CPQ_InfiniCeptCallouts.sendWithdrawalRequest(quoteID, withdrawalComments);
		return response;
    }
     
}