public class SalesBacklogOrdersDailySyncUp implements Database.Batchable<SObject> {
    
    
    public Database.queryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator('SELECT Id, Amount_in_USD__c, Country_Code_With_Master_Customer_Nbr__c, Order_Number__c,OrderNumber_Country_code__c  FROM ERP_Orders_Backlog__c WHERE SystemModStamp = TODAY') ;
        
    }
    
    
    public void execute(Database.BatchableContext bc , List<ERP_Orders_Backlog__c> scope) {
        // Map<String, Decimal> mapOrderNbrToClosedAmt = new Map<String, Decimal>() ;
        // Map<String, Decimal> mapOrderNbrToOpenAmt = new Map<String, Decimal>() ;
        Set<String> MCNIdsSet = new Set<String>() ;
        
        for(ERP_Orders_Backlog__c orderLine  :  scope) {
            MCNIdsSet.add(orderLine.Country_Code_With_Master_Customer_Nbr__c) ;
            System.debug('MCNIdsSet----'+MCNIdsSet);
        }
        
        Map<String, Account> mapAcctMCNToAccount = new Map<String, Account>() ;
        for(Account acct  : [SELECT Id, Backlog_Orders_Closed_amount__c, Backlog_Orders_Open_amount__c,
                             Country_with_Master_customer_Number__c
                             FROM Account 
                             WHERE Country_with_Master_customer_Number__c IN:MCNIdsSet
                            ]) {
                                mapAcctMCNToAccount.put(acct.Country_with_Master_customer_Number__c, acct) ;
                            } 
        
        //Map<String, Decimal> mapOrderNbrToOrder = new Ord
        
        
        Map<String, Decimal> mapOrderNbrToClosedAmt = new Map<String, Decimal>() ;
        Map<String, Decimal> mapOrderNbrToOpenAmt = new Map<String, Decimal>() ;
        Map<String, Date> mapOrderNbrToMaxPromiseDate = new Map<String, Date>() ;
        Map<String, Date> mapOrderNbrToCustReqDate = new Map<String, Date>() ;
        
        for( ERP_Orders_Backlog__c orderLine: [SELECT Id, Promise_Date_Time__c, Customer_Requested_Date__c ,
                                               Amount_in_USD__c, Order_Status_Ind__c, Order_Number__c, OrderNumber_Country_code__c
                                               FROM ERP_Orders_Backlog__c 
                                               WHERE Country_Code_With_Master_Customer_Nbr__c IN:MCNIdsSet
                                               AND  Order_Status_Ind__c = 'BOOKED' 
                                               AND OrderNumber_Country_code__c != null AND
                                               (NOT Product_ID__c LIKE '%F%' ) AND 
                                               (NOT Product_ID__c LIKE '%FEATURE%' ) AND 
                                               (NOT Product_ID__c LIKE '%OPTION%' ) AND 
                                               (NOT  Product_ID__c LIKE '%D%' ) AND 
                                               (NOT Product_ID__c LIKE '%R%' )
                                              ]) {
                                                  System.debug('OrderId---'+orderLine);
                                                  if(!mapOrderNbrToOpenAmt.containsKey(orderLine.OrderNumber_Country_code__c) ){
                                                      mapOrderNbrToOpenAmt.put(orderLine.OrderNumber_Country_code__c ,  0.0) ;
                                                  }  
                                                  mapOrderNbrToOpenAmt.put(orderLine.OrderNumber_Country_code__c ,  mapOrderNbrToOpenAmt.get(orderLine.OrderNumber_Country_code__c  ) + Decimal.ValueOf(orderLine.Amount_in_USD__c)   ) ;
                                                  
                                                  if(!mapOrderNbrToMaxPromiseDate.containsKey(orderLine.OrderNumber_Country_code__c ) ) {
                                                      mapOrderNbrToMaxPromiseDate.put(orderLine.OrderNumber_Country_code__c , orderLine.Promise_Date_Time__c ) ;
                                                  }
                                                  mapOrderNbrToMaxPromiseDate.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToMaxPromiseDate.get(orderLine.OrderNumber_Country_code__c) < orderLine.Promise_Date_Time__c ?  orderLine.Promise_Date_Time__c :  mapOrderNbrToMaxPromiseDate.get(orderLine.OrderNumber_Country_code__c)  ) ;
                                                  
                                                  
                                                  if(!mapOrderNbrToCustReqDate.containsKey(orderLine.OrderNumber_Country_code__c ) ) {
                                                      mapOrderNbrToCustReqDate.put(orderLine.OrderNumber_Country_code__c , orderLine.Customer_Requested_Date__c ) ;
                                                  }
                                                  mapOrderNbrToCustReqDate.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToCustReqDate.get(orderLine.OrderNumber_Country_code__c) < orderLine.Customer_Requested_Date__c ?  orderLine.Customer_Requested_Date__c :  mapOrderNbrToCustReqDate.get(orderLine.OrderNumber_Country_code__c)  ) ;
                                                  
                                              }
        
        for( ERP_Orders_Backlog__c orderLine: [SELECT Id, Promise_Date_Time__c, Customer_Requested_Date__c ,
                                               Amount_in_USD__c, Order_Status_Ind__c, Order_Number__c,
                                               OrderNumber_Country_code__c
                                               FROM ERP_Orders_Backlog__c 
                                               WHERE Country_Code_With_Master_Customer_Nbr__c IN:MCNIdsSet
                                               AND  Order_Status_Ind__c = 'CLOSED' 
                                               AND OrderNumber_Country_code__c != null AND
                                               (NOT Product_ID__c LIKE '%F%' ) AND 
                                               (NOT Product_ID__c LIKE '%FEATURE%' ) AND 
                                               (NOT Product_ID__c LIKE '%OPTION%' ) AND 
                                               (NOT  Product_ID__c LIKE '%D%' ) AND 
                                               (NOT Product_ID__c LIKE '%R%' )
                                              ]) {
                                                  System.debug('orderLine***'+orderLine);
                                                  if(!mapOrderNbrToClosedAmt.containsKey(orderLine.OrderNumber_Country_code__c) ){
                                                      mapOrderNbrToClosedAmt.put(orderLine.OrderNumber_Country_code__c ,  0.0) ;
                                                  } 
                                                  if(orderLine.Amount_in_USD__c!=null){
                                                  mapOrderNbrToClosedAmt.put(orderLine.OrderNumber_Country_code__c ,  mapOrderNbrToClosedAmt.get(orderLine.OrderNumber_Country_code__c  ) + Decimal.ValueOf(orderLine.Amount_in_USD__c)   ) ;
                                                  }
                                                  if(!mapOrderNbrToMaxPromiseDate.containsKey(orderLine.OrderNumber_Country_code__c ) ) {
                                                      mapOrderNbrToMaxPromiseDate.put(orderLine.OrderNumber_Country_code__c , orderLine.Promise_Date_Time__c ) ;
                                                  }
                                                  mapOrderNbrToMaxPromiseDate.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToMaxPromiseDate.get(orderLine.OrderNumber_Country_code__c) < orderLine.Promise_Date_Time__c ?  orderLine.Promise_Date_Time__c :  mapOrderNbrToMaxPromiseDate.get(orderLine.OrderNumber_Country_code__c)  ) ;
                                                  
                                                  
                                                  if(!mapOrderNbrToCustReqDate.containsKey(orderLine.OrderNumber_Country_code__c ) ) {
                                                      mapOrderNbrToCustReqDate.put(orderLine.OrderNumber_Country_code__c , orderLine.Customer_Requested_Date__c ) ;
                                                  }
                                                  mapOrderNbrToCustReqDate.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToCustReqDate.get(orderLine.OrderNumber_Country_code__c) < orderLine.Customer_Requested_Date__c ?  orderLine.Customer_Requested_Date__c :  mapOrderNbrToCustReqDate.get(orderLine.OrderNumber_Country_code__c)  ) ;
                                                  
                                                  
                                              }
        
        
        
        Map<String, Decimal > mapMCNNbrToClosedOrdersAmt = new Map<String, Decimal>() ;
        Map<String, Decimal > mapMCNNbrToOpenOrdersAmt = new Map<String, Decimal>() ;
        Map<String, EDBI_Order__c > mapOrderNbrToOrder = new Map<String, EDBI_Order__c>() ;


