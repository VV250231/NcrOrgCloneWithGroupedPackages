trigger EmailCreatedTimeTrigger on EmailMessage (after insert) {
	  if(Trigger.isAfter){
        if(Trigger.isInsert){
            CaseToFeedItemHelper.caseIdToFeedItemMethod1(Trigger.New);
        }
    }
    
}