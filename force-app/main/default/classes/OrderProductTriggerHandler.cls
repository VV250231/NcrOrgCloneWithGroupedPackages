public with sharing class OrderProductTriggerHandler extends ErrorLogUtil{
    private List<OrderItem> listNewOrderProducts;
    private Map<Id, OrderItem> mapOldOrderProducts;

    public OrderProductTriggerHandler( List<OrderItem> triggerNew, Map<Id, OrderItem> triggerOldMap) {
        this.listNewOrderProducts = triggerNew;
        this.mapOldOrderProducts = triggerOldMap;
    }

    public void handleAfterInsert(){
        Set<Id> setOrderIds = ApexUtils.pluckIdSet(listNewOrderProducts, OrderItem.OrderId);
        List<OrderItem> listOrderItemsRelatedToOrderIds = queryOrderProductsRelatedToOrders( setOrderIds );
        Map<String, List<OrderItem>> mapOrderItemsByOrderIds = ApexUtils.groupBy( listOrderItemsRelatedToOrderIds, OrderItem.OrderId );
        List<Order> listOrderToUpdate = evaluateOrders(mapOrderItemsByOrderIds);

        Set<Id> setContractIds = ApexUtils.pluckIdSet(listOrderItemsRelatedToOrderIds, 'SBQQ__Subscription__r.SBQQ__Contract__c');
        List<OrderItem> listOrderItemsRelatedToContract = queryOrderProductsRelatedToContracts(setContractIds);
        Map<String, List<OrderItem>> mapOrderItemsByContractId = APexUtils.groupBy( listOrderItemsRelatedToContract, 'SBQQ__Subscription__r.SBQQ__Contract__c');
        List<Contract> listContractToUpdate = evaluateContracts( mapOrderItemsByContractId );

        try{
            update listOrderToUpdate;
            update listContractToUpdate;
        } catch( DmlException ex ){
            System.debug( ex.getMessage() );
            log('OrderProductTriggerHandler handleAfterInsert', ex);
            commitLogs();
        }
    }

    public void handleAfterUpdate(){
        List<Schema.SObjectField> listFieldsToEvaluate = new List<Schema.SObjectField>{ OrderItem.qtc_Missing_Usage__c, OrderItem.SBQQ__Subscription__c};
        List<OrderItem> listOrderItemsToEvaluate = ApexUtils.findChangedRecs(listNewOrderProducts, mapOldOrderProducts, listFieldsToEvaluate);
        
        Set<Id> setOrderIds = ApexUtils.pluckIdSet(listOrderItemsToEvaluate, OrderItem.OrderId);
        List<OrderItem> listOrderItemsRelatedToOrderIds = queryOrderProductsRelatedToOrders( setOrderIds );
        Map<String, List<OrderItem>> mapOrderItemsByOrderIds = ApexUtils.groupBy( listOrderItemsRelatedToOrderIds, OrderItem.OrderId );
        List<Order> listOrderToUpdate = evaluateOrders(mapOrderItemsByOrderIds);

        Set<Id> setContractIds = ApexUtils.pluckIdSet(listOrderItemsRelatedToOrderIds, 'SBQQ__Subscription__r.SBQQ__Contract__c');
        List<OrderItem> listOrderItemsRelatedToContract = queryOrderProductsRelatedToContracts(setContractIds);
        Map<String, List<OrderItem>> mapOrderItemsByContractId = APexUtils.groupBy( listOrderItemsRelatedToContract, 'SBQQ__Subscription__r.SBQQ__Contract__c');
        List<Contract> listContractToUpdate = evaluateContracts( mapOrderItemsByContractId );
        
        try{
            update listOrderToUpdate;
            update listContractToUpdate;
        } catch( DmlException ex ){
            System.debug( ex.getMessage() );
            log('OrderProductTriggerHandler handleAfterUpdate', ex);
            commitLogs();
        }
    }

    private List<Order> evaluateOrders( Map<String, List<OrderItem>> mapOrderItemsByOrderIds){
        List<Order> listOrderToUpdate = new List<Order>();
        for( String orderId : mapOrderItemsByOrderIds.keySet() ){
            Order thisOrder;
            Boolean missingUsage = false;

            for(OrderItem thisOrderItem : mapOrderItemsByOrderIds.get( orderId )){
                if( thisOrder == null && thisOrderItem.OrderId != null){
                    thisOrder = new Order(
                        Id = thisOrderItem.OrderId,
                        qtc_Missing_Usage__c = thisOrderItem.Order.qtc_Missing_Usage__c
                    );
                }

                if( thisOrderItem.qtc_Missing_Usage__c == true){
                    missingUsage = true;
                }
                if( missingUsage == true && thisOrder != null){
                    break;
                }
            }

            if( thisOrder != null && thisOrder.qtc_Missing_Usage__c != missingUsage){
                thisOrder.qtc_Missing_Usage__c = missingUsage;
                listOrderToUpdate.add( thisOrder );
            }
        }
        return listOrderToUpdate;
    }

    private List<Contract> evaluateContracts( Map<String, List<OrderItem>> mapOrderItemsByContractId ){
        List<Contract> listContractsToUpdate = new List<Contract>();
        for(String contractId : mapOrderItemsByContractId.keySet() ){
            Contract thisContract;
            Boolean missingUsage = false;
            for(OrderItem thisOrderProduct : mapOrderItemsByContractId.get( contractId )){
                if(thisContract == null && thisOrderProduct.SBQQ__Subscription__r?.SBQQ__Contract__c != null){
                    thisContract = new Contract( 
                        Id = thisOrderProduct.SBQQ__Subscription__r.SBQQ__Contract__c,
                        qtc_Missing_Usage__c = thisOrderProduct.SBQQ__Subscription__r.SBQQ__Contract__r.qtc_Missing_Usage__c
                    );
                }

                if(thisOrderProduct.qtc_Missing_Usage__c == true){
                    missingUsage = true;
                }

                if( missingUsage == true && thisContract != null){
                    break;
                }
            }
            if( thisContract != null && thisContract.qtc_Missing_Usage__c != missingUsage){
                thisContract.qtc_Missing_Usage__c = missingUsage;
                listContractsToUpdate.add(thisContract);
            }
        }
        return listContractsToUpdate;
    }

    private List<OrderItem> queryOrderProductsRelatedToOrders( Set<Id> setOrderId){
        List<OrderItem> listOrderProducts = 
            [   SELECT Id, qtc_Missing_Usage__c, OrderId, Order.qtc_Missing_Usage__c, SBQQ__Subscription__r.SBQQ__Contract__c
                FROM OrderItem
                WHERE OrderId IN : setOrderId ];
        return listOrderProducts;
    }

    private List<OrderItem> queryOrderProductsRelatedToContracts( Set<Id> setContractId){
        List<OrderItem> listOrderProducts = 
            [   SELECT Id, qtc_Missing_Usage__c, SBQQ__Subscription__r.SBQQ__Contract__c, SBQQ__Subscription__r.SBQQ__Contract__r.qtc_Missing_Usage__c
                FROM OrderItem
                WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN :setContractId ];
        return listOrderProducts;
    }
}