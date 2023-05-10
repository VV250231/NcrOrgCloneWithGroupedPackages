@isTest
public class PlanRowTriggerTest {
    @isTest
    public static void plnRowTestMthd(){
        ALTF__Solution__c solObj = new ALTF__Solution__c();
        solObj.Name ='Products Unassigned';
        insert solObj;
        ALTF__Account_Plan_Type__c obj1 = new ALTF__Account_Plan_Type__c();
        obj1.name ='Test Type';
        insert obj1;
        altf__account_plan__c obj = new altf__account_plan__c();
        obj.Name ='Test AccountPlan';
        obj.ALTF__Account_Plan_Type__c =obj1.id;
        insert obj;
        ALTF__Account_Plan_Revenue_Target__c revObj = new ALTF__Account_Plan_Revenue_Target__c();
        revObj.Name ='Test Revenue';        
        revObj.ALTF__Start_Date__c =Date.parse('8/29/2021');
        revObj.ALTF__End_Date__c =Date.parse('8/31/2021');
        revObj.ALTF__Revenue_Target__c = 100;
        revObj.ALTF__Account_Plan__c = obj.id;
        insert revObj;
        ALTF__Account_Plan_Row__c objRecd = new ALTF__Account_Plan_Row__c();
        objRecd.ALTF__Account__c = TestRecordsFactory.createAccount().id;
        objRecd.ALTF__Type__c ='Division';
        objRecd.ALTF__Account_Plan__c = obj.id;
        insert objRecd;
        system.assert(objRecd.id!=null);
       
       // SynchronisePlannedOpportunities oo = new SynchronisePlannedOpportunities();
        //oo.createAccountOpportunities(TestRecordsFactory.createAccount().id,revObj.ALTF__Start_Date__c,revObj.ALTF__End_Date__c,objRecd.id);
    }
}