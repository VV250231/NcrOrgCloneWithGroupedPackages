/**
 * @author ATG
 * @description This TriggerHandler is used by the Platform Event Order Activation Event to Activate an Order
*/
public with sharing class OrderActivationEventTriggerHandler extends ErrorLogUtil {
    private List<qtcOrderActivation__e> listOrderActivationEvent;
    private Map<Id, qtcOrderActivation__e> mapOldOrderActivationEvent;
    final static List<String> LIST_PRICE_CALC_STATUS = new List<String>{ 'Not Needed', 'Completed' };

    List<Order> listOrdersToActivate = new List<Order>();
    @testVisible 
    private List<qtcContractOrder__e> listContractOrderEvents = new List<qtcContractOrder__e>();
    @testVisible 
    private List<qtcOrderActivation__e> listOrderActivationEventsToRepublish = new List<qtcOrderActivation__e>();
   

     /**
     * @description Constructor method to Instantiate The Trigger Handler
     * @param   triggerNew      List of New Order Activation Events
     * @param   triggerOldMap   Map of Old Order Activation Events
     */
    public OrderActivationEventTriggerHandler( List<qtcOrderActivation__e> triggerNew, Map<Id, qtcOrderActivation__e> triggerOldMap) {
        this.listOrderActivationEvent = triggerNew;
        this.mapOldOrderActivationEvent = triggerOldMap;
    }

     /**
     * @description After Insert method loops through the events, query the orders and check if the calculations have completed.
     *              If the calculations are completed, activate the order and publish the Contract Order Event
     *              If the calculations are not completed, retry platform event
     */
    public void handleAfterInsert(){
        Map<Id, qtcOrderActivation__e> mapOrderActivationEventByOrderId = new Map<Id, qtcOrderActivation__e>();

        for(qtcOrderActivation__e thisEvent : listOrderActivationEvent){
            mapOrderActivationEventByOrderId.put( thisEvent.qtcOrderId__c, thisEvent);
        }
        List<Order> listOrders = queryOrders( mapOrderActivationEventByOrderId.keySet() );
        for( Order thisOrder : listOrders ){
            if( LIST_PRICE_CALC_STATUS.contains( thisOrder.SBQQ__PriceCalcStatus__c) ){
                listOrdersToActivate.add(
                    new Order(
                        Id = thisOrder.Id,
                        status = 'Activated'
                    )
                );
            }
            else{
                qtcOrderActivation__e thisEvent = mapOrderActivationEventByOrderId.get( thisOrder.Id );
                retryOrderActivationEvent( thisEvent );
            }
        }
        Database.SaveResult[] listOfUpdatedOrders = Database.Update(listOrdersToActivate, false);

        for(Database.SaveResult orderSaveResult : listOfUpdatedOrders ) {
            if(orderSaveResult.isSuccess()){
                listContractOrderEvents.add(
                    new qtcContractOrder__e (
                        qtcOrderId__c = String.valueOf( orderSaveResult.getId() )
                    )
                );
            }
            else {
                qtcOrderActivation__e thisEvent = mapOrderActivationEventByOrderId.get( orderSaveResult.getId() );
                retryOrderActivationEvent( thisEvent );
            }
        }
      List<Database.SaveResult> contractOrderEventResult = EventBus.publish(listContractOrderEvents);
      List<Database.SaveResult> listOrderActivationEventRepublishResult = EventBus.publish(listOrderActivationEventsToRepublish);
       
       
    }

    /**
     * @description Retry method to republish an event that failed or did not meet the criteria, and increment the retry count
     * @param   thisEvent   Order Activation Event To retry
     */
    private void retryOrderActivationEvent(  qtcOrderActivation__e thisEvent ){
        System.debug('@@@ retry attempt '+ thisEvent);
        if( thisEvent.qtcRetryAttempt__c < 5 ){
            listOrderActivationEventsToRepublish.add(
                new qtcOrderActivation__e(
                    qtcOrderId__c = thisEvent.qtcOrderId__c,
                    qtcRetryAttempt__c = thisEvent.qtcRetryAttempt__c + 1
                )
            );
            System.debug('@@@ listOrderActivationEventsToRepublish '+ listOrderActivationEventsToRepublish);
        } 
        else {
            log('The Order '+thisEvent.qtcOrderId__c+' failed to activate because Price Calculation Status has not been completed.', new List<String>());
        }
    }

     /**
     * @description Query method to get the related order records
     * @param   setOrderIds     Set of Order Ids
     */
    private List<Order> queryOrders( Set<Id> setOrderIds ){
        return [SELECT Id, SBQQ__PriceCalcStatus__c FROM Order WHERE Id IN : setOrderIds];
    }
}