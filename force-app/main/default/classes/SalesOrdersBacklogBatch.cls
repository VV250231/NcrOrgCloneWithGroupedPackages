public class SalesOrdersBacklogBatch implements Database.Batchable<SObject> {
    
    Set<String> MCNIds = new Set<String>() ;
    
    public SalesOrdersBacklogBatch(Set<String> MCNIdsSet) {
        MCNIds = MCNIdsSet ;
    }
    
    
    public  Database.QueryLocator start(Database.BatchableContext bc) {
        String actQuery = '' ;
        if(MCNIds != null && !MCNIds.isEmpty() ) {
            actQuery = 'SELECT Id, Name , Master_Customer_Number__c,Country_with_Master_customer_Number__c , Backlog_Orders_Closed_amount__c, Backlog_Orders_Open_amount__c FROM Account WHERE Country_with_Master_customer_Number__c IN:MCNIds'  ;// \'' + 'DIV001\'' ;
        } else {
            actQuery = 'SELECT Id, Name , Master_Customer_Number__c,Country_with_Master_customer_Number__c , Backlog_Orders_Closed_amount__c, Backlog_Orders_Open_amount__c FROM Account WHERE Country_with_Master_customer_Number__c != null'  ;// \'' + 'DIV001\'' ;
        }
        return Database.getQueryLocator(actQuery) ;
    }
    
    
    public void execute(Database.BatchableContext bc , List<Account> scope) {
        
        
        Map<String, Account> mapMCNtoAcct = new Map<String, Account>() ;
        for(Account acct : scope) {
            mapMCNtoAcct.put(acct.Country_with_Master_customer_Number__c , acct) ;
        } 
        
        if(!mapMCNtoAcct.keySet().isEmpty() ) { 
            Map<String, Decimal > mapMCNNbrToOrdersAmt = new Map<String, Decimal>() ;
            Map<String, EDBI_Order__c > mapOrderNbrToOrder = new Map<String, EDBI_Order__c>() ;
            for( EDBI_Order__c order : [SELECT Id, Order_Number__c, Backlog_Orders_Amount__c  ,
                                        Backlog_Orders_Status__c , Master_Customer_Number__c ,
                                        Max_Promise_DateTime__c, Max_Customer_Requested_Date__c,
                                        Country_Code_With_Master_Customer_Nbr__c , Order_Number_with_Country_Code__c
                                        FROm EDBI_Order__c 
                                        WHERE Country_Code_With_Master_Customer_Nbr__c IN:mapMCNtoAcct.keySet()
                                        AND Order_Number_with_Country_Code__c != null ] ) {
                                            mapOrderNbrToOrder.put(order.Order_Number_with_Country_Code__c ,order ) ;
                                            
                                            
                                        }
            
            Map<String, Decimal> mapOrderNbrToOpenAmt = new Map<String, Decimal>() ;
            Map<String, Decimal> mapOrderNbrToCloseAmt = new Map<String , Decimal>() ;
            Map<String, Date> mapOrderNbrToMaxPromiseDate = new Map<String, Date>() ;
            Map<String, Date> mapOrderNbrToCustReqDate = new Map<String, Date>() ;
            
            for( ERP_Orders_Backlog__c orderLine: [SELECT Id, Promise_Date_Time__c, Customer_Requested_Date__c ,
                                                   Amount_in_USD__c, Order_Status_Ind__c, Order_Number__c, OrderNumber_Country_code__c
                                                   FROM ERP_Orders_Backlog__c 
                                                   WHERE OrderNumber_Country_code__c IN:mapOrderNbrToOrder.keySet() 
                                                   AND  Order_Status_Ind__c = 'CLOSED' 
                                                   AND OrderNumber_Country_code__c != null AND
                                                   (NOT Product_ID__c LIKE '%F%' ) AND 
                                                   (NOT Product_ID__c LIKE '%FEATURE%' ) AND 
                                                   (NOT Product_ID__c LIKE '%OPTION%' ) AND 
                                                   (NOT  Product_ID__c LIKE '%D%' ) AND 
                                                   (NOT Product_ID__c LIKE '%R%' )
                                                  ]) {
                                                      
                                                      if(!mapOrderNbrToCloseAmt.containsKey(orderLine.OrderNumber_Country_code__c) ) {
                                                          mapOrderNbrToCloseAmt.put(orderLine.OrderNumber_Country_code__c , 0.0) ;
                                                      }
                                                      if(orderLine.Amount_in_USD__c!=null){                                         
                                                          mapOrderNbrToCloseAmt.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToCloseAmt.get(orderLine.OrderNumber_Country_code__c ) + Decimal.valueOf( orderLine.Amount_in_USD__c )  ) ;
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
            
            /*System.assert(false,'>>>>' +  [SELECT Id, Promise_Date_Time__c, Customer_Requested_Date__c 
FROM ERP_Orders_Backlog__c WHERE Order_Number__c IN:mapOrderNbrToOrder.keySet() 
AND  Order_Status_Ind__c = 'BOOKED' 
]) ;*/
            for( ERP_Orders_Backlog__c orderLine: [SELECT Id, Promise_Date_Time__c, Customer_Requested_Date__c ,
                                                   Amount_in_USD__c, Order_Status_Ind__c, Order_Number__c,
                                                   OrderNumber_Country_code__c
                                                   FROM ERP_Orders_Backlog__c 
                                                   WHERE OrderNumber_Country_code__c IN:mapOrderNbrToOrder.keySet() 
                                                   AND  Order_Status_Ind__c = 'BOOKED' 
                                                   AND OrderNumber_Country_code__c != null AND
                                                   (NOT Product_ID__c LIKE '%F%' ) AND 
                                                   (NOT Product_ID__c LIKE '%FEATURE%' ) AND 
                                                   (NOT Product_ID__c LIKE '%OPTION%' ) AND 
                                                   (NOT  Product_ID__c LIKE '%D%' ) AND 
                                                   (NOT Product_ID__c LIKE '%R%' )
                                                  ]) {
                                                      if(!mapOrderNbrToOpenAmt.containsKey(orderLine.OrderNumber_Country_code__c) ) {
                                                          mapOrderNbrToOpenAmt.put(orderLine.OrderNumber_Country_code__c , 0.0) ;
                                                      }
                                                      mapOrderNbrToOpenAmt.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToOpenAmt.get(orderLine.OrderNumber_Country_code__c ) + Decimal.valueOf( orderLine.Amount_in_USD__c )  ) ;
                                                      
                                                      if(!mapOrderNbrToMaxPromiseDate.containsKey(orderLine.OrderNumber_Country_code__c ) ) {
                                                          mapOrderNbrToMaxPromiseDate.put(orderLine.OrderNumber_Country_code__c , orderLine.Promise_Date_Time__c ) ;
                                                      }
                                                      mapOrderNbrToMaxPromiseDate.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToMaxPromiseDate.get(orderLine.OrderNumber_Country_code__c) < orderLine.Promise_Date_Time__c ?  orderLine.Promise_Date_Time__c :  mapOrderNbrToMaxPromiseDate.get(orderLine.OrderNumber_Country_code__c)  ) ;
                                                      
                                                      
                                                      if(!mapOrderNbrToCustReqDate.containsKey(orderLine.OrderNumber_Country_code__c ) ) {
                                                          mapOrderNbrToCustReqDate.put(orderLine.OrderNumber_Country_code__c , orderLine.Customer_Requested_Date__c ) ;
                                                      }
                                                      mapOrderNbrToCustReqDate.put(orderLine.OrderNumber_Country_code__c , mapOrderNbrToCustReqDate.get(orderLine.OrderNumber_Country_code__c) < orderLine.Customer_Requested_Date__c ?  orderLine.Customer_Requested_Date__c :  mapOrderNbrToCustReqDate.get(orderLine.OrderNumber_Country_code__c)  ) ;
                                                      
                                                  }
            
            //System.assert(false, mapOrderNbrToOpenAmt) ;
            
            for( String orderNbr : mapOrderNbrToOrder.keySet() ) {
                if(mapOrderNbrToCloseAmt.containsKey(orderNbr) ) {
                    mapOrderNbrToOrder.get(orderNbr).Backlog_Orders_Amount__c =  mapOrderNbrToCloseAmt.get(orderNbr) ;
                    mapOrderNbrToOrder.get(orderNbr).Backlog_Orders_Status__c = 'CLOSED' ;
                } else if(mapOrderNbrToOpenAmt.containsKey(orderNbr)) {
                    mapOrderNbrToOrder.get(orderNbr).Backlog_Orders_Amount__c =  mapOrderNbrToOpenAmt.get(orderNbr) ;
                    mapOrderNbrToOrder.get(orderNbr).Backlog_Orders_Status__c = 'BOOKED' ;
                }
                if(mapOrderNbrToMaxPromiseDate.containsKey(orderNbr) ) {
                    mapOrderNbrToOrder.get(orderNbr).Max_Promise_DateTime__c =  mapOrderNbrToMaxPromiseDate.get(orderNbr)  ;
                }
                if(mapOrderNbrToCustReqDate.containsKey(orderNbr) ) {
                    mapOrderNbrToOrder.get(orderNbr).Max_Customer_Requested_Date__c =  mapOrderNbrToCustReqDate.get(orderNbr)  ;
                }
            }
            
            
            update mapOrderNbrToOrder.values() ;
            
            Map<String, Decimal > mapMCNNbrToClosedOrdersAmt = new Map<String, Decimal>() ;
            Map<String, Decimal > mapMCNNbrToOpenOrdersAmt = new Map<String, Decimal>() ;
            // System.assert(false, mapOrderNbrToOrder ) ;
            for(EDBI_Order__c order  : mapOrderNbrToOrder.values() ) {
                if(order.Backlog_Orders_Status__c == 'BOOKED') {
                    if(!mapMCNNbrToOpenOrdersAmt.containsKey(order.Country_Code_With_Master_Customer_Nbr__c) ) {
                        mapMCNNbrToOpenOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c , 0.0 ) ;
                        
                    }
                    mapMCNNbrToOpenOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c ,mapMCNNbrToOpenOrdersAmt.get(order.Country_Code_With_Master_Customer_Nbr__c) + order.Backlog_Orders_Amount__c  ) ;
                    
                } else if(order.Backlog_Orders_Status__c == 'CLOSED') {
                    if(!mapMCNNbrToClosedOrdersAmt.containsKey(order.Country_Code_With_Master_Customer_Nbr__c) ) {
                        mapMCNNbrToClosedOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c , 0.0 ) ;
                        
                    }
                    mapMCNNbrToClosedOrdersAmt.put(order.Country_Code_With_Master_Customer_Nbr__c ,mapMCNNbrToClosedOrdersAmt.get(order.Country_Code_With_Master_Customer_Nbr__c) + order.Backlog_Orders_Amount__c  ) ;
                    
                }
                
            }
            
            
            
            for(String MCNNbr : mapMCNtoAcct.keySet() ) {
                if(mapMCNNbrToClosedOrdersAmt.containsKey(MCNNbr) ) { 
                    mapMCNtoAcct.get(MCNNbr).Backlog_Orders_Closed_amount__c = mapMCNNbrToClosedOrdersAmt.get(MCNNbr) ;
                }
                if(mapMCNNbrToOpenOrdersAmt.containsKey(MCNNbr) ) {
                    mapMCNtoAcct.get(MCNNbr).Backlog_Orders_Open_amount__c = mapMCNNbrToOpenOrdersAmt.get(MCNNbr) ;
                    
                }
                
            }
            
            update mapMCNtoAcct.values() ;
            // System.assert(false, mapMCNtoAcct ) ;
            
            
        }
        
    }
    
    
    public void finish(Database.BatchableContext bc) { 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));    
    }
    
    
    
}