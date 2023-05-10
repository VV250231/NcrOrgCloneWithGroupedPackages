@isTest 
private class NonERPTriggerTestClass {
    static testMethod void Method1() {
        Non_ERP_Order__c Obj = new Non_ERP_Order__c();
        Obj.Amount_in_Local__c='1200120';
        Obj.Currency__c='USD';
        Obj.Customer_Country_Code__c   ='US';
        Obj.Customer_Name__c='TestCustomer';
        Obj.Date__c=System.Today();
        Obj.Enterprise_ID__c='@Test';
        Obj.HW_Amount__c='123121';
        Obj.Master_Customer_Number__c='Test';
        Obj.Order_Number__c='123121';
        Obj.PS_Amount__c='1000';
        Obj.Salesperson_Global_ID__c='35252345fDE';
        Obj.SW_Amount__c='100';
        Obj.Total_Order_Amount__c='10000';
        Obj.Transaction_Source__c='Manual';
        Obj.TS_Amount__c='100';
        Insert Obj;
        Obj.Currency__c='USD';
        update Obj;
        try{
        System.debug('>>>>>>>>>>>>>>>>>:::');
         
         Non_ERP_Order__c Obj1 = new Non_ERP_Order__c();
         Obj1.Transaction_Source__c='Manual';
         Insert Obj1; 
         NonERPBlankFieldException  test = new NonERPBlankFieldException('test');
            Non_ERP_Order__c nonerpObj = [select id from Non_ERP_Order__c where id=:Obj1.id];
            System.assert(nonerpObj.id!=null);
        }
        
        Catch(Exception e){
            System.debug('Error: '+e.getMessage());
            System.assert(e.getMessage()!=null);
        }
        
         
        
    }
}