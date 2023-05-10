public without sharing class PRM_MarketingActivityResultCon {
	@AuraEnabled
    public static ActvityResult getActvityResult(String mdfReqId) {
        ActvityResult ar = new ActvityResult();
        List<SFDC_MDF__c> reqLst = [SELECT Id, Name, Estimated_New_Leads__c, Estimated_Opportunity__c, Estimated_Existing_Leads__c, Estimated_Interactions__c,Activity_Type__c, 
                           (SELECT Id, Name, Actual_New_Leads__c,Actual_Opportunity__c,Actual_Existing_Leads__c,Actual_Interactions__c FROM R00N30000002DjDcEAK LIMIT 1)
                           FROM SFDC_MDF__c WHERE Id =: mdfReqId
                          ] ;
        if (reqLst.size()>0) {
            ar.mdfReq = reqLst[0];
            if (reqLst[0].R00N30000002DjDcEAK.size() > 0) {
                ar.mdfClaim = reqLst[0].R00N30000002DjDcEAK[0];
            }
        }
        return ar;
    }
    
    public class ActvityResult {
        @AuraEnabled public SFDC_MDF__c mdfReq ;
        @AuraEnabled public SFDC_MDF_Claim__c mdfClaim ;
    }
}