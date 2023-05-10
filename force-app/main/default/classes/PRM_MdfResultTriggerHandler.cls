/*************************************************************************************************
*   ClassName   : PRM_MdfClaimHandler
*   Description :   
*   Author      :   
# Modification History.: 
Story No         Date           DevName         Description
EBA_SF-1948     20-10-2022      KAVYA SREE      Technical Debt - Apex sharing violation part 2 -PRM 
*************************************************************************************************/
public without sharing class PRM_MdfResultTriggerHandler {
    
    // Fill Partner Account, Partner Contact, CAM from MDF (Fund Request)
    public void updatePartnerInfo(List<Partner_Fund_ROI__c> newRecords) {
        Set<Id> fundIds = new Set<Id>();
        for (Partner_Fund_ROI__c ROI : newRecords) {
            if (ROI.Fund_Request__c != null) {
                fundIds.add(ROI.Fund_Request__c);
            }
            
        }
        
        Map<Id,SFDC_MDF__c> fundIdToFundRec = new Map<Id,SFDC_MDF__c>([SELECT Id, Name, Account__c, CAM__c, Requester_Name__c FROM SFDC_MDF__c WHERE Id IN : fundIds]);
        
        for (Partner_Fund_ROI__c ROI : newRecords) {
            if (fundIdToFundRec.containsKey(ROI.Fund_Request__c ) ) {
                if (fundIdToFundRec.get(ROI.Fund_Request__c ).Account__c != null) {
                    ROI.Partner_Account__c= fundIdToFundRec.get(ROI.Fund_Request__c ).Account__c;
                }
                
                if (fundIdToFundRec.get(ROI.Fund_Request__c ).CAM__c!= null) {
                    ROI.Channel_Account_Manager__c = fundIdToFundRec.get(ROI.Fund_Request__c ).CAM__c;
                }
                
                if (fundIdToFundRec.get(ROI.Fund_Request__c ).Requester_Name__c != null) {
                    ROI.Partner_Contact__c = fundIdToFundRec.get(ROI.Fund_Request__c ).Requester_Name__c;
                }
            }
        }
    }

}