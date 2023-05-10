global class BatchShareMDFWithPartnerUser implements Database.Batchable<sObject>
{
    global Set<Id> setUserId;
    global BatchShareMDFWithPartnerUser(Set<Id> setUserId)
    {
        this.setUserId = setUserId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('Select Id, ContactId, Contact.AccountId from User where Id IN: setUserId and isActive = true');
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        User objUser = scope[0];
        Set<Id> setPartnerId = new Set<Id>();
        
        List<SFDC_MDF__Share> lstMDFShare = new List<SFDC_MDF__Share>();
        
        for(SFDC_MDF__c objMDF : [Select Id, Account__c from SFDC_MDF__c where Account__c != null and Account__c =: objUser.Contact.AccountId])
        {
            SFDC_MDF__Share objMDFShare = new SFDC_MDF__Share();
            objMDFShare.UserOrGroupId = objUser.Id;
            objMDFShare.AccessLevel = 'Edit';
            objMDFShare.ParentId = objMDF.Id;
            objMDFShare.RowCause = Schema.SFDC_MDF__Share.RowCause.Manual;
            lstMDFShare.add(objMDFShare);
        }
        
        if (lstMDFShare.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(lstMDFShare, false);
        }
        
        List<SFDC_MDF_Claim__Share> lstMDFClaimShare = new List<SFDC_MDF_Claim__Share>();
        
        for(SFDC_MDF_Claim__c objClaim : [Select Id, Fund_Request__r.Account__c from SFDC_MDF_Claim__c where Fund_Request__r.Account__c =: objUser.Contact.AccountId ])
        {
            SFDC_MDF_Claim__Share objMDFClaimShare = new SFDC_MDF_Claim__Share();
            objMDFClaimShare.UserOrGroupId = objUser.Id;
            objMDFClaimShare.AccessLevel = 'Edit';
            objMDFClaimShare.ParentId = objClaim.Id;
            objMDFClaimShare.RowCause = Schema.SFDC_MDF_Claim__Share.RowCause.Manual;
            lstMDFClaimShare.add(objMDFClaimShare);
        }
        
        if (lstMDFClaimShare.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(lstMDFClaimShare, false);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        // Do nothing
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));    
    }
}