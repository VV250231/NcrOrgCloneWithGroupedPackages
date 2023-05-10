global class BatchShareMDFClaim implements Database.Batchable<sObject>
{
    global Set<Id> setMDFClaimId;
    global BatchShareMDFClaim(Set<Id> setMDFClaimId)
    {
        this.setMDFClaimId = setMDFClaimId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('Select Id, Fund_Request__r.Account__c from SFDC_MDF_Claim__c where Id IN: setMDFClaimId ');
    }

    global void execute(Database.BatchableContext BC, List<SFDC_MDF_Claim__c> scope)
    {
        SFDC_MDF_Claim__c objMDFClaim = scope[0];
        Set<Id> setPartnerId = new Set<Id>();
        List<SFDC_MDF_Claim__Share> lstMDFClaimShare = new List<SFDC_MDF_Claim__Share>();
        System.debug('-----------objMDF.Account__c---------'+objMDFClaim.Fund_Request__r.Account__c);
        System.debug('-----------objMDF.Id---------'+objMDFClaim.Id);
        
        for(Contact objContact : [Select Id, Partner_User__c from Contact 
                                  where Partner_User__c != null and AccountId =: objMDFClaim.Fund_Request__r.Account__c and Partner_User__r.isActive = true])
        {
            SFDC_MDF_Claim__Share objMDFClaimShare = new SFDC_MDF_Claim__Share();
            objMDFClaimShare.UserOrGroupId = objContact.Partner_User__c;
            objMDFClaimShare.AccessLevel = 'Edit';
            objMDFClaimShare.ParentId = objMDFClaim.Id;
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