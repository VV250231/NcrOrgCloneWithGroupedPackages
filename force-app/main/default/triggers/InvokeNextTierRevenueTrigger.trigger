/**************************************************************************************************************************************************************
Trigger was created for the ChannelProgramMember Object

#############################################################################################################################################################
Created By                           Date                              Description
Naman Kumar(nk250337)                6th September 2019                Version 1.0 , which invokes PopulateNextTierRevenue Trigger

****************************************************************************************************************************************************************/
trigger InvokeNextTierRevenueTrigger on ChannelProgramMember (after insert, after update, after delete) {
    if (PRM_TriggersController.getTriggersStatus('InvokeNextTierRevenueTrigger')) {
        if(Trigger.isInsert || Trigger.isUpdate){
            if(Trigger.isAfter){
                Set<Id> accId = new Set<Id>();
                for(ChannelProgramMember obj :Trigger.New){
                    if(obj.ProgramId != NULL && obj.LevelId != NULL && obj.PartnerId != NULL){
                        accId.add(obj.PartnerId);
                    }
                }
                if(!accId.isEmpty())
                    updateAccounts(accId);
            }
        }
        if(Trigger.isDelete && Trigger.isAfter){
            Set<Id> accId = new Set<Id>();
            for(ChannelProgramMember obj :Trigger.Old){
                if(obj.PartnerId != NULL){
                    accId.add(obj.PartnerId);
                }
            }
            if(!accId.isEmpty())
                updateAccounts(accId);
        }
        
    }
    public void updateAccounts(Set<Id> accId){
        List<Account> accList = new List<Account>();
        for(Account accObj :[SELECT Id FROM Account WHERE Id IN :accId]){
            accList.add(accObj);
        }
        if(!accList.isEmpty())
            update accList;
    }
}