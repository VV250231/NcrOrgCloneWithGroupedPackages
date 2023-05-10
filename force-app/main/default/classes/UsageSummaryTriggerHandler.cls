public with sharing class UsageSummaryTriggerHandler extends ErrorLogUtil{
    private List<blng__UsageSummary__c> listNewUsageSummaries;
    private Map<Id, blng__UsageSummary__c> mapOldUsageSummaries;

    private String USAGE_STATUS_EXPECTING_USAGE = 'Expecting Usage';
    private List<blng__UsageSummary__c> listUsageSummaryToEvaluateWithMissingUsageChanges = new List<blng__UsageSummary__c>();
    Map<Id, OrderItem> mapOrderItemByIdToUpdate = new Map<Id, OrderItem>();

    public UsageSummaryTriggerHandler(List<blng__UsageSummary__c> triggerNew, Map<Id, blng__UsageSummary__c> triggerOldMap) {
        this.listNewUsageSummaries = triggerNew;
        this.mapOldUsageSummaries = triggerOldMap;
    }

    public void handleAfterInsert(){
        Set<Id> setOrderProductIds = ApexUtils.pluckIdSet(listNewUsageSummaries, blng__UsageSummary__c.blng__OrderProduct__c);

        List<blng__UsageSummary__c> listUsageSummariesRelatedToOrderProducts = queryUsageSummariesFromOrderProduct( setOrderProductIds );
        Map<String, List<blng__UsageSummary__c>> mapListUsageSummariesByOrderProductIds = ApexUtils.groupBy(listUsageSummariesRelatedToOrderProducts, blng__UsageSummary__c.blng__OrderProduct__c);

        evaluateMissingUsage(setOrderProductIds, mapListUsageSummariesByOrderProductIds);
        aggregateUnbilledSubtotal( setOrderProductIds, mapListUsageSummariesByOrderProductIds);

        try{
            System.debug('### mapOrderItemByIdToUpdate '+mapOrderItemByIdToUpdate);
            update mapOrderItemByIdToUpdate.values();
        } catch( DmlException ex ){
            System.debug(ex.getMessage());
            log('UsageSummaryTriggerHandler handleAfterInsert', ex);
            commitLogs();
        }
    }

    public void handleAfterUpdate(){
        Set<Id> setOrderProductIdsToQuery = new Set<Id>();
        List<Schema.SObjectField> listFields = new List<Schema.SObjectField>{
            blng__UsageSummary__c.qtc_No_Usage__c,
            blng__UsageSummary__c.qtc_Usage_Status__c
        };
        List<blng__UsageSummary__c>  listUsageSummaryToEvaluateWithMissingUsageChanges = ApexUtils.findChangedRecs(listNewUsageSummaries, mapOldUsageSummaries, listFields);
        List<blng__UsageSummary__c>  listUsageSummaryToEvaluateWitSubTotalChanges = ApexUtils.findChangedRecs(listNewUsageSummaries, mapOldUsageSummaries, blng__UsageSummary__c.blng__Subtotal__c);

        Set<Id> setOrderProductIdsWithMissingUsageChanges = ApexUtils.pluckIdSet(listUsageSummaryToEvaluateWithMissingUsageChanges, blng__UsageSummary__c.blng__OrderProduct__c);
        Set<Id> setOrderProductIdsWithSubTotalChanges = ApexUtils.pluckIdSet(listUsageSummaryToEvaluateWitSubTotalChanges, blng__UsageSummary__c.blng__OrderProduct__c);

        setOrderProductIdsToQuery.addAll( setOrderProductIdsWithMissingUsageChanges );
        setOrderProductIdsToQuery.addAll( setOrderProductIdsWithSubTotalChanges );

        List<blng__UsageSummary__c> listUsageSummariesRelatedToOrderProducts = queryUsageSummariesFromOrderProduct( setOrderProductIdsToQuery );
        Map<String, List<blng__UsageSummary__c>> mapListUsageSummariesByOrderProductIds = ApexUtils.groupBy(listUsageSummariesRelatedToOrderProducts, blng__UsageSummary__c.blng__OrderProduct__c);

        evaluateMissingUsage(setOrderProductIdsWithMissingUsageChanges, mapListUsageSummariesByOrderProductIds );
        aggregateUnbilledSubtotal( setOrderProductIdsWithSubTotalChanges, mapListUsageSummariesByOrderProductIds);

        try{
            update mapOrderItemByIdToUpdate.values();
        } catch( DmlException ex ){
            System.debug(ex.getMessage());
            log('UsageSummaryTriggerHandler handleAfterUpdate', ex);
            commitLogs();
        }

    }

    private void evaluateMissingUsage( Set<Id> setOrderProductIdsToEvaluate, Map<String, List<blng__UsageSummary__c>> mapListUsageSummariesByOrderProductIds ){
        for(Id orderProductId : setOrderProductIdsToEvaluate ){
            OrderItem thisOrderItem;

            Boolean thisOrderProductMissingUsage = false;
            for(blng__UsageSummary__c thisUsageSummary : mapListUsageSummariesByOrderProductIds.get( orderProductId )){
                if( thisOrderItem == null && thisUsageSummary.blng__OrderProduct__c != null ){
                    thisOrderItem = new OrderItem(
                        Id = thisUsageSummary.blng__OrderProduct__c,
                        qtc_Missing_Usage__c = thisUsageSummary.blng__OrderProduct__r.qtc_Missing_Usage__c
                    );
                }

                if( thisUsageSummary.qtc_No_Usage__c == true
                    && USAGE_STATUS_EXPECTING_USAGE.equals( thisUsageSummary.qtc_Usage_Status__c)){

                    thisOrderProductMissingUsage = true;
                }

                if(thisOrderItem != null && thisOrderProductMissingUsage == true){
                    break;
                }
            }
            if( thisOrderItem.qtc_Missing_Usage__c != thisOrderProductMissingUsage ){
                thisOrderItem.qtc_Missing_Usage__c = thisOrderProductMissingUsage;
                this.mapOrderItemByIdToUpdate.put(thisOrderItem.Id, thisOrderItem );
            }

        }
    }
    private void aggregateUnbilledSubtotal(  Set<Id> setOrderProductIdsToEvaluate, Map<String, List<blng__UsageSummary__c>> mapListUsageSummariesByOrderProductIds ){
        for( Id orderProductId : setOrderProductIdsToEvaluate){
            OrderItem thisOrderItem;
            Double unbilledUsageTotal = 0;
            for(blng__UsageSummary__c thisUsageSummary : mapListUsageSummariesByOrderProductIds.get( orderProductId )){
                unbilledUsageTotal += thisUsageSummary?.blng__Subtotal__c == null ? 0 : thisUsageSummary.blng__Subtotal__c; 
            }

            if( this.mapOrderItemByIdToUpdate.containsKey( orderProductId )){
                thisOrderItem = this.mapOrderItemByIdToUpdate.get( orderProductId );
            } else {
                thisOrderItem = new OrderItem( Id = orderProductId );
            }
            thisOrderItem.qtc_Unbilled_Usage_Total__c = unbilledUsageTotal;
            this.mapOrderItemByIdToUpdate.put(thisOrderItem.Id, thisOrderItem );
        }
       
    }

    private List<blng__UsageSummary__c> queryUsageSummariesFromOrderProduct(Set<Id> setOrderProductIds){
        List<blng__UsageSummary__c> listUsageSummaries = 
            [   SELECT Id, qtc_No_Usage__c, qtc_Usage_Status__c, blng__OrderProduct__c, blng__OrderProduct__r.qtc_Missing_Usage__c, blng__Subtotal__c
                FROM blng__UsageSummary__c 
                WHERE blng__OrderProduct__c IN :setOrderProductIds];
        return listUsageSummaries;
    }
}