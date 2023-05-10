public with sharing class ContractTriggerHandler extends ErrorLogUtil{

    private list<Contract> listNewContracts;
    private map<Id, Contract> mapOldContracts;

    public ContractTriggerHandler(list<Contract> triggerNew, map<Id, Contract> triggerOldMap ){
        this.listNewContracts = triggerNew;
        this.mapOldContracts = triggerOldMap;
    }

    public void handleAfterUpdate(){
        evaluateAndUpdateOrders();
    }

    public void handleBeforeUpdate() {   
        evaluateAndUpdateTeriminationDate(); 
    }

    private void evaluateAndUpdateTeriminationDate() {
        Set<Id> newOrderIds = new Set<Id>();
        Map<Id, Order> orderMap = new Map<Id, Order>();
        List<Contract> modifiedOrderContract = new List<Contract>();
        
        modifiedOrderContract = getChangedOrderContract(listNewContracts);
        for (Contract contractRec : modifiedOrderContract) {
            newOrderIds.add(contractRec.SBQQ__Order__c);
        }

        if (! newOrderIds.isEmpty()) {
            orderMap = getOrderMap(new List<Id>(newOrderIds));
            for (Contract contractRec : modifiedOrderContract) {
                Order orderRec = orderMap.get(contractRec.SBQQ__Order__c);
                
                if ( orderRec != null && orderRec.SBQQ__Quote__r.qtc_Cancelled__c) {
                    contractRec.qtc_Termination_Date__c = orderRec.EffectiveDate - 1;
                } else {
                    contractRec.qtc_Termination_Date__c = null;
                }
            }
        }
    }

    private List<Contract> getChangedOrderContract( List<Contract> contracts) {
        List<Contract> changedOrderContract = new List<Contract>();
        for (Contract contractRec : contracts) {
            if (isOrderChanged(contractRec) && contractRec.SBQQ__Order__c != null) {
                changedOrderContract.add(contractRec);
            }
        }
        return changedOrderContract;
    }


    private Map<Id, Order> getOrderMap(List<Id> orderIds) {
        Map<Id, Order> orderMap = new Map<Id, Order>(
                [SELECT Id, SBQQ__Quote__r.qtc_Cancelled__c, EffectiveDate FROM Order 
                WHERE Id IN : orderIds]);
        return orderMap;
    }

    public boolean isOrderChanged(Contract contractObj) {
        boolean isOrderChanged = false;
        if (contractObj.SBQQ__Order__c != mapOldContracts.get(contractObj.Id)?.SBQQ__Order__c) {
            isOrderChanged = true;
        }
        return isOrderChanged;
    }

    private void evaluateAndUpdateOrders(){
        Map<Id, Contract> mapContractWithBilltoAccountUpdate = new Map<Id, Contract>();
        Map<Id, Contract> mapContractWithHoldBillingUpdate = new Map<Id, Contract>();        
        for(Contract thisContract : listNewContracts ){
            Contract oldContract = mapOldContracts.get( thisContract.Id );
            if( thisContract.qtc_Bill_To_Account__c !=  oldContract?.qtc_Bill_To_Account__c
                || thisContract.qtc_Deliver_To_Site__c != oldContract?.qtc_Deliver_To_Site__c){

                mapContractWithBilltoAccountUpdate.put(thisContract.Id, thisContract);
            }

            if(thisContract.qtc_Hold_Billing__c != oldContract?.qtc_Hold_Billing__c){
                mapContractWithHoldBillingUpdate.put(thisContract.Id, thisContract);
            }

        }

        Set<Id> setContractIdsToQuery = new Set<Id>();
        setContractIdsToQuery.addAll( mapContractWithBilltoAccountUpdate.keySet() );
        setContractIdsToQuery.addAll( mapContractWithHoldBillingUpdate.keySet() );

        List<SBQQ__Subscription__c> listSubscriptions = querySubscriptions( setContractIdsToQuery );
        
        Map<Id, Order> mapOrderToUpdate = new Map<Id, Order>();

        evaluateSubscriptionsOrder( mapOrderToUpdate, listSubscriptions, mapContractWithBilltoAccountUpdate, mapContractWithHoldBillingUpdate);
       
        if( !mapOrderToUpdate.isEmpty()){
            try{
                update mapOrderToUpdate.values();
            }
            catch(DmlException ex){
                System.debug(ex.getMessage());
                log('ContractTriggerHandler evaluateAndUpdateOrders', ex);
                commitLogs();
            }
        }
    }

    private void evaluateSubscriptionsOrder( Map<Id, Order> mapOrderToUpdate, 
                                        List<SBQQ__Subscription__c> listSubscriptions, 
                                        Map<Id, Contract> mapContractWithBilltoAccountUpdate,
                                        Map<Id, Contract> mapContractWithHoldBillingUpdate){
        for(SBQQ__Subscription__c thisSubscription : listSubscriptions){
            boolean addToUpdateMap = false;
            Id thisOrderId= thisSubscription.SBQQ__OrderProduct__r?.OrderId;
            Id thisContractId = thisSubscription.SBQQ__Contract__c;
            
            if(mapOrderToUpdate.containsKey( thisOrderId) || thisOrderId == null){
                continue;
            }
            else {
                Order thisOrder = new Order( Id = thisOrderId );
                if( mapContractWithBilltoAccountUpdate.containsKey( thisContractId )){
                    Contract thisContract = mapContractWithBilltoAccountUpdate.get( thisContractId );
                    thisOrder.Deliver_To_Site__c =  thisContract.qtc_Deliver_To_Site__c;
                    thisOrder.qtc_Bill_To_Site__c = thisContract.qtc_Bill_To_Account__c;
                }

                if( mapContractWithHoldBillingUpdate.containsKey( thisContractId )){
                    Contract thisContract = mapContractWithHoldBillingUpdate.get( thisContractId );
                    thisOrder.qtc_Hold_Billing__c = thisContract.qtc_Hold_Billing__c;
                }

                mapOrderToUpdate.put(thisOrder.id, thisOrder);
            }
        }
   
    }

    private List<SBQQ__Subscription__c> querySubscriptions(set<Id> setContractIds){
        return [SELECT SBQQ__OrderProduct__r.OrderId, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN :setContractIds];
    }
}