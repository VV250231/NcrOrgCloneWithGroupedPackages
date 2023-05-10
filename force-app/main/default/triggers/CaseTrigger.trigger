/****************************************************************************************************************
*   TriggerName :   CaseTrigger
*   Description :   To move all 6 triggers into 1 trigger (Best practices implemented due to story EBA_SF-680)
*   Author      :   Varsha Pal
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description

****************************************************************************************************************/
trigger CaseTrigger on Case (before insert,after insert, before update,after update) {    
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('CaseTrigger')){
             System.debug('Run CaseTrigger');
              new CaseTriggerDispatcher().run();
        }else{
           System.debug('Skip CaseTrigger');  
    } 
}