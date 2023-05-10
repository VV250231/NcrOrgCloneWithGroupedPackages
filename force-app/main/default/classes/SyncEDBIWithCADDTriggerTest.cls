@IsTest
public class SyncEDBIWithCADDTriggerTest {
    static testMethod void myTest(){
        Account a = TestRecordsFactory.createAccount(); 
        Deming__C demObj=new Deming__C();
        demObj.Order_Id__c='5321';
        demObj.Order_Number__c='1662159';
        demObj.Customer_Country_code__c ='US';
        
        insert demObj;
        
        Opportunity Opp = new Opportunity();  
        
        Opp.Name='Test';
        opp.AccountID = a.id;
        Opp.StageName='Prospecting';
        Opp.CloseDate=System.today();
        insert Opp;
        
        EDBI_Order__c edbiorder  = new EDBI_Order__c ();
        edbiorder.Order_Number_with_Country_Code__c='1662159US';
        edbiorder.Order_Number__c='1662159';
        edbiorder.Opportunity__C=Opp.Id;
        
        
        insert edbiorder;
        
        edbiorder.Backlog_Orders_Status__c='cancelled';
        edbiorder.FUA_Site_Name__c='test';        
        update edbiorder;
        system.assert(edbiorder !=null);
        
        
    }
}