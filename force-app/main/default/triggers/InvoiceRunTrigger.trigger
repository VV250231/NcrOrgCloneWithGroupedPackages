/****************************************************************************************************************
*   TriggerName :   InvoiceRunTrigger
*   Description :   Invoice Run Trigger
*   Author      :   Todd
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
****************************************************************************************************************/
trigger InvoiceRunTrigger on blng__InvoiceRun__c (after update) {
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('InvoiceRunTrigger')){
        System.debug('Run InvoiceRunTrigger Triggers ');
        new InvoiceRunTriggerHandler().run();
    }else{
        System.debug('Skip InvoiceRunTrigger Triggers ');  
    }

}