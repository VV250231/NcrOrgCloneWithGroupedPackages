/* Class Name : prmGenericDataHelper 
* Date : 17/10/19 
* Description : This Class  is used for Partner Portal for holding generic Data which can be used multiple times
* DeveloperName : Deeksharth Sriwastava
*/
public without sharing class prmGenericDataHelper {
    
    /* This method returns the current user Account Data */
    @AuraEnabled(cacheable=true)
    public static List<Account> getCurrentUserAccountData(){

    User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
    List<Account> accList  = New List<Account>();
    // added NPC fields(your customer,your account) in existing code.
     if(u.AccountId != null) {
            accList = [SELECT Id, Name, Master_Customer_Number__c, Partner_Program_Level__c,
                        Account_Region__c,Partner_Industry__c,Net_Promotor_Score__c FROM Account WHERE Id =: u.AccountId LIMIT 1];
     }
     if(accList.size()>0 && accList != Null){
         return accList;
     }
    return new List<Account>();
    }
    // Below method is Added and Tested by Nikhil to enable PRM_NPSDetails to send accountId to Apex
    @auraEnabled(cacheable = true)
    public static List<Account> setNPSScore(String AccId){
        List<Account> accList;
        if(AccId != NULL){
            accList  = [SELECT Id, Name, Master_Customer_Number__c, Partner_Program_Level__c,
                        Account_Region__c,Partner_Industry__c,Net_Promotor_Score__c FROM Account WHERE Id =: AccId];
        }
        system.debug('accList---------------------'+accList);
        return accList;
    } 
}