public with sharing class OrderTriggerHandler {
    private List<Order> listOrders;
    private Map<Id, Order> mapOldOrders;
    private static string   HOLD_BILLING_YES    = 'Yes',
                            HOLD_BILLING_NO     = 'No';

    public OrderTriggerHandler( List<Order> triggerNew, Map<Id, Order> triggerOldMap ){
        this.listOrders = triggerNew;
        this.mapOldOrders = triggerOldMap;
    }

    public void handleAfterUpdate(){
        updateOrderItems();
        //Dharmendra added
        updateContract();
        requestToMyNCR();
    }

    /**
     * Dharmendra added on 07-Dec-2021
     * SFCPQBLG-519 CPQ should inform MYNCR whenever there is change in Bill To Address on CPQ quote or Order
     * */
    Public void requestToMyNCR(){
        if(!System.isFuture() && !System.isBatch() && Limits.getQueueableJobs()<Limits.getLimitQueueableJobs() && Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
            Boolean billSiteUpdated = false;
            List<Order> newList=new List<Order>();
            Map<id,Order> oldMap = new Map<id,Order>();
            for(Order tOrder : this.listOrders){
                Order oldOrder = this.mapOldOrders.get(tOrder.Id);
                if(tOrder.qtc_Bill_To_Site__c != oldOrder.qtc_Bill_To_Site__c){ 
                    newList.add(tOrder);
                    oldMap.put(oldOrder.Id,oldOrder);
                }
            }
            if(newList.size()>0){
                System.enqueueJob(new CPQMyNcrRequestAsync(newList,oldMap));
            }
        }  
    }
    
    private void updateOrderItems(){
        Map<Id, Order> mapOrdersToEvaluateById = evaluateOrders();
        List<OrderItem> listOrderItems = queryOrderItems( mapOrdersToEvaluateById.keySet() );
        if( !listOrderItems.isEmpty() ){
            for( OrderItem thisOrderItem : listOrderItems ){
                Order thisOrder = mapOrdersToEvaluateById.get( thisOrderItem.OrderId );
                thisOrderItem.blng__HoldBilling__c = thisOrder.qtc_Hold_Billing__c ? HOLD_BILLING_YES : HOLD_BILLING_NO;
            }
            try{
                update listOrderItems;
            } catch( DmlException ex ){
                System.debug( ex.getMessage() );
            }
        }
    }
    
    /**
    * CreatedBy: Dharmendra Kumar Pandey
    * Description: SFCPQBLG-657 aaSe - Contract Mgmt - Contract Details - Display Subscription Fee per Billing Period
    * Date: 26-NOV-2021
    * */
    public void updateContract(){
        Map<Id, Order> mapOrderToEvaluate = new Map<Id, Order>();
        List<Id> contractIds = new List<Id>();
        for( Order thisOrder : this.listOrders ){
            Order oldOrder = this.mapOldOrders.get( thisOrder.Id );
            if( thisOrder.qtc_Contract__c != oldOrder.qtc_Contract__c ){
                mapOrderToEvaluate.put( thisOrder.Id, thisOrder);
                contractIds.add(thisOrder.qtc_Contract__c);
            }
        }
        
        Map<ID, Contract> contracts = new Map<ID, Contract>([Select Id,qtc_Subscription_Fee_per_Billing_Period__c from Contract where Id in :contractIds]);
        
        for(Id orderId:mapOrderToEvaluate.keySet()){
            Order ord = mapOrderToEvaluate.get(orderId);
            Contract cnt= contracts.get(ord.qtc_Contract__c);
            if(cnt.qtc_Subscription_Fee_per_Billing_Period__c==null){
                cnt.qtc_Subscription_Fee_per_Billing_Period__c = ord.qtc_Monthly_Subscription_Amount__c;
            } else {
                cnt.qtc_Subscription_Fee_per_Billing_Period__c += ord.qtc_Monthly_Subscription_Amount__c;
            }
        }
        
        try{
            update contracts.values();
        } catch( DmlException ex ){
            System.debug( ex.getMessage() );
        }
    }

    private Map<Id, Order> evaluateOrders(){
        Map<Id, Order> mapOrderToEvaluate = new Map<Id, Order>();
        for( Order thisOrder : this.listOrders ){
            Order oldOrder = this.mapOldOrders.get( thisOrder.Id );
            if( thisOrder.qtc_Hold_Billing__c != oldOrder.qtc_Hold_Billing__c ){
                mapOrderToEvaluate.put( thisOrder.Id, thisOrder);
            }
        }
        return mapOrderToEvaluate;
    }

    private List<OrderItem> queryOrderItems( Set<Id> setOrderIds ){
        return [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN : setOrderIds];
    }
}