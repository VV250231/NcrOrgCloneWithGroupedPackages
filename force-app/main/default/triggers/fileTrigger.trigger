/*************************************************************************************************
    * Author        :   Sushant  
    * Date          :   15-06-2020
    * Param         :   
    * Return        :   
    * Description   :   This Trigger will added a new Case Comment on Dispute Record when a file
                        attachment is added/deleted(remove from record button needs to be used) to Dispute.
# Modification History.: 
Story No#         Date            DevName           		Description
EBA_SF-1446    29th Sep 2021    Varsha Pal         Consolidation of ContentDocumentLink trigger                  
***************************************************************************************************/

trigger fileTrigger on ContentDocumentLink (after insert,before delete, after delete) {
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('fileTrigger')){
        if(Trigger.isBefore){
            if(Trigger.isDelete){
                fileTriggerHandler.insrtCaseCmnt(Trigger.old,'delete');
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                fileTriggerHandler.insrtCaseCmnt(Trigger.new,'insert');
                 fileTriggerHandler.updateDealsDeskCase(Trigger.new);
            }
            if(Trigger.isDelete){
                fileTriggerHandler.delImgOnFileDelete(Trigger.old);
            }
        }   
    }else{
        System.debug('Skip fileTrigger Triggers');
    }
    
}