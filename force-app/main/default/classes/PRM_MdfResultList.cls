public with sharing class PRM_MdfResultList {
     
        /* -Method Name : getPartnerFundROIList.
    *  -Method parameters :  There is no parameter are required to call this method.
    *  -Method Return Type : Return typre is  List of Partner Fund ROI. 
    *  -Method Description : This method is called By wire method(LWC) and used to get all ROI records Where Status is != to Drafted.  
    */
    @AuraEnabled 
    public static List<Partner_Fund_ROI__c> getPartnerFundROIList(){        
        List<Partner_Fund_ROI__c> partnerFundRoiList = [SELECT Name, Fund_Claim__c, Fund_Claim__r.Name, Fund_Request__c,Fund_Request__r.Name,Fund_Request__r.Request_ID__c, Status__c, Channel_Account_Manager__c, Partner_Contact__c, Current_Revenue_earned__c, Partner_Account__c, CreatedDate, Id 
            FROM Partner_Fund_ROI__c WHERE Status__c != 'Drafted' ORDER BY CreatedDate DESC];
        return partnerFundRoiList;    
    } 
}