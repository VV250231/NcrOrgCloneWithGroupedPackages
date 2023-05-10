public class PRM_Opp_Net_New_Customer_PopUP_Contoller {
    
    @AuraEnabled
    public static Opportunity getOpportunityDetail(String oppId ){        
        Opportunity opportunityInfo = [SELECT Id,Net_New_Customer__c, CAM_TAM_Confirm_Net_New_Customer__c, Linked_Special_Bid_Registration__c 
                                       FROM Opportunity 
                                       WHERE Id =: oppId 
                                       LIMIT 1];
        return opportunityInfo;
    } 
    
    @AuraEnabled
    public static void setConfrimNetNewCustomer(String oppId ,Boolean netNewCustomerConfirm){        
        Opportunity opportunityInfo = [SELECT Id,Net_New_Customer__c, CAM_TAM_Confirm_Net_New_Customer__c, Linked_Special_Bid_Registration__c 
                                       FROM Opportunity 
                                       WHERE Id =: oppId 
                                       LIMIT 1];
		opportunityInfo.CAM_TAM_Confirm_Net_New_Customer__c = netNewCustomerConfirm;
        opportunityInfo.Net_New_Customer__c = true;
        Update opportunityInfo;
    }
}