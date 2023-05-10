trigger OpportunityUpdateTempTrigger on Opportunity (before update){
    if(FeatureManagement.checkPermission('ETL_PreventOverwrite')){
        OpportunityTriggerHandler.updateCATMProductRollup(trigger.newMap, false);
    }
}