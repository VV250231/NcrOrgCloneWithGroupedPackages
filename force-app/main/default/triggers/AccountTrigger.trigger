/****************************************************************************************************************
*   TriggerName :   AccountTrigger
*   Description :   
*   Author      :   Puneet
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
NC_AGILE-1618     30 July 2018     Nagendra Singh         Custom setting to ByPass all triggers 
****************************************************************************************************************/
trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if(CPQTriggerControl.cpqSpclHdlgNew){
            return;
        }
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('AccountTrigger')){
             System.debug('Run AccountTrigger Triggers ');
              new AccountTriggerDispatcher().run();
        }else{
           System.debug('Skip AccountTrigger Triggers ');  
    }
    
}