/**
 * @author ATG
 * @description Invoice Run Trigger Handler, extends Trigger Handler Base
*/
public with sharing class InvoiceRunTriggerHandler extends TriggerHandlerBase{

    /**
     * @description Method for the After Update Context, When the status has changed to Completed or Completed with Error, Process the Invoice Run records
    */
    public override void afterUpdate(){
        Set<Id> setInvoiceScheduleIds = InvoiceRunService.getInvoiceSchedulersToProcess((List<blng__InvoiceRun__c>)Trigger.new, (Map<Id, blng__InvoiceRun__c>)Trigger.oldMap);
        InvoiceRunService.processInvoiceSchedulers( setInvoiceScheduleIds );
    }
}