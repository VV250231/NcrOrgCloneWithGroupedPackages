/*************************************************************************************************
*   ClassName   : PRM_DealRegistrationDispatcher
*   Description :   
*   Author      :   
# Modification History.: 
Story No         Date           DevName         Description
EBA_SF-1948     20-10-2022      KAVYA SREE      Technical Debt - Apex sharing violation part 2 -PRM 
*************************************************************************************************/
public without sharing class PRM_DealRegistrationDispatcher extends TriggerHandlerBase {
    private static PRM_DealRegistrationTriggerHandler dealRegHdlr;

    public override void beforeInsert() {
        dealRegHdlr = (dealRegHdlr != null) ? dealRegHdlr : new PRM_DealRegistrationTriggerHandler();
        Set<Id> accountIds = new Set<Id>(); 
        Set<Id> endCustomerActIds = new Set<Id>();
        List<Deal_Registration__c> dealRegList = new List<Deal_Registration__c>();
        dealRegList = (List<Deal_Registration__c>) Trigger.new;
        /*Populate partner Account and Partner contact 
        If partner user is not filling these two fileds than autopopulate the information*/

        User u = [SELECT Id, Name, AccountId, ContactId, UserType FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];   
        for (Deal_registration__c dr : dealRegList) {
            
            if (dr.Partner_Company_Name__c == null && u.AccountId != null && u.Usertype == 'PowerPartner') {
                dr.Partner_Company_Name__c = u.AccountId;
            }
            
            if (dr.Partner_Contact__c == null && u.ContactId != null && u.Usertype == 'PowerPartner') {
                dr.Partner_Contact__c = u.ContactId;
            }          
        }
        dealRegHdlr.updateSaleOpInfo(dealRegList);

    }

    public override void afterInsert() {
        dealRegHdlr = (dealRegHdlr != null) ? dealRegHdlr : new PRM_DealRegistrationTriggerHandler();
        List<Deal_Registration__c> dealList = (List<Deal_Registration__c>) Trigger.new;
        Map<Id,Deal_Registration__c> newDealMap = (Map<Id,Deal_Registration__c>) Trigger.newMap;
        // Share Deal Registration Record with the Partner contact if Deal Registraion request created by Distributor.
        dealRegHdlr.dealSharing(dealList, newDealMap); 
    }

    public override void beforeUpdate() {
        dealRegHdlr = (dealRegHdlr != null) ? dealRegHdlr : new PRM_DealRegistrationTriggerHandler();
        Set<Id> accountIds = new Set<Id>(); 
        Set<Id> endCustomerActIds = new Set<Id>();
        List<Deal_Registration__c> dealRegList = new List<Deal_Registration__c>();
        dealRegList = (List<Deal_Registration__c>) Trigger.new;
        /*Populate partner Account and Partner contact 
        If partner user is not filling these two fileds than autopopulate the information*/

        User u = [SELECT Id, Name, AccountId, ContactId, UserType FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];   
        for (Deal_registration__c dr : dealRegList) {
            
            if (dr.Partner_Company_Name__c == null && u.AccountId != null && u.Usertype == 'PowerPartner') {
                dr.Partner_Company_Name__c = u.AccountId;
            }
            
            if (dr.Partner_Contact__c == null && u.ContactId != null && u.Usertype == 'PowerPartner') {
                dr.Partner_Contact__c = u.ContactId;
            }
            
            if (dr.Channel_Operation_Review_Request__c == false && dr.Status_Update__c == 'Submitted to CAM' && dr.Special_Bid_Registration_Type__c == 'Net New Customer') {
                dr.Status_Update__c = 'Submitted to Channel Operation';
            }          
        }
        dealRegHdlr.updateSaleOpInfo(dealRegList);
        
    }

    public override void afterUpdate() {
        dealRegHdlr = (dealRegHdlr != null) ? dealRegHdlr : new PRM_DealRegistrationTriggerHandler();
        Map<Id,Deal_Registration__c> newDealMap = (Map<Id,Deal_Registration__c>) Trigger.newMap;
        Map<Id,Deal_Registration__c> oldDealMap = (Map<Id,Deal_Registration__c>) Trigger.oldMap;
        List<Deal_Registration__c> newDeals =(List<Deal_Registration__c>)Trigger.new;
        
        // Share Deal Registration Record with the Partner contact if Deal Registraion request created by Distributor.
        List<Deal_Registration__c> dealsToShare = new List<Deal_Registration__c>();
        Set<Id> recsToDeltSharing = new Set<Id>();
        for (Deal_registration__c dr : newDeals) {
            if (dr.Deal_Created_By_Distributor__c == true && dr.Partner_Company_Name__c != null && 
            newDealMap.get(dr.Id).Partner_Company_Name__c != oldDealMap.get(dr.Id).Partner_Company_Name__c) {
                dealsToShare.add(dr);
            }
            if (newDealMap.get(dr.Id).Partner_Company_Name__c != oldDealMap.get(dr.Id).Partner_Company_Name__c 
            && oldDealMap.get(dr.Id).Partner_Company_Name__c != null) {
                recsToDeltSharing.add(dr.Id);
            }
        }

        // First perform delete operation to recalculate sharing.
        if (!recsToDeltSharing.isEmpty()) {
            dealRegHdlr.deleteSharing(recsToDeltSharing,'Distributor_Sharing_With_Partner__c');
        }
        if (!dealsToShare.IsEmpty()) {
            dealRegHdlr.dealSharing(dealsToShare, newDealMap); 
        }
        
        // Send Email to distributor on deal approval.
        PRM_DRSendEmailAfterApproval.SendEmails(oldDealMap,newDeals);
    }
}