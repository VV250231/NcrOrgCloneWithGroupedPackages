trigger DupChecker on Message_Center__c (before Insert,before Update) {
    if (PRM_TriggersController.getTriggersStatus('DupChecker')) {
        if(trigger.isBefore){
            if(Trigger.isInsert)
                MCenterDupCheckerHelper.DupChecker(Trigger.New,NULL);
            if(trigger.isUpdate)
                MCenterDupCheckerHelper.DupChecker(Trigger.New,Trigger.Old);
        }
    }
}