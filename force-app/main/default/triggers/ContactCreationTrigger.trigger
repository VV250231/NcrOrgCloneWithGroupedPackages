trigger ContactCreationTrigger on LiveChatTranscript (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContactCreationHelper.createContact(Trigger.New);
        }
    }
}