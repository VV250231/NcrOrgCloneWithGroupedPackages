public without sharing class partnerInformationCon {
    @AuraEnabled(cacheable=true)
    public static Account getPartnerInfo(String AccId){
        Account act;
        //User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        if (AccId != null) {
            List<Account> tempList = [SELECT Id, Name, Master_Customer_Number__c, Partner_Program_Level__c,
            Dashboard_last_updated_on__c FROM Account WHERE Id =: AccId];
            if (tempList.size() > 0) {
                act = tempList[0];
            }
        }
        return act;
    }

}