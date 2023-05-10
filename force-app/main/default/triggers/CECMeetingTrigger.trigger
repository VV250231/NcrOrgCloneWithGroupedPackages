/*##################################################################################################
# Description...........: This trigger is for CEC functionality.
# Created by......: Sushant, Saurav, Yogesh, Monika 
# Created Date....: Nov 2021.  
# Story Number ......: EBA_SF-1607 , EBA_SF-1606 , EBA_SF-1605 , EBA_SF-1554
##################################################################################################*/
trigger CECMeetingTrigger on CEC__c (before update) {
    if(trigger.isUpdate){
        if(CECMeetingTriggerHandler.isFlag){
            CECMeetingTriggerHandler.isFlag=false;
            CECMeetingTriggerHandler.updateStatus(Trigger.New);
        }
        
    }

}