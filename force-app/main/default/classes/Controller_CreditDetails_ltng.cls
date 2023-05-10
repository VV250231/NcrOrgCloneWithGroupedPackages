public class Controller_CreditDetails_ltng {
    
    @AuraEnabled
    public static Credit_Detail__c Loadcompletedetail(id ID)
    {
       system.debug('######## inside controller controller_creditdetails_ltng------received account id is ::'+ID);
        return [Select Account__c,
       // Average_Days_Late__c,
        Customer_Balance__c,
        Id,Name,
        Not_Due_1_360_Days__c,
        Not_Due_360_Days__c,
        On_Hold__c,
        Risk_Level__c,
        Unique_ID__c,
        X1_30_Days_Late__c,
        X31_60_Days_Late__c,
        X61_90_Days_Late__c,
        X91_180_Days_Late__c,
        X181_360_Days_Late__c,
        X361_Days_Late__c,
                Account__r.Credit_Limit__c,
                Account__r.Credit_Values_As_Of__c,
                Account__r.Available_Credit__c
               // Account__r.AR_issues__c
               // commenting duE to EA_SF-688
                From Credit_Detail__c
                WHERE Account__c = :ID
                limit 1];
    }
    
    
}