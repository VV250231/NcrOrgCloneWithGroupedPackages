/*##################################################################################################
# Description...........: This trigger is part of our One Trigger Per Object intiative.Please do not 
                           write any business logic inside this trigger.
# Created by......: P Kashyap 
# Created Date....: 
# Modification History.: 
Story No#         Date            DevName                Description
NC_AGILE-1618     30 July 2018     Nagendra Singh         Custom setting to ByPass all triggers 
                     
##################################################################################################*/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update,After Delete) {
    if(OpportunityLineItemTriggerDispatcher.runTrigger || new TriggerControl().RunTrigger('OpportunityLineItemTrigger')){
        System.debug('Run OpportunityLineItemTrigger Triggers');  
        
        OpportunityLineItemTriggerDispatcher.runTrigger = true;
        new OpportunityLineItemTriggerDispatcher().run();
        /*if(!CPQTriggerControl.cpqSpclHdlgNew || (CPQTriggerControl.cpqSpclHdlgNew && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) {
            new OpportunityLineItemTriggerDispatcher().run();
        } */
    } else{
        System.debug('Skip OpportunityLineItemTrigger Triggers ');      
    } 
}