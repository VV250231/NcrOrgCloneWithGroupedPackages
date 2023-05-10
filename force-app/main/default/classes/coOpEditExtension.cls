public class coOpEditExtension {
    public String coOpId {get;set;} // co op Id is a co op document id here.
    public Attachment att {get;set;}
    public Co_Op_Supporting_Document__c supportingDoc {get;set;}
    public Map<String,String> params {get;set;}
    String retUrl;
    Attachment existingAtt;
        
    public coOpEditExtension (ApexPages.StandardController sc) {
        String coOpId = ApexPages.currentPage().getParameters().get('id');
        List<Co_Op_Supporting_Document__c> supportingDocs;
        
        if (! String.isBlank(coOpId)) {
            supportingDocs = [SELECT Id, Name, Attachment_Id__c, Cost__c, Date__c,Type__c, Description__c FROM Co_Op_Supporting_Document__c 
                             WHERE Id =: coOpId LIMIT 1
                            ];
            if (supportingDocs.size() > 0) {
                supportingDoc = supportingDocs[0];
            }
            
            if (! String.isBlank(supportingDoc.Attachment_Id__c)) {
                List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment WHERE Id =: supportingDoc.Attachment_Id__c LIMIT 1];
                if (attachments.size() > 0) {
                    existingAtt = attachments[0];
                }
            }
        } else {
            supportingDoc = new Co_Op_Supporting_Document__c();
        }
        
        
        att = new Attachment();
    }
    
    public PageReference saveSupportingDoc() {
        Savepoint sp = Database.setSavepoint();
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pageRef = new PageReference(retUrl);
        try {
            // Insert attachment
            if (att.Name != null)
                existingAtt.Name = att.Name;
            if (att.Body != null)
                existingAtt.Body = att.Body;
            if (att.Name != null || att.Body != null)
                update existingAtt;
            // Insert Supporting Doc record
            if (att.Name != null)
            supportingDoc.Name = att.Name;
            update supportingDoc;
            
        } catch (Exception ex) {
            Database.rollback(sp);
        }
        return pageRef;
    }

}