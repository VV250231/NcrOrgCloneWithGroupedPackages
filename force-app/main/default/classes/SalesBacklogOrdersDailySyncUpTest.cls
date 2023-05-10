@isTest(SeeAllData=false)
public class SalesBacklogOrdersDailySyncUpTest {
    @isTest
    public static void testBatch(){
        
        /* EDBI_Order__c edbiTest = [SELECT Id, Order_Number__c, Backlog_Orders_Amount__c  ,
                                        Backlog_Orders_Status__c , Master_Customer_Number__c ,
                                        Max_Promise_DateTime__c, Max_Customer_Requested_Date__c,
                                        Country_Code_With_Master_Customer_Nbr__c 
                                        FROm EDBI_Order__c 
                                        WHERE Country_Code_With_Master_Customer_Nbr__c='US6374311' limit 1];
      Account acct=  [SELECT Id, Name , Master_Customer_Number__c,Country_with_Master_customer_Number__c , Backlog_Orders_Closed_amount__c, Backlog_Orders_Open_amount__c FROM Account WHERE Country_with_Master_customer_Number__c='USDIV001' limit 1 ];
*/
        EDBI_Order__c edbiOrder = new EDBI_Order__c();
        edbiOrder.Order_Number__c='100';
        edbiOrder.Backlog_Orders_Amount__c=100.00;
        edbiOrder.Backlog_Orders_Status__c='BOOKED'; 
        edbiOrder.Master_Customer_Number__c='Test001';
        edbiOrder.Max_Promise_DateTime__c=Date.valueOf('2019-10-20');
        edbiOrder.Max_Customer_Requested_Date__c=Date.valueOf('2019-10-20');
        edbiOrder.Customer_Country_Code__c = 'US' ;
        edbiOrder.Country_Code_With_Master_Customer_Nbr__c='UDIV001';
        insert edbiOrder;
        
        
         EDBI_Order__c edbiOrder1 = new EDBI_Order__c();
        edbiOrder1.Order_Number__c='101';
        edbiOrder1.Backlog_Orders_Amount__c=100.00;
        edbiOrder1.Backlog_Orders_Status__c='CLOSED'; 
        edbiOrder1.Master_Customer_Number__c='Test001';
        edbiOrder1.Max_Promise_DateTime__c=Date.valueOf('2019-10-20');
        edbiOrder1.Max_Customer_Requested_Date__c=Date.valueOf('2019-10-20');
        edbiOrder1.Customer_Country_Code__c = 'US' ;
        edbiOrder1.Country_Code_With_Master_Customer_Nbr__c='UDIV001';
        insert edbiOrder1;
        
       ERP_Orders_Backlog__c erpBacklog = new ERP_Orders_Backlog__c();
        erpBacklog.Amount_in_USD__c='100';
        erpBacklog.Country_Code_With_Master_Customer_Nbr__c='USTest001';
        erpBacklog.Order_Number__c='101';
        erpBacklog.Product_ID__c='1XY';
        erpBacklog.Order_Number__c = '101' ;
        erpBacklog.Order_Status_Ind__c='CLOSED'; 
        erpBacklog.OrderNumber_Country_code__c = '101US' ;
        erpBacklog.Country_Code__c = 'US' ;
        insert erpBacklog;
        
        ERP_Orders_Backlog__c erpBacklog1 = new ERP_Orders_Backlog__c();
        erpBacklog1.Amount_in_USD__c='100';
        erpBacklog1.Country_Code_With_Master_Customer_Nbr__c='USTest001';
        erpBacklog1.Order_Number__c='100';
        erpBacklog1.Product_ID__c='1XY';
        erpBacklog1.Order_Number__c = '100' ;
        erpBacklog1.Order_Status_Ind__c='BOOKED';
        erpBacklog1.OrderNumber_Country_code__c = '100US' ;
        erpBacklog1.Country_Code__c = 'US' ;
        insert erpBacklog1;
        
        Account a = new Account(); 
        a.Name = 'Dummy Account'; 
        a.AccountNumber = '1234';
        a.BillingStreet = '5601 N Lindero Canyon Rd';
        a.BillingCity = 'Westlake Village';
        a.BillingState = 'CA';
        a.BillingPostalCode = '91362';
        a.ShippingStreet = a.BillingStreet; 
        a.ShippingCity = a.BillingCity;
        a.ShippingState = a.BillingState;
        a.ShippingPostalCode = a.BillingPostalCode;
        a.Phone = '818-867-5309';
        a.Fax = '818-597-6310';
        a.Master_Customer_Number__c = 'Test001'; 
        a.Tier__c = '1';
        a.Backlog_Orders_Closed_amount__c=100.00;
        a.Backlog_Orders_Open_amount__c=100.00;
        a.Country_with_Master_customer_Number__c='USTest001';
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
       /* Account acc = new Account(); 
        acc.Name = 'Dummy Account1'; 
        acc.AccountNumber = '1234';
        acc.BillingStreet = '5601 N Lindero Canyon Rd';
        acc.BillingCity = 'Westlake Village';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '91362';
        acc.ShippingStreet = a.BillingStreet; 
        acc.ShippingCity = a.BillingCity;
        acc.ShippingState = a.BillingState;
        acc.ShippingPostalCode = a.BillingPostalCode;
        acc.Phone = '818-867-5309';
        acc.Fax = '818-597-6310';
        acc.Master_Customer_Number__c = '12344'; 
        acc.Tier__c = '1';
        acc.Interface_Type__c = 'Batch'; 
        acc.Backlog_Orders_Closed_amount__c=100.00;
        acc.Backlog_Orders_Open_amount__c=100.00;
        acc.Country_with_Master_customer_Number__c='USDIV001';
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;
        } */
 
        

        
   //     System.debug('***edbiOrder' + edbiOrder);
        
        
        test.startTest();
        SalesBacklogOrdersSyncUpSchdl sh1 = new SalesBacklogOrdersSyncUpSchdl();
        String sch = '0 0 2 * * ?'; 
        String job1=system.schedule('Test Daily ERP Orders Sync', sch, sh1); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals(sch, ct.CronExpression);
        SalesBacklogOrdersDailySyncUp salesSyncUp = new SalesBacklogOrdersDailySyncUp();   
        ID batchprocessid = Database.executeBatch(salesSyncUp);
        
        test.stopTest();
    }
}