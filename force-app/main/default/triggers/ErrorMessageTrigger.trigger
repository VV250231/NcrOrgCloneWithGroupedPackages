trigger ErrorMessageTrigger on Error_Message__e (after insert) {
    
    List<Error_Log__c> errs = new List<Error_Log__c>();
       
    for (Error_Message__e event : trigger.new) {
		Error_Log__c err = new Error_Log__c();
        err.Source__c = event.Source__c;
        err.message__c = event.Message__c;
		err.Error_Type__c = event.Error_Type__c;
		err.Line_Number__c = event.Line_Number__c;
		err.Stack_Trace__c = event.Stack_Trace__c;
		err.Cause__c = event.Cause__c;
        errs.add(err);
    }
    
    insert errs;
}