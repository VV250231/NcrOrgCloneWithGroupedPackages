/****************************************************************************************************************
*   TriggerName :   CmpgnMembrTrigger
*   Description :   
*   Author      :  	Yogesh Singh
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName           		Description
EBA_SF-1446    29th Sep 2021    Varsha Pal         Consolidation of Campaign Member trigger
****************************************************************************************************************/
trigger CmpgnMembrTrigger on CampaignMember(before insert,after insert){
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('CampaignTrigger')){
        System.debug('Run CampaignTrigger Triggers ');
        if(Trigger.IsBefore && Trigger.IsInsert){
            campaign_member_trigger_helper.sub_dispatcher(Trigger.new);
        }
        if(Trigger.isAfter && trigger.isInsert){
            if(CampaignTriggerHandler.isFirst==true){
               	CampaignTriggerHandler.insertMethod(Trigger.New);
                CampaignTriggerHandler.isFirst =false;
            }
        }
    }else{
        System.debug('Skip CampaignTrigger Triggers');  
    }
    
}