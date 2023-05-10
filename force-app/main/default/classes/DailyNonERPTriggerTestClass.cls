@isTest 
private class DailyNonERPTriggerTestClass {
    static testMethod void Method1() {
        Daily_Non_ERP_Order__c Obj = new Daily_Non_ERP_Order__c();
        obj.Order_Date__c = Date.today();
        Obj.Order_Number__c='123121';
        Obj.Enterprise_ID__c='@Test';
        Obj.Master_Customer_Number__c='Test';
        Obj.Customer_Country_Code__c   ='TestCountryCode';
        Obj.Customer_Name__c='TestCustomer';
        Obj.Input_Sales_Org_Code__c = '1234';
        Obj.Input_Total_Order_Amount__c ='1200120';
        Obj.Input_Currency__c  ='USD';
        Obj.Input_HW_Amount__c ='1200120';
        Obj.Input_SW_Amount__c = '1200120';
        Obj.Input_PS_Amount__c ='1200120';
        Obj.Input_TS_Amount__c ='1200120';   

        Obj.Salesperson_Quicklook_ID__c='3525234';
        Obj.Salesperson_Global_ID__c='35252345f';       
        Obj.Source_System__c='Synergy';
       
        Insert Obj;
        Obj.Input_Currency__c  ='USD';
        update Obj;
       
		Daily_Non_ERP_Order__c Obj1 = [Select id, Input_Currency__c from Daily_Non_ERP_Order__c where Input_Currency__c = 'USD'];
        System.assert(Obj1.id!=null);
    }
}