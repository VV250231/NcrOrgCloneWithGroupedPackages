/*************************************************************************************************
*   ClassName   : PRM_DealRegistrationTriggerHandler
*   Description :   
*   Author      :   
# Modification History.: 
Story No         Date           DevName         Description
EBA_SF-1948     20-10-2022      KAVYA SREE      Technical Debt - Apex sharing violation part 2 -PRM 
*************************************************************************************************/
public without sharing class PRM_DealRegistrationTriggerHandler {

    // Share Deal Registration Record with the Partner's contact if Deal Registraion request created by Distributor.
    public void dealSharing(List<Deal_Registration__c> dealList,Map<Id,Deal_Registration__c> newDealMap) {  
        
        Set<Id> dealRegIds = new Set<Id>();
        Set<Id> actIds = new Set<Id>();
        List<Deal_Registration__Share> partnerSharing = new List<Deal_Registration__Share>();
        for (Deal_Registration__c dr : dealList) {
            if (dr.Deal_Created_By_Distributor__c == true && dr.Partner_Company_Name__c != null) {
                dealRegIds.add(dr.Id);
                actIds.add(dr.Partner_Company_Name__c);
            }
        }
            
        if (dealRegIds.size() > 0) {
            Map<Id,List<User>> actIdToUsers = new Map<Id,List<User>>();
            for (User u : [SELECT Id, Name, ContactId, AccountId FROM User WHERE AccountId IN : actIds AND isActive = true]) {
                if (actIdToUsers.get(u.AccountId) != null) {
                    actIdToUsers.get(u.AccountId).add(u);
                } else {
                    actIdToUsers.put(u.AccountId, new List<User>());
                    actIdToUsers.get(u.AccountId).add(u);
                }

            }
            for(Deal_Registration__c dr : dealList) {
                if (dr.Partner_Company_Name__c!= null && actIdToUsers.containsKey(dr.Partner_Company_Name__c)) {
                    for (User u : actIdToUsers.get(dr.Partner_Company_Name__c)) {
                        Deal_Registration__Share partnerShare = new Deal_Registration__Share();
                        partnerShare.ParentId = dr.Id;
                        partnerShare.AccessLevel = 'read';
                        partnerShare.UserOrGroupId = u.Id;
                        partnerShare.RowCause = Schema.Deal_Registration__Share.RowCause.Distributor_Sharing_With_Partner__c;
                        partnerSharing.add(partnerShare);
                    }
                    
                }
            }

            if (!partnerSharing.isEmpty()) {
                // Insert sharing records and capture save result 
                Database.SaveResult[] lsr = Database.insert(partnerSharing,false);
                
                Integer i=0;
                
                for(Database.SaveResult sr : lsr){
                    if(!sr.isSuccess()){
                        // Get the first save result error
                        Database.Error err = sr.getErrors()[0];
                        
                        /* Check if the error is related to a trivial access level
                        Access levels equal or more permissive than the object's default 
                        access level are not allowed. 
                        These sharing records are not required and thus an insert exception is 
                        acceptable.*/
                        if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel'))){
                            // Throw an error when the error is not related to trivial access level.
                           // newDealMap.get(partnerSharing[i].ParentId).addError(system.label.DealRegSh + err.getMessage());
                           System.debug('Error in partner sharing:'+err.getMessage());
                        }
                    }
                    i++;
                }
            }
        }
    }


    public void deleteSharing(Set<Id> parentIds, String rowCause) {
        List<Deal_Registration__Share> dealSharing = [SELECT Id FROM Deal_Registration__Share 
        WHERE ParentId IN : parentIds AND RowCause =: rowCause];
        if (!dealSharing.isEmpty()) {
            try {
                delete dealSharing;
            } catch (Exception ex) {
                system.debug(ex.getMessage());
            }
        }
    }

    public void updateSaleOpInfo(List<Deal_Registration__c> newDealRegRecs){
        Set<Id> accountIds = new Set<Id>(); 
        Set<Id> endCustomerActIds = new Set<Id>();
        for (Deal_Registration__c dr : newDealRegRecs) {
            if (dr.Partner_Company_Name__c != null) {
                accountIds.add(dr.Partner_Company_Name__c);
            }
            // Making list of End customer account Ids
            if (dr.End_Customer_Account_name__c != null) {
                endCustomerActIds.add(dr.End_Customer_Account_name__c);
            }
        }
        Map<Id,Account> idToAccountMap = new Map<Id,Account>([SELECT Id, Name, OwnerId, Owner.Name, Owner.ManagerId,LOB__c FROM Account WHERE Id IN:accountIds]);
        Map<Id,Account> idToendCustomerActMap = new Map<Id,Account>([SELECT Id, Name, OwnerId, Owner.Name, Owner.ManagerId, LOB__c FROM Account WHERE Id IN: endCustomerActIds]);
        
        
        for (Deal_Registration__c dr : newDealRegRecs) {
            //Populate CAM and RCL/Senior Account Manager
            //and if user wants to change CAM or RCL manually on Deal Reg then allow them. So on the time of insert we need to poulate the CAM and RCL
            if (dr.Partner_Company_Name__c != null && idToAccountMap.containsKey(dr.Partner_Company_Name__c)) {
                if (idToAccountMap.get(dr.Partner_Company_Name__c).OwnerId != null) {
                    dr.NCR_Account_Manager__c = idToAccountMap.get(dr.Partner_Company_Name__c).OwnerId; // CAM
                }
                if (idToAccountMap.get(dr.Partner_Company_Name__c).Owner.ManagerId != null) {
                    dr.NCR_Account_Senior_Manager__c =  idToAccountMap.get(dr.Partner_Company_Name__c).Owner.ManagerId; // RCL
                }
            }
            // Modify End_Customer_Company_Name__c[Text] if needed.
            // While submitting the request partner fills the end customr name (in text). Later on NCR Sales
            // team can populate end customer lookup field. In that case if their is name mismatch between
            // NSC system and filled by the partner, than name will be overwritten by the system.
            if (dr.End_Customer_Account_name__c != null && idToendCustomerActMap.containsKey(dr.End_Customer_Account_name__c) && 
                dr.End_Customer_Company_Name__c != idToendCustomerActMap.get(dr.End_Customer_Account_name__c).Name){
                    
                dr.End_Customer_Company_Name__c = idToendCustomerActMap.get(dr.End_Customer_Account_name__c).Name;
            }

            // populate direct sales rep and their manager. (for End Customer)
            if ( dr.End_Customer_Account_name__c != null && !idToendCustomerActMap.isEmpty() && 
            idToendCustomerActMap.containsKey(dr.End_Customer_Account_name__c) ) {
                    dr.Direct_Sales_Rep__c = idToendCustomerActMap.get(dr.End_Customer_Account_name__c).OwnerId;
                    dr.Direct_Sales_Rep_Manager__c = idToendCustomerActMap.get(dr.End_Customer_Account_name__c).Owner.ManagerId;
            } else if( dr.End_Customer_Account_name__c == null) {
                dr.Direct_Sales_Rep__c = null;
                dr.Direct_Sales_Rep_Manager__c = null;
            }

            // populate sales operation approver
            if (! String.isBlank(dr.Partner_Industry__c) && dr.Sales_Opp_Approver__c == null) {
                dr.Sales_Opp_Approver__c = getIndustrySalesOpApprover(dr.Partner_Industry__c);
            }

            // Queue_Mailbox__c
            if(! String.isBlank(dr.Partner_Industry__c) && dr.Queue_Mailbox__c == null) {
                dr.Queue_Mailbox__c = getIndustrySalesOpApproverQueueMail(dr.Partner_Industry__c);
            }

            // populate reminder date
            if (dr.Partner_Submission_Date__c != null) {
                dr.Sales_Operation_Reminder_Date_Time__c = getReminderDate(dr.Partner_Submission_Date__c);
            }
        }
   
    }

    public Map<String,Deal_Registration_Approval_Setting__mdt> drApprovalSetting ;
    
    {
        drApprovalSetting = new Map<String,Deal_Registration_Approval_Setting__mdt>();
        for(Deal_Registration_Approval_Setting__mdt drMdt : [SELECT MasterLabel, User_Id_OR_Queue_Id__c,
        Queue_Mailbox__c, DeveloperName FROM Deal_Registration_Approval_Setting__mdt]) {
            drApprovalSetting.put(drMdt.MasterLabel,drMdt);
        }
    }

    public String getIndustrySalesOpApprover(String partnerIndustry) {
        if (partnerIndustry == null) {
            return null;
        }
        String approver;
        if (drApprovalSetting.containsKey(partnerIndustry)&& ! String.isBlank(drApprovalSetting.get(partnerIndustry).User_Id_OR_Queue_Id__c)) {
            approver = drApprovalSetting.get(partnerIndustry).User_Id_OR_Queue_Id__c;
        }
        return approver;
    }

    public String getIndustrySalesOpApproverQueueMail(String partnerIndustry) {
        if (partnerIndustry == null) {
            return null;
        }
        
        String mailBox;
        if (drApprovalSetting.containsKey(partnerIndustry)&& ! String.isBlank(drApprovalSetting.get(partnerIndustry).Queue_Mailbox__c)) {
            mailBox = drApprovalSetting.get(partnerIndustry).Queue_Mailbox__c;
        }
        return mailBox;
    }

    /**
     * 
     */
    public DateTime getReminderDate(DateTime dealRegSubDT){
        // Populate reminder date
        if (dealRegSubDT == null) { return null;}

        DateTime dealRegSubmissionDT = dealRegSubDT;
        DateTime dealRegSalsOpsReminderDT;
        switch on dealRegSubmissionDT.format('E') {
            when  'Mon', 'Tue'{
                dealRegSalsOpsReminderDT = dealRegSubmissionDT.addHours(62);
            }
            when 'Wed' {
                if (dealRegSubmissionDT.addHours(62).format('E') == 'Sat' || 
                dealRegSubmissionDT.addHours(62).format('E') == 'Sun') {
                    dealRegSalsOpsReminderDT = nextMondayDate(dealRegSubmissionDT);
                } else {
                    dealRegSalsOpsReminderDT = dealRegSubmissionDT.addHours(62);
                }
            }
            when 'Thu' {
                dealRegSalsOpsReminderDT = nextMondayDate(dealRegSubmissionDT);
            }
            when 'Fri' {
                if (dealRegSubmissionDT.addHours(62).format('E') == 'Sun') {
                    dealRegSalsOpsReminderDT = nextMondayDate(dealRegSubmissionDT);
                } else {
                    dealRegSalsOpsReminderDT = dealRegSubmissionDT.addHours(62);
                }
            }
            when 'Sat','Sun'{
                dealRegSalsOpsReminderDT = nextMondayDate(dealRegSubmissionDT)+62;
            }
        }
        return dealRegSalsOpsReminderDT;
   
    }

    public DateTime nextMondayDate(DateTime dt) {
        Date nextWeekStartDate = dt.date().toStartOfWeek()+7;
        Date d = Date.newInstance(nextWeekStartDate.year(), nextWeekStartDate.month(), nextWeekStartDate.day());
        Time t = Time.newInstance(10, 00, 00, 00);
        return DateTime.newInstance(d, t);
    }
}