/*##################################################################################################
# Description...........: This trigger is part of our One Trigger Per Object intiative.Please do not 
write any business logic inside this trigger.
# Created by......: Nagendra Singh 
# Created Date....: 24 May 2018.
# Modification History.: 
Story No#         Date            DevName                Description
NC_AGILE-1618     30 July 2018     Nagendra Singh         Custom setting to ByPass all triggers   
##################################################################################################*/
trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if(checkRecursive.OpportunityTriggerbypass == false){
        return;
    }
    if(CPQTriggerControl.cpqSpclHdlgNew){
        if(Trigger.isUpdate){
            if(Trigger.isAfter && CheckRecursive.cpq_OppAfterRunOnce){
                CheckRecursive.cpq_OppAfterRunOnce=false;
            }else{
                return;
            }
            if(Trigger.isBefore && CheckRecursive.cpq_OppBfrRunOnce){
                CheckRecursive.cpq_OppBfrRunOnce=false;
            }else{
                return;
            }  
        } 
    }    
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('OpportunityTrigger')){
        System.debug('Run Opportunity Triggers ');
        new OpportunityTriggerDispatcher().run(); 
    }else{
        
    }
    
}