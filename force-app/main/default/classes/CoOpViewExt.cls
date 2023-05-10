public class CoOpViewExt {
    public Co_Op__c coOpCurrentRec {get;set;}
    public Boolean isRecordLocked {get;set;}
    
    public coOpViewExt(ApexPages.StandardController sc) {
        coOpCurrentRec = (Co_Op__c) sc.getRecord();
        isRecordLocked = Approval.isLocked(coOpCurrentRec.Id);
        
    }
    
    public PageReference submitRequest() {
        
        if ( coOpCurrentRec.Number_of_pages_to_follow__c == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please attach Invoices OR Proof of Payment(POP) document with request.'));
            return null;
        } else {
            // Check user has attached both type of document invoice and POP document.
            Boolean isPopDocAtt = false;
            Boolean isInvoiceDocAtt = false;
            for (Co_Op_Supporting_Document__c supportingDoc : [SELECT Id, Type__c FROM Co_Op_Supporting_Document__c WHERE Co_Op_Request__c=: coOpCurrentRec.Id]) {
                if (supportingDoc.Type__c == 'Invoices') {
                    isInvoiceDocAtt = true;
                }
                
                if (supportingDoc.Type__c == 'Proof of payment') {
                    isPopDocAtt = true;
                }
            }
            
            if (isPopDocAtt != true && isInvoiceDocAtt != true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please attach Invoices OR Proof of Payment(POP) document with request.'));
                return null;
            }
        }
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(coOpCurrentRec.Id);
        // Submitting the request to specific process
        Approval.ProcessResult result = Approval.process(req);
        
        PageReference pr = ApexPages.currentPage();
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference redirectToEdit() {
        PageReference pr = Page.ipt_co_op_new;
        pr.getParameters().put('id',coOpCurrentRec.Id);
        return pr;
    }
    
    public PageReference cancel() {
        return new PageReference('/a3z/o');
    }
}