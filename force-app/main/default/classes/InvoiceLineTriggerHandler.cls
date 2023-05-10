public with sharing class InvoiceLineTriggerHandler extends ErrorLogUtil{
    private List<blng__InvoiceLine__c> listInvoiceLines;
    private Map<Id, blng__InvoiceLine__c> mapOldInvoiceLines;
    private Map<Id, blng__InvoiceLine__c> mapInvoiceLineDetails;

    public InvoiceLineTriggerHandler(List<blng__InvoiceLine__c> triggerNew, Map<Id, blng__InvoiceLine__c> triggerOldMap) {
        this.listInvoiceLines = triggerNew;
        this.mapOldInvoiceLines = triggerOldMap;
    }

    public void handleAfterInsert(){
        this.mapInvoiceLineDetails = queryInvoiceLines();
        setInvoiceOrder(listInvoiceLines);
    }

    public void handleAfterUpdate(){
        this.mapInvoiceLineDetails = queryInvoiceLines();
        List<blng__InvoiceLine__c> listInvoiceLinesToProcess = new List<blng__InvoiceLine__c>();
        for( blng__InvoiceLine__c thisInvoiceLine : listInvoiceLines){
            blng__InvoiceLine__c oldInvoiceLine = mapOldInvoiceLines.get( thisInvoiceLine.Id );
            if( thisInvoiceLine.blng__OrderProduct__c != null 
                && oldInvoiceLine.blng__OrderProduct__c == null){
                
                listInvoiceLinesToProcess.add( thisInvoiceLine );
            }
        }
        setInvoiceOrder(listInvoiceLines);
    }

    private void setInvoiceOrder(List<blng__InvoiceLine__c> listInvoiceLinesToProcess){
        Map<Id, blng__Invoice__c> mapInvoiceToUpdate = new Map<Id, blng__Invoice__c>();

        //First loop is to populate the Order field with orders Order's of Type New
        for(blng__InvoiceLine__c thisInvoiceLine : listInvoiceLinesToProcess){
            blng__InvoiceLine__c thisInvoiceLineDetails = mapInvoiceLineDetails.get( thisInvoiceLine.Id );
            Id invoiceId = thisInvoiceLine.blng__Invoice__c;

            if( thisInvoiceLineDetails.blng__Invoice__r?.blng__Order__c == null
                && thisInvoiceLineDetails.blng__OrderProduct__r?.Order?.Type == 'New'
                && !mapInvoiceToUpdate.containsKey( invoiceId ) ) {

                blng__Invoice__c invoiceToUpdate = new blng__Invoice__c(
                    Id = invoiceId,
                    blng__Order__c = thisInvoiceLineDetails.blng__OrderProduct__r.OrderId
                );
                mapInvoiceToUpdate.put(invoiceId, invoiceToUpdate );
            }
        }
        
        //Second Loop is to populate the Order field with any order Id
        for(blng__InvoiceLine__c thisInvoiceLine : listInvoiceLinesToProcess){
            blng__InvoiceLine__c thisInvoiceLineDetails = mapInvoiceLineDetails.get( thisInvoiceLine.Id );
            Id invoiceId = thisInvoiceLine.blng__Invoice__c;

            if( thisInvoiceLineDetails.blng__Invoice__r?.blng__Order__c == null
                && thisInvoiceLineDetails.blng__OrderProduct__r?.OrderId != null
                && !mapInvoiceToUpdate.containsKey( invoiceId ) ) {

                blng__Invoice__c invoiceToUpdate = new blng__Invoice__c(
                    Id = invoiceId,
                    blng__Order__c = thisInvoiceLineDetails.blng__OrderProduct__r.OrderId
                );
                mapInvoiceToUpdate.put(invoiceId, invoiceToUpdate );
            }
        }

        if( !mapInvoiceToUpdate.isEmpty() ){
            try{
                update mapInvoiceToUpdate.values();
            } catch( DmlException ex ){
                log('InvoiceLineTriggerHandler', ex);
                commitLogs();
            }
        }
    }

    private Map<Id, blng__InvoiceLine__c> queryInvoiceLines(){
        return new Map<Id, blng__InvoiceLine__c>([  SELECT blng__Invoice__c, blng__Invoice__r.blng__Order__c, blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.Type  
                                                    FROM blng__InvoiceLine__c 
                                                    WHERE Id IN :listInvoiceLines]);
    }
}