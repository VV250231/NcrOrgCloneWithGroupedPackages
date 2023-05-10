global class BatchShareMDF implements Database.Batchable<sObject>
{
    global Set<Id> setMDFId;
    global BatchShareMDF(Set<Id> setMDFId)
    {
        this.setMDFId = setMDFId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('Select Id, Account__c from SFDC_MDF__c where Id IN: setMDFId ');
    }

    global void execute(Database.BatchableContext BC, List<SFDC_MDF__c> scope)
    {
        SFDC_MDF__c objMDF = scope[0];
        Set<Id> setPartnerId = new Set<Id>();
        List<SFDC_MDF__Share> lstMDFShare = new List<SFDC_MDF__Share>();
        System.debug('-----------objMDF.Account__c---------'+objMDF.Account__c);
        System.debug('-----------objMDF.Id---------'+objMDF.Id);
        for(Contact objContact : [Select Id, Partner_User__c from Contact where Partner_User__c != null and AccountId =: objMDF.Account__c and Partner_User__r.isActive = true])
        {
            SFDC_MDF__Share objMDFShare = new SFDC_MDF__Share();
            objMDFShare.UserOrGroupId = objContact.Partner_User__c;
            objMDFShare.AccessLevel = 'Edit';
            objMDFShare.ParentId = objMDF.Id;
            objMDFShare.RowCause = Schema.SFDC_MDF__Share.RowCause.Manual;
            lstMDFShare.add(objMDFShare);
        }
        
        if (lstMDFShare.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(lstMDFShare, false);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        // Do nothing
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));    
    }
}