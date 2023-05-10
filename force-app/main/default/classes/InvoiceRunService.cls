/**
 * @author ATG
 * @description Service class for the Invoice Run Trigger Handler. The Purpose of this trigger/service is to chain the Invoice Run Batches,
 *              so that the next invoice batch on the Picklist will run when the previous batch run has completed. This will attempt to update
 *              the Invoice Scheduler start time and Invoice Batches field do the Billing processes will schedule a new Invoice Batch Run.
*/
public with sharing class InvoiceRunService extends ErrorLogUtil{
    final static string STATUS_COMPLETED = 'Completed',
                        STATUS_COMPLETED_ERROR = 'Completed with errors	';
    final static List<String> listCompletedStatuses = new List<String>{ STATUS_COMPLETED, STATUS_COMPLETED_ERROR };

    /**
     * @description Getter properyty to return active picklist entries
    */
    static List<String> listInvoiceBatches{ 
        get{
            if( listInvoiceBatches == null){
                List<Schema.PicklistEntry> listPicklistEntry = Schema.blng__InvoiceScheduler__c.blng__InvoiceBatches__c.getDescribe().getPicklistValues();
                listInvoiceBatches = new List<String>();
                for(Schema.PicklistEntry thisPicklistEntry : listPicklistEntry){
                    if( thisPicklistEntry.isActive() ){
                        listInvoiceBatches.add( thisPicklistEntry.getValue() );
                    }
                }
            } 
            return listInvoiceBatches;
        } set;
    }

    /**
     * @description Query method to return the Related Invoice Schedulers
     * @param   setInvoiceScheduleIds   Set of Invoice Scheduler Ids
     * @return  List of Invoice Scheduler records
    */
    private static List<blng__InvoiceScheduler__c> getInvoiceSchedules( Set<Id> setInvoiceScheduleIds ){
        return [SELECT Id, blng__InvoiceBatches__c, qtc_Single_Invoice_Run__c FROM blng__InvoiceScheduler__c WHERE Id IN :setInvoiceScheduleIds];
    }

    /**
     * @description Returns the Next picklist entry value
     * @param   currentInvoiceBatch   Current Picklist entry 
     * @return  String of the next value in the Picklist
    */
    public static string getNextInvoiceBatch( String currentInvoiceBatch ){
        //is a multi select list
        Integer invoiceBatchIndex = listInvoiceBatches.indexOf( currentInvoiceBatch );
        invoiceBatchIndex += 1;
        if( invoiceBatchIndex > 0 && invoiceBatchIndex < listInvoiceBatches.size()){
            return listInvoiceBatches[ invoiceBatchIndex ];
        }
        else {
            return null;
        }
    }

    /**
     * @description Returns Invoice Scheduler Ids When the Invoice Run status has changed to Completed or Completed with Error
     * @param   listTriggerNew  Trigger.New
     * @param   mapTriggerOld   trigger.OldMap
     * @return  Set of Invoice Scheduler Ids 
    */
    public static Set<Id> getInvoiceSchedulersToProcess(List<blng__InvoiceRun__c> listTriggerNew, Map<Id, blng__InvoiceRun__c> mapTriggerOld){
        Set<Id> setInvoiceSchedulerIds = new Set<Id>();
        for(blng__InvoiceRun__c thisInvoiceRun : listTriggerNew){
            blng__InvoiceRun__c oldInvoiceRun = mapTriggerOld.get( thisInvoiceRun.Id );
            
            if( listCompletedStatuses.contains(thisInvoiceRun.blng__Status__c) && thisInvoiceRun.blng__Status__c != oldInvoiceRun.blng__Status__c){
                setInvoiceSchedulerIds.add( thisInvoiceRun.blng__InvoiceScheduler__c );
            }
        }
        return setInvoiceSchedulerIds;
    }

    /**
     * @description Updates the Invoice Scheduler record's start time and batch
     * @param   setInvoiceSchedulerIds  Set of Invoice Scheduler Ids to process
    */
    public static void processInvoiceSchedulers(Set<Id> setInvoiceSchedulerIds){
        List<blng__InvoiceScheduler__c> listInvoiceSchedulers = getInvoiceSchedules( setInvoiceSchedulerIds );
        List<blng__InvoiceScheduler__c> listInvoiceSchedulersToUpdate = new List<blng__InvoiceScheduler__c>();
        for( blng__InvoiceScheduler__c thisInvoiceScheduler : listInvoiceSchedulers ){
            String nextInvoiceBatch = getNextInvoiceBatch( thisInvoiceScheduler.blng__InvoiceBatches__c );
            if( String.isNotBlank(nextInvoiceBatch) && !thisInvoiceScheduler.qtc_Single_Invoice_Run__c){
                Datetime newStartDatetime = Datetime.now().addMinutes( 1 );
            
                thisInvoiceScheduler.blng__InvoiceBatches__c = nextInvoiceBatch;
                thisInvoiceScheduler.blng__StartDateTime__c  = newStartDatetime;

                listInvoiceSchedulersToUpdate.add( thisInvoiceScheduler );
            }
        }

        if( !listInvoiceSchedulersToUpdate.isEmpty() ){
            try{
                update listInvoiceSchedulersToUpdate;
            }catch(DmlException ex){
                log('InvoiceRunService', ex);
                commitLogs();
            }
        }

    }

}