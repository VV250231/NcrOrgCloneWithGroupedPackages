public with sharing class ERPOrderLineDashboardController {
    @AuraEnabled
    public static List<ERP_Order_Line__c> getERPOrderLineDetail(String orderId) {
        System.debug('orderId !!@@'+orderId);
        String res='failed';
        Set<String> OrderIdSet= new Set<String>();
        OrderIdSet.add(orderId);
        
        /*System.debug('before service');
if(!Test.isRunningTest()){
res= ERPOrderLineService.synchOrdLine(OrderIdSet);
}
System.debug('After service'+res);*/
        
        List<ERP_Order_Line__c> erpOrderLineDetail = [Select Shipping_Date__c, Additional_Tracking_Info__c, PROMISE_DATE__c,
                                                      Bill_To__c, Bill_To_Address1__c, Bill_To_Address2__c, Bill_To_Address3__c,
                                                      Bill_To_Address4__c, Bill_To_Address5__c, Bill_To_Contact__c, Bill_To_Customer__c,
                                                      Cust_PO_Line_Number__c, Cust_Product_Desc__c, Deliver_To_Contact__c,
                                                      Deliver_To_Location__c, Delivery_Status__c, EMS_Airway_Shipment_Number__c, 
                                                      EMS_Shipment_Number__c, Extended_Price__c, Carrier_Name__c, Freight_Forwarder__c,
                                                      Intermediate_Ship_To__c, Line_Number__c, Line_Status__c, Order_Source__c, 
                                                      Order_Source_Reference__c, Package_Number_High__c, Package_Number_Low__c, 
                                                      Partial_Invoice_Flag__c, Pro_Number__c, Product_Description__c, Ordered_Item__c,
                                                      PS_Project_Number__c, Quantity__c, Qty_Cancelled__c, Qty_Shipped__c, Request_Date__c, 
                                                      Shipping_Method__c, Ship_To__c, Ship_To_Address1__c, Ship_To_Address2__c,
                                                      Ship_To_Address3__c, Ship_To_Address4__c, Ship_To_Address5__c, Ship_To_Contact__c, 
                                                      Ship_To_Customer__c, SW_Key_End_Date__c , Tax_Amount__c, Unit_Selling_Price__c
                                                      FROM ERP_Order_Line__c WHERE Order_Id__c =: orderId  ];
        
        System.debug('erpOrderLineDetail !!@@ '+erpOrderLineDetail);
        return erpOrderLineDetail;
    }
    @AuraEnabled 
    public Static String serviceLines(String orderId){
        String res='failed';
        /*Set<String> OrderIdSet= new Set<String>();
        OrderIdSet.add(orderId);*/
        System.debug('before service');
        if(!Test.isRunningTest()){
            res= ERPOrderLineService.synchOrdLine(orderId); 
        }
        System.debug('After service'+res);  
        return 'SUCCESS';
        
    }
    @AuraEnabled    
    public Static String deleteLines(String orderId){
        String isSuccess = 'SUCCESS';
        System.debug('deleteLines() Order Id @@@@@@@'+orderId);
        String res='failed';
        Set<String> OrderIdSet= new Set<String>();
        OrderIdSet.add(orderId);
        List<ERP_Order_Line__c> lstDelete= [select Id from ERP_Order_Line__c where Order_Id__c in:OrderIdSet];
        Database.DeleteResult[] drList = Database.delete(lstDelete, false);      
        // Iterate through each returned result
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted OLI with ID: ' + dr.getId());
            }
            else {
                // Operation failed, so get all errors
                String Msg;                
                for(Database.Error err : dr.getErrors()) {
                    Msg +=err.getMessage();
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('lines fields that affected this error: ' + err.getFields());
                }
                isSuccess = Msg;
            }
        }
        return isSuccess;
    }
    
    @AuraEnabled
    public static List<ERP_Order_Line__c> searchOrderLinesByBillToCustomer(String searchStr, String orderId ) {
        
        String billToCustmer = '%' + searchStr + '%' ;
        List<ERP_Order_Line__c> erpOrderLineDetail = [Select Shipping_Date__c, Additional_Tracking_Info__c, PROMISE_DATE__c,
                                                      Bill_To__c, Bill_To_Address1__c, Bill_To_Address2__c, Bill_To_Address3__c,
                                                      Bill_To_Address4__c, Bill_To_Address5__c, Bill_To_Contact__c, Bill_To_Customer__c,
                                                      Cust_PO_Line_Number__c, Cust_Product_Desc__c, Deliver_To_Contact__c,
                                                      Deliver_To_Location__c, Delivery_Status__c, EMS_Airway_Shipment_Number__c, 
                                                      EMS_Shipment_Number__c, Extended_Price__c, Carrier_Name__c, Freight_Forwarder__c,
                                                      Intermediate_Ship_To__c, Line_Number__c, Line_Status__c, Order_Source__c, 
                                                      Order_Source_Reference__c, Package_Number_High__c, Package_Number_Low__c, 
                                                      Partial_Invoice_Flag__c, Pro_Number__c, Product_Description__c, Ordered_Item__c,
                                                      PS_Project_Number__c, Quantity__c, Qty_Cancelled__c, Qty_Shipped__c, Request_Date__c, 
                                                      SERIAL_NUMBER__c, Shipping_Method__c, Ship_To__c, Ship_To_Address1__c, Ship_To_Address2__c,
                                                      Ship_To_Address3__c, Ship_To_Address4__c, Ship_To_Address5__c, Ship_To_Contact__c, 
                                                      Ship_To_Customer__c, SW_Key_End_Date__c  , Tax_Amount__c, Unit_Selling_Price__c
                                                      FROM ERP_Order_Line__c WHERE Order_Id__c =: orderId AND Bill_To_Customer__c LIKE : billToCustmer];
        
        System.debug('Result After Search : '+erpOrderLineDetail);
        return  erpOrderLineDetail;   
    }
}