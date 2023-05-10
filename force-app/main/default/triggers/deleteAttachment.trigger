trigger deleteAttachment on Co_Op_Supporting_Document__c (before delete) {
    
    Set<String> attachmentIds = new Set<String>();
    
    for (Co_Op_Supporting_Document__c doc : Trigger.old) {
        if (doc.Attachment_Id__c != null) {
            attachmentIds.add(doc.Attachment_Id__c);
        }
    }
    
    if (attachmentIds.size() > 0) {
        delete [SELECT Id FROM Attachment WHERE Id IN : attachmentIds];
    }
}