// System.debug('mapAcctMCNToAccount.keySet()-------------'+mapAcctMCNToAccount.keySet());   
       
        for( EDBI_Order__c order : [SELECT Id, Order_Number__c, Backlog_Orders_Amount__c ,
                                    Backlog_Orders_Status__c , Master_Customer_Number__c ,
                                    Max_Promise_DateTime__c, Max_Customer_Requested_Date__c,
                                    Country_Code_With_Master_Customer_Nbr__c,Order_Number_with_Country_Code__c
                                    FROM EDBI_Order__c 
                                    WHERE Country_Code_With_Master_Customer_Nbr__c IN:mapAcctMCNToAccount.keySet()
                                    AND Order_Number_with_Country_Code__c != null
                                    ] ) {
                                        
                                        System.debug('Order-----'+order);
                                        if(mapOrderNbrToClosedAmt.containsKey(order.Order_Number_with_Country_Code__c) ) {
                                            order.Backlog_Orders_Amount__c =  mapOrderNbrToClosedAmt.get(order.Order_Number_with_Country_Code__c) ;
                                            order.Backlog_Orders_Status__c =  'CLOSED' ;
                                        } else if(mapOrderNbrToOpenAmt.containsKey(order.Order_Number_with_Country_Code__c )  ) {
                                            order.Backlog_Orders_Amount__c =  mapOrderNbrToOpenAmt.get(order.Order_Number_with_Country_Code__c) ;
                                            order.Backlog_Orders_Status__c = 'BOOKED' ;
                                        }
                                        if(mapOrderNbrToMaxPromiseDate.containsKey(order.Order_Number_with_Country_Code__c) ) {
                                            order.Max_Promise_DateTime__c = mapOrderNbrToMaxPromiseDate.get(order.Order_Number_with_Country_Code__c) ;
                                        }
                                        if(mapOrderNbrToCustReqDate.containsKey(order.Order_Number_with_Country_Code__c) ) {
                                            order.Max_Customer_Requested_Date__c = mapOrderNbrToCustReqDate.get(order.Order_Number_with_Country_Code__c) ;
                                        }
                                        
                                        
                                        if(order.Backlog_Orders_Status__c ==  'CLOSED') {
                                            if(!mapMCNNbrToClosedOrdersAmt.containsKey(order.Country_Code_With_Master_Customer_Nbr__c) ) {
                                                mapMCNNbrToClosedOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c , 0.0 ) ;
                                                
                                            }
                                            mapMCNNbrToClosedOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c ,mapMCNNbrToClosedOrdersAmt.get(order.Country_Code_With_Master_Customer_Nbr__c) + order.Backlog_Orders_Amount__c  ) ;
                                            
                                        } else if(order.Backlog_Orders_Status__c ==  'BOOKED') {
                                            if(!mapMCNNbrToOpenOrdersAmt.containsKey(order.Country_Code_With_Master_Customer_Nbr__c) ) {
                                                mapMCNNbrToOpenOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c , 0.0 ) ;
                                                
                                            }
                                            mapMCNNbrToOpenOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c ,mapMCNNbrToOpenOrdersAmt.get(order.Country_Code_With_Master_Customer_Nbr__c) + order.Backlog_Orders_Amount__c  ) ;
                                            
                                        }
                                        /* if(!mapMCNNbrToOrdersAmt.containsKey(order.Country_Code_With_Master_Customer_Nbr__c) ) {
mapMCNNbrToOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c , 0.0 ) ;

}
mapMCNNbrToOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c ,  
mapMCNNbrToOrdersAmt.get(order.Country_Code_With_Master_Customer_Nbr__c ) + Decimal.valueOf(order.Backlog_Orders_Amount__c )  ) ;
*/
                                        mapOrderNbrToOrder.put(order.Order_Number_with_Country_Code__c ,order ) ;
                                        
                                        
                                    }
        
        if(!mapOrderNbrToOrder.keySet().isEmpty() ) {
            update mapOrderNbrToOrder.values() ;
        }
        
        
        
        for(String MCNNbr : mapAcctMCNToAccount.keySet() ) {
            if(mapMCNNbrToClosedOrdersAmt.containsKey(MCNNbr) ) { 
                mapAcctMCNToAccount.get(MCNNbr).Backlog_Orders_Closed_amount__c = mapMCNNbrToClosedOrdersAmt.get(MCNNbr) ;
            } else {
                mapAcctMCNToAccount.get(MCNNbr).Backlog_Orders_Closed_amount__c = 0.0 ;
            }
            
            if(mapMCNNbrToOpenOrdersAmt.containsKey(MCNNbr) ) {
                mapAcctMCNToAccount.get(MCNNbr).Backlog_Orders_Open_amount__c = mapMCNNbrToOpenOrdersAmt.get(MCNNbr) ;
            }else {
                mapAcctMCNToAccount.get(MCNNbr).Backlog_Orders_Open_amount__c = 0.0 ;
            }
            
        }
        
        update mapAcctMCNToAccount.values() ;
        
        
        
        //  Map<String, Decimal> mapOrderNbrToClosedOrdersAmt = new Map<String, Decimal>() ;
        /*for(EDBI_Order__c order : [SELECT Id, Backlog_Orders_Amount__c , Order_Number__c,
Master_Customer_Number__c
FROM EDBI_Order__c 
WHERE Order_Number__c IN:orderNbrSet
]) {
if(order.Backlog_Orders_Amount__c == null  ) {
order.Backlog_Orders_Amount__c = 0.0 ;
}



if(!mapOrderNbrToClosedOrdersAmt.containsKey(order.Master_Customer_Number__c) ) {
mapOrderNbrToClosedOrdersAmt.put(order.Master_Customer_Number__c , 0.0) ;
}
mapOrderNbrToClosedOrdersAmt.put(order.Master_Customer_Number__c , mapOrderNbrToClosedOrdersAmt.get(order.Master_Customer_Number__c) + order.Backlog_Orders_Amount__c ) ;



}*/
        
        
        
        
        
    }
    
    
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));
    }
    
}