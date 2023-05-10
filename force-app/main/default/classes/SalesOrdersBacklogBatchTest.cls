@isTest(SeeAllData=false)
public class SalesOrdersBacklogBatchTest {
    @isTest
    public static void testBatch(){
        /*EDBI_Order__c edbiOrder = new EDBI_Order__c();
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
        insert edbiOrder1;*/
           
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
        
      /*  Account a = new Account(); 
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
        a.Master_Customer_Number__c = '1234'; 
        a.Tier__c = '1';
        a.Interface_Type__c = 'Batch'; 
        a.Backlog_Orders_Closed_amount__c=100.00;
        a.Backlog_Orders_Open_amount__c=100.00;
        a.Country_with_Master_customer_Number__c='UDIV001';
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }*/
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
        
        
        test.startTest();
        SalesOrdersBacklogBatch salesBackUp = new SalesOrdersBacklogBatch(new Set<String>{'USTest001'});   
        ID batchprocessid = Database.executeBatch(salesBackUp);
        System.assert(batchprocessid!=null);
        test.stopTest();
    }
}