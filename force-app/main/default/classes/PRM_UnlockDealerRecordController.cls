/* Developer : Deeksharth 
* Date: 02-08-2019
* Comment : This class was written to handle unlock approval record from lightning detail Page for dealer
*/
public without sharing class PRM_UnlockDealerRecordController {
    // This method check record locked or not
    @AuraEnabled
    public static PRM_DRLockApprovedWrapper islocked(String recordId){
        //system.debug('Is record locked >>'+Approval.isLocked(Id.ValueOf(recordId)));
        PRM_DRLockApprovedWrapper dealWrapper = new PRM_DRLockApprovedWrapper();
        Deal_Registration__c dealRecord = [SELECT Status__c FROM Deal_Registration__c WHERE Id =:recordId];
        if(dealRecord != null){
            dealWrapper.isLock = Approval.isLocked(Id.ValueOf(recordId));
            dealWrapper.isApproved = (dealRecord.Status__c == 'Approved' ? TRUE : FALSE);
        }
        return dealWrapper;
    }
    // This method is for unlock the record. 
    @AuraEnabled
    public static boolean unlockRecord(String objId){
        List<String> unlockrec = new List<string>();
        unlockrec.add(objId);
        Approval.UnlockResult[] unlockedRersult = Approval.unlock(unlockrec);
        if(unlockedRersult!= Null){
            system.debug(unlockedRersult[0].isSuccess());
        }
        system.debug('unlockedRersult >>'+unlockedRersult);
        return true;
    }
    public class PRM_DRLockApprovedWrapper{
        @AuraEnabled public Boolean isLock;
        @AuraEnabled public Boolean isApproved;
    }
}