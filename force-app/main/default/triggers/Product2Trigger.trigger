/*##################################################################################################
# Description...........: This trigger is part of our One Trigger Per Object intiative.Please do not 
                           write any business logic inside this trigger.
# Created by......: Nagendra Singh 
# Created Date....: 13 July 2018.
# Modification History.: 
Story No#         Date            DevName                Description
NC_AGILE-1618     30 July 2018     Nagendra Singh         Custom setting to ByPass all triggers 
                     
##################################################################################################*/
trigger Product2Trigger on Product2 (after update,before insert,before update,after insert) {
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('Product2Trigger')){
             System.debug('Run Product2Trigger Triggers ');
              new Product2TriggerDispatcher().run();
        }else{
           System.debug('Skip Product2Trigger Triggers ');  
    }
   
}