/**************************************************************************************************************************************************************
Trigger was created for the ChannelProgramLevel Object

#############################################################################################################################################################
Created By                           Date                              Description
Naman Kumar(nk250337)                26th September 2019                Version 1.0 , which invokes PopulateNextTierRevenue Trigger

This trigger make a update call on channel program member, which further make update to accounts which inovkes PopulateNextTierRevenue to
recalculate nextLevel and nextToNextLevel Revenue.
****************************************************************************************************************************************************************/
trigger InvokeNextTierRevenueByCPL on ChannelProgramLevel (after update, before delete) {
    if (PRM_TriggersController.getTriggersStatus('InvokeNextTierRevenueByCPL')) {
        if(Trigger.isUpdate){
            if(Trigger.isAfter){
                List<ChannelProgramMember> CPMemberList = new List<ChannelProgramMember>();
                for(ChannelProgramMember obj :[SELECT Id, ProgramId, LevelId, PartnerId FROM ChannelProgramMember WHERE LevelId IN :Trigger.New]){
                    if(obj.ProgramId != null && obj.LevelId != null && obj.PartnerId != null){
                        CPMemberList.add(obj);
                    }
                }
                if(!CPMemberList.isEmpty())
                    update CPMemberList;
            }
        }
        
        if(Trigger.isDelete && Trigger.isBefore){
            Set<Id> levelId = new Set<Id>();
            for(ChannelProgramMember memberObj :[SELECT Id, ProgramId, LevelId, PartnerId FROM ChannelProgramMember WHERE LevelId IN :Trigger.Old]){
                levelId.add(memberObj.LevelId);
            }
            for(ChannelProgramLevel obj :Trigger.Old){
                if(levelId.contains(obj.Id)){
                    obj.addError(system.label.InvkNxtTierRev);
                }
                //Error msg for custom label InvkNxtTierRev
                //Can't delete this record is related to ChannelProgramMember
            }
           
        }
    }
}