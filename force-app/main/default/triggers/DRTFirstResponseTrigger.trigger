trigger DRTFirstResponseTrigger on Task (after insert) {
    //Added Trigger control logic as part of CATM EBA_SF-2056
    TriggerControl TC = new TriggerControl();
    if(TC.RunTrigger('DRTFirstResponseTrigger'))
    {
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                System.debug('@@@@@@CCC');
                DRTFirstResonseCallHelper.caseIdToFeedItemMethod(Trigger.New);
                
            }
        }
    }
    else
    {
        System.debug('Skipped DRTFirstResponseTrigger ');
    }
}