@isTest
public class Controller_CreditDetails_ltngTest {
    public static testMethod void myTest() {
        
        Account a = TestRecordsFactory.createAccount();
        
        
        Credit_Detail__c cd = new Credit_Detail__c();
        //cd.Average_Days_Late__c= 3;
        cd.Customer_Balance__c=3;
        cd.On_Hold__c='YES';
        cd.Risk_Level__c='GREEN';
        cd.Unique_ID__c='1234567';
        cd.X1_30_Days_Late__c=10;
        cd.X361_Days_Late__c=10;
        cd.X31_60_Days_Late__c=10;
        cd.X61_90_Days_Late__c=10;
        cd.X91_180_Days_Late__c=10;
        cd.Account__c=a.id;
        
        insert cd;
        
       Credit_Detail__c cdObj  =  Controller_CreditDetails_ltng.Loadcompletedetail(a.id);
        System.assert(cdObj.Id!=null);
        
    }
}