/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_DetailTrigger.trigger                                                        
# Version...............: 32.0 
# Created by............: Santosh Jha                                                                 
# Created Date..........: 25-10-2020                                                                            
# Last Modified by......: Santosh Jha 
# Last Modified Date....: 25-10-2020
# Description...........: unify multiple trigger into one trigger

##################################################################################################*/
trigger QuBy_DetailTrigger on QuBy_Detail__c ( before insert , before update , after insert , after update , after delete , after undelete ) {
    
    QuBY_DetailTriggerHandler.QubyDetailHelper(Trigger.new,Trigger.old,Trigger.oldmap);
    
    if((Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isAfter)) 
    {
        
        QuBY_DetailTriggerHandler.updateQuoteNumOnPartnerOpp(trigger.New);
        
        QuBY_DetailTriggerHandler.QuBy_DeleteQuote(Trigger.new);
        
        
    }
}