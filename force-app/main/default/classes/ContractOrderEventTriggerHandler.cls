/**
 * @author ATG
 * @description This TriggerHandler is used by the Platform Event Contract Order Event to Contract an Order
 * Updates: 
*/
public with sharing class ContractOrderEventTriggerHandler extends ErrorLogUtil {
    private List<qtcContractOrder__e> listNewContractOrderEvent;
    private Map<Id, qtcContractOrder__e> mapOldContractOrderEvent;

     /**
     * @description Constructor method to Instantiate The Trigger Handler
     * @param   triggerNew      List of New Contract Order Events
     * @param   triggerOldMap   Map of Old Contract Order Events
     */
    public ContractOrderEventTriggerHandler(List<qtcContractOrder__e> triggerNew, Map<Id, qtcContractOrder__e> triggerOldMap) {
        this.listNewContractOrderEvent = triggerNew;
        this.mapOldContractOrderEvent = triggerOldMap;
    }

     /**
     * @description After Insert method loops through the events, instantiate the order, and set the contracted field to true
     */
    public void handleAfterInsert(){
        List<Order> listOrdersToUpdate = new List<Order>();
        Set<Id> setOrderIds = new Set<Id>();
        for(qtcContractOrder__e thisEvent: listNewContractOrderEvent){
            setOrderIds.add( thisEvent.qtcOrderId__c);
        }
        for( Id thisOrderId : setOrderIds){
            Order thisOrder = new Order(
                Id = thisOrderId,
                SBQQ__Contracted__c = true
            );
            listOrdersToUpdate.add(thisOrder);
        }
        try{
            update listOrdersToUpdate;
        }
        catch(DmlException ex){
            if (EventBus.TriggerContext.currentContext().retries < 5) {
                throw new EventBus.RetryableException(
                         'Order failed to contract, attempting to retry trigger.');
            } else {
                log('Contract Order Event Trigger ', ex);
            }
        }
        finally{
            commitLogs();
        }
    }
}