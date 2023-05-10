trigger APOC_MassUpdateAllRoles on ASM_Role_Hierarchy__c (before insert,before update,after insert,after update,before delete) {
    if(Trigger.isBefore){
        if(APOC_MassUpdateAllRolesHandler.runonce){
            if(Trigger.isInsert || Trigger.isUpdate){
                APOC_MassUpdateAllRolesHandler.assignReference(Trigger.new,Trigger.oldMap);
            }
            if(Trigger.isDelete){
                if(System.Label.APOCStopTrigger =='false'){
                    APOC_MassUpdateAllRolesHandler.createReassignforDelete(Trigger.old);
                }
            }
        }
    }
    else{
        if(System.Label.APOCStopTrigger =='false'){
            APOC_MassUpdateAllRolesHandler.validatePO(Trigger.new);
        }
        if(APOC_MassUpdateAllRolesHandler.runonce){
            if(System.Label.APOCStopTrigger =='false'){
                APOC_MassUpdateAllRolesHandler.handleDelete(Trigger.new);
                if(Trigger.isInsert){
                    APOC_MassUpdateAllRolesHandler.createReassignforInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    APOC_MassUpdateAllRolesHandler.sendNotificationToUser(Trigger.new,Trigger.oldMap);
                }
            }
        }
    }
}