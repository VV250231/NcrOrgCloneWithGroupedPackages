/****************************************************************************************************************
*   TriggerName :   ContactTrigger
*   Description :   
*   Author      :   Mudit Saxena
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
NC_AGILE-1618     30 July 2018     Nagendra Singh         Custom setting to ByPass all triggers 
****************************************************************************************************************/
trigger ContactTrigger on Contact (before insert,before update, after update, after insert ) {
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('ContactTrigger')){
             System.debug('Run ContactTrigger Triggers ');
              new ContactTriggerDispatcher().run();
        }else{
           System.debug('Skip ContactTrigger Triggers ');  
    }
    
}