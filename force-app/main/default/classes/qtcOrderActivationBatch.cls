/**
 * @author ATG
 * @description This is a batch class to activate Orders and publish Order Activation Platform Events 
 *              for Quotes of type "Quote" and "PARTNER"
*/
public with sharing class qtcOrderActivationBatch extends ErrorLogUtil implements Database.Batchable<sObject>  {
    final static string CHANNEL_PARTNER = 'PARTNER',
                        TYPE_QUOTE  = 'Quote';

     /**
     * @description Batch start method, queries for Fulfillment Orders that matches the criteria
     * @param   BC  Batchable Context
     * @return  Database.QueryLocator Scope of the batch
     */
    public Database.QueryLocator  start(Database.BatchableContext BC) {
        Date startOfMonth = Date.today().toStartOfMonth();
        String  query =     'SELECT Id, qtc_Quote__c ';
                query +=    'FROM qtc_FulfillmentOrder__c ';
                query +=    'WHERE qtc_OrderStartDate__c <= :startOfMonth ';
                query +=    'AND qtc_Quote__r.qtc_Ordered_Custom__c = false ';
                query +=    'AND qtc_Quote__r.SBQQ__Type__c = :TYPE_QUOTE ';
                query +=    'AND qtc_Quote__r.qtc_Channel_Local_Office_Record_Type__c = :CHANNEL_PARTNER ';
       
        return Database.getQueryLocator( query );
    }

     /**
     * @description Batch execute logic, set the Quote records to true and publish Order Activation events
     * @param   BC                      Batchable Context
     * @param   listFulfillmentOrders   Scope of the batch
     */
    public void execute(Database.BatchableContext BC, list<qtc_FulfillmentOrder__c> listFulfillmentOrders){
        List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
        for(qtc_FulfillmentOrder__c thisFulfillmentOrder : listFulfillmentOrders ){
            listQuotes.add(
                new SBQQ__Quote__c(
                    Id = thisFulfillmentOrder.qtc_Quote__c,
                    qtc_Ordered_Custom__c = true,
                    qtc_Dont_Run_Ordered_Flow__c = true,
                    SBQQ__Ordered__c = true
                )
            );
        }

        List<Database.SaveResult> updatedQuoteResults = Database.update( listQuotes, false);
        Set<Id> setUpdatedQuoteIds = new Set<Id>();
        for(Database.SaveResult thisSaveResult : updatedQuoteResults){
            if( thisSaveResult.isSuccess() ){
                setUpdatedQuoteIds.add( thisSaveResult.getId() );
            }
            else {
                log( 'Order Activation Batch', thisSaveResult);
            }
        }


        List<Order> listOrders = [SELECT Id, Status, SBQQ__Contracted__c, SBQQ__Quote__c FROM Order WHERE SBQQ__Quote__c IN : setUpdatedQuoteIds ];
        List<qtcOrderActivation__e> listOrderActivationEvent = new List<qtcOrderActivation__e>();
        for(Order thisOrder: listOrders){
            listOrderActivationEvent.add(
                new qtcOrderActivation__e(
                    qtcOrderId__c = thisOrder.id
                )
            );
        }
        List<Database.SaveResult> results = EventBus.publish(listOrderActivationEvent);
        commitLogs();

    }
    public void finish(Database.BatchableContext BC){

    }
